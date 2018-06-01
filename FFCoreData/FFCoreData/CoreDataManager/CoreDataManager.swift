//
//  CoreDataManager.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 10/06/15.
//  Copyright 2015 Florian Friedrich
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import CoreData
import FFFoundation

fileprivate final class CoreDataManager {
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = configuration.bundle.url(forResource: configuration.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = configuration.databaseURL
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            func message(for error: Error) -> String { return "FFCoreData: Failed to add persistent store with error: \(error)" }
            guard configuration.clearDataStoreOnSetupFailure else { fatalError(message(for: error)) }
            
            print("\(message(for: error))\nTrying to clear the data store now!")
            do {
                try clearDataStore()
            } catch {
                print("FFCoreData: Failed to delete data store with error: \(error)")
            }
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                fatalError(message(for: error))
            }
        }
        return coordinator
    }()
    
    private lazy var backgroundSavingContext: NSManagedObjectContext = {
        let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        ctx.persistentStoreCoordinator = persistentStoreCoordinator
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }()
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let ctx = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        ctx.parent = backgroundSavingContext
        return ctx
    }()
    
    let configuration: CoreDataStack.Configuration
    init(configuration: CoreDataStack.Configuration) {
        self.configuration = configuration
    }
    
    func createTemporaryMainContext() -> NSManagedObjectContext {
        return createTemporaryContext(with: .mainQueueConcurrencyType)
    }
    
    func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        return createTemporaryContext(with: .privateQueueConcurrencyType)
    }
    
    private func createTemporaryContext(with type: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        let tempCtx = NSManagedObjectContext(concurrencyType: type)
        tempCtx.parent = managedObjectContext
        tempCtx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        tempCtx.undoManager = nil
        return tempCtx
    }
    
    func clearDataStore() throws {
        let fileManager = FileManager.default
        try fileManager.contentsOfDirectory(at: configuration.storePath, includingPropertiesForKeys: nil, options: [])
            .filter { $0.lastPathComponent.hasPrefix(configuration.sqliteName) }
            .forEach(fileManager.removeItem)
    }
    
    func save(context ctx: NSManagedObjectContext, rollback: Bool, completion: @escaping (Bool) -> Void) {
        guard ctx.hasChanges else {
            return completion(true)
        }
        var result = true
        do {
            try ctx.save()
            #if DEBUG
                switch ctx {
                case managedObjectContext:
                    print("FFCoreData: Main NSManagedObjectContext saved successfully!")
                case backgroundSavingContext:
                    print("FFCoreData: Background NSManagedObjectContext saved successfully!")
                default:
                    print("FFCoreData: NSManagedObjectContext \(ctx) saved successfully!")
                }
            #endif
        } catch {
            print("Unresolved error while saving NSManagedObjectContext \(error)")
            result = false
            if rollback { ctx.rollback() }
        }
        
        if let parentContext = ctx.parent, result != false {
            parentContext.perform {
                self.save(context: parentContext, rollback: rollback, completion: { success in
                    if !success && rollback {
                        ctx.rollback()
                    }
                    completion(success)
                })
            }
        } else {
            completion(result)
        }
    }
}

public struct CoreDataStack {
    public static var configuration = Configuration.legacyConfiguration {
        didSet {
            NSManagedObject.shouldRemoveNamespaceInEntityName = configuration.removeNamespacesFromEntityNames
            _manager.reset()
        }
    }
    private static var _manager = Lazy { CoreDataManager(configuration: CoreDataStack.configuration) }
    private static var manager: CoreDataManager { return _manager.value }
    
    public static var mainContext: NSManagedObjectContext { return manager.managedObjectContext }
    
    public static func save(context: NSManagedObjectContext, rollback: Bool = true, completion: @escaping (Bool) -> () = { _ in }) {
        context.sync { manager.save(context: context, rollback: rollback, completion: completion) }
    }

    public static func saveMainContext(rollback: Bool = true, completion: @escaping (Bool) -> () = { _ in }) {
        save(context: mainContext, rollback: rollback, completion: completion)
    }
    
    public static func createTemporaryMainContext() -> NSManagedObjectContext {
        return manager.createTemporaryMainContext()
    }
    
    public static func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        return manager.createTemporaryBackgroundContext()
    }

    public static func clearDataStore() throws {
        try manager.clearDataStore()
    }
}

extension CoreDataStack {
    public struct Configuration {
        private static let infoDictionarySQLiteNameKey = "FFCDDataManagerSQLiteName"
        private static let infoDictionaryModelNameKey = "FFCDDataManagerModelName"
        
        fileprivate static let legacyConfiguration: Configuration = {
            let bundle = Bundle.main
            let modelName = bundle.infoDictionary?[Configuration.infoDictionaryModelNameKey] as? String
            let sqliteName = bundle.infoDictionary?[Configuration.infoDictionarySQLiteNameKey] as? String
            return Configuration(bundle: bundle, modelName: modelName, sqliteName: sqliteName)
        }()

        public struct Options: OptionSet {
            public typealias RawValue = UInt
            public let rawValue: RawValue
            public init(rawValue: RawValue) { self.rawValue = rawValue }
        }
        
        public let bundle: Bundle
        public let modelName: String
        public let sqliteName: String
        public let storePath: URL

        private var sqliteStoreName: String { return sqliteName + ".sqlite" }
        public var databaseURL: URL { return storePath.appendingPathComponent(sqliteStoreName) }

        #if os(macOS)
        public let applicationSupportSubfolderName: String
        #endif

        public let options: Options
        public var removeNamespacesFromEntityNames: Bool { return options.contains(.removeNamespacesFromEntityNames) }
        public var clearDataStoreOnSetupFailure: Bool { return options.contains(.clearDataStoreOnSetupFailure) }

        private static func url(for searchPathDirectory: FileManager.SearchPathDirectory, subDirectoryName: String? = nil) -> URL {
            let fileManager = FileManager.default
            var dataDirectory = fileManager.urls(for: searchPathDirectory, in: .userDomainMask)[0]
            if let subfolderName = subDirectoryName {
                dataDirectory.appendPathComponent(subfolderName)
            }
            do {
                try fileManager.createDirectoryIfNeeded(at: dataDirectory)
            } catch {
                print("FFCoreData: Could not create data folder: \(error)")
            }
            return dataDirectory
        }
        #if os(iOS) || os(watchOS) || os(tvOS)
        public static let appDataDirectoryURL: URL = url(for: .documentDirectory)
        #elseif os(macOS)
        public static func appDataDirectoryURL(withSubfolderName subfolderName: String) -> URL {
            return url(for: .applicationSupportDirectory, subDirectoryName: subfolderName)
        }
        #endif
        
        private static let infoDictionaryTargetDisplayNameKey = "CFBundleDisplayName"
        private static let infoDictionaryTargetNameKey = String(kCFBundleNameKey)
        private static let defaultTargetName = "UNKNOWN_TARGET_NAME"
        
        private init(bundle: Bundle,
                     modelName: String?,
                     sqliteName: String?,
                     storePath: URL?,
                     appSupportFolderName: String?,
                     options: Options) {
            func targetName(from bundle: Bundle) -> String {
                guard let infoDict = bundle.infoDictionary else { return Configuration.defaultTargetName }
                let name = infoDict[Configuration.infoDictionaryTargetDisplayNameKey] ?? infoDict[Configuration.infoDictionaryTargetNameKey]
                return (name as? String) ?? Configuration.defaultTargetName
            }
            
            self.bundle = bundle
            self.modelName = modelName ?? targetName(from: bundle)
            self.sqliteName = sqliteName ?? targetName(from: bundle)
            self.options = options

            #if os(iOS) || os(watchOS) || os(tvOS)
                self.storePath = storePath ?? CoreDataStack.Configuration.appDataDirectoryURL
            #elseif os(macOS)
                let subfolderName = appSupportFolderName ?? bundle.bundleIdentifier ?? targetName(from: bundle)
                self.applicationSupportSubfolderName = subfolderName
                self.storePath = storePath ?? CoreDataStack.Configuration.appDataDirectoryURL(withSubfolderName: subfolderName)
            #endif
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        public init(bundle: Bundle,
                    storePath: URL? = nil,
                    modelName: String? = nil,
                    sqliteName: String? = nil,
                    options: Options = .`default`) {
            self.init(bundle: bundle,
                      modelName: modelName,
                      sqliteName: sqliteName,
                      storePath: storePath,
                      appSupportFolderName: nil,
                      options: options)
        }
        #elseif os(macOS)
        public init(bundle: Bundle,
                    applicationSupportSubfolder: String? = nil,
                    storePath: URL? = nil,
                    modelName: String? = nil,
                    sqliteName: String? = nil,
                    options: Options = .`default`) {
            self.init(bundle: bundle,
                      modelName: modelName,
                      sqliteName: sqliteName,
                      storePath: storePath,
                      appSupportFolderName: applicationSupportSubfolder,
                      options: options)
        }
        #endif
    }
}

public extension CoreDataStack.Configuration.Options {
    public static var `default`: CoreDataStack.Configuration.Options { return .removeNamespacesFromEntityNames }

    public static let removeNamespacesFromEntityNames: CoreDataStack.Configuration.Options = .init(rawValue: 1 << 0)
    public static let clearDataStoreOnSetupFailure: CoreDataStack.Configuration.Options = .init(rawValue: 1 << 1)
}

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
#if canImport(os)
import os
#endif

fileprivate final class CoreDataManager {
    private lazy var managedObjectModel = NSManagedObjectModel(contentsOf: configuration.modelURL)!

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = configuration.databaseURL
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true,
            ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            guard configuration.clearDataStoreOnSetupFailure else {
                os_log("Failed to add persistent store with error: %@", log: .ffCoreData, type: .fault, String(describing: error))
                fatalError("FFCoreData: Failed to add persistent store with error: \(error)")
            }
            os_log("Failed to add persistent store with error: %@\nTrying to delete the data store now!", log: .ffCoreData, type: .error, String(describing: error))
            do {
                try clearDataStore()
            } catch {
                os_log("Failed to delete data store with error: %@!", log: .ffCoreData, type: .error, String(describing: error))
            }
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                os_log("Failed to add persistent store with error: %@", log: .ffCoreData, type: .fault, String(describing: error))
                fatalError("FFCoreData: Failed to add persistent store with error: \(error)")
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
        createTemporaryContext(with: .mainQueueConcurrencyType)
    }

    func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        createTemporaryContext(with: .privateQueueConcurrencyType)
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
            .lazy
            .filter { [configuration] in $0.lastPathComponent.hasPrefix(configuration.sqliteName) }
            .forEach(fileManager.removeItem)
    }

    private func _saveContext(_ context: NSManagedObjectContext, rollback: Bool) -> Bool {
        guard context.hasChanges else { return true }
        do {
            try context.save()
            switch context {
            case managedObjectContext:
                os_log("Main NSManagedObjectContext saved successfully!", log: .ffCoreData, type: .debug)
            case backgroundSavingContext:
                os_log("Background NSManagedObjectContext saved successfully!", log: .ffCoreData, type: .debug)
            default:
                os_log("NSManagedObjectContext %@ saved successfully!", log: .ffCoreData, type: .debug, context)
            }
            return true
        } catch {
            os_log("Unresolved error while saving NSManagedObjectContext!%@", log: .ffCoreData, type: .error, rollback ? " Rolling back..." : "")
            if rollback {
                context.rollback()
            }
            return false
        }
    }

    func saveContext(_ context: NSManagedObjectContext, rollback: Bool, completion: @escaping (Bool) -> Void) {
        context.perform {
            guard self._saveContext(context, rollback: rollback) else { return completion(false) }
            guard let parent = context.parent else { return completion(true) }
            self.saveContext(parent, rollback: rollback, completion: {
                if !$0 && rollback {
                    context.perform {
                        context.rollback()
                        completion(false)
                    }
                } else {
                    completion(true)
                }
            })
        }
    }

    #if canImport(_Concurrency)
    @discardableResult
    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    func saveContext(_ context: NSManagedObjectContext, rollback: Bool) async -> Bool {
        guard await context.run({ self._saveContext($0, rollback: rollback) }) else { return false }
        guard let parent = context.parent else { return true }
        let success = await self.saveContext(parent, rollback: rollback)
        if !success && rollback {
            await context.run { $0.rollback() }
        }
        return success
    }
#endif
}

@frozen
public enum CoreDataStack {
    @Lazy private static var manager = CoreDataManager(configuration: configuration)

    private static var _configuration: Configuration? {
        didSet {
            assert(_configuration != nil)
            NSManagedObject.shouldRemoveNamespaceInEntityName = configuration.removeNamespacesFromEntityNames
            _manager.reset()
        }
    }
    public static var configuration: Configuration {
        get { _configuration ?? .legacyConfiguration }
        set { _configuration = newValue }
    }

    public static var mainContext: NSManagedObjectContext { manager.managedObjectContext }

    public static func save(context: NSManagedObjectContext, rollback: Bool = true, completion: @escaping (Bool) -> () = { _ in }) {
        manager.saveContext(context, rollback: rollback, completion: completion)
    }

    public static func saveMainContext(rollback: Bool = true, completion: @escaping (Bool) -> () = { _ in }) {
        save(context: mainContext, rollback: rollback, completion: completion)
    }

#if canImport(_Concurrency)
    @discardableResult
    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    public static func saveContext(_ context: NSManagedObjectContext, rollback: Bool = true) async -> Bool {
        await manager.saveContext(context, rollback: rollback)
    }

    @discardableResult
    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    public static func saveMainContext(rollback: Bool = true) async -> Bool {
        await saveContext(mainContext, rollback: rollback)
    }
#endif

    public static func createTemporaryMainContext() -> NSManagedObjectContext {
        manager.createTemporaryMainContext()
    }

    public static func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        manager.createTemporaryBackgroundContext()
    }

    public static func clearDataStore() throws {
        try manager.clearDataStore()
    }

    public static func closeConnections() {
        _manager.reset()
    }
}

extension CoreDataStack {
    public struct Configuration {
        fileprivate static let legacyConfiguration: Configuration = {
            let bundle = Bundle.main
            let modelName = bundle.infoDictionary?["FFCDDataManagerModelName"] as? String
            let sqliteName = bundle.infoDictionary?["FFCDDataManagerSQLiteName"] as? String
            return Configuration(bundle: bundle, modelName: modelName, sqliteName: sqliteName)
        }()

        public struct Options: OptionSet {
            public typealias RawValue = UInt

            public let rawValue: RawValue

            public init(rawValue: RawValue) { self.rawValue = rawValue }
        }

        public let modelURL: URL
        public let sqliteName: String
        public let storePath: URL

        private var sqliteStoreName: String { sqliteName + ".sqlite" }
        public var databaseURL: URL { storePath.appendingPathComponent(sqliteStoreName) }

        #if os(macOS)
        public let applicationSupportSubfolderName: String
        #endif

        public let options: Options
        @inlinable
        public var removeNamespacesFromEntityNames: Bool { options.contains(.removeNamespacesFromEntityNames) }
        @inlinable
        public var clearDataStoreOnSetupFailure: Bool { options.contains(.clearDataStoreOnSetupFailure) }

        private static func url(for searchPathDirectory: FileManager.SearchPathDirectory, subDirectoryName: String? = nil) -> URL {
            let fileManager = FileManager.default
            var dataDirectory = fileManager.urls(for: searchPathDirectory, in: .userDomainMask)[0]
            if let subfolderName = subDirectoryName {
                dataDirectory.appendPathComponent(subfolderName)
            }
            do {
                try fileManager.createDirectoryIfNeeded(at: dataDirectory)
            } catch {
                os_log("Could not create data folder: %@", log: .ffCoreData, type: .error, String(describing: error))
            }
            return dataDirectory
        }
        #if os(iOS) || os(watchOS) || os(tvOS)
        public static let appDataDirectoryURL: URL = url(for: .documentDirectory)
        #elseif os(macOS)
        public static func appDataDirectoryURL(withSubfolderName subfolderName: String) -> URL {
            url(for: .applicationSupportDirectory, subDirectoryName: subfolderName)
        }
        #endif

        private static let infoDictionaryTargetDisplayNameKey = "CFBundleDisplayName"
        private static let infoDictionaryTargetNameKey = String(kCFBundleNameKey)
        private static let defaultTargetName = "UNKNOWN_TARGET_NAME"

        private init(modelURL: URL,
                     sqliteName: String,
                     storePath: URL?,
                     appSupportFolderName: @autoclosure () -> String,
                     options: Options) {
            self.modelURL = modelURL
            self.sqliteName = sqliteName
            self.options = options

            #if os(iOS) || os(watchOS) || os(tvOS)
                self.storePath = storePath ?? Configuration.appDataDirectoryURL
            #elseif os(macOS)
                let folderName = appSupportFolderName()
                self.applicationSupportSubfolderName = folderName
                self.storePath = storePath ?? Configuration.appDataDirectoryURL(withSubfolderName: folderName)
            #endif
        }

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

            self.init(modelURL: bundle.url(forResource: modelName ?? targetName(from: bundle), withExtension: "momd")!,
                      sqliteName: sqliteName ?? targetName(from: bundle),
                      storePath: storePath,
                      appSupportFolderName: appSupportFolderName ?? bundle.bundleIdentifier ?? targetName(from: bundle),
                      options: options)
        }

        #if os(iOS) || os(watchOS) || os(tvOS)
        public init(bundle: Bundle,
                    storePath: URL? = nil,
                    modelName: String? = nil,
                    sqliteName: String? = nil,
                    options: Options = .default) {
            self.init(bundle: bundle,
                      modelName: modelName,
                      sqliteName: sqliteName,
                      storePath: storePath,
                      appSupportFolderName: nil,
                      options: options)
        }

        public init(modelURL: URL,
                    storePath: URL? = nil,
                    sqliteName: String,
                    options: Options = .default) {
            self.init(modelURL: modelURL,
                      sqliteName: sqliteName,
                      storePath: storePath,
                      appSupportFolderName: "",
                      options: options)
        }
        #elseif os(macOS)
        public init(bundle: Bundle,
                    applicationSupportSubfolder: String? = nil,
                    storePath: URL? = nil,
                    modelName: String? = nil,
                    sqliteName: String? = nil,
                    options: Options = .default) {
            self.init(bundle: bundle,
                      modelName: modelName,
                      sqliteName: sqliteName,
                      storePath: storePath,
                      appSupportFolderName: applicationSupportSubfolder,
                      options: options)
        }

        public init(modelURL: URL,
                    applicationSupportSubfolder: String,
                    storePath: URL? = nil,
                    sqliteName: String,
                    options: Options = .default) {
            self.init(modelURL: modelURL,
                      sqliteName: sqliteName,
                      storePath: storePath,
                      appSupportFolderName: applicationSupportSubfolder,
                      options: options)
        }
        #endif
    }
}

extension CoreDataStack.Configuration.Options {
    public static var `default`: CoreDataStack.Configuration.Options { .removeNamespacesFromEntityNames }

    public static let removeNamespacesFromEntityNames = CoreDataStack.Configuration.Options(rawValue: 1 << 0)
    public static let clearDataStoreOnSetupFailure = CoreDataStack.Configuration.Options(rawValue: 1 << 1)
}

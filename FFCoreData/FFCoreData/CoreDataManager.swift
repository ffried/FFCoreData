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

private final class CoreDataManager {
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = self.configuration.bundle.url(forResource: self.configuration.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.configuration.storeURL
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            print("FFCoreData: Failed to add persistent store with error: \(error)\nTrying to clear the data store now!")
            do {
                try self.clearDataStore()
            } catch {
                print("FFCoreData: Failed to delete data store with error: \(error)")
            }
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                fatalError("FFCoreData: Could not add persistent store with error: \(error)")
            }
        }
        return coordinator
    }()
    
    private lazy var backgroundSavingContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        ctx.persistentStoreCoordinator = coordinator
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }()
    
    fileprivate lazy var managedObjectContext: NSManagedObjectContext = {
        let parentContext = self.backgroundSavingContext
        let ctx = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        ctx.parent = parentContext
        return ctx
    }()
    
    private(set) fileprivate var configuration: CoreDataStack.Configuration
    
    fileprivate init(configuration: CoreDataStack.Configuration) {
        self.configuration = configuration
    }
    
    fileprivate func createTemporaryMainContext() -> NSManagedObjectContext {
        return createTemporaryContext(with: .mainQueueConcurrencyType)
    }
    
    fileprivate func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        return createTemporaryContext(with: .privateQueueConcurrencyType)
    }
    
    private func createTemporaryContext(with type: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        let parentContext = managedObjectContext
        let tempCtx = NSManagedObjectContext(concurrencyType: type)
        tempCtx.parent = parentContext
        tempCtx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        tempCtx.undoManager = nil
        return tempCtx
    }
    
    fileprivate func clearDataStore() throws {
        try FileManager.default.removeItem(at: configuration.storeURL)
    }
    
    fileprivate func save(context ctx: NSManagedObjectContext, rollback: Bool, completion: @escaping (Bool) -> Void) {
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
        didSet { NSManagedObject.shouldRemoveNamespaceInEntityName = configuration.removeNamespacesFromEntityNames }
    }
    private static let manager = CoreDataManager(configuration: configuration)
    
    public static let mainContext = CoreDataStack.manager.managedObjectContext
    
    public static func save(context: NSManagedObjectContext, rollback: Bool = true, completion: @escaping (Bool) -> Void = {_ in}) {
        context.performAndWait {
            CoreDataStack.manager.save(context: context, rollback: rollback, completion: completion)
        }
    }

    public static func saveMainContext(rollback: Bool = true, completion: @escaping (Bool) -> Void = {_ in}) {
        CoreDataStack.save(context: CoreDataStack.mainContext, rollback: rollback, completion: completion)
    }
    
    public static func createTemporaryMainContext() -> NSManagedObjectContext {
        return CoreDataStack.manager.createTemporaryMainContext()
    }
    
    public static func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        return CoreDataStack.manager.createTemporaryBackgroundContext()
    }

    public static func clearDataStore() throws {
        try CoreDataStack.manager.clearDataStore()
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
        
        public let bundle: Bundle
        public let modelName: String
        public let sqliteName: String
        private var sqliteStoreName: String { return sqliteName + ".sqlite" }
        
        public let removeNamespacesFromEntityNames: Bool
        
        public let storePath: URL
        public private(set) lazy var storeURL: URL = self.storePath.appendingPathComponent(self.sqliteStoreName)
        
        #if os(OSX)
        public let applicationSupportSubfolderName: String
        #endif

        #if os(iOS) || os(watchOS) || os(tvOS)
        public static let appDataDirectoryURL: URL = {
            let fileManager = FileManager.default
            let dataFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
            do {
                try fileManager.createDirectoryIfNeeded(at: dataFolderURL)
            } catch {
                print("FFCoreData: Could not create application support folder: \(error)")
            }
            return dataFolderURL
        }()
        #elseif os(OSX)
        public static func appDataDirectoryURL(withSubfolderName subfolderName: String) -> URL {
            let fileManager = FileManager.default
            let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
            let dataFolderURL = url.appendingPathComponent(subfolderName)
            do {
                try fileManager.createDirectoryIfNeeded(at: dataFolderURL)
            } catch {
                print("FFCoreData: Could not create application support folder: \(error)")
            }
            return dataFolderURL
        }
        #endif
        
        private static let InfoDictionaryTargetDisplayNameKey = "CFBundleDisplayName"
        private static let InfoDictionaryTargetNameKey = String(kCFBundleNameKey)
        private static let DefaultTargetName = "UNKNOWN_TARGET_NAME"
        
        private init(bundle: Bundle, modelName: String?, sqliteName: String?, storePath: URL?, appSupportFolderName: String?, removeNamespaces: Bool) {
            func targetName(from bundle: Bundle) -> String {
                guard let infoDict = bundle.infoDictionary else { return Configuration.DefaultTargetName }
                let name = infoDict[Configuration.InfoDictionaryTargetDisplayNameKey] ?? infoDict[Configuration.InfoDictionaryTargetNameKey]
                return (name as? String) ?? Configuration.DefaultTargetName
            }
            
            self.bundle = bundle
            self.modelName = modelName ?? targetName(from: bundle)
            self.sqliteName = sqliteName ?? targetName(from: bundle)
            self.removeNamespacesFromEntityNames = removeNamespaces
            
            #if os(iOS) || os(watchOS) || os(tvOS)
                self.storePath = storePath ?? CoreDataStack.Configuration.appDataDirectoryURL
            #elseif os(OSX)
                let subfolderName = appSupportFolderName ?? bundle.bundleIdentifier ?? targetName(from: bundle)
                self.applicationSupportSubfolderName = subfolderName
                self.storePath = storePath ?? CoreDataStack.Configuration.appDataDirectoryURL(withSubfolderName: subfolderName)
            #endif
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS)
        public init(bundle: Bundle, storePath: URL? = nil, modelName: String? = nil, sqliteName: String? = nil, removeNamespaces: Bool = true) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, storePath: storePath, appSupportFolderName: nil, removeNamespaces: removeNamespaces)
        }
        #elseif os(OSX)
        public init(bundle: Bundle, applicationSupportSubfolder: String? = nil, storePath: URL? = nil, modelName: String? = nil, sqliteName: String? = nil, removeNamespaces: Bool = true) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, storePath: storePath, appSupportFolderName: applicationSupportSubfolder, removeNamespaces: removeNamespaces)
        }
        #endif
    }
}

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
        #if swift(>=3.0)
            let modelURL = self.configuration.bundle.url(forResource: self.configuration.modelName, withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        #else
            let modelURL = self.configuration.bundle.URLForResource(self.configuration.modelName, withExtension: "momd")!
            return NSManagedObjectModel(contentsOfURL: modelURL)!
        #endif
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.configuration.storeURL
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            #if swift(>=3.0)
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
            #else
                try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
            #endif
        } catch {
            print("FFCoreData: Failed to add persistent store with error: \(error)\nTrying to clear the data store now!")
            do {
                try self.clearDataStore()
            } catch {
                print("FFCoreData: Failed to delete data store with error: \(error)")
            }
            do {
                #if swift(>=3.0)
                    try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
                #else
                    try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
                #endif
            } catch {
                fatalError("FFCoreData: Could not add persistent store with error: \(error)")
            }
        }
        return coordinator
    }()
    
    private lazy var backgroundSavingContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        #if swift(>=3.0)
            let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        #else
            let ctx = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        #endif
        ctx.persistentStoreCoordinator = coordinator
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }()
    
    #if swift(>=3.0)
    fileprivate lazy var managedObjectContext: NSManagedObjectContext = {
        let parentContext = self.backgroundSavingContext
        let ctx = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        ctx.parent = parentContext
        return ctx
    }()
    #else
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let parentContext = self.backgroundSavingContext
        let ctx = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        ctx.parentContext = parentContext
        return ctx
    }()
    #endif
    
    #if swift(>=3.0)
    private(set) fileprivate var configuration: CoreDataStack.Configuration
    
    fileprivate init(configuration: CoreDataStack.Configuration) {
        self.configuration = configuration
    }
    #else
    private var configuration: CoreDataStack.Configuration
    
    private init(configuration: CoreDataStack.Configuration) {
        self.configuration = configuration
    }
    #endif
    
    #if swift(>=3.0)
    fileprivate func createTemporaryMainContext() -> NSManagedObjectContext {
        return createTemporaryContext(withConcurrencyType: .mainQueueConcurrencyType)
    }
    
    fileprivate func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        return createTemporaryContext(withConcurrencyType: .privateQueueConcurrencyType)
    }
    #else
    private func createTemporaryMainContext() -> NSManagedObjectContext {
        return createTemporaryContextWithConcurrencyType(.MainQueueConcurrencyType)
    }
    
    private func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        return createTemporaryContextWithConcurrencyType(.PrivateQueueConcurrencyType)
    }
    #endif
    
    #if swift(>=3.0)
    private func createTemporaryContext(withConcurrencyType type: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        let parentContext = managedObjectContext
        let tempCtx = NSManagedObjectContext(concurrencyType: type)
        tempCtx.parent = parentContext
        tempCtx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        tempCtx.undoManager = nil
        return tempCtx
    }
    #else
    private func createTemporaryContextWithConcurrencyType(type: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        let parentContext = managedObjectContext
        let tempCtx = NSManagedObjectContext(concurrencyType: type)
        tempCtx.parentContext = parentContext
        tempCtx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        tempCtx.undoManager = nil
        return tempCtx
    }
    #endif
    
    #if swift(>=3.0)
    fileprivate func clearDataStore() throws {
        try FileManager.default.removeItem(at: configuration.storeURL)
    }
    #else
    private func clearDataStore() throws {
        try NSFileManager.defaultManager().removeItemAtURL(configuration.storeURL)
    }
    #endif
    
    #if swift(>=3.0)
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
    #else
    private func saveContext(ctx: NSManagedObjectContext, rollback: Bool, completion: (Bool) -> Void) {
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
        if let parentContext = ctx.parentContext where result != false {
            parentContext.performBlock {
                self.saveContext(parentContext, rollback: rollback, completion: { success in
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
    #endif
}

public struct CoreDataStack {
    public static var configuration = Configuration.legacyConfiguration {
        didSet { NSManagedObject.setShouldRemoveNamespaceInEntityName(configuration.removeNamespacesFromEntityNames) }
    }
    private static let manager = CoreDataManager(configuration: configuration)
    
    #if swift(>=3.0)
    public static let mainContext = CoreDataStack.manager.managedObjectContext
    #else
    public static let MainContext = CoreDataStack.manager.managedObjectContext
    #endif
    
    #if swift(>=3.0)
    public static func save(context: NSManagedObjectContext, rollback: Bool = true, completion: @escaping (Bool) -> Void = {_ in}) {
        context.performAndWait {
            CoreDataStack.manager.save(context: context, rollback: rollback, completion: completion)
        }
    }
    #else
    public static func saveContext(context: NSManagedObjectContext, rollback: Bool = true, completion: Bool -> Void = {_ in}) {
        context.performBlockAndWait {
            CoreDataStack.manager.saveContext(context, rollback: rollback, completion: completion)
        }
    }
    #endif
    
    #if swift(>=3.0)
    public static func saveMainContext(rollback: Bool = true, completion: @escaping (Bool) -> Void = {_ in}) {
        CoreDataStack.save(context: CoreDataStack.mainContext, rollback: rollback, completion: completion)
    }
    #else
    public static func saveMainContext(rollback: Bool = true, completion: (Bool) -> Void = {_ in}) {
        CoreDataStack.saveContext(CoreDataStack.MainContext, rollback: rollback, completion: completion)
    }
    #endif
    
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
        
        #if swift(>=3.0)
        fileprivate static let legacyConfiguration: Configuration = {
            let bundle = Bundle.main
            let modelName = bundle.infoDictionary?[Configuration.infoDictionaryModelNameKey] as? String
            let sqliteName = bundle.infoDictionary?[Configuration.infoDictionarySQLiteNameKey] as? String
            return Configuration(bundle: bundle, modelName: modelName, sqliteName: sqliteName)
        }()
        #else
        private static let legacyConfiguration: Configuration = {
            let bundle = NSBundle.mainBundle()
            let modelName = bundle.infoDictionary?[Configuration.infoDictionaryModelNameKey] as? String
            let sqliteName = bundle.infoDictionary?[Configuration.infoDictionarySQLiteNameKey] as? String
            return Configuration(bundle: bundle, modelName: modelName, sqliteName: sqliteName)
        }()
        #endif
        
        #if swift(>=3.0)
        public let bundle: Bundle
        #else
        public let bundle: NSBundle
        #endif
        public let modelName: String
        public let sqliteName: String
        private var sqliteStoreName: String { return sqliteName + ".sqlite" }
        
        public let removeNamespacesFromEntityNames: Bool
        
        #if swift(>=3.0)
        public let storePath: URL
        #else
        public let storePath: NSURL
        #endif
        
        #if swift(>=3.0)
        public private(set) lazy var storeURL: URL = self.storePath.appendingPathComponent(self.sqliteStoreName)
        #else
        public private(set) lazy var storeURL: NSURL = self.storePath.URLByAppendPathComponent(self.sqliteStoreName)
        #endif
        
        #if os(OSX)
        public let applicationSupportSubfolderName: String
        #endif
        
        #if swift(>=3.0)
        #if os(iOS)
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
        #else
        #if os(iOS)
        public static let appDataDirectoryURL: NSURL = {
            let fileManager = NSFileManager.defaultManager()
            let dataFolderURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
            do {
                try fileManager.createDirectoryAtURLIfNeeded(dataFolderURL)
            } catch {
                print("FFCoreData: Could not create application support folder: \(error)")
            }
            return dataFolderURL
        }()
        #elseif os(OSX)
        public static func appDataDirectoryURLWithSubfolderName(subfolderName: String) -> NSURL {
            let fileManager = NSFileManager.defaultManager()
            let url = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).last!
            let dataFolderURL = url.URLByAppendingPathComponent(subfolderName)
            do {
                try fileManager.createDirectoryAtURLIfNeeded(dataFolderURL)
            } catch {
                print("FFCoreData: Could not create application support folder: \(error)")
            }
            return dataFolderURL
        }
        #endif
        #endif
        
        private static let InfoDictionaryTargetDisplayNameKey = "CFBundleDisplayName"
        private static let InfoDictionaryTargetNameKey = String(kCFBundleNameKey)
        private static let DefaultTargetName = "UNKNOWN_TARGET_NAME"
        
        #if swift(>=3.0)
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
            
            #if os(iOS)
                self.storePath = storePath ?? CoreDataStack.Configuration.appDataDirectoryURL
            #elseif os(OSX)
                let subfolderName = appSupportFolderName ?? bundle.bundleIdentifier ?? targetName(from: bundle)
                self.applicationSupportSubfolderName = subfolderName
                self.storePath = storePath ?? CoreDataStack.Configuration.appDataDirectoryURL(withSubfolderName: subfolderName)
            #endif
        }
        
        #if os(iOS)
        public init(bundle: Bundle, storePath: URL? = nil, modelName: String? = nil, sqliteName: String? = nil, removeNamespaces: Bool = true) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, storePath: storePath, appSupportFolderName: nil, removeNamespaces: removeNamespaces)
        }
        #elseif os(OSX)
        public init(bundle: Bundle, applicationSupportSubfolder: String? = nil, storePath: URL? = nil, modelName: String? = nil, sqliteName: String? = nil, removeNamespaces: Bool = true) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, storePath: storePath, appSupportFolderName: applicationSupportSubfolder, removeNamespaces: removeNamespaces)
        }
        #endif
        #else
        private init(bundle: NSBundle, modelName: String?, sqliteName: String?, storePath: NSURL?, appSupportFolderName: String?, removeNamespaces: Bool) {
            func targetName(bundle: NSBundle) -> String {
                guard let infoDict = bundle.infoDictionary else { return Configuration.DefaultTargetName }
                let name = infoDict[Configuration.InfoDictionaryTargetDisplayNameKey] ?? infoDict[Configuration.InfoDictionaryTargetNameKey]
                return (name as? String) ?? Configuration.DefaultTargetName
            }

            self.bundle = bundle
            self.modelName = modelName ?? targetName(bundle)
            self.sqliteName = sqliteName ?? targetName(bundle)
            self.removeNamespacesFromEntityNames = removeNamespaces
        
            #if os(iOS)
                self.storePath = storePath ?? CoreDataStack.Configuration.appDataDirectoryURL
            #elseif os(OSX)
                let subfolderName = appSupportFolderName ?? bundle.bundleIdentifier ?? targetName(bundle)
                self.applicationSupportSubfolderName = subfolderName
                self.storePath = storePath ?? CoreDataStack.Configuration.appDataDirectoryURLWithSubfolderName(subfolderName)
            #endif
        }
        
        #if os(iOS)
        public init(bundle: NSBundle, storePath: NSURL? = nil, modelName: String? = nil, sqliteName: String? = nil, removeNamespaces: Bool = true) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, storePath: storePath, appSupportFolderName: nil, removeNamespaces: removeNamespaces)
        }
        #elseif os(OSX)
        public init(bundle: NSBundle, applicationSupportSubfolder: String? = nil, storePath: NSURL? = nil, modelName: String? = nil, sqliteName: String? = nil, removeNamespaces: Bool = true) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, storePath: storePath, appSupportFolderName: applicationSupportSubfolder, removeNamespaces: removeNamespaces)
        }
        #endif
        #endif
    }
}

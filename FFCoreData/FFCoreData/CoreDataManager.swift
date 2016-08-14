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
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let parentContext = self.backgroundSavingContext
        #if swift(>=3.0)
            let ctx = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            ctx.parent = parentContext
        #else
            let ctx = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            ctx.parentContext = parentContext
        #endif
        return ctx
    }()
    
    private var configuration: CoreDataStack.Configuration
    
    private init(configuration: CoreDataStack.Configuration) {
        self.configuration = configuration
    }
    
    private func createTemporaryMainContext() -> NSManagedObjectContext {
        #if swift(>=3.0)
            return createTemporaryContext(withConcurrencyType: .mainQueueConcurrencyType)
        #else
            return createTemporaryContextWithConcurrencyType(.MainQueueConcurrencyType)
        #endif
    }
    
    private func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        #if swift(>=3.0)
            return createTemporaryContext(withConcurrencyType: .privateQueueConcurrencyType)
        #else
            return createTemporaryContextWithConcurrencyType(.PrivateQueueConcurrencyType)
        #endif
    }
    
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
    
    private func clearDataStore() throws {
        #if swift(>=3.0)
            try FileManager.default.removeItem(at: configuration.storeURL)
        #else
            try NSFileManager.defaultManager().removeItemAtURL(configuration.storeURL)
        #endif
    }
    
    #if swift(>=3.0)
    private func save(context ctx: NSManagedObjectContext, rollback: Bool, completion: (Bool) -> Void) {
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
    public static func save(context: NSManagedObjectContext, rollback: Bool = true, completion: (Bool) -> Void = {_ in}) {
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
    
    public static func saveMainContext(rollback: Bool = true, completion: (Bool) -> Void = {_ in}) {
        #if swift(>=3.0)
            CoreDataStack.save(context: CoreDataStack.mainContext, rollback: rollback, completion: completion)
        #else
            CoreDataStack.saveContext(CoreDataStack.MainContext, rollback: rollback, completion: completion)
        #endif
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
        
        private static let legacyConfiguration: Configuration = {
            #if swift(>=3.0)
                let bundle = Bundle.main
            #else
                let bundle = NSBundle.mainBundle()
            #endif
            let modelName = bundle.infoDictionary?[Configuration.infoDictionaryModelNameKey] as? String
            let sqliteName = bundle.infoDictionary?[Configuration.infoDictionarySQLiteNameKey] as? String
            return Configuration(bundle: bundle, modelName: modelName, sqliteName: sqliteName)
        }()
        
        #if swift(>=3.0)
        public let bundle: Bundle
        #else
        public let bundle: NSBundle
        #endif
        public let modelName: String
        public let sqliteName: String
        
        public let removeNamespacesFromEntityNames: Bool
        
        #if swift(>=3.0)
        public private(set) lazy var storeURL: URL = {
            self.dataDirectoryURL.appendingPathComponent(self.sqliteName + ".sqlite")
        }()
        #else
        public private(set) lazy var storeURL: NSURL = {
            self.dataDirectoryURL.URLByAppendingPathComponent(self.sqliteName + ".sqlite")
        }()
        #endif
        #if os(OSX)
        public let applicationSupportSubfolderName: String
        #endif
        #if swift(>=3.0)
        public private(set) lazy var dataDirectoryURL: URL = {
            let fileManager = FileManager.default
            let dataFolderURL: URL
            #if os(iOS)
                dataFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
            #elseif os(OSX)
                let url = fileManager.urls(for: .applicationSupportDirectory, inDomains: .userDomainMask).last!
                dataFolderURL = url.URLByAppendingPathComponent(self.applicationSupportSubfolderName)
            #endif
            var isDir: ObjCBool = false
            let exists = fileManager.fileExists(atPath: dataFolderURL.path, isDirectory: &isDir)
            if !exists || (exists && !isDir.boolValue) {
                do {
                    try fileManager.createDirectory(at: dataFolderURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("FFCoreData: Could not create application support folder: \(error)")
                }
            }
            return dataFolderURL
        }()
        #else
        public private(set) lazy var dataDirectoryURL: NSURL = {
            let fileManager = NSFileManager.defaultManager()
            let dataFolderURL: NSURL
            #if os(iOS)
                dataFolderURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
            #elseif os(OSX)
                let url = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).last!
                dataFolderURL = url.URLByAppendingPathComponent(self.applicationSupportSubfolderName)
            #endif
            var isDir: ObjCBool = false
            let exists = fileManager.fileExistsAtPath(dataFolderURL.path!, isDirectory: &isDir)
            if !exists || (exists && !isDir) {
                do {
                    try fileManager.createDirectoryAtURL(dataFolderURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("FFCoreData: Could not create application support folder: \(error)")
                }
            }
            return dataFolderURL
        }()
        #endif
        
        private static let InfoDictionaryTargetDisplayNameKey = "CFBundleDisplayName"
        private static let InfoDictionaryTargetNameKey = String(kCFBundleNameKey)
        private static let DefaultTargetName = "UNKNOWN_TARGET_NAME"
        
        #if swift(>=3.0)
        private init(bundle: Bundle, modelName: String?, sqliteName: String?, appSupportFolderName: String?, removeNamespaces: Bool) {
            func targetName(from bundle: Bundle) -> String {
                guard let infoDict = bundle.infoDictionary else { return Configuration.DefaultTargetName }
                let name = infoDict[Configuration.InfoDictionaryTargetDisplayNameKey] ?? infoDict[Configuration.InfoDictionaryTargetNameKey]
                return (name as? String) ?? Configuration.DefaultTargetName
            }
            self.bundle = bundle
            self.modelName = modelName ?? targetName(from: bundle)
            self.sqliteName = sqliteName ?? targetName(from: bundle)
            #if os(OSX)
                self.applicationSupportSubfolderName = appSupportFolderName ?? bundle.bundleIdentifier ?? targetName(from: bundle)
            #endif
            self.removeNamespacesFromEntityNames = removeNamespaces
        }
        
        #if os(iOS)
        public init(bundle: Bundle, modelName: String? = nil, sqliteName: String? = nil, removeNamespaces: Bool = true) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, appSupportFolderName: nil, removeNamespaces: removeNamespaces)
        }
        #elseif os(OSX)
        public init(bundle: Bundle, applicationSupportSubfolder: String? = nil, modelName: String? = nil, sqliteName: String? = nil, removeNamespaces: Bool = true) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, appSupportFolderName: applicationSupportSubfolder, removeNamespaces: removeNamespaces)
        }
        #endif
        #else
        private init(bundle: NSBundle, modelName: String?, sqliteName: String?, appSupportFolderName: String?, removeNamespaces: Bool) {
            func targetName(bundle: NSBundle) -> String {
                guard let infoDict = bundle.infoDictionary else { return Configuration.DefaultTargetName }
                let name = infoDict[Configuration.InfoDictionaryTargetDisplayNameKey] ?? infoDict[Configuration.InfoDictionaryTargetNameKey]
                return (name as? String) ?? Configuration.DefaultTargetName
            }
            self.bundle = bundle
            self.modelName = modelName ?? targetName(bundle)
            self.sqliteName = sqliteName ?? targetName(bundle)
            #if os(OSX)
                self.applicationSupportSubfolderName = appSupportFolderName ?? bundle.bundleIdentifier ?? targetName(bundle)
            #endif
            self.removeNamespacesFromEntityNames = removeNamespaces
        }
        
        #if os(iOS)
        public init(bundle: NSBundle, modelName: String? = nil, sqliteName: String? = nil, removeNamespaces: Bool = true) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, appSupportFolderName: nil, removeNamespaces: removeNamespaces)
        }
        #elseif os(OSX)
        public init(bundle: NSBundle, applicationSupportSubfolder: String? = nil, modelName: String? = nil, sqliteName: String? = nil, removeNamespaces: Bool = true) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, appSupportFolderName: applicationSupportSubfolder, removeNamespaces: removeNamespaces)
        }
        #endif
        #endif
    }
}

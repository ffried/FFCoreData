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
        let modelURL = self.configuration.bundle.URLForResource(self.configuration.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.configuration.storeURL
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch {
            print("FFCoreData: Failed to add persistent store with error: \(error)\nTrying to clear the data store now!")
            do {
                try self.clearDataStore()
            } catch {
                print("FFCoreData: Failed to delete data store with error: \(error)")
            }
            do {
                try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            }
            catch {
                fatalError("FFCoreData: Could not add persistent store with error: \(error)")
            }
        }
        return coordinator
        }()

    private lazy var backgroundSavingContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        let ctx = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        ctx.persistentStoreCoordinator = coordinator
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let parentContext = self.backgroundSavingContext
        let ctx = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        ctx.parentContext = parentContext
        return ctx
    }()
    
    private var configuration: CoreDataStack.Configuration
    
    private init(configuration: CoreDataStack.Configuration) {
        self.configuration = configuration
    }
    
    private func createTemporaryMainContext() -> NSManagedObjectContext {
        return createTemporaryContextWithConcurrencyType(.MainQueueConcurrencyType)
    }
    
    private func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        return createTemporaryContextWithConcurrencyType(.PrivateQueueConcurrencyType)
    }
    
    private func createTemporaryContextWithConcurrencyType(type: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        let parentContext = managedObjectContext
        let tempCtx = NSManagedObjectContext(concurrencyType: type)
        tempCtx.parentContext = parentContext
        tempCtx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        tempCtx.undoManager = nil
        return tempCtx
    }
    
    private func clearDataStore() throws {
        try NSFileManager.defaultManager().removeItemAtURL(configuration.storeURL)
    }
    
    private func saveContext(ctx: NSManagedObjectContext, rollback: Bool, completion: Bool -> Void) {
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
}

public struct CoreDataStack {
    public struct Configuration {
        private static let InfoDictionarySQLiteNameKey = "FFCDDataManagerSQLiteName"
        private static let InfoDictionaryModelNameKey = "FFCDDataManagerModelName"
        private static let LegacyConfiguration: Configuration = {
            let bundle = NSBundle.mainBundle()
            var modelName: String? = nil
            var sqliteName: String? = nil
            if let infoDict = bundle.infoDictionary {
                modelName = infoDict[Configuration.InfoDictionaryModelNameKey] as? String
                sqliteName = infoDict[Configuration.InfoDictionarySQLiteNameKey] as? String
            }
            return Configuration(bundle: bundle, modelName: modelName, sqliteName: sqliteName)
        }()
        
        public let bundle: NSBundle
        public let modelName: String
        public let sqliteName: String
        
        public private(set) lazy var storeURL: NSURL = {
            self.dataDirectoryURL.URLByAppendingPathComponent(self.sqliteName + ".sqlite")
        }()
        #if os(OSX)
        public let applicationSupportSubfolderName: String
        #endif
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
        
        private static let InfoDictionaryTargetDisplayNameKey = "CFBundleDisplayName"
        private static let InfoDictionaryTargetNameKey = String(kCFBundleNameKey)
        private static let DefaultTargetName = "UNKNOWN_TARGET_NAME"
        
        private init(bundle: NSBundle, modelName: String?, sqliteName: String?, appSupportFolderName: String?) {
            func targetName(bundle: NSBundle) -> String {
                let infoDict = bundle.infoDictionary!
                let name = infoDict[Configuration.InfoDictionaryTargetDisplayNameKey] ?? infoDict[Configuration.InfoDictionaryTargetNameKey]
                return (name as? String) ?? Configuration.DefaultTargetName
            }
            self.bundle = bundle
            self.modelName = modelName ?? targetName(bundle)
            self.sqliteName = sqliteName ?? targetName(bundle)
            #if os(OSX)
                self.applicationSupportSubfolderName = appSupportFolderName ?? bundle.bundleIdentifier ?? targetName(bundle)
            #endif
        }
        
        #if os(iOS)
        public init(bundle: NSBundle, modelName: String? = nil, sqliteName: String? = nil) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, appSupportFolderName: nil)
        }
        #elseif os(OSX)
        public init(bundle: NSBundle, applicationSupportSubfolder: String? = nil, modelName: String? = nil, sqliteName: String? = nil) {
            self.init(bundle: bundle, modelName: modelName, sqliteName: sqliteName, appSupportFolderName: applicationSupportSubfolder)
        }
        #endif
    }
    
    public static var configuration = Configuration.LegacyConfiguration
    private static let Manager = CoreDataManager(configuration: configuration)
    
    public static let MainContext = CoreDataStack.Manager.managedObjectContext
    
    public static func saveContext(context: NSManagedObjectContext, rollback: Bool = true, completion: Bool -> Void = {_ in}) {
        context.performBlockAndWait {
            CoreDataStack.Manager.saveContext(context, rollback: rollback, completion: completion)
        }
    }
    
    public static func saveMainContext(rollback: Bool = true, completion: Bool -> Void = {_ in}) {
        CoreDataStack.saveContext(CoreDataStack.MainContext, rollback: rollback, completion: completion)
    }
    
    public static func createTemporaryMainContext() -> NSManagedObjectContext {
        return CoreDataStack.Manager.createTemporaryMainContext()
    }
    
    public static func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        return CoreDataStack.Manager.createTemporaryBackgroundContext()
    }
    
    public static func clearDataStore() throws {
        try CoreDataStack.Manager.clearDataStore()
    }
}

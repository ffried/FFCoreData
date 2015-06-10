//
//  CoreDataManager.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 10/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

import FFCoreData

private class CoreDataManager {
    private let managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private static let persistenStoreOptions = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: nil, options: CoreDataManager.persistenStoreOptions)
        } catch {
            do {
                try self.clearDataStore()
            } catch {
                print("Failed to delete data store")
            }
            do {
                try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: nil, options: nil)
            }
            catch {
                fatalError("Could not add persistent store with error: \(error)")
            }
        }
        return coordinator
        }()
    
    private let applicationDataDirectory: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        let dataFolderURL: NSURL
#if os(iOS)
        dataFolderURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
#elseif os(OSX)
        let url = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).last!
        dataFolderURL = url.URLByAppendingPathComponent(NSApp.identifier)
        var isDir = false
        let exists = fileManager.fileExistsAtPath(dataFolderURL.path!, isDirectory: &isDir)
        if !exists || (exists && !isDir) {
            do {
                try fileManager.createDirectoryAtURL(dataFolderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Could not create application support folder: \(error)")
            }
        }
#endif
        return dataFolderURL
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

    private static let InfoDictionaryTargetNameKey = "CFBundleDisplayName"
    private static let InfoDictionarySQLiteNameKey = "FFCDDataManagerSQLiteName"
    private static let InfoDictionaryModelNameKey = "FFCDDataManagerModelName"
    private let targetName: String = {
        let infoDict = NSBundle.mainBundle().infoDictionary!
        return infoDict[CoreDataManager.InfoDictionaryTargetNameKey] as! String
    }()
    private lazy var sqliteName: String = {
        let infoDict = NSBundle.mainBundle().infoDictionary!
        let sqliteName = infoDict[CoreDataManager.InfoDictionarySQLiteNameKey] as? String
        return sqliteName ?? self.targetName
    }()
    private lazy var modelName: String = {
        let infoDict = NSBundle.mainBundle().infoDictionary!
        let modelName = infoDict[CoreDataManager.InfoDictionaryModelNameKey] as? String
        return modelName ?? self.targetName
    }()
    
    private var storeURL: NSURL {
        let pathComponent = self.sqliteName + ".sqlite"
        return self.applicationDataDirectory.URLByAppendingPathComponent(pathComponent)
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
        try NSFileManager.defaultManager().removeItemAtURL(storeURL)
    }
    
    private func saveContext(ctx: NSManagedObjectContext) {
        if !ctx.hasChanges { return }
        do {
            try ctx.save()
            switch ctx {
            case managedObjectContext:
                print("Main ManagedObjectContext saved successfully!")
            case backgroundSavingContext:
                print("Background ManagedObjectContext saved successfully!")
            default:
                print("ManagedObjectContext \(ctx) saved successfully!")
            }
        } catch {
            print("Unresolved error while saving ManagedObjectContext \(error)")
        }
        if let parentContext = ctx.parentContext {
            parentContext.performBlock { self.saveContext(parentContext) }
        }
    }
}

public struct CoreDataStack {
    private static let Manager = CoreDataManager()
    public static let MainContext: NSManagedObjectContext = CoreDataStack.Manager.managedObjectContext
    
    public static func saveMainContext() {
        CoreDataStack.saveContext(CoreDataStack.MainContext)
    }
    
    public static func saveContext(context: NSManagedObjectContext) {
        context.performBlockAndWait { CoreDataStack.Manager.saveContext(context) }
    }
    
    public static func createTemporaryMainContext() -> NSManagedObjectContext {
        return CoreDataStack.Manager.createTemporaryMainContext()
    }
    
    public static func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        return CoreDataStack.Manager.createTemporaryBackgroundContext()
    }
    
    public func clearDataStore() throws {
        try CoreDataStack.Manager.clearDataStore()
    }
}

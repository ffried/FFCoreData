//
//  CoreDataManager.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 10/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

import FFCoreData

/*
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundSavingContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSURL *storeURL;
@property (nonatomic, strong, readonly) NSString *targetName;
@property (nonatomic, strong, readonly) NSString *modelName;
@property (nonatomic, strong, readonly) NSString *sqliteName;

+ (instancetype)sharedManager;
- (void)clearDataStore;*/

private struct CoreDataManager {
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
//            clearDataStore()
            do { try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: nil, options: nil) }
            catch {
                fatalError("Could not add persistent store with error: \(error)")
            }
        }
        return coordinator
        }()
    
    private var applicationDataDirectory: NSURL {
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
    }
    /*
    #pragma mark - Store URL
    - (NSURL *)storeURL {
    NSString *pathComponent = [NSString stringWithFormat:@"%@.sqlite", self.sqliteName];
    return [[self applicationDataDirectory] URLByAppendingPathComponent:pathComponent];
    }
    
    #pragma mark - Names
    - (NSString *)targetName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return infoDictionary[FFCDDataManagerTargetNameInfoDictionaryKey];
    }
    
    - (NSString *)modelName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *modelName = infoDictionary[FFCDDataManagerModelNameInfoDictionaryKey];
    if (!modelName.length) { modelName = self.targetName; }
    return modelName;
    }
    
    - (NSString *)sqliteName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *sqliteName = infoDictionary[FFCDDataManagerSQLiteNameInfoDictionaryKey];
    if (!sqliteName.length) { sqliteName = self.targetName; }
    return sqliteName;
    }
*/
}

//public var MainContext: NSManagedObjectContext = {
//
//}()

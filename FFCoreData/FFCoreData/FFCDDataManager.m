//
//  FFDataManager.m
//  FFCoreData
//
//  Created by Florian Friedrich on 1.2.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import "FFCDDataManager.h"
#import "FFCoreData.h"
#import "FFCoreDataDefines.h"

static NSString *const FFCDDataManagerModelNameInfoDictionaryKey = @"FFCDDataManagerModelName";
static NSString *const FFCDDataManagerSQLiteNameInfoDictionaryKey = @"FFCDDataManagerSQLiteName";
static NSString *const FFCDDataManagerTargetNameInfoDictionaryKey = @"CFBundleDisplayName";

@interface FFCDDataManager : NSObject
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundSavingContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSURL *storeURL;
@property (nonatomic, strong, readonly) NSString *targetName;
@property (nonatomic, strong, readonly) NSString *modelName;
@property (nonatomic, strong, readonly) NSString *sqliteName;

+ (instancetype)sharedManager;
- (void)clearDataStore;
@end

@implementation FFCDDataManager
@synthesize backgroundSavingContext = _backgroundSavingContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

+ (instancetype)sharedManager {
    static id SharedManager = nil;
    static dispatch_once_t SharedManagerToken;
    @synchronized(self) {
        dispatch_once(&SharedManagerToken, ^{
            SharedManager = [[self alloc] init];
        });
    }
    return SharedManager;
}

#pragma mark - Core Data stack
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        // NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        NSManagedObjectContext *parentContext = self.backgroundSavingContext;
        if (parentContext != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            _managedObjectContext.parentContext = parentContext;
        }
    }
    return _managedObjectContext;
}

- (NSManagedObjectContext *)backgroundSavingContext {
    if (!_backgroundSavingContext) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator != nil) {
            _backgroundSavingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            _backgroundSavingContext.persistentStoreCoordinator = coordinator;
            _backgroundSavingContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        }
    }
    return _backgroundSavingContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        __autoreleasing NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:self.storeURL
                                                             options:@{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                                                       NSInferMappingModelAutomaticallyOption: @YES}
                                                               error:&error]) {
            // Delete the file
            [self clearDataStore];
            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                           configuration:nil
                                                                     URL:self.storeURL
                                                                 options:nil
                                                                   error:&error]) {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                 Typical reasons for an error here include:
                 * The persistent store is not accessible;
                 * The schema for the persistent store is incompatible with current managed object model.
                 Check the error message to determine what the actual problem was.
                 
                 
                 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
                 
                 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
                 * Simply deleting the existing store:
                 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
                 
                 * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
                 @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
                 
                 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
                 
                 */
//                DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                FFLog(@"Unresolved error %@, %@", error, [error userInfo]);
#if FFCDManagerCrashesOnFailure
                abort();
#endif
            }
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Temporary Contexts
- (NSManagedObjectContext *)createTemporaryMainContext {
    return [self temporaryContextWithConcurrencyType:NSMainQueueConcurrencyType];
}

- (NSManagedObjectContext *)createTemporaryBackgroundContext {
    return [self temporaryContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
}

- (NSManagedObjectContext *)temporaryContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type {
    NSManagedObjectContext *tempContext = nil;
    NSManagedObjectContext *parentContext = self.managedObjectContext;
    if (parentContext) {
        tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
        tempContext.parentContext = parentContext;
        tempContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        tempContext.undoManager = nil;
    }
    return tempContext;
}

#pragma mark - Clearing
- (void)clearDataStore {
    __autoreleasing NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:self.storeURL error:&error]) {
        FFLog(@"Failed to delete data store: %@", error);
    }
}

#pragma mark - Data Directory
- (NSURL *)applicationDataDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *dataFolderURL = nil;
#if TARGET_OS_IPHONE
    dataFolderURL = [[fileManager URLsForDirectory:NSDocumentDirectory
                                         inDomains:NSUserDomainMask] lastObject];
#elif TARGET_OS_MAC
    dataFolderURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory
                                         inDomains:NSUserDomainMask] lastObject];
    dataFolderURL = [appSupportURL URLByAppendingPathComponent:[NSApp identifier]];
    BOOL isDir = NO;
    BOOL exists = [fileManager fileExistsAtPath:[dataFolderURL path] isDirectory:&isDir];
    if (!exists || (exists && !isDir)) {
        __autoreleasing NSError *error;
        [fileManager createDirectoryAtURL:dataFolderURL withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
//            DDLogError(@"Failed to create application support folder: %@", error);
            FFLog(@"Failed to create application support folder: %@", error);
        }
    }
#endif
    return dataFolderURL;
}

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

@end

NSManagedObjectContext *FFCDMainContext() {
    return [[FFCDDataManager sharedManager] managedObjectContext];
}

NSManagedObjectContext *FFCDTemporaryMainContext() {
    return [[FFCDDataManager sharedManager] createTemporaryMainContext];
}

NSManagedObjectContext *FFCDTemporaryBackgroundContext() {
    return [[FFCDDataManager sharedManager] createTemporaryBackgroundContext];
}

void __ffcd_save_context(NSManagedObjectContext *context) {
    if (![context hasChanges]) { return; }
    __autoreleasing NSError *error = nil;
    if (![context save:&error]) {
//        DDLogError(@"Unresolved error while saving ManagedObjectContext %@, %@", error, [error userInfo]);
        FFLog(@"Unresolved error while saving ManagedObjectContext %@, %@", error, [error userInfo]);
    } else {
        if (context == [[FFCDDataManager sharedManager] managedObjectContext]) {
//            DDLogInfo(@"Main ManagedObjectContext %@ saved successfully", context);
            FFLog(@"Main ManagedObjectContext %@ saved successfully", context);
        } else if (context == [[FFCDDataManager sharedManager] backgroundSavingContext]) {
//            DDLogInfo(@"Background ManagedObjectContext %@ saved successfully", context);
            FFLog(@"Background ManagedObjectContext %@ saved successfully", context);
        } else {
//            DDLogInfo(@"ManagedObjectContext %@ saved successfully", context);
            FFLog(@"ManagedObjectContext %@ saved successfully", context);
        }
        NSManagedObjectContext *parentContext = context.parentContext;
        if (parentContext) {
            [parentContext performBlock:^{ __ffcd_save_context(parentContext); }];
        }
    }
}

void FFCDSaveContext(NSManagedObjectContext *context) {
    [context performBlockAndWait:^{ __ffcd_save_context(context); }];
}

void FFCDSaveMainContext() { FFCDSaveContext(FFCDMainContext()); }

#if FFCDManagerAllowsStoreDeletion
void FFCDClearDataStore() {
    [[FFCDDataManager sharedManager] clearDataStore];
}
#endif

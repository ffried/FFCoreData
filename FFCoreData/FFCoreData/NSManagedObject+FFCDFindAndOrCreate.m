//
//  NSManagedObject+FFCDFindAndOrCreate.m
//  FFCoreData
//
//  Created by Florian Friedrich on 15.12.13.
//  Copyright (c) 2013 Florian Friedrich. All rights reserved.

#import "NSManagedObject+FFCDFindAndOrCreate.h"
#import "FFCoreData.h"

@implementation NSManagedObject (FFCDFindAndOrCreate)

#pragma mark - Just create
+ (instancetype)createObjectInManagedObjectContext:(NSManagedObjectContext *)context {
    return [self createObjectWithEntityName:NSStringFromClass(self)
                     inManagedObjectContext:context];
}

+ (instancetype)createObjectWithEntityName:(NSString *)entityName
                    inManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:entityName
                                         inManagedObjectContext:context];
}

#pragma mark - Just find
#pragma mark All objects
+ (FFCDCollectionResult *)allObjectsInContext:(NSManagedObjectContext *)context {
    return [self allObjectsWithEntity:NSStringFromClass(self) inContext:context];
}

+ (FFCDCollectionResult *)allObjectsWithEntity:(NSString *)entity inContext:(NSManagedObjectContext *)context {
    return [self allObjectsWithEntity:entity inContext:context withError:nil];
}

+ (FFCDCollectionResult *)allObjectsWithEntity:(NSString *)entity
                                     inContext:(NSManagedObjectContext *)context
                                     withError:(NSError * _Nullable __autoreleasing *)error {
    return [self findObjectsWithEntityName:entity byUsingPredicate:nil inContext:context withError:error];
}

#pragma mark Single values
+ (FFCDCollectionResult *)findObjectsByKey:(NSString *)key
                               objectValue:(NSObject *)objectValue
                    inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsByKeyObjectValue:@{key: objectValue}
                      inManagedObjectContext:context];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                              byKey:(NSString *)key
                                        objectValue:(NSObject *)objectValue
                             inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:@{key: objectValue}
                    inManagedObjectContext:context];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                              byKey:(NSString *)key
                                        objectValue:(NSObject *)objectValue
                             inManagedObjectContext:(NSManagedObjectContext *)context
                                          withError:(NSError * _Nullable __autoreleasing *)error {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:@{key: objectValue}
                    inManagedObjectContext:context
                                 withError:error];
}

#pragma mark Multiple values
+ (FFCDCollectionResult *)findObjectsByKeyObjectValue:(FFCDKeyObjectsDictionary *)keyObjectDictionary
                               inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:NSStringFromClass(self)
                     byKeyObjectDictionary:keyObjectDictionary
                    inManagedObjectContext:context];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                              byKeyObjectDictionary:(FFCDKeyObjectsDictionary *)keyObjectDictionary
                             inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:keyObjectDictionary
                    inManagedObjectContext:context
                                 withError:nil];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                              byKeyObjectDictionary:(FFCDKeyObjectsDictionary *)keyObjectDictionary
                             inManagedObjectContext:(NSManagedObjectContext *)context
                                          withError:(NSError *__autoreleasing  _Nullable *)error {
    NSPredicate *predicate = nil;
    if (keyObjectDictionary) {
        NSMutableArray<NSPredicate *> *subpredicates = [NSMutableArray<NSPredicate *> array];
        
        [keyObjectDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"%K == %@", key, obj];
            [subpredicates addObject:p];
        }];
        
        predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType
                                                subpredicates:[NSArray<NSPredicate *> arrayWithArray:subpredicates]];
    }
    
    return [self findObjectsWithEntityName:entityName
                          byUsingPredicate:predicate
                                 inContext:context
                                 withError:error];;
}

#pragma mark Predicates
+ (FFCDCollectionResult *)findObjectsByUsingPredicate:(NSPredicate *)predicate
                                            inContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:NSStringFromClass(self)
                          byUsingPredicate:predicate
                                 inContext:context];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                   byUsingPredicate:(NSPredicate *)predicate
                                          inContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:entityName
                          byUsingPredicate:predicate
                                 inContext:context
                                 withError:nil];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                   byUsingPredicate:(NSPredicate *)predicate
                                          inContext:(NSManagedObjectContext *)context
                                          withError:(NSError *__autoreleasing  _Nullable *)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.predicate = predicate;
    
    NSError *_Nullable __autoreleasing *errorPtr = error;
    if (errorPtr == nil) {
        __autoreleasing NSError *localError = nil;
        errorPtr = &localError;
    }
    FFCDCollectionResult *fetchedObjects = [context executeFetchRequest:fetchRequest error:errorPtr];
    if (fetchedObjects == nil && *errorPtr != nil) {
        NSLog(@"FFCoreData: Error while executing findOrCreate fetch request: %@", *errorPtr);
    }
    
    return fetchedObjects;
}

#pragma mark - Find or Create
#pragma mark Singleton objects
+ (instancetype)findOrCreateObjectInManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectByKeyObjectDictionary:nil inManagedObjectContext:context];
}

+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                          inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:nil
                           inManagedObjectContext:context];
}

+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                          inManagedObjectContext:(NSManagedObjectContext *)context
                                       withError:(NSError *__autoreleasing  _Nullable *)error {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:nil
                           inManagedObjectContext:context
                                        withError:error];
}

#pragma mark Single key/value methods
+ (instancetype)findOrCreateObjectByKey:(NSString *)key
                            objectValue:(NSObject *)objectValue
                 inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectByKeyObjectDictionary:@{key: objectValue}
                                  inManagedObjectContext:context];
}

+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                           byKey:(NSString *)key
                                     objectValue:(NSObject *)objectValue
                          inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:@{key: objectValue}
                           inManagedObjectContext:context];
}

+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                           byKey:(NSString *)key
                                     objectValue:(NSObject *)objectValue
                          inManagedObjectContext:(NSManagedObjectContext *)context
                                       withError:(NSError *__autoreleasing  _Nullable *)error {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:@{key: objectValue}
                           inManagedObjectContext:context
                                        withError:error];
}

#pragma mark Key/value dict methods
+ (instancetype)findOrCreateObjectByKeyObjectDictionary:(FFCDKeyObjectsDictionary *)keyObjectDictionary
                                 inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:NSStringFromClass(self)
                            byKeyObjectDictionary:keyObjectDictionary
                           inManagedObjectContext:context];
}

+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                           byKeyObjectDictionary:(FFCDKeyObjectsDictionary *)keyObjectDictionary
                          inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:keyObjectDictionary
                           inManagedObjectContext:context
                                        withError:nil];
}

+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                           byKeyObjectDictionary:(FFCDKeyObjectsDictionary *)keyObjectDictionary
                          inManagedObjectContext:(NSManagedObjectContext *)context
                                       withError:(NSError *__autoreleasing  _Nullable *)error {
    FFCDCollectionResult *fetchedObjects = [self findObjectsWithEntityName:entityName
                                                     byKeyObjectDictionary:keyObjectDictionary
                                                    inManagedObjectContext:context
                                                                 withError:error];
    
    __kindof NSManagedObject *managedObject;
    if (fetchedObjects != nil && fetchedObjects.count > 0) {
        managedObject = [fetchedObjects firstObject];
    } else {
        managedObject = [self createObjectWithEntityName:entityName inManagedObjectContext:context];
        if (keyObjectDictionary) {
            [keyObjectDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSManagedObjectID class]]) {
                    [managedObject setValue:[context objectWithID:obj] forKey:key];
                } else {
                    [managedObject setValue:obj forKey:key];
                }
            }];
        }
    }
    
    return managedObject;
}

@end

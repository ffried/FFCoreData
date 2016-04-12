//
//  NSManagedObject+FFCDFindAndOrCreate.m
//  FFCoreData
//
//  Created by Florian Friedrich on 15.12.13.
//  Copyright 2013 Florian Friedrich
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

#import "NSManagedObject+FFCDFindAndOrCreate.h"

@implementation NSManagedObject (FFCDFindAndOrCreate)

#pragma mark - Entity
+ (NSString *)entityName {
    return [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
}

#pragma mark - Just create
+ (instancetype)createObjectInManagedObjectContext:(NSManagedObjectContext *)context {
    return [self createObjectWithEntityName:[self entityName]
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
    return [self allObjectsInContext:context withError:nil] ?: @[];
}

+ (nullable FFCDCollectionResult *)allObjectsInContext:(NSManagedObjectContext *)context
                                             withError:(NSError * __autoreleasing _Nullable *)error {
    return [self allObjectsWithEntity:[self entityName]
                            inContext:context
                            withError:error];
}

+ (FFCDCollectionResult *)allObjectsWithEntity:(NSString *)entity
                                     inContext:(NSManagedObjectContext *)context {
    return [self allObjectsWithEntity:entity inContext:context withError:nil] ?: @[];
}

+ (nullable FFCDCollectionResult *)allObjectsWithEntity:(NSString *)entity
                                              inContext:(NSManagedObjectContext *)context
                                              withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:entity
                          byUsingPredicate:nil
                                 inContext:context
                                 withError:error];
}

#pragma mark Single values
+ (FFCDCollectionResult *)findObjectsByKey:(NSString *)key
                               objectValue:(nullable NSObject *)objectValue
                    inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsByKey:key
                      objectValue:objectValue
           inManagedObjectContext:context
                        withError:nil] ?: @[];
}

+ (nullable FFCDCollectionResult *)findObjectsByKey:(NSString *)key
                                        objectValue:(nullable NSObject *)objectValue
                             inManagedObjectContext:(NSManagedObjectContext *)context
                                          withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:[self entityName]
                                     byKey:key
                               objectValue:objectValue
                    inManagedObjectContext:context
                                 withError:nil];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                              byKey:(NSString *)key
                                        objectValue:(nullable NSObject *)objectValue
                             inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:entityName
                                     byKey:key
                               objectValue:objectValue
                    inManagedObjectContext:context
                                 withError:nil] ?: @[];
}

+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                                       byKey:(NSString *)key
                                                 objectValue:(nullable NSObject *)objectValue
                                      inManagedObjectContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:@{key: (objectValue ?: [NSNull null])}
                    inManagedObjectContext:context
                                 withError:error];
}

#pragma mark Multiple values
+ (FFCDCollectionResult *)findObjectsByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                    inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsByKeyObjectDictionary:keyObjectDictionary
                           inManagedObjectContext:context
                                        withError:nil] ?: @[];
}

+ (nullable FFCDCollectionResult *)findObjectsByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                             inManagedObjectContext:(NSManagedObjectContext *)context
                                                          withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:[self entityName]
                     byKeyObjectDictionary:keyObjectDictionary
                    inManagedObjectContext:context
                                 withError:error];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                              byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                             inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:keyObjectDictionary
                    inManagedObjectContext:context
                                 withError:nil] ?: @[];
}

+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                       byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                      inManagedObjectContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error {
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
+ (FFCDCollectionResult *)findObjectsByUsingPredicate:(nullable NSPredicate *)predicate
                                            inContext:(NSManagedObjectContext *)context {
    return [self findObjectsByUsingPredicate:predicate
                                   inContext:context
                                   withError:nil] ?: @[];
}

+ (nullable FFCDCollectionResult *)findObjectsByUsingPredicate:(nullable NSPredicate *)predicate
                                                     inContext:(NSManagedObjectContext *)context
                                                     withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:[self entityName]
                          byUsingPredicate:predicate
                                 inContext:context
                                 withError:error];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                   byUsingPredicate:(nullable NSPredicate *)predicate
                                          inContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:entityName
                          byUsingPredicate:predicate
                                 inContext:context
                                 withError:nil] ?: @[];
}

+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                            byUsingPredicate:(nullable NSPredicate *)predicate
                                                   inContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error {
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
+ (null_unspecified instancetype)findOrCreateObjectInManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectInManagedObjectContext:context
                                                withError:nil];
}

+ (nullable instancetype)findOrCreateObjectInManagedObjectContext:(NSManagedObjectContext *)context
                                                        withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findOrCreateObjectWithEntityName:[self entityName]
                           inManagedObjectContext:context
                                        withError:error];
}

+ (null_unspecified instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                           inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:nil
                           inManagedObjectContext:context
                                        withError:nil];
}

+ (nullable instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                   inManagedObjectContext:(NSManagedObjectContext *)context
                                                withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:nil
                           inManagedObjectContext:context
                                        withError:error];
}

#pragma mark Single key/value methods
+ (null_unspecified instancetype)findOrCreateObjectByKey:(NSString *)key
                                             objectValue:(nullable NSObject *)objectValue
                                  inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectByKey:key
                             objectValue:objectValue
                  inManagedObjectContext:context
                               withError:nil];
}

+ (nullable instancetype)findOrCreateObjectByKey:(NSString *)key
                                     objectValue:(nullable NSObject *)objectValue
                          inManagedObjectContext:(NSManagedObjectContext *)context
                                       withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findOrCreateObjectWithEntityName:[self entityName]
                                            byKey:key
                                      objectValue:objectValue
                           inManagedObjectContext:context
                                        withError:error];
}

+ (null_unspecified instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                                            byKey:(NSString *)key
                                                      objectValue:(nullable NSObject *)objectValue
                                           inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:entityName
                                            byKey:key
                                      objectValue:objectValue
                           inManagedObjectContext:context
                                        withError:nil];
}

+ (nullable instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                                    byKey:(NSString *)key
                                              objectValue:(nullable NSObject *)objectValue
                                   inManagedObjectContext:(NSManagedObjectContext *)context
                                                withError:(NSError * __autoreleasing  _Nullable *)error {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:@{key: (objectValue ?: [NSNull null])}
                           inManagedObjectContext:context
                                        withError:error];
}

#pragma mark Key/value dict methods
+ (null_unspecified instancetype)findOrCreateObjectByKeyObjectDictionary:(FFCDKeyObjectsDictionary *)keyObjectDictionary
                                                  inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectByKeyObjectDictionary:keyObjectDictionary
                                  inManagedObjectContext:context
                                               withError:nil];
}

+ (nullable instancetype)findOrCreateObjectByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                          inManagedObjectContext:(NSManagedObjectContext *)context
                                                       withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findOrCreateObjectWithEntityName:[self entityName]
                            byKeyObjectDictionary:keyObjectDictionary
                           inManagedObjectContext:context
                                        withError:error];
}

+ (null_unspecified instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                            byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                           inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:keyObjectDictionary
                           inManagedObjectContext:context
                                        withError:nil];
}

+ (nullable instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                    byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                   inManagedObjectContext:(NSManagedObjectContext *)context
                                                withError:(NSError * __autoreleasing  _Nullable *)error {
    FFCDCollectionResult *fetchedObjects = [self findObjectsWithEntityName:entityName
                                                     byKeyObjectDictionary:keyObjectDictionary
                                                    inManagedObjectContext:context
                                                                 withError:error];
    
    __kindof NSManagedObject *managedObject;
    if (fetchedObjects != nil && fetchedObjects.count > 0) {
        managedObject = [fetchedObjects firstObject];
    } else {
        managedObject = [self createObjectWithEntityName:entityName
                                  inManagedObjectContext:context];
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

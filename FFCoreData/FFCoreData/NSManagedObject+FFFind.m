//
//  NSManagedObject+FFFind.m
//  FFCoreData
//
//  Created by Florian Friedrich on 30/05/16.
//  Copyright © 2016 Florian Friedrich. All rights reserved.
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

#import "NSManagedObject+FFFind.h"
#import <FFCoreData/NSManagedObject+FFEntity.h>

@implementation NSManagedObject (FFFind)

#pragma mark - All objects
+ (nullable FFCDCollectionResult *)allObjectsInContext:(NSManagedObjectContext *)context
                                             withError:(NSError * __autoreleasing _Nullable *)error {
    return [self allObjectsSortedBy:nil inContext:context withError:error];
}

+ (nullable FFCDCollectionResult *)allObjectsWithEntity:(NSString *)entity
                                              inContext:(NSManagedObjectContext *)context
                                              withError:(NSError * __autoreleasing _Nullable *)error {
    return [self allObjectsWithEntity:entity
                             sortedBy:nil
                            inContext:context
                            withError:error];
}

+ (nullable FFCDCollectionResult *)allObjectsSortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                            inContext:(NSManagedObjectContext *)context
                                            withError:(NSError * _Nullable __autoreleasing *)error {
    return [self allObjectsWithEntity:[self entityName]
                             sortedBy:sortDescriptors
                            inContext:context
                            withError:error];
}

+ (nullable FFCDCollectionResult *)allObjectsWithEntity:(NSString *)entity
                                               sortedBy:(NSArray<NSSortDescriptor *> *)sortDescriptors
                                              inContext:(NSManagedObjectContext *)context
                                              withError:(NSError * _Nullable __autoreleasing *)error {
    return [self findObjectsWithEntityName:entity
                          byUsingPredicate:nil
                                  sortedBy:sortDescriptors
                                 inContext:context
                                 withError:error];
}

#pragma mark - Single values
+ (nullable FFCDCollectionResult *)findObjectsByKey:(NSString *)key
                                        objectValue:(nullable NSObject *)objectValue
                             inManagedObjectContext:(NSManagedObjectContext *)context
                                          withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsByKey:key
                      objectValue:objectValue
                         sortedBy:nil
           inManagedObjectContext:context
                        withError:error];
}

+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                                       byKey:(NSString *)key
                                                 objectValue:(nullable NSObject *)objectValue
                                      inManagedObjectContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:@{key: (objectValue ?: [NSNull null])}
                                  sortedBy:nil
                    inManagedObjectContext:context
                                 withError:error];
}

+ (nullable FFCDCollectionResult *)findObjectsByKey:(NSString *)key
                                        objectValue:(nullable NSObject *)objectValue
                                           sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                             inManagedObjectContext:(NSManagedObjectContext *)context
                                          withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:[self entityName]
                                     byKey:key
                               objectValue:objectValue
                                  sortedBy:sortDescriptors
                    inManagedObjectContext:context
                                 withError:error];
}

+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                                       byKey:(NSString *)key
                                                 objectValue:(nullable NSObject *)objectValue
                                                    sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                      inManagedObjectContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:@{key: (objectValue ?: [NSNull null])}
                    inManagedObjectContext:context
                                 withError:error];
}

#pragma mark - Multiple values
+ (nullable FFCDCollectionResult *)findObjectsByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                             inManagedObjectContext:(NSManagedObjectContext *)context
                                                          withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsByKeyObjectDictionary:keyObjectDictionary
                                         sortedBy:nil
                           inManagedObjectContext:context
                                        withError:error];
}

+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                       byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                      inManagedObjectContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:keyObjectDictionary
                                  sortedBy:nil
                    inManagedObjectContext:context
                                 withError:error];
}

+ (nullable FFCDCollectionResult *)findObjectsByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                                           sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                             inManagedObjectContext:(NSManagedObjectContext *)context
                                                          withError:(NSError * _Nullable __autoreleasing *)error {
    return [self findObjectsWithEntityName:[self entityName]
                     byKeyObjectDictionary:keyObjectDictionary
                                  sortedBy:sortDescriptors
                    inManagedObjectContext:context
                                 withError:error];
}

+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                              byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                           sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                             inManagedObjectContext:(NSManagedObjectContext *)context
                                          withError:(NSError * _Nullable __autoreleasing *)error {
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
                                  sortedBy:sortDescriptors
                                 inContext:context
                                 withError:error];
}

#pragma mark - Predicates
+ (nullable FFCDCollectionResult *)findObjectsByUsingPredicate:(nullable NSPredicate *)predicate
                                                     inContext:(NSManagedObjectContext *)context
                                                     withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:[self entityName]
                          byUsingPredicate:predicate
                                 inContext:context
                                 withError:error];
}

+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                            byUsingPredicate:(nullable NSPredicate *)predicate
                                                   inContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:entityName
                          byUsingPredicate:predicate
                                  sortedBy:nil
                                 inContext:context
                                 withError:error];
    
}

+ (nullable FFCDCollectionResult *)findObjectsByUsingPredicate:(nullable NSPredicate *)predicate
                                                      sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                                     inContext:(NSManagedObjectContext *)context
                                                     withError:(NSError * _Nullable __autoreleasing *)error {
    return [self findObjectsByUsingPredicate:predicate
                                    sortedBy:sortDescriptors
                                   inContext:context
                                   withError:error];
}

+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                            byUsingPredicate:(nullable NSPredicate *)predicate
                                                    sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                                   inContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * _Nullable __autoreleasing *)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = sortDescriptors;
    
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

#pragma mark - Single objects
+ (nullable instancetype)findFirstObjectByUsingPredicate:(nullable NSPredicate *)predicate
                                               inContext:(NSManagedObjectContext *)context
                                               withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findFirstObjectByUsingPredicate:predicate
                                        sortedBy:nil
                                       inContext:context
                                       withError:error];
}

+ (nullable instancetype)findFirstObjectWithEntityName:(NSString *)entityName
                                      byUsingPredicate:(nullable NSPredicate *)predicate
                                             inContext:(NSManagedObjectContext *)context
                                             withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findFirstObjectWithEntityName:entityName
                              byUsingPredicate:predicate
                                      sortedBy:nil
                                     inContext:context
                                     withError:error];
}

+ (nullable instancetype)findFirstObjectByUsingPredicate:(nullable NSPredicate *)predicate
                                                sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                               inContext:(NSManagedObjectContext *)context
                                               withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findFirstObjectWithEntityName:[self entityName]
                              byUsingPredicate:predicate
                                      sortedBy:sortDescriptors
                                     inContext:context
                                     withError:error];
}

+ (nullable instancetype)findFirstObjectWithEntityName:(NSString *)entityName
                                      byUsingPredicate:(nullable NSPredicate *)predicate
                                              sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                             inContext:(NSManagedObjectContext *)context
                                             withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:entityName
                          byUsingPredicate:predicate
                                  sortedBy:sortDescriptors
                                 inContext:context
                                 withError:error].firstObject;
}

+ (nullable instancetype)findLastObjectByUsingPredicate:(nullable NSPredicate *)predicate
                                              inContext:(NSManagedObjectContext *)context
                                              withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findLastObjectByUsingPredicate:predicate
                                       sortedBy:nil
                                      inContext:context
                                      withError:error];
}

+ (nullable instancetype)findLastObjectWithEntityName:(NSString *)entityName
                                     byUsingPredicate:(nullable NSPredicate *)predicate
                                            inContext:(NSManagedObjectContext *)context
                                            withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findLastObjectWithEntityName:entityName
                             byUsingPredicate:predicate
                                     sortedBy:nil
                                    inContext:context
                                    withError:error];
}

+ (nullable instancetype)findLastObjectByUsingPredicate:(nullable NSPredicate *)predicate
                                               sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                              inContext:(NSManagedObjectContext *)context
                                              withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findLastObjectWithEntityName:[self entityName]
                             byUsingPredicate:predicate
                                     sortedBy:sortDescriptors
                                    inContext:context
                                    withError:error];
}

+ (nullable instancetype)findLastObjectWithEntityName:(NSString *)entityName
                                     byUsingPredicate:(nullable NSPredicate *)predicate
                                             sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                            inContext:(NSManagedObjectContext *)context
                                            withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findObjectsWithEntityName:entityName
                          byUsingPredicate:predicate
                                  sortedBy:sortDescriptors
                                 inContext:context
                                 withError:error].lastObject;
}

@end

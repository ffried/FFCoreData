//
//  NSManagedObject+FFFindOrCreate.m
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

@import FFFoundation;
#import "NSManagedObject+FFFindOrCreate.h"
#import <FFCoreData/NSManagedObject+FFEntity.h>
#import <FFCoreData/NSManagedObject+FFCreate.h>
#import <FFCoreData/NSManagedObject+FFFind.h>

@implementation NSManagedObject (FFFindOrCreate)

#pragma mark - Singleton objects
+ (nullable instancetype)findOrCreateObjectInManagedObjectContext:(NSManagedObjectContext *)context
                                                        withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findOrCreateObjectWithEntityName:[self entityName]
                           inManagedObjectContext:context
                                        withError:error];
}

+ (nullable instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                   inManagedObjectContext:(NSManagedObjectContext *)context
                                                withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:nil
                           inManagedObjectContext:context
                                        withError:error];
}

#pragma mark - Single values
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

#pragma mark - Multiple values
+ (nullable instancetype)findOrCreateObjectByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                          inManagedObjectContext:(NSManagedObjectContext *)context
                                                       withError:(NSError * __autoreleasing _Nullable *)error {
    return [self findOrCreateObjectWithEntityName:[self entityName]
                            byKeyObjectDictionary:keyObjectDictionary
                           inManagedObjectContext:context
                                        withError:error];
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

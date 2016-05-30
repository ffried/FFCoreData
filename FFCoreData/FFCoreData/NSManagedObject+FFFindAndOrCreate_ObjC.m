//
//  NSManagedObject+FFFindAndOrCreate_ObjC.m
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

#import "NSManagedObject+FFFindAndOrCreate_ObjC.h"
#import <FFCoreData/NSManagedObject+FFFind.h>
#import <FFCoreData/NSManagedObject+FFCreate.h>
#import <FFCoreData/NSManagedObject+FFFindOrCreate.h>

@implementation NSManagedObject (FFFindAndOrCreate_ObjC)

#pragma mark - Just find
#pragma mark All objects
+ (FFCDCollectionResult *)allObjectsInContext:(NSManagedObjectContext *)context {
    return [self allObjectsInContext:context withError:nil] ?: @[];
}

+ (FFCDCollectionResult *)allObjectsWithEntity:(NSString *)entity
                                     inContext:(NSManagedObjectContext *)context {
    return [self allObjectsWithEntity:entity inContext:context withError:nil] ?: @[];
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

#pragma mark Multiple values
+ (FFCDCollectionResult *)findObjectsByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                    inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsByKeyObjectDictionary:keyObjectDictionary
                           inManagedObjectContext:context
                                        withError:nil] ?: @[];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                              byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                             inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:keyObjectDictionary
                    inManagedObjectContext:context
                                 withError:nil] ?: @[];
}

#pragma mark Predicates
+ (FFCDCollectionResult *)findObjectsByUsingPredicate:(nullable NSPredicate *)predicate
                                            inContext:(NSManagedObjectContext *)context {
    return [self findObjectsByUsingPredicate:predicate
                                   inContext:context
                                   withError:nil] ?: @[];
}

+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                   byUsingPredicate:(nullable NSPredicate *)predicate
                                          inContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:entityName
                          byUsingPredicate:predicate
                                 inContext:context
                                 withError:nil] ?: @[];
}

#pragma mark - Find or Create
#pragma mark Singleton objects
+ (null_unspecified instancetype)findOrCreateObjectInManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectInManagedObjectContext:context
                                                withError:nil];
}

+ (null_unspecified instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                           inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:nil
                           inManagedObjectContext:context
                                        withError:nil];
}

#pragma mark Single values
+ (null_unspecified instancetype)findOrCreateObjectByKey:(NSString *)key
                                             objectValue:(nullable NSObject *)objectValue
                                  inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectByKey:key
                             objectValue:objectValue
                  inManagedObjectContext:context
                               withError:nil];
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

#pragma mark Key/value dict methods
+ (null_unspecified instancetype)findOrCreateObjectByKeyObjectDictionary:(FFCDKeyObjectsDictionary *)keyObjectDictionary
                                                  inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectByKeyObjectDictionary:keyObjectDictionary
                                  inManagedObjectContext:context
                                               withError:nil];
}

+ (null_unspecified instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                            byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                           inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:keyObjectDictionary
                           inManagedObjectContext:context
                                        withError:nil];
}

@end

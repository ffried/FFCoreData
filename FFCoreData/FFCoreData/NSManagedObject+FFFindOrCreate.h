//
//  NSManagedObject+FFCDFindAndOrCreate.h
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

@import Foundation;
@import CoreData;
#import <FFCoreData/NSManagedObject+FFFindAndOrCreateTypes.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Some useful find or create extensions to NSManagedObject.
 *  @see NSManagedObject
 */
@interface NSManagedObject (FFFindOrCreate)

#pragma mark - Singleton objects
/**
 *  Finds or creates an object in a given managed object context and the class name as entity.
 *  @param context The context in which to search/create the object
 *  @param error   A pointer to a NSError in which to save any error.
 *  @return The singleton object or nil if an error occurred.
 */
+ (nullable instancetype)findOrCreateObjectInManagedObjectContext:(NSManagedObjectContext *)context
                                                        withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Finds or creates an object with a given entity in a given managed object context.
 *  @param entityName The entity of the object.
 *  @param context    The context in which to search/create the object.
 *  @param error      A pointer to a NSError in which to save any error.
 *  @return The singleton object or nil if an error occurred.
 */
+ (nullable __kindof NSManagedObject *)findOrCreateObjectWithEntityName:(NSString *)entityName
                                                 inManagedObjectContext:(NSManagedObjectContext *)context
                                                              withError:(NSError * __autoreleasing _Nullable *)error;


#pragma mark - Single values
/**
 *  Finds or creates an object with a given objectvalue for a given key in a given managed object context and the class as entity name.
 *  @param key         The key of the objectvalue to match.
 *  @param objectValue The objectvalue of the key.
 *  @param context     The context in which to search/create the object.
 *  @param error       A pointer to a NSError in which to save any error.
 *  @return The found/created object or nil if an error occurred.
 */
+ (nullable instancetype)findOrCreateObjectByKey:(NSString *)key
                                     objectValue:(nullable NSObject *)objectValue
                          inManagedObjectContext:(NSManagedObjectContext *)context
                                       withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Finds or creates an object with a given objectvalue for a given key and a given entity in a given managed object context.
 *  @param entityName  The entity of the object.
 *  @param key         The key of the objectvalue to match.
 *  @param objectValue The objectvalue of the key.
 *  @param context     The context in which to search/create the object.
 *  @param error       A pointer to a NSError in which to save any error.
 *  @return The found/created object or nil if an error occurred.
 */
+ (nullable __kindof NSManagedObject *)findOrCreateObjectWithEntityName:(NSString *)entityName
                                                                  byKey:(NSString *)key
                                                            objectValue:(nullable NSObject *)objectValue
                                                 inManagedObjectContext:(NSManagedObjectContext *)context
                                                              withError:(NSError * __autoreleasing _Nullable *)error;

#pragma mark - Multiple values
/**
 *  Finds or creates an object with given keys/objectvalues in a given managed object context with the class as entity.
 *  @param keyObjectDictionary The keys/objectvalues of the object to search/create.
 *  @param context             The context in which to search/create the object.
 *  @param error               A pointer to a NSError in which to save any error.
 *  @return The found/created object or nil if an error occurred.
 */
+ (nullable instancetype)findOrCreateObjectByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                          inManagedObjectContext:(NSManagedObjectContext *)context
                                                       withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Finds or creates an object with a given entity and given keys/objectvalues in a given managed object context.
 *
 *  @param entityName          The entity of the object.
 *  @param keyObjectDictionary The keys/objectvalues of the object to search/create.
 *  @param context             The context in which to search/create the object.
 *  @param error               A pointer to a NSError in which to save any error.
 *  @return The found/created object or nil if an error occurred.
 */
+ (nullable __kindof NSManagedObject *)findOrCreateObjectWithEntityName:(NSString *)entityName
                                                  byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                                 inManagedObjectContext:(NSManagedObjectContext *)context
                                                              withError:(NSError * __autoreleasing _Nullable *)error;

@end

NS_ASSUME_NONNULL_END

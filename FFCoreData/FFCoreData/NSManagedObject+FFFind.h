//
//  NSManagedObject+FFFind.h
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

@import Foundation;
@import CoreData;
#import <FFCoreData/NSManagedObject+FFFindAndOrCreateTypes.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Some useful find extensions to NSManagedObject.
 *  @see NSManagedObject
 */
@interface NSManagedObject (FFFind)

#pragma mark - All objects
/**
 *  Finds all objects in a given context and the class name as entity name.
 *  @param context The context in which to search.
 *  @param error   A pointer to a NSError in which to store any error.
 *  @return An array containing all objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)allObjectsInContext:(NSManagedObjectContext *)context
                                             withError:(NSError * __autoreleasing _Nullable *)error;
/**
 *  Finds all objects of a given entity in a given context.
 *  @param entity  The entity of which to fetch all objects.
 *  @param context The context in which to search.
 *  @param error   A pointer to a NSError in which to store any error.
 *  @return An array containing all objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)allObjectsWithEntity:(NSString *)entity
                                              inContext:(NSManagedObjectContext *)context
                                              withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Finds all objects in a given context and the class name as entity name.
 *  @param sortDescriptors An array of sort descriptors to use.
 *  @param context         The context in which to search.
 *  @param error           A pointer to a NSError in which to store any error.
 *  @return An array containing all objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)allObjectsSortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                            inContext:(NSManagedObjectContext *)context
                                            withError:(NSError * __autoreleasing _Nullable *)error;
/**
 *  Finds all objects of a given entity in a given context.
 *  @param entity          The entity of which to fetch all objects.
 *  @param sortDescriptors An array of sort descriptors to use.
 *  @param context         The context in which to search.
 *  @param error           A pointer to a NSError in which to store any error.
 *  @return An array containing all objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)allObjectsWithEntity:(NSString *)entity
                                               sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                              inContext:(NSManagedObjectContext *)context
                                              withError:(NSError * __autoreleasing _Nullable *)error;

#pragma mark - Single values
/**
 *  Find objects by a key and an objectValue in a given context and the class name as entity.
 *  @param key         The key to which to match the objectvalue.
 *  @param objectValue The objectValue for the given key.
 *  @param context     The context in which to search.
 *  @param error       A pointer to a NSError in which to save any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsByKey:(NSString *)key
                                        objectValue:(nullable NSObject *)objectValue
                             inManagedObjectContext:(NSManagedObjectContext *)context
                                          withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Find objects of a given entity by a key and an objectValue in a given context.
 *  @param entityName  The entity of which to search instances.
 *  @param key         The key to which to match the objectvalue.
 *  @param objectValue The objectValue for the given key.
 *  @param context     The context in which to search.
 *  @param error       A pointer to a NSError in which to save any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                                       byKey:(NSString *)key
                                                 objectValue:(nullable NSObject *)objectValue
                                      inManagedObjectContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Find objects by a key and an objectValue in a given context and the class name as entity.
 *  @param key             The key to which to match the objectvalue.
 *  @param objectValue     The objectValue for the given key.
 *  @param sortDescriptors An array of sort descriptors to use.
 *  @param context         The context in which to search.
 *  @param error           A pointer to a NSError in which to save any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsByKey:(NSString *)key
                                        objectValue:(nullable NSObject *)objectValue
                                           sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                             inManagedObjectContext:(NSManagedObjectContext *)context
                                          withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Find objects of a given entity by a key and an objectValue in a given context.
 *  @param entityName      The entity of which to search instances.
 *  @param key             The key to which to match the objectvalue.
 *  @param objectValue     The objectValue for the given key.
 *  @param sortDescriptors An array of sort descriptors to use.
 *  @param context         The context in which to search.
 *  @param error           A pointer to a NSError in which to save any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                                       byKey:(NSString *)key
                                                 objectValue:(nullable NSObject *)objectValue
                                                    sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                      inManagedObjectContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error;

#pragma mark - Multiple values
/**
 *  Find objects by a key/objectValue dictionary in a given context and the class name as entity name.
 *  @param keyObjectDictionary The dictionary containing keys and objects to match.
 *  @param context             The context in which to search.
 *  @param error               A pointer to a NSError in which to save any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                             inManagedObjectContext:(NSManagedObjectContext *)context
                                                          withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Find objects of a given entity by a key/objectValue dictionary in a given context.
 *  @param entityName          The entity of which to search objects.
 *  @param keyObjectDictionary The dictionary containing keys and objects to match.
 *  @param context             The context in which to search.
 *  @param error               A pointer to a NSError in which to save any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                       byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                      inManagedObjectContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Find objects by a key/objectValue dictionary in a given context and the class name as entity name.
 *  @param keyObjectDictionary The dictionary containing keys and objects to match.
 *  @param sortDescriptors     An array of sort descriptors to use.
 *  @param context             The context in which to search.
 *  @param error               A pointer to a NSError in which to save any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                                           sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                             inManagedObjectContext:(NSManagedObjectContext *)context
                                                          withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Find objects of a given entity by a key/objectValue dictionary in a given context.
 *  @param entityName          The entity of which to search objects.
 *  @param keyObjectDictionary The dictionary containing keys and objects to match.
 *  @param sortDescriptors     An array of sort descriptors to use.
 *  @param context             The context in which to search.
 *  @param error               A pointer to a NSError in which to save any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                       byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                                    sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                      inManagedObjectContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error;

#pragma mark - Predicates
/**
 *  Finds objects using a predicate in a given context and the class name as entity name.
 *  @param predicate The predicate to use for the fetch request.
 *  @param context   The context in which to search.
 *  @param error     A pointer to a NSError in which to store any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsByUsingPredicate:(nullable NSPredicate *)predicate
                                                     inContext:(NSManagedObjectContext *)context
                                                     withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Finds objects of a given entity using a predicate in a given context.
 *  @param entityName The entity of which to search objects.
 *  @param predicate  The predicate to use for the fetch request.
 *  @param context    The context in which to search.
 *  @param error      A pointer to a NSError in which to store any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                            byUsingPredicate:(nullable NSPredicate *)predicate
                                                   inContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error;
/**
 *  Finds objects using a predicate in a given context and the class name as entity name.
 *  @param predicate       The predicate to use for the fetch request.
 *  @param sortDescriptors An array of sort descriptors to use.
 *  @param context         The context in which to search.
 *  @param error           A pointer to a NSError in which to store any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsByUsingPredicate:(nullable NSPredicate *)predicate
                                                      sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                                     inContext:(NSManagedObjectContext *)context
                                                     withError:(NSError * __autoreleasing _Nullable *)error;

/**
 *  Finds objects of a given entity using a predicate in a given context.
 *  @param entityName      The entity of which to search objects.
 *  @param predicate       The predicate to use for the fetch request.
 *  @param sortDescriptors An array of sort descriptors to use.
 *  @param context         The context in which to search.
 *  @param error           A pointer to a NSError in which to store any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                            byUsingPredicate:(nullable NSPredicate *)predicate
                                                    sortedBy:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
                                                   inContext:(NSManagedObjectContext *)context
                                                   withError:(NSError * __autoreleasing _Nullable *)error;

@end

NS_ASSUME_NONNULL_END

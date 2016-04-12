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

NS_ASSUME_NONNULL_BEGIN

typedef NSArray<__kindof NSManagedObject *> FFCDCollectionResult;
typedef NSDictionary<NSString *, id> FFCDKeyObjectsDictionary;

/**
 *  Some useful find and/or create extensions to NSManagedObject.
 *  @see NSManagedObject
 */
@interface NSManagedObject (FFCDFindAndOrCreate)

#pragma mark - Entity
/**
 * Tries to guess the entity name by using the class name. For Swift the module is removed by splitting by "." and using the last part.
 * @return The entity name according to the class name.
 */
+ (NSString *)entityName;

#pragma mark - Just create
/**
 *  Creates a managed object in a given managed object context with the class name as entity name.
 *  @param context The context in which to create the managed object.
 *  @return The new managed object instance or nil if an error occured.
 */
+ (instancetype)createObjectInManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Creates a managed object with a given entity name in a given managed object context.
 *  @param entityName The entity name of the new managed object.
 *  @param context    The context in which to create the managed object.
 *  @return The new managed object instance or nil if an error occured.
 */
+ (__kindof NSManagedObject *)createObjectWithEntityName:(NSString *)entityName
                                  inManagedObjectContext:(NSManagedObjectContext *)context;

#pragma mark - Just find
#pragma mark All objects
/**
 *  Finds all objects in a given context and the class name as entity name.
 *  @param context The context in which to search.
 *  @return An array containing all objects (may be empty) or an empty array if an error occurred.
 */
+ (FFCDCollectionResult *)allObjectsInContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
/**
 *  Finds all objects in a given context and the class name as entity name.
 *  @param context The context in which to search.
 *  @param error   A pointer to a NSError in which to store any error.
 *
 *  @return An array containing all objects (may be empty) or nil if an error occurred.
 */
+ (nullable FFCDCollectionResult *)allObjectsInContext:(NSManagedObjectContext *)context
                                             withError:(NSError * __autoreleasing _Nullable *)error;
/**
 *  Finds all objects of a given entity in a given context.
 *  @param entity  The entity of which to fetch all objects.
 *  @param context The context in which to search.
 *  @return An array containing all objects (may be empty) or an empty array if an error occurred.
 */
+ (FFCDCollectionResult *)allObjectsWithEntity:(NSString *)entity
                                     inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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

#pragma mark Single values
/**
 *  Find objects by a key and an objectValue in a given context and the class name as entity.
 *  @param key         The key to which to match the objectvalue.
 *  @param objectValue The objectValue for the given key.
 *  @param context     The context in which to search.
 *  @return An array of found objects (may be empty) or an empty array if an error occurred.
 */
+ (FFCDCollectionResult *)findObjectsByKey:(NSString *)key
                               objectValue:(nullable NSObject *)objectValue
                    inManagedObjectContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");

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
 *  @return An array of found objects (may be empty) or an empty array if an error occurred.
 */
+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                              byKey:(NSString *)key
                                        objectValue:(nullable NSObject *)objectValue
                             inManagedObjectContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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

#pragma mark Multiple values
/**
 *  Find objects by a key/objectValue dictionary in a given context and the class name as entity name.
 *  @param keyObjectDictionary The dictionary containing keys and objects to match.
 *  @param context             The context in which to search.
 *  @return An array of found objects (may be empty) or an empty array if an error occurred.
 */
+ (FFCDCollectionResult *)findObjectsByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                    inManagedObjectContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");

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
 *  @return An array of found objects (may be empty) or an empty array if an error occurred.
 */
+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                              byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                             inManagedObjectContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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

#pragma mark Predicates
/**
 *  Finds objects using a predicate in a given context and the class name as entity name.
 *  @param predicate The predicate to use for the fetch request.
 *  @param context   The context in which to search.
 *  @return An array of found objects (may be empty) or an empty array if an error occurred.
 */
+ (FFCDCollectionResult *)findObjectsByUsingPredicate:(nullable NSPredicate *)predicate
                                            inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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
 *  @return An array of found objects (may be empty) or an empty array if an error occurred.
 */
+ (FFCDCollectionResult *)findObjectsWithEntityName:(NSString *)entityName
                                   byUsingPredicate:(nullable NSPredicate *)predicate
                                          inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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

#pragma mark - Find or Create
#pragma mark Singleton objects
/**
 *  Finds or creates an object in a given managed object context and the class name as entity.
 *  @param context The context in which to search/create the object
 *  @return The singleton object or nil if an error occurred.
 */
+ (null_unspecified instancetype)findOrCreateObjectInManagedObjectContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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
 *  @return The singleton object or nil if an error occurred.
 */
+ (null_unspecified __kindof NSManagedObject *)findOrCreateObjectWithEntityName:(NSString *)entityName
                                                         inManagedObjectContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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


#pragma mark Single values
/**
 *  Finds or creates an object with a given objectvalue for a given key in a given managed object context and the class as entity name.
 *  @param key         The key of the objectvalue to match.
 *  @param objectValue The objectvalue of the key.
 *  @param context     The context in which to search/create the object.
 *  @return The found/created object or nil if an error occurred.
 */
+ (null_unspecified instancetype)findOrCreateObjectByKey:(NSString *)key
                                             objectValue:(nullable NSObject *)objectValue
                                  inManagedObjectContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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
 *  @return The found/created object or nil if an error occurred.
 */
+ (null_unspecified __kindof NSManagedObject *)findOrCreateObjectWithEntityName:(NSString *)entityName
                                                                          byKey:(NSString *)key
                                                                    objectValue:(nullable NSObject *)objectValue
                                                         inManagedObjectContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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

#pragma mark Multiple values
/**
 *  Finds or creates an object with given keys/objectvalues in a given managed object context with the class as entity.
 *  @param keyObjectDictionary The keys/objectvalues of the object to search/create.
 *  @param context             The context in which to search/create the object.
 *  @return The found/created object or nil if an error occurred.
 */
+ (null_unspecified instancetype)findOrCreateObjectByKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary

                                                  inManagedObjectContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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
 *  @return The found/created object or nil if an error occurred.
 */
+ (null_unspecified __kindof NSManagedObject *)findOrCreateObjectWithEntityName:(NSString *)entityName
                                                          byKeyObjectDictionary:(nullable FFCDKeyObjectsDictionary *)keyObjectDictionary
                                                         inManagedObjectContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use throwing method");
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

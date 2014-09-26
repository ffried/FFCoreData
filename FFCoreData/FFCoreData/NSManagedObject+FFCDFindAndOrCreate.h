//
//  NSManagedObject+FFCDFindAndOrCreate.h
//  FFCoreData
//
//  Created by Florian Friedrich on 15.12.13.
//  Copyright (c) 2013 Florian Friedrich. All rights reserved.
//

@import Foundation;
@import CoreData.NSManagedObject;
@class NSManagedObjectContext;

// Defines
#ifndef kNSManagedObjectFFCDFindOrCreateCrashOnError
#if DEBUG
    #define kNSManagedObjectFFCDFindOrCreateCrashOnError YES
#else
    #define kNSManagedObjectFFCDFindOrCreateCrashOnError NO
#endif
#endif

#ifndef kNSManagedObjectFFCDFindOrCreateDefaultCombineAction
    #define kNSManagedObjectFFCDFindOrCreateDefaultCombineAction @"AND"
#endif

/**
 *  Some useful find and/or create extensions to NSManagedObject.
 *  @see NSManagedObject
 */
@interface NSManagedObject (FFCDFindAndOrCreate)

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
+ (instancetype)createObjectWithEntityName:(NSString *)entityName
                    inManagedObjectContext:(NSManagedObjectContext *)context;

#pragma mark - Just find
// Single values
/**
 *  Find objects by a key and an objectValue in a given context and the class name as entity.
 *  @param key         The key to which to match the objectvalue.
 *  @param objectValue The objectValue for the given key.
 *  @param context     The context in which to search.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (NSArray *)findObjectsByKey:(NSString *)key
                  objectValue:(NSObject *)objectValue
       inManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Find objects of a given entity by a key and an objectValue in a given context.
 *  @param entityName  The entity of which to search instances.
 *  @param key         The key to which to match the objectvalue.
 *  @param objectValue The objectValue for the given key.
 *  @param context     The context in which to search.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (NSArray *)findObjectsWithEntityName:(NSString *)entityName
                                 byKey:(NSString *)key
                           objectValue:(NSObject *)objectValue
                inManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Find objects of a given entity by a key and an objectValue in a given context.
 *  @param entityName  The entity of which to search instances.
 *  @param key         The key to which to match the objectvalue.
 *  @param objectValue The objectValue for the given key.
 *  @param context     The context in which to search.
 *  @param error       A pointer to a NSError in which to save any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (NSArray *)findObjectsWithEntityName:(NSString *)entityName
                                 byKey:(NSString *)key
                           objectValue:(NSObject *)objectValue
                inManagedObjectContext:(NSManagedObjectContext *)context
                             withError:(NSError *__autoreleasing *)error;

// Multiple values
/**
 *  Find objects by a key/objectValue dictionary in a given context and the class name as entity name.
 *  @param keyObjectDictionary The dictionary containing keys and objects to match.
 *  @param context             The context in which to search.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (NSArray *)findObjectsByKeyObjectValue:(NSDictionary *)keyObjectDictionary
                  inManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Find objects of a given entity by a key/objectValue dictionary in a given context.
 *  @param entityName          The entity of which to search objects.
 *  @param keyObjectDictionary The dictionary containing keys and objects to match.
 *  @param context             The context in which to search.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (NSArray *)findObjectsWithEntityName:(NSString *)entityName
                 byKeyObjectDictionary:(NSDictionary *)keyObjectDictionary
                inManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Find objects of a given entity by a key/objectValue dictionary in a given context.
 *  @param entityName          The entity of which to search objects.
 *  @param keyObjectDictionary The dictionary containing keys and objects to match.
 *  @param context             The context in which to search.
 *  @param error               A pointer to a NSError in which to save any error.
 *  @return An array of found objects (may be empty) or nil if an error occurred.
 */
+ (NSArray *)findObjectsWithEntityName:(NSString *)entityName
                 byKeyObjectDictionary:(NSDictionary *)keyObjectDictionary
                inManagedObjectContext:(NSManagedObjectContext *)context
                             withError:(NSError *__autoreleasing *)error;

#pragma mark - Find or Create
// Singleton objects
/**
 *  Finds or creates an object in a given managed object context and the class name as entity.
 *  @param context The context in which to search/create the object
 *  @return The singleton object or nil if an error occurred.
 */
+ (instancetype)findOrCreateObjectInManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Finds or creates an object with a given entity in a given managed object context.
 *  @param entityName The entity of the object.
 *  @param context    The context in which to search/create the object.
 *  @return The singleton object or nil if an error occurred.
 */
+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                          inManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Finds or creates an object with a given entity in a given managed object context.
 *  @param entityName The entity of the object.
 *  @param context    The context in which to search/create the object.
 *  @param error      A pointer to a NSError in which to save any error.
 *  @return The singleton object or nil if an error occurred.
 */
+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                          inManagedObjectContext:(NSManagedObjectContext *)context
                                       withError:(NSError *__autoreleasing *)error;


// Single values
/**
 *  Finds or creates an object with a given objectvalue for a given key in a given managed object context and the class as entity name.
 *  @param key         The key of the objectvalue to match.
 *  @param objectValue The objectvalue of the key.
 *  @param context     The context in which to search/create the object.
 *  @return The found/created object or nil if an error occurred.
 */
+ (instancetype)findOrCreateObjectByKey:(NSString *)key
                            objectValue:(NSObject *)objectValue
                 inManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Finds or creates an object with a given objectvalue for a given key and a given entity in a given managed object context.
 *  @param entityName  The entity of the object.
 *  @param key         The key of the objectvalue to match.
 *  @param objectValue The objectvalue of the key.
 *  @param context     The context in which to search/create the object.
 *  @return The found/created object or nil if an error occurred.
 */
+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                           byKey:(NSString *)key
                                     objectValue:(NSObject *)objectValue
                          inManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Finds or creates an object with a given objectvalue for a given key and a given entity in a given managed object context.
 *  @param entityName  The entity of the object.
 *  @param key         The key of the objectvalue to match.
 *  @param objectValue The objectvalue of the key.
 *  @param context     The context in which to search/create the object.
 *  @param error       A pointer to a NSError in which to save any error.
 *  @return The found/created object or nil if an error occurred.
 */
+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                                           byKey:(NSString *)key
                                     objectValue:(NSObject *)objectValue
                          inManagedObjectContext:(NSManagedObjectContext *)context
                                       withError:(NSError *__autoreleasing *)error;

// Multiple values
/**
 *  Finds or creates an object with given keys/objectvalues in a given managed object context with the class as entity.
 *  @param keyObjectDictionary The keys/objectvalues of the object to search/create.
 *  @param context             The context in which to search/create the object.
 *  @return The found/created object or nil if an error occurred.
 */
+ (instancetype)findOrCreateObjectByKeyObjectDictionary:(NSDictionary *)keyObjectDictionary
                                 inManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Finds or creates an object with a given entity and given keys/objectvalues in a given managed object context.
 *
 *  @param entityName          The entity of the object.
 *  @param keyObjectDictionary The keys/objectvalues of the object to search/create.
 *  @param context             The context in which to search/create the object.
 *  @return The found/created object or nil if an error occurred.
 */
+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                           byKeyObjectDictionary:(NSDictionary *)keyObjectDictionary
                          inManagedObjectContext:(NSManagedObjectContext *)context;
/**
 *  Finds or creates an object with a given entity and given keys/objectvalues in a given managed object context.
 *
 *  @param entityName          The entity of the object.
 *  @param keyObjectDictionary The keys/objectvalues of the object to search/create.
 *  @param context             The context in which to search/create the object.
 *  @param error               A pointer to a NSError in which to save any error.
 *  @return The found/created object or nil if an error occurred.
 */
+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                           byKeyObjectDictionary:(NSDictionary *)keyObjectDictionary
                          inManagedObjectContext:(NSManagedObjectContext *)context
                                       withError:(NSError *__autoreleasing *)error;

@end

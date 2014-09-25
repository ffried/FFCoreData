//
//  NSManagedObject+FFCDFindAndOrCreate.m
//  FFCoreData
//
//  Created by Florian Friedrich on 15.12.13.
//  Copyright (c) 2013 Florian Friedrich. All rights reserved.

#import "NSManagedObject+FFCDFindAndOrCreate.h"

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
#pragma mark Single values
+ (NSArray *)findObjectsByKey:(NSString *)key
                  objectValue:(NSObject *)objectValue
       inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsByKeyObjectValue:@{key: objectValue} inManagedObjectContext:context];
}

+ (NSArray *)findObjectsWithEntityName:(NSString *)entityName
                                 byKey:(NSString *)key
                           objectValue:(NSObject *)objectValue
                inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:@{key: objectValue}
                    inManagedObjectContext:context];
}

+ (NSArray *)findObjectsWithEntityName:(NSString *)entityName
                                 byKey:(NSString *)key
                           objectValue:(NSObject *)objectValue
                inManagedObjectContext:(NSManagedObjectContext *)context
                             withError:(NSError *__autoreleasing *)error {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:@{key: objectValue}
                    inManagedObjectContext:context
                                 withError:error];
}

#pragma mark Multiple values
+ (NSArray *)findObjectsByKeyObjectValue:(NSDictionary *)keyObjectDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:NSStringFromClass(self)
                     byKeyObjectDictionary:keyObjectDictionary
                    inManagedObjectContext:context];
}

+ (NSArray *)findObjectsWithEntityName:(NSString *)entityName
                 byKeyObjectDictionary:(NSDictionary *)keyObjectDictionary
                inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findObjectsWithEntityName:entityName
                     byKeyObjectDictionary:keyObjectDictionary
                    inManagedObjectContext:context
                                 withError:nil];
}

+ (NSArray *)findObjectsWithEntityName:(NSString *)entityName
                 byKeyObjectDictionary:(NSDictionary *)keyObjectDictionary
                inManagedObjectContext:(NSManagedObjectContext *)context
                             withError:(NSError *__autoreleasing *)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    if (keyObjectDictionary) {
        NSMutableString *formatString = [[NSMutableString alloc] init];
        NSMutableArray *argumentArray = [[NSMutableArray alloc] init];
        
        [keyObjectDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            if (formatString.length > 0) {
                [formatString appendFormat:@" %@ ", kNSManagedObjectFFCDFindOrCreateDefaultCombineAction];
            }
            [formatString appendString:[NSString stringWithFormat:@"%@ == %@", key, @"%@"]];
            [argumentArray addObject:obj];
        }];
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:formatString.copy
                                                    argumentArray:argumentArray.copy];
    }
    
    __autoreleasing NSError *localError = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&localError];
    if (!fetchedObjects && localError) {
        if (error != nil) error = &localError;
        
        FFLog(@"Error while executing findOrCreate fetch request: %@", localError);
#if kNSManagedObjectFFCDFindOrCreateCrashOnError
        abort();
#endif
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
                                       withError:(NSError *__autoreleasing *)error {
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
                                       withError:(NSError *__autoreleasing *)error {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:@{key: objectValue}
                           inManagedObjectContext:context
                                        withError:error];
}

#pragma mark Key/value dict methods
+ (instancetype)findOrCreateObjectByKeyObjectDictionary:(NSDictionary *)keyObjectDictionary
                                 inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:NSStringFromClass(self)
                            byKeyObjectDictionary:keyObjectDictionary
                           inManagedObjectContext:context];
}

+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                           byKeyObjectDictionary:(NSDictionary *)keyObjectDictionary
                          inManagedObjectContext:(NSManagedObjectContext *)context {
    return [self findOrCreateObjectWithEntityName:entityName
                            byKeyObjectDictionary:keyObjectDictionary
                           inManagedObjectContext:context
                                        withError:nil];
}

+ (instancetype)findOrCreateObjectWithEntityName:(NSString *)entityName
                           byKeyObjectDictionary:(NSDictionary *)keyObjectDictionary
                          inManagedObjectContext:(NSManagedObjectContext *)context
                                       withError:(NSError *__autoreleasing *)error {
    NSArray *fetchedObjects = [self findObjectsWithEntityName:entityName
                                        byKeyObjectDictionary:keyObjectDictionary
                                       inManagedObjectContext:context withError:error];
    
    NSManagedObject *managedObject;
    if (fetchedObjects && fetchedObjects.count > 0) {
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

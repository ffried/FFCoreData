//
//  NSManagedObject+FFCreate.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 *  Some useful create extensions to NSManagedObject.
 *  @see NSManagedObject
 */
@interface NSManagedObject (FFCreate)

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

@end

NS_ASSUME_NONNULL_END

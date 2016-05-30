//
//  NSManagedObject+FFEntity.h
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
 *  Adds the entity as class property.
 *  @see NSManagedObject
 */
@interface NSManagedObject (FFEntity)

#pragma mark - Entity
/**
 * Tries to guess the entity name by using the class name. For Swift the module is removed by splitting by "." and using the last part.
 * @return The entity name according to the class name.
 */
+ (NSString *)entityName;

#pragma mark - Namespace
/**
 *  Whether or not the namespace should be removed when converting the class name to the entity name.
 *  @note This only affects Swift projects.
 *  @return `YES` if the namespace should be removed. `NO` otherwise.
 */
+ (BOOL)shouldRemoveNamespaceInEntityName;
/**
 *  Set whether or not the namespace should be removed when converting the class name to the entity name.
 *  @note: This only affects Swift projects.
 *  @param shouldRemove `YES` if the namespace should be removed. `NO` otherwise.
 */
+ (void)setShouldRemoveNamespaceInEntityName:(BOOL)shouldRemove;

@end

NS_ASSUME_NONNULL_END

//
//  MOCEntitiesObserver.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 24.1.15.
//  Copyright 2015 Florian Friedrich
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

import Foundation
import CoreData

public final class MOCEntitiesObserver: MOCObserver {
    public var entityNames: [String]
    
    public required init(entityNames: [String], contexts: [NSManagedObjectContext]? = nil, fireInitially: Bool = false, block: MOCObserverBlock) {
        self.entityNames = entityNames
        super.init(contexts: contexts, fireInitially: fireInitially, block: block)
    }
    
    public convenience init(entities: [NSEntityDescription], contexts: [NSManagedObjectContext]? = nil, fireInitially: Bool = false, block: MOCObserverBlock) {
        self.init(entityNames: entities.map { return $0.name ?? $0.managedObjectClassName }, contexts: contexts, fireInitially: fireInitially, block: block)
    }
    
    override func includeManagedObject(object: NSManagedObject) -> Bool {
        return entityNames.contains((object.entity.name ?? object.entity.managedObjectClassName))
    }
}

public extension NSManagedObject {
    public static func createMOCEntitiesObserver(contexts: [NSManagedObjectContext]? = nil, fireInitially: Bool = false, block: MOCObserver.MOCObserverBlock) -> MOCEntitiesObserver {
        return MOCEntitiesObserver(entityNames: [entityName()], contexts: contexts, fireInitially: fireInitially, block: block)
    }
}


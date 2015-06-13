//
//  MOCEntitiesObserver.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 24.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFCoreData

public class MOCEntitiesObserver: MOCObserver {
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
    public static func createMOCEntitiesObserver(fireInitially: Bool = false, block: MOCObserver.MOCObserverBlock) -> MOCEntitiesObserver {
        return createMOCEntitiesObserver(fireInitially, contexts: nil, block: block)
    }
    
    public static func createMOCEntitiesObserver(fireInitially: Bool = false, contexts: [NSManagedObjectContext]? = nil, block: MOCObserver.MOCObserverBlock) -> MOCEntitiesObserver {
        var className = NSStringFromClass(self)
        if let range = className.rangeOfString(".", options: .BackwardsSearch) { // Fix Swift class names
            className = className.substringFromIndex(range.endIndex)
        }
        return MOCEntitiesObserver(entityNames: [className], contexts: contexts, fireInitially: fireInitially, block: block)
    }
}


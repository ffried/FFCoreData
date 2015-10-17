//
//  NSManagedObject+FindAndOrCreate.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 13/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

import FFCoreData

internal extension NSManagedObject {
    internal static func entityInContext(context: NSManagedObjectContext) -> NSEntityDescription? {
        return entityWithName(StringFromClass(self), inContext: context)
    }
    
    internal static func entityWithName(name: String, inContext context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(name, inManagedObjectContext: context)
    }
}

public extension NSManagedObject {
    public typealias FindAndOrCreateResult = NSManagedObject
    public typealias KeyObjectDictionary = [String: NSObject]
    
    // MARK: Create
    public static func createInManagedObjectContext(context: NSManagedObjectContext) -> Self {
        return self(entity: entityInContext(context)!, insertIntoManagedObjectContext: context)
    }
    
    public static func allObjectsInContext(context: NSManagedObjectContext) throws -> [FindAndOrCreateResult] {
        return try findObjectsInManagedObjectContext(context)
    }
    
    public static func findObjectsInManagedObjectContext(context: NSManagedObjectContext, byUsingKeyObjectDictionary dictionary: KeyObjectDictionary?) throws -> [FindAndOrCreateResult] {
        var predicate: NSPredicate? = nil
        if let dict = dictionary {
            var subPredicates = [NSPredicate]()
            for (key, value) in dict {
                let predicate = NSPredicate(format: "%K == %@", key, value)
                subPredicates.append(predicate)
            }
            predicate = NSCompoundPredicate.andPredicateWithSubpredicates(subPredicates)
        }
        return try findObjectsInManagedObjectContext(context, byUsingPredicate: predicate)
    }
    
    public static func findObjectsInManagedObjectContext(context: NSManagedObjectContext, byUsingPredicate predicate: NSPredicate? = nil) throws -> [FindAndOrCreateResult] {
        let entity = entityInContext(context)!.name!
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.predicate = predicate
        return try context.executeFetchRequest(fetchRequest) as! [FindAndOrCreateResult]
    }
    
    public static func findOrCreateObjectInManagedObjectContext(context: NSManagedObjectContext, byKeyObjectDictionary dictionary: KeyObjectDictionary? = nil) throws -> FindAndOrCreateResult {
        let foundObjects = try findObjectsInManagedObjectContext(context, byUsingKeyObjectDictionary: dictionary)
        let object = foundObjects.first ?? createInManagedObjectContext(context)
        if let dict = dictionary {
            for (key, value) in dict {
                if let id = value as? NSManagedObjectID {
                    object.setValue(context.objectWithID(id), forKey: key)
                } else {
                    object.setValue(value, forKey: key)
                }
            }
        }
        return object
    }
}

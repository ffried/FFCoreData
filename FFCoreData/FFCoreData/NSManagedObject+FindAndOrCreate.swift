//
//  NSManagedObject+FindAndOrCreate.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 13/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

import Foundation
import CoreData


//public protocol FindOrCreatable: class {
//    // MARK: Create
//    static func createInManagedObjectContext(context: NSManagedObjectContext) -> Self
//    
//    static func allObjectsInContext(context: NSManagedObjectContext) throws -> [Self]
//    
//    static func findObjectsInManagedObjectContext(context: NSManagedObjectContext, byUsingKeyObjectDictionary dictionary: KeyObjectDictionary?) throws -> [Self]
//    
//    static func findObjectsInManagedObjectContext(context: NSManagedObjectContext, byUsingPredicate predicate: NSPredicate?) throws -> [Self]
//    
//    static func findOrCreateObjectInManagedObjectContext(context: NSManagedObjectContext, byKeyObjectDictionary dictionary: KeyObjectDictionary?) throws -> Self
//}

internal extension NSManagedObject {
    internal static func entityInContext(context: NSManagedObjectContext) -> NSEntityDescription? {
        return entityWithName(StringFromClass(self), inContext: context)
    }
    
    internal static func entityWithName(name: String, inContext context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(name, inManagedObjectContext: context)
    }
}

extension NSManagedObject {
    public typealias KeyObjectDictionary = [String: AnyObject]
    public typealias FindOrCreateResult = NSManagedObject
    
    public static func allObjectsInContext(context: NSManagedObjectContext) throws -> [FindOrCreateResult] {
        return try findObjectsInManagedObjectContext(context)
    }
    
    public static func findObjectsInManagedObjectContext(context: NSManagedObjectContext, byUsingKeyObjectDictionary dictionary: KeyObjectDictionary?) throws -> [FindOrCreateResult] {
        var predicate: NSPredicate? = nil
        if let dict = dictionary {
            var subPredicates = [NSPredicate]()
            for (key, value) in dict {
                let predicate: NSPredicate
                if let obj = value as? NSObject {
                    predicate = NSPredicate(format: "%K == %@", key, obj)
                } else {
                    print("FFCoreData: A value which isn't an NSObject was used to create a predicate. Might go wrong!")
                    predicate = NSPredicate(format: "%K == \(value)", key)
                }
                subPredicates.append(predicate)
            }
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)
        }
        return try findObjectsInManagedObjectContext(context, byUsingPredicate: predicate)
    }
    
    public static func findObjectsInManagedObjectContext(context: NSManagedObjectContext, byUsingPredicate predicate: NSPredicate? = nil) throws -> [FindOrCreateResult] {
        let entity = entityInContext(context)!.name!
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.predicate = predicate
        return try context.executeFetchRequest(fetchRequest) as! [FindOrCreateResult]
    }
    
    public static func findOrCreateObjectInManagedObjectContext(context: NSManagedObjectContext, byKeyObjectDictionary dictionary: KeyObjectDictionary? = nil) throws -> FindOrCreateResult {
        let foundObjects = try findObjectsInManagedObjectContext(context, byUsingKeyObjectDictionary: dictionary)
        let object = foundObjects.first ?? createInManagedObjectContext(context)
//        if let managedObject = object as? NSManagedObject {
        if let dict = dictionary {
            for (key, value) in dict {
                if let id = value as? NSManagedObjectID {
                    object.setValue(context.objectWithID(id), forKey: key)
                } else {
                    object.setValue(value, forKey: key)
                }
            }
        }
//        }
        return object
    }

    // MARK: Create
    public static func createInManagedObjectContext(context: NSManagedObjectContext) -> FindOrCreateResult {
        return self.init(entity: entityInContext(context)!, insertIntoManagedObjectContext: context)
    }
}

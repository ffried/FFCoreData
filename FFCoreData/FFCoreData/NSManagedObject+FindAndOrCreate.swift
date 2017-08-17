//
//  NSManagedObject+FindAndOrCreate.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 13/06/15.
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
import FFFoundation

public typealias KeyObjectDictionary = [String: Any]

fileprivate extension Sequence where Iterator.Element == KeyObjectDictionary.Iterator.Element {
    func asPredicate(with compoundType: NSCompoundPredicate.LogicalType) -> NSCompoundPredicate {
        let subPredicates = map { (key, value) -> NSPredicate in
            let predicate: NSPredicate
            // The ReferenceConvertible objects currently need to use its reference type. Casting to NSObject should do the trick.
            if let obj: CVarArg = (value as? CVarArg) ?? (value as? ReferenceConvertible as? NSObject) {
                predicate = NSPredicate(format: "%K == %@", key, obj)
            } else {
                print("FFCoreData: The value for key \"\(key)\" is not a CVarArg. This predicate might go wrong!")
                predicate = NSPredicate(format: "%K == \(value)", key)
            }
            return predicate
        }
        return NSCompoundPredicate(type: compoundType, subpredicates: subPredicates)
    }
    
    func apply(to object: NSObject, in context: NSManagedObjectContext) {
        forEach { (key, value) in
            if let id = value as? NSManagedObjectID {
                object.setValue(context.object(with: id), forKey: key)
            } else {
                object.setValue(value, forKey: key)
            }
        }
    }
}

public protocol Fetchable: NSFetchRequestResult {
    static var entityName: String { get }
    
    static func fetchRequest() -> NSFetchRequest<Self>
}

public protocol FindOrCreatable: Fetchable {
    static func create(in context: NSManagedObjectContext, applying: KeyObjectDictionary?) throws -> Self
    
    static func find(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary) throws -> [Self]
    static func find(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary, sortedBy sortDescriptors: [NSSortDescriptor]) throws -> [Self]
    
    static func find(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> [Self]
    
    static func findOrCreate(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary?) throws -> Self
}

public extension Fetchable {
    static func fetchRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest(entityName: entityName)
    }
}

public extension Fetchable where Self: NSManagedObject {
    public static var entityName: String {
        return String(class: self, removeNamespace: shouldRemoveNamespaceInEntityName)
    }
}

internal extension Fetchable {
    internal static func entity(in context: NSManagedObjectContext) throws -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            throw FindOrCreatableError.invalidEntity(entityName: entityName)
        }
        return entity
    }
}

public extension FindOrCreatable {
    public static func create(in context: NSManagedObjectContext) throws -> Self {
        return try create(in: context, applying: nil)
    }
    
    public static func all(in context: NSManagedObjectContext) throws -> [Self] {
        return try find(in: context)
    }
    
    public static func find(in context: NSManagedObjectContext) throws -> [Self] {
        return try find(in: context, with: nil)
    }
    
    public static func find(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary) throws -> [Self] {
        return try find(in: context, with: dictionary.asPredicate(with: .and))
    }
    
    static func find(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary, sortedBy sortDescriptors: [NSSortDescriptor]) throws -> [Self] {
        return try find(in: context, with: dictionary.asPredicate(with: .and), sortedBy: sortDescriptors)
    }
    
    public static func find(in context: NSManagedObjectContext, with predicate: NSPredicate?) throws -> [Self] {
        return try find(in: context, with: predicate, sortedBy: nil)
    }
    
    static func find(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> [Self] {
        let request = fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return try context.fetch(request)
    }
    
    public static func findOrCreate(in context: NSManagedObjectContext) throws -> Self {
        return try findOrCreate(in: context, by: nil)
    }
}

public extension FindOrCreatable where Self: NSObject {
    public static func findOrCreate(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary?) throws -> Self {
        let foundObjects = try find(in: context, with: dictionary?.asPredicate(with: .and))
        let object = try foundObjects.first ?? create(in: context)
        dictionary?.apply(to: object, in: context)
        return object
    }
}

public extension FindOrCreatable where Self: NSManagedObject {
    public static func create(in context: NSManagedObjectContext, applying dictionary: KeyObjectDictionary?) throws -> Self {
        let obj = self.init(entity: try entity(in: context), insertInto: context)
        dictionary?.apply(to: obj, in: context)
        return obj
    }
}

internal extension NSManagedObject {
    @nonobjc internal static var shouldRemoveNamespaceInEntityName: Bool = true
}

public enum FindOrCreatableError: Error, CustomStringConvertible {
    case invalidEntity(entityName: String)
    
    public var description: String {
        switch self {
        case .invalidEntity(let entityName):
            return "Invalid entity with name \"\(entityName)\""
        }
    }
}

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

public extension NSPredicate {
    public convenience init(format: String, arguments: Any...) {
        self.init(format: format, argumentArray: arguments)
    }
}

fileprivate extension Sequence where Iterator.Element == KeyObjectDictionary.Iterator.Element {
    func asPredicate(with compoundType: NSCompoundPredicate.LogicalType) -> NSCompoundPredicate {
        return NSCompoundPredicate(type: compoundType, subpredicates: map {
            NSPredicate(format: "%K == %@", arguments: $0.key, $0.value)
        })
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

    static func findFirst(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary) throws -> Self?
    static func findFirst(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary, sortedBy sortDescriptors: [NSSortDescriptor]) throws -> Self?

    static func findFirst(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> Self?

    static func findOrCreate(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary?) throws -> Self
}

public extension Fetchable {
    public static func fetchRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest(entityName: entityName)
    }

    public static func fetchRequest(with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) -> NSFetchRequest<Self> {
        let fetchRequest = self.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        return fetchRequest
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
    
    public static func find(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> [Self] {
        return try context.fetch(fetchRequest(with: predicate, sortedBy: sortDescriptors))
    }

    public static func findFirst(in context: NSManagedObjectContext) throws -> Self? {
        return try findFirst(in: context, with: nil)
    }

    public static func findFirst(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary) throws -> Self? {
        return try findFirst(in: context, with: dictionary.asPredicate(with: .and))
    }

    static func findFirst(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary, sortedBy sortDescriptors: [NSSortDescriptor]) throws -> Self? {
        return try findFirst(in: context, with: dictionary.asPredicate(with: .and), sortedBy: sortDescriptors)
    }

    public static func findFirst(in context: NSManagedObjectContext, with predicate: NSPredicate?) throws -> Self? {
        return try findFirst(in: context, with: predicate, sortedBy: nil)
    }

    public static func findFirst(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> Self? {
        let request = fetchRequest(with: predicate, sortedBy: sortDescriptors)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    public static func findOrCreate(in context: NSManagedObjectContext) throws -> Self {
        return try findOrCreate(in: context, by: nil)
    }
}

public extension FindOrCreatable where Self: NSManagedObject {
    public static func create(in context: NSManagedObjectContext, applying dictionary: KeyObjectDictionary?) throws -> Self {
        let obj = self.init(entity: try entity(in: context), insertInto: context)
        dictionary?.apply(to: obj, in: context)
        return obj
    }

    public static func findOrCreate(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary?) throws -> Self {
        let foundObject = try findFirst(in: context, with: dictionary?.asPredicate(with: .and))
        return try foundObject ?? create(in: context, applying: dictionary)
    }
}

internal extension NSManagedObject {
    @nonobjc internal static var shouldRemoveNamespaceInEntityName: Bool = true
}

public enum FindOrCreatableError: Error, Equatable, CustomStringConvertible {
    case invalidEntity(entityName: String)
    
    public var description: String {
        switch self {
        case .invalidEntity(let entityName):
            return "Invalid entity with name \"\(entityName)\""
        }
    }

    public static func ==(lhs: FindOrCreatableError, rhs: FindOrCreatableError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidEntity(let lhsEntityName), .invalidEntity(let rhsEntityName)):
            return lhsEntityName == rhsEntityName
        }
    }
}

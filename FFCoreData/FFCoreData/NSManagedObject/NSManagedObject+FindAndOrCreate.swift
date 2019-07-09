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

extension NSPredicate {
    @inlinable
    public convenience init(format: String, arguments: Any...) {
        self.init(format: format, argumentArray: arguments)
    }
}

public typealias KeyObjectDictionary = [String: Any]

fileprivate extension KeyObjectDictionary {
    func asPredicate(with compoundType: NSCompoundPredicate.LogicalType) -> NSCompoundPredicate {
        return NSCompoundPredicate(type: compoundType, subpredicates: map {
            NSPredicate(format: "%K == %@", arguments: $0.key, $0.value)
        })
    }
    
    func apply(to object: NSObject, in context: NSManagedObjectContext) {
        forEach {
            if let id = $1 as? NSManagedObjectID {
                object.setValue(context.object(with: id), forKey: $0)
            } else {
                object.setValue($1, forKey: $0)
            }
        }
    }
}

public protocol Entity: NSObjectProtocol {
    static var entityName: String { get }
}

public protocol Fetchable: Entity, NSFetchRequestResult {
    static func fetchRequest() -> NSFetchRequest<Self>

    static func count(in context: NSManagedObjectContext) throws -> Int
}

public protocol Creatable: Entity {
    static func create(in context: NSManagedObjectContext, applying: KeyObjectDictionary?) throws -> Self
}

public typealias FindOrCreatable = Fetchable & Creatable

public struct InvalidEntityError: Error, Equatable, CustomStringConvertible {
    let entityName: String

    public var description: String {
        return "Invalid entity with name \"\(entityName)\""
    }
}

extension Entity {
    internal static func entity(in context: NSManagedObjectContext) throws -> NSEntityDescription {
        let name = entityName
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else {
            throw InvalidEntityError(entityName: name)
        }
        return entity
    }
}

extension Entity where Self: NSManagedObject {
    @inlinable
    public static var entityName: String {
        return String(class: self, removeNamespace: shouldRemoveNamespaceInEntityName)
    }
}

extension Fetchable {
    @inlinable
    public static func fetchRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest(entityName: entityName)
    }

    public static func fetchRequest(with predicate: NSPredicate?,
                                    sortedBy sortDescriptors: [NSSortDescriptor]?,
                                    offsetBy offset: Int? = nil,
                                    limitedBy limit: Int? = nil) -> NSFetchRequest<Self> {
        let fetchRequest = self.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        if let offset = offset {
            fetchRequest.fetchOffset = offset
        }
        return fetchRequest
    }

    @inlinable
    public static func count(in context: NSManagedObjectContext) throws -> Int {
        return try context.count(for: fetchRequest())
    }
}

extension Creatable {
    @inlinable
    public static func create(in context: NSManagedObjectContext) throws -> Self {
        return try create(in: context, applying: nil)
    }
}

extension Fetchable {
    @inlinable
    public static func all(in context: NSManagedObjectContext) throws -> [Self] {
        return try find(in: context)
    }

    @inlinable
    public static func find(in context: NSManagedObjectContext) throws -> [Self] {
        return try find(in: context, with: nil)
    }
    
    public static func find(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary) throws -> [Self] {
        return try find(in: context, with: dictionary.asPredicate(with: .and))
    }
    
    public static func find(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary, sortedBy sortDescriptors: [NSSortDescriptor]) throws -> [Self] {
        return try find(in: context, with: dictionary.asPredicate(with: .and), sortedBy: sortDescriptors)
    }

    @inlinable
    public static func find(in context: NSManagedObjectContext, with predicate: NSPredicate?) throws -> [Self] {
        return try find(in: context, with: predicate, sortedBy: nil)
    }

    @inlinable
    public static func find(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> [Self] {
        return try context.fetch(fetchRequest(with: predicate, sortedBy: sortDescriptors))
    }

    @inlinable
    public static func findFirst(in context: NSManagedObjectContext) throws -> Self? {
        return try findFirst(in: context, with: nil)
    }

    public static func findFirst(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary) throws -> Self? {
        return try findFirst(in: context, with: dictionary.asPredicate(with: .and))
    }

    public static func findFirst(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary, sortedBy sortDescriptors: [NSSortDescriptor]) throws -> Self? {
        return try findFirst(in: context, with: dictionary.asPredicate(with: .and), sortedBy: sortDescriptors)
    }

    @inlinable
    public static func findFirst(in context: NSManagedObjectContext, with predicate: NSPredicate?) throws -> Self? {
        return try findFirst(in: context, with: predicate, sortedBy: nil)
    }

    @inlinable
    public static func findFirst(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> Self? {
        return try context.fetch(fetchRequest(with: predicate, sortedBy: sortDescriptors, limitedBy: 1)).first
    }

    @inlinable
    public static func random(in context: NSManagedObjectContext) throws -> Self? {
        return try random(upTo: count(in: context), in: context)
    }

    public static func random(upTo randomBound: Int, in context: NSManagedObjectContext) throws -> Self? {
        return try context.fetch(fetchRequest(with: nil, sortedBy: nil, offsetBy: Int.random(in: 0..<randomBound), limitedBy: 1)).first
    }
}

extension Fetchable where Self: Creatable {
    public static func findOrCreate(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary?) throws -> Self {
        return try findFirst(in: context, with: dictionary?.asPredicate(with: .and)) ?? create(in: context, applying: dictionary)
    }

    @inlinable
    public static func findOrCreate(in context: NSManagedObjectContext) throws -> Self {
        return try findOrCreate(in: context, by: nil)
    }
}

extension Creatable where Self: NSManagedObject {
    public static func create(in context: NSManagedObjectContext, applying dictionary: KeyObjectDictionary?) throws -> Self {
        let obj = self.init(entity: try entity(in: context), insertInto: context)
        dictionary?.apply(to: obj, in: context)
        return obj
    }
}

extension Entity where Self: NSManagedObject {
    /// Safely accessess the given KeyPath on the objects managedObjectContext.
    /// If no managedObjectContext is there, it directly accesses the property.
    public subscript<T>(safe keyPath: ReferenceWritableKeyPath<Self, T>) -> T {
        get {
            if let moc = managedObjectContext {
                return moc.sync { self[keyPath: keyPath] }
            } else {
                return self[keyPath: keyPath]
            }
        }
        set {
            if let moc = managedObjectContext {
                moc.sync { self[keyPath: keyPath] = newValue }
            } else {
                self[keyPath: keyPath] = newValue
            }
        }
    }

    public subscript<T>(safe keyPath: KeyPath<Self, T>) -> T {
        if let moc = managedObjectContext {
            return moc.sync { self[keyPath: keyPath] }
        } else {
            return self[keyPath: keyPath]
        }
    }
}

extension NSManagedObject {
    @usableFromInline
    @nonobjc
    internal static var shouldRemoveNamespaceInEntityName: Bool = true
}

extension NSManagedObjectContext {
    public final func sync<T>(do work: () throws -> T) rethrows -> T {
        return try {
            var result: Result<T, Error>!
            performAndWait {
                result = Result(catching: work)
            }
            return try result.get()
        }()
    }

    @inlinable
    public final func async(do work: @escaping () -> ()) {
        perform(work)
    }
}

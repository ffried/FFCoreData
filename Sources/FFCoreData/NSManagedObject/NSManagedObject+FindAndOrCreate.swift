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

fileprivate extension KeyObjectDictionary {
    @inline(__always)
    func asPredicate(with compoundType: NSCompoundPredicate.LogicalType) -> NSCompoundPredicate {
        return NSCompoundPredicate(type: compoundType, dictionary: self)
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
    let entityType: Any.Type

    public var description: String {
        "Invalid entity with name \"\(entityName)\" on type \(entityType)"
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.entityName == rhs.entityName && lhs.entityType == rhs.entityType
    }
}

extension Entity {
    internal static func entityDescription(in context: NSManagedObjectContext) throws -> NSEntityDescription {
        let name = entityName
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else {
            throw InvalidEntityError(entityName: name, entityType: Self.self)
        }
        return entity
    }
}

extension Entity where Self: NSManagedObject {
    @inlinable
    public static var entityName: String {
        String(class: self, removeNamespace: shouldRemoveNamespaceInEntityName)
    }
}

extension Fetchable {
    @inlinable
    public static func fetchRequest() -> NSFetchRequest<Self> { NSFetchRequest(entityName: entityName) }

    public static func fetchRequest(with predicate: NSPredicate?,
                                    sortedBy sortDescriptors: Array<NSSortDescriptor>? = nil,
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
    public static func fetchRequest<SortExpressions>(where filter: FetchableFilterExpression<Self>,
                                                     sortedBy sortExpressions: SortExpressions,
                                                     offsetBy offset: Int? = nil,
                                                     limitedBy limit: Int? = nil) -> NSFetchRequest<Self>
    where SortExpressions: Collection, SortExpressions.Element == FetchableSortExpression<Self>
    {
        let sortDescriptors = sortExpressions.map { $0.sortDescriptor }
        return fetchRequest(with: filter.predicate,
                            sortedBy: sortDescriptors.isEmpty ? nil : sortDescriptors,
                            offsetBy: offset,
                            limitedBy: limit)
    }

    @inlinable
    public static func fetchRequest(where filter: FetchableFilterExpression<Self>,
                                    sortedBy sortExpressions: FetchableSortExpression<Self>...,
                                    offsetBy offset: Int? = nil,
                                    limitedBy limit: Int? = nil) -> NSFetchRequest<Self> {
        fetchRequest(where: filter, sortedBy: sortExpressions, offsetBy: offset, limitedBy: limit)
    }

    @inlinable
    public static func count(in context: NSManagedObjectContext, with predicate: NSPredicate?) throws -> Int {
        try context.count(for: fetchRequest(with: predicate))
    }

    @inlinable
    public static func count(in context: NSManagedObjectContext, where filter: FetchableFilterExpression<Self>) throws -> Int {
        try context.count(for: fetchRequest(where: filter))
    }

    @inlinable
    public static func count(in context: NSManagedObjectContext) throws -> Int {
        // This method is required since it is a protocol requirement which cannot be fulfilled with nil default parameters.
        try count(in: context, with: nil)
    }
}

extension Creatable {
    @inlinable
    public static func create(in context: NSManagedObjectContext) throws -> Self {
        try create(in: context, applying: nil)
    }

    @inlinable
    public static func create(in context: NSManagedObjectContext,
                              setting dictionaryExp: KeyObjectDictionaryExpression<Self>) throws -> Self {
        try create(in: context, applying: dictionaryExp.dict)
    }
}

extension Fetchable {
    @inlinable
    public static func all(in context: NSManagedObjectContext) throws -> Array<Self> {
        try find(in: context)
    }

    @inlinable
    public static func find(in context: NSManagedObjectContext,
                            with predicate: NSPredicate? = nil,
                            sortedBy sortDescriptors: Array<NSSortDescriptor>? = nil) throws -> Array<Self> {
        try context.fetch(fetchRequest(with: predicate, sortedBy: sortDescriptors))
    }

    @inlinable
    public static func find<SortExpressions>(in context: NSManagedObjectContext,
                                             where filter: FetchableFilterExpression<Self>,
                                             sortedBy sortExpressions: SortExpressions) throws -> Array<Self>
    where SortExpressions: Collection, SortExpressions.Element == FetchableSortExpression<Self>
    {
        try context.fetch(fetchRequest(where: filter, sortedBy: sortExpressions))
    }

    @inlinable
    public static func find(in context: NSManagedObjectContext,
                            where filter: FetchableFilterExpression<Self>,
                            sortedBy sortExpressions: FetchableSortExpression<Self>...) throws -> Array<Self> {
        try find(in: context, where: filter, sortedBy: sortExpressions)
    }

    public static func find(in context: NSManagedObjectContext,
                            by dictionary: KeyObjectDictionary,
                            sortedBy sortDescriptors: Array<NSSortDescriptor>? = nil) throws -> Array<Self> {
        try find(in: context, with: dictionary.asPredicate(with: .and), sortedBy: sortDescriptors)
    }

    @inlinable
    public static func findFirst(in context: NSManagedObjectContext,
                                 with predicate: NSPredicate? = nil,
                                 sortedBy sortDescriptors: Array<NSSortDescriptor>? = nil) throws -> Self? {
        try context.fetch(fetchRequest(with: predicate, sortedBy: sortDescriptors, limitedBy: 1)).first
    }

    @inlinable
    public static func findFirst<SortExpressions>(in context: NSManagedObjectContext,
                                                  where filter: FetchableFilterExpression<Self>,
                                                  sortedBy sortExpressions: SortExpressions) throws -> Self?
    where SortExpressions: Collection, SortExpressions.Element == FetchableSortExpression<Self>
    {
        try context.fetch(fetchRequest(where: filter, sortedBy: sortExpressions, limitedBy: 1)).first
    }

    @inlinable
    public static func findFirst(in context: NSManagedObjectContext,
                                 where filter: FetchableFilterExpression<Self>,
                                 sortedBy sortExpressions: FetchableSortExpression<Self>...) throws -> Self? {
        try findFirst(in: context, where:  filter, sortedBy: sortExpressions)
    }

    public static func findFirst(in context: NSManagedObjectContext,
                                 by dictionary: KeyObjectDictionary,
                                 sortedBy sortDescriptors: Array<NSSortDescriptor>? = nil) throws -> Self? {
        try findFirst(in: context, with: dictionary.asPredicate(with: .and), sortedBy: sortDescriptors)
    }

    public static func random(upTo randomBound: Int,
                              in context: NSManagedObjectContext,
                              with predicate: NSPredicate? = nil) throws -> Self? {
        try context.fetch(fetchRequest(with: predicate, offsetBy: .random(in: 0..<randomBound), limitedBy: 1)).first
    }

    public static func random(upTo randomBound: Int,
                              in context: NSManagedObjectContext,
                              where filter: FetchableFilterExpression<Self>) throws -> Self? {
        try context.fetch(fetchRequest(where: filter, offsetBy: .random(in: 0..<randomBound), limitedBy: 1)).first
    }

    @inlinable
    public static func random(in context: NSManagedObjectContext, with predicate: NSPredicate? = nil) throws -> Self? {
        try random(upTo: count(in: context, with: predicate), in: context, with: predicate)
    }

    @inlinable
    public static func random(in context: NSManagedObjectContext, where filter: FetchableFilterExpression<Self>) throws -> Self? {
        try random(upTo: count(in: context, where: filter), in: context, where: filter)
    }
}

extension Fetchable where Self: Creatable {
    public static func findOrCreate(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary? = nil) throws -> Self {
        try findFirst(in: context, with: dictionary?.asPredicate(with: .and)) ?? create(in: context, applying: dictionary)
    }

    @inlinable
    public static func findOrCreate(in context: NSManagedObjectContext, where dictionaryExp: KeyObjectDictionaryExpression<Self>) throws -> Self {
        try findFirst(in: context, where: dictionaryExp.filter) ?? create(in: context, setting: dictionaryExp)
    }
}

extension Creatable where Self: NSManagedObject {
    public static func create(in context: NSManagedObjectContext, applying dictionary: KeyObjectDictionary?) throws -> Self {
        let obj = self.init(entity: try entityDescription(in: context), insertInto: context)
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
    internal static var shouldRemoveNamespaceInEntityName = true
}

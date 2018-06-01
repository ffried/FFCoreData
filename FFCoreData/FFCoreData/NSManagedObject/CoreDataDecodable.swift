//
//  CoreDataDecodable.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 20.10.17.
//  Copyright © 2017 Florian Friedrich. All rights reserved.
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

import CoreData

public protocol CoreDataDecodable: Decodable {
    associatedtype DTO: Decodable

    @discardableResult
    static func findOrCreate(for dto: DTO, in context: NSManagedObjectContext) throws -> Self

    init(with dto: DTO, in context: NSManagedObjectContext) throws

    mutating func update(from dto: DTO) throws
}

public extension CoreDataDecodable {
    public init(from decoder: Decoder) throws {
        try self.init(with: DTO(from: decoder), in: .decodingContext(at: decoder.codingPath))
    }
}

public extension CoreDataDecodable where Self: FindOrCreatable {
    @discardableResult
    public static func findOrCreate(for dto: DTO, in context: NSManagedObjectContext) throws -> Self {
        var object = try findOrCreate(in: context)
        try object.update(from: dto)
        return object
    }
}

public extension CoreDataDecodable where Self: NSManagedObject {
    public init(with dto: DTO, in context: NSManagedObjectContext) throws {
        self.init(context: context)
        try update(from: dto)
    }
}

/// Errors thrown during the process of decoding CoreData entities.
///
/// - missingContext: Thrown if a managed object context was missing during the decoding.
public enum CoreDataDecodingError: Error, CustomStringConvertible {
    case missingContext(codingPath: [CodingKey])

    public var description: String {
        switch self {
        case .missingContext(let codingPath): return "Missing context at \(codingPath)"
        }
    }
}

fileprivate extension Thread {
    private static let decodingContextThreadKey = "net.ffried.FFCoreData.DecodingContext"
    var decodingContext: Unmanaged<NSManagedObjectContext>? {
        get { return threadDictionary[Thread.decodingContextThreadKey] as? Unmanaged<NSManagedObjectContext> }
        set { threadDictionary[Thread.decodingContextThreadKey] = newValue }
    }
}

public extension NSManagedObjectContext {
    private static var _decodingContext: NSManagedObjectContext? {
        get { return Thread.current.decodingContext?.takeUnretainedValue() }
        set { Thread.current.decodingContext = newValue.map(Unmanaged.passUnretained) }
    }

    /// Returns the current decoding context. Throws if no context is registered as decoding context.
    ///
    /// - Parameter codingPath: The coding path for which to request the decoding context. Only used for debugging purposes.
    /// - Returns: The current decoding context.
    /// - Throws: `CoreDataDecodingError.missingContext`
    public static func decodingContext(at codingPath: [CodingKey] = []) throws -> NSManagedObjectContext {
        if let context = _decodingContext { return context }
        throw CoreDataDecodingError.missingContext(codingPath: codingPath)
    }

    /// Sets the current managed object context as decoding context.
    ///
    /// - Parameter work: The work to perform with the receiver as decoding context.
    /// - Returns: Any value returned by `work`
    /// - Throws: Any error thrown by `work`.
    /// - Note: The context is only registered as valid decoding context for the during the execution of `work`.
    public final func asDecodingContext<T>(do work: () throws -> T) rethrows -> T {
        NSManagedObjectContext._decodingContext = self
        defer { NSManagedObjectContext._decodingContext = nil }
        return try sync { try work() }
    }
}

// MARK: - Foundation decoder extensions
public extension JSONDecoder {
    /// Decodes the entity from a JSON in a given `Data` using its `DTO` type.
    ///
    /// - Parameters:
    ///   - entity: The entity to decode.
    ///   - data: The data to decode from.
    /// - Returns: The decoded entity.
    /// - Throws: Any error thrown by `Entity.findOrCreate`, `JSONDecoder.decode(_: from:)` or `NSManagedObjectContext.decodingContext(at:)`
    /// - Note: Only use this method inside a closure submitted to `NSManagedObject.asDecodingContext(do:)`.
    /// - SeeAlso: `JSONDecoder.decode(_:from:in:)`
    public final func decode<Entity: CoreDataDecodable>(_ entity: Entity.Type, from data: Data) throws -> Entity {
        return try .findOrCreate(for: decode(entity.DTO.self, from: data), in: .decodingContext())
    }

    /// Decodes the entity from a JSON in a given `Data` using its `DTO` type inside a given `NSManagedObjectContext`.
    ///
    /// - Parameters:
    ///   - entity: The entity to decode.
    ///   - data: The data to decode from.
    ///   - context: The context to use for decoding.
    /// - Returns: The decoded entity.
    /// - Throws: Any error thrown by `JSONDecoder.decode(_:from:)`
    /// - SeeAlso: `JSONDecoder.decode(_:from:)`
    public final func decode<Entity: CoreDataDecodable>(_ entity: Entity.Type, from data: Data, in context: NSManagedObjectContext) throws -> Entity {
        return try context.asDecodingContext { try decode(entity, from: data) }
    }
}

public extension PropertyListDecoder {
    /// Decodes the entity from a PropertyList in a given `Data` using its `DTO` type.
    ///
    /// - Parameters:
    ///   - entity: The entity to decode.
    ///   - data: The data to decode from.
    /// - Returns: The decoded entity.
    /// - Throws: Any error thrown by `Entity.findOrCreate`, `PropertyListDecoder.decode(_: from:)` or `NSManagedObjectContext.decodingContext(at:)`
    /// - Note: Only use this method inside a closure submitted to `NSManagedObject.asDecodingContext(do:)`.
    /// - SeeAlso: `PropertyListDecoder.decode(_:from:in:)`
    public final func decode<Entity: CoreDataDecodable>(_ entity: Entity.Type, from data: Data) throws -> Entity {
        return try .findOrCreate(for: decode(entity.DTO.self, from: data), in: .decodingContext())
    }

    /// Decodes the entity from a PropertyList in a given `Data` using its `DTO` type inside a given `NSManagedObjectContext`.
    ///
    /// - Parameters:
    ///   - entity: The entity to decode.
    ///   - data: The data to decode from.
    ///   - context: The context to use for decoding.
    /// - Returns: The decoded entity.
    /// - Throws: Any error thrown by `PropertyListDecoder.decode(_:from:)`
    /// - SeeAlso: `PropertyListDecoder.decode(_:from:)`
    public final func decode<Entity: CoreDataDecodable>(_ entity: Entity.Type, from data: Data, in context: NSManagedObjectContext) throws -> Entity {
        return try context.asDecodingContext { try decode(entity, from: data) }
    }
}

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
    @available(iOS 10, iOSApplicationExtension 10,
               tvOS 10, tvOSApplicationExtension 10,
               watchOS 10, watchOSApplicationExtension 10,
               OSX 10.12, OSXApplicationExtension 10.12, *)
    public init(with dto: DTO, in context: NSManagedObjectContext) throws {
        self.init(context: context)
        try update(from: dto)
    }
}

public enum CoreDataDecodingError: Error {
    case missingContext(codingPath: [CodingKey])
}

public extension NSManagedObjectContext {
    private static var _decodingContext: NSManagedObjectContext?

    public static func decodingContext(at codingPath: [CodingKey] = []) throws -> NSManagedObjectContext {
        if let context = _decodingContext { return context }
        throw CoreDataDecodingError.missingContext(codingPath: codingPath)
    }

    public final func asDecodingContext<T>(do work: () throws -> T) rethrows -> T {
        NSManagedObjectContext._decodingContext = self
        defer { NSManagedObjectContext._decodingContext = nil }
        return try sync { try work() }
    }
}

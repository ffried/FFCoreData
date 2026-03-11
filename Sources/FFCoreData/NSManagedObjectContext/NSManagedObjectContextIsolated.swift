//
//  NSManagedObjectContextIsolated.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 11.03.26.
//  Copyright © 2026 Florian Friedrich. All rights reserved.
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

public import CoreData

private struct UnsafeSending<T: ~Copyable>: @unchecked Sendable, ~Copyable {
    let value: T

    init(_ value: consuming T) {
        self.value = value
    }
}

extension UnsafeSending: Copyable where T: Copyable {}

@dynamicMemberLookup
public struct NSManagedObjectContextIsolated<Value: ~Copyable>: @unchecked Sendable, ~Copyable {
    @dynamicMemberLookup
    @available(*, noasync)
    public struct Blocking: @unchecked Sendable, ~Copyable {
        let context: NSManagedObjectContext
        var value: Value

        public subscript<T>(dynamicMember memberPath: any Sendable & KeyPath<Value, T>) -> T {
            get {
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    context.performAndWait { value[keyPath: memberPath] }
                } else {
                    context.sync { value[keyPath: memberPath] }
                }
            }
        }

        public subscript<T>(dynamicMember memberPath: any Sendable & ReferenceWritableKeyPath<Value, T>) -> T {
            get {
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    context.performAndWait { value[keyPath: memberPath] }
                } else {
                    context.sync { value[keyPath: memberPath] }
                }
            }
            nonmutating set {
                let sendableNewValue = UnsafeSending(newValue)
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    context.performAndWait { value[keyPath: memberPath] = sendableNewValue.value }
                } else {
                    context.sync { value[keyPath: memberPath] = sendableNewValue.value }
                }
            }
        }

        public subscript<T: Sendable>(dynamicMember memberPath: any Sendable & ReferenceWritableKeyPath<Value, T>) -> T {
            get {
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    context.performAndWait { value[keyPath: memberPath] }
                } else {
                    context.sync { value[keyPath: memberPath] }
                }
            }
            nonmutating set {
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    context.performAndWait { value[keyPath: memberPath] = newValue }
                } else {
                    context.sync { value[keyPath: memberPath] = newValue }
                }
            }
        }

        public func set<T>(_ newValue: sending T, for member: any Sendable & ReferenceWritableKeyPath<Value, T>)  {
            self[dynamicMember: member] = newValue
        }

        public func set<T: Sendable>(_ newValue: T, for member: any Sendable & ReferenceWritableKeyPath<Value, T>) {
            self[dynamicMember: member] = newValue
        }

        public func withValue<T, F>(do work: @Sendable (borrowing Value) throws(F) -> sending T) throws(F) -> sending T {
            if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                try context.performAndWaitWithTypedThrows { () throws(F) -> sending T in try work(value) }
            } else {
                try context.sync { () throws(F) -> sending T in try work(value) }
            }
        }

        public mutating func withMutableValue<T, F>(do work: @Sendable (inout Value) throws(F) -> sending T) throws(F) -> sending T
        where Value: Copyable
        {
            let (newSelf, result): (Self, T)
            if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                (newSelf, result) = try context.performAndWaitWithTypedThrows { [self] () throws(F) -> sending (Self, T) in
                    var newSelf = self
                    let result = try work(&newSelf.value)
                    return (newSelf, result)
                }
            } else {
                (newSelf, result) = try context.sync { [self] () throws(F) -> sending (Self, T) in
                    var newSelf = self
                    let result = try work(&newSelf.value)
                    return (newSelf, result)
                }
            }
            self = newSelf
            return result
        }

        public func saveContext(rollback: Bool = true, completion: @escaping @Sendable (Bool) -> () = { _ in }) {
            CoreDataStack.save(context: context, rollback: rollback, completion: completion)
        }
    }

    let context: NSManagedObjectContext
    var value: Value

    public init(context: NSManagedObjectContext, value: consuming Value) {
        self.context = context
        self.value = value
    }

    @available(*, noasync)
    public consuming func blocking() -> Blocking {
        .init(context: context, value: value)
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public subscript<T>(dynamicMember memberPath: any Sendable & KeyPath<Value, T>) -> sending T {
        get async {
            await context.perform { value[keyPath: memberPath] }
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func set<T>(_ newValue: consuming sending T, for member: any Sendable & ReferenceWritableKeyPath<Value, T>) async {
        await context.perform { [sendableNewValue = UnsafeSending(newValue)] in
            value[keyPath: member] = sendableNewValue.value
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func set<T: Sendable>(_ newValue: T, for member: any Sendable & ReferenceWritableKeyPath<Value, T>) async {
        await context.perform {
            value[keyPath: member] = newValue
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func perform<T, F>(do work: @escaping @Sendable (borrowing Value) throws(F) -> sending T) async throws(F) -> sending T
    where Value: Copyable
    {
        try await context.performWithTypedThrows { () throws(F) -> sending T in try work(value) }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public mutating func performMutating<T, F>(do work: @escaping @Sendable (inout Value) throws(F) -> sending T) async throws(F) -> sending T
    where Value: Copyable
    {
        let (newSelf, result) = try await context.performWithTypedThrows { [self] () throws(F) -> sending (Self, T) in
            var newSelf = self
            let result = try work(&newSelf.value)
            return (newSelf, result)
        }
        self = newSelf
        return result
    }

    @discardableResult
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func saveContext(rollback: Bool = true) async -> Bool {
        await CoreDataStack.saveContext(context, rollback: rollback)
    }
}

extension NSManagedObjectContextIsolated: Copyable where Value: Copyable {}
extension NSManagedObjectContextIsolated.Blocking: Copyable where Value: Copyable {}

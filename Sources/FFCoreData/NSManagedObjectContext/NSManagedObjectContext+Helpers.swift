//
//  FetchableSortExpression.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 11.08.22.
//  Copyright © 2022 Florian Friedrich. All rights reserved.
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

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension NSManagedObjectContext {
    internal final nonisolated func performAndWaitWithTypedThrows<T, F>(
        _ work: @Sendable () throws(F) -> sending T
    ) throws(F) -> sending T {
        do {
            return try performAndWait { try work() }
        } catch {
            throw error as! F
        }
    }

    internal final nonisolated func performWithTypedThrows<T, F>(
        schedule: sending NSManagedObjectContext.ScheduledTaskType = .immediate,
        _ work: @Sendable @escaping () throws(F) -> sending T
    ) async throws(F) -> sending T {
        do {
            return try await perform(schedule: schedule) { try work() }
        } catch {
            throw error as! F
        }
    }
}

#if compiler(<6.2)
extension NSManagedObjectContext: @retroactive @unchecked Sendable {}
#endif

#if compiler(>=6.2)
@safe
fileprivate final class UnsafeSending<V>: @unchecked Sendable {
    private let ptr: UnsafeMutablePointer<V>

    init() {
        unsafe ptr = .allocate(capacity: 1)
    }

    func set(_ value: V) {
        unsafe ptr.initialize(to: value)
    }

    /*consuming*/ func get() -> V {
        unsafe ptr.move()
    }

    deinit {
        unsafe ptr.deallocate()
    }
}
#else
fileprivate final class UnsafeSending<V>: @unchecked Sendable {
    private let ptr: UnsafeMutablePointer<V>

    init() {
        ptr = .allocate(capacity: 1)
    }

    func set(_ value: V) {
        ptr.initialize(to: value)
    }

    func get() -> V {
        ptr.move()
    }

    deinit {
        ptr.deallocate()
    }
}
#endif

extension NSManagedObjectContext {
    @preconcurrency
    @available(macOS, deprecated: 12, message: "Use performAndWait", renamed: "performAndWait")
    @available(iOS, deprecated: 15, message: "Use performAndWait", renamed: "performAndWait")
    @available(tvOS, deprecated: 15, message: "Use performAndWait", renamed: "performAndWait")
    @available(watchOS, deprecated: 8, message: "Use performAndWait", renamed: "performAndWait")
    public nonisolated final func sync<T, F>(do work: @Sendable () throws(F) -> sending T) throws(F) -> sending T {
        let result = UnsafeSending<Result<T, F>>()
        performAndWait {
            result.set(Result(catching: work))
        }
        return try result.get().get()
    }

    @inlinable
    @preconcurrency
    @available(*, deprecated, renamed: "perform")
    public nonisolated final func async(do work: @escaping @Sendable () -> ()) {
        perform(work)
    }
}

@available(macOS, introduced: 10.15, deprecated: 12, message: "Use perform")
@available(iOS, introduced: 13, deprecated: 15, message: "Use perform")
@available(tvOS, introduced: 13, deprecated: 15, message: "Use perform")
@available(watchOS, introduced: 6, deprecated: 8, message: "Use perform")
extension NSManagedObjectContext {
    @preconcurrency
    public nonisolated final func run<T, F>(_ work: @escaping @Sendable (NSManagedObjectContext) throws(F) -> sending T) async throws(F) -> sending T {
#if compiler(>=6.2)
        unsafe try await withUnsafeContinuation { (continuation: UnsafeContinuation<Result<T, F>, Never>) in
            perform {
                unsafe continuation.resume(returning: .init(catching: { () throws(F) -> T in try work(self) }))
            }
        }.get()
#else
        try await withUnsafeContinuation { (continuation: UnsafeContinuation<Result<T, F>, Never>) in
            perform {
                continuation.resume(returning: .init(catching: { () throws(F) -> T in try work(self) }))
            }
        }.get()
#endif
    }

    @inlinable
    @preconcurrency
    public nonisolated final func run<T, F>(_ work: @escaping @Sendable () throws(F) -> sending T) async throws(F) -> sending T {
        try await run { (_) throws(F) -> T in try work() }
    }
}

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

import CoreData

extension NSManagedObjectContext {
    public final func sync<T>(do work: () throws -> T) rethrows -> T {
        try {
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

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension NSManagedObjectContext {
    public final func run<T>(_ work: @escaping (NSManagedObjectContext) throws -> T) async rethrows -> T {
        try await {
            try await withUnsafeContinuation { (continuation: UnsafeContinuation<Result<T, Error>, Never>) in
                perform {
                    continuation.resume(returning: .init(catching: { try work(self) }))
                }
            }.get()
        }()
    }

    public final func run<T>(_ work: @escaping () throws -> T) async rethrows -> T {
        try await run { _ in try work() }
    }
}

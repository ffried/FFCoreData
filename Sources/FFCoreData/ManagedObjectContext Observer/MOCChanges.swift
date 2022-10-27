//
//  MOCChanges.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 27.10.22.
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

import struct Foundation.Notification
import class Foundation.NotificationCenter
import CoreData

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct MOCChanges<Filter: MOCObserverFilter>: AsyncSequence {
    public typealias Element = AsyncIterator.Element

    public struct AsyncIterator: AsyncIteratorProtocol {
        public typealias Element = MOCObservedChanges

        var upstream: AsyncCompactMapSequence<AsyncStream<Notification>, MOCObservedChanges>.AsyncIterator

        public mutating func next() async -> Element? {
            await upstream.next()
        }
    }

    public let mode: MOCObservationMode
    public let filter: Filter
    private let upstream: AsyncCompactMapSequence<AsyncStream<Notification>, MOCObservedChanges>

    public init(mode: MOCObservationMode, filter: Filter) {
        self.mode = mode
        self.filter = filter

        let stream: AsyncStream<Notification>
        if let contexts = mode.nonEmptyContexts {
            stream = .init { continuation in
                let observers = contexts.map {
                    NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange,
                                                           object: $0,
                                                           queue: nil) { note in continuation.yield(note) }
                }
                continuation.onTermination = { _ in
                    observers.forEach {
                        NotificationCenter.default.removeObserver($0)
                    }
                }
            }
        } else {
            stream = .init { continuation in
                let observer = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange,
                                                                      object: nil,
                                                                      queue: nil) { note in continuation.yield(note) }
                continuation.onTermination = { _ in
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        }
        self.upstream = stream.compactMap { MOCObservedChanges(notification: $0, filter: filter) }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        .init(upstream: upstream.makeAsyncIterator())
    }
}

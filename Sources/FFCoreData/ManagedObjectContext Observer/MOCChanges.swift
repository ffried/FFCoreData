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

import Foundation
import CoreData

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct MOCChanges<Filter: MOCObserverFilter>: AsyncSequence {
    public typealias Element = AsyncIterator.Element
    public typealias Failure = AsyncIterator.Failure

    private struct SendableNotificationRegistration: @unchecked Sendable {
        let observer: any NSObjectProtocol
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        public typealias Element = MOCObservedChanges
        public typealias Failure = Never

        private(set) var upstream: AsyncStream<MOCObservedChanges>.AsyncIterator

        public mutating func next() async -> Element? {
            await upstream.next()
        }

        @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
        public mutating func next(isolation actor: isolated (any Actor)?) async throws(Failure) -> Element? {
            await upstream.next(isolation: actor)
        }
    }

    public let mode: MOCObservationMode
    public let filter: Filter
    private let upstream: AsyncStream<MOCObservedChanges>

    public init(mode: MOCObservationMode, filter: Filter) {
        self.mode = mode
        self.filter = filter

        let notificationCenter = NotificationCenter.default
        if let contexts = mode.nonEmptyContexts {
            upstream = .init { continuation in
                let observers = contexts.map {
                    SendableNotificationRegistration(observer: notificationCenter.addObserver(forName: .NSManagedObjectContextObjectsDidChange,
                                                                                              object: $0,
                                                                                              queue: nil) {
                        guard let changes = MOCObservedChanges(notification: $0, filter: filter)
                        else { return }
                        continuation.yield(changes)
                    })
                }
                continuation.onTermination = { _ in
                    observers.forEach {
                        notificationCenter.removeObserver($0.observer)
                    }
                }
            }
        } else {
            upstream = .init { continuation in
                let observer = SendableNotificationRegistration(
                    observer: notificationCenter.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: nil, queue: nil) {
                        guard let changes = MOCObservedChanges(notification: $0, filter: filter)
                        else { return }
                        continuation.yield(changes)
                    }
                )
                continuation.onTermination = { _ in
                    notificationCenter.removeObserver(observer.observer)
                }
            }
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        .init(upstream: upstream.makeAsyncIterator())
    }
}

//
//  MOCChangePublisher.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 08.07.19.
//  Copyright © 2019 Florian Friedrich. All rights reserved.
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

#if canImport(Combine)
import struct Foundation.Notification
import class Foundation.NotificationCenter
import Combine
import CoreData

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct MOCChangePublisher<Filter: MOCObserverFilter>: Publisher {
    public typealias Output = MOCObservedChanges
    public typealias Failure = Never

    public let mode: MOCObservationMode
    public let filter: Filter
    private let upstream: Publishers.CompactMap<Publishers.MergeMany<NotificationCenter.Publisher>, MOCObservedChanges>

    public init(mode: MOCObservationMode, filter: Filter) {
        self.mode = mode
        self.filter = filter
        let notificationCenter = NotificationCenter.default
        let publisher: Publishers.MergeMany<NotificationCenter.Publisher>
        if let contexts = mode.nonEmptyContexts {
            publisher = Publishers.MergeMany(contexts.map { notificationCenter.publisher(for: .NSManagedObjectContextObjectsDidChange, object: $0) })
        } else {
            publisher = Publishers.MergeMany(notificationCenter.publisher(for: .NSManagedObjectContextObjectsDidChange, object: nil))
        }
        upstream = publisher.compactMap { MOCObservedChanges(notification: $0, filter: filter) }
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        upstream.receive(subscriber: subscriber)
    }
}
#endif

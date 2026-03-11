//
//  MOCBlockObservers.swift
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

import Foundation
public import CoreData

@available(*, noasync, message: "Use MOCChanges instead")
public final class MOCBlockObserver<Filter: MOCObserverFilter> {
    public typealias Handler = (MOCBlockObserver, MOCObservedChanges) -> ()

    public let mode: MOCObservationMode
    public var queue: OperationQueue
    public var handler: Handler

    private let filter: Filter
    private let workerQueue = OperationQueue()
    private var observers = Array<any NSObjectProtocol>()

    public init(mode: MOCObservationMode,
                filter: Filter,
                queue: OperationQueue = .current ?? .main,
                fireInitially: Bool,
                handler: @escaping Handler) {
        self.mode = mode
        self.filter = filter
        self.handler = handler
        self.queue = queue
#if compiler(>=6.2)
        let observerBlock = unsafe unsafeBitCast({ [weak self] (note: Notification) -> () in
            self?.managedObjectContextDidChange(notification: note)
        }, to: (@Sendable (Notification) -> ()).self)
#else
        let observerBlock = unsafeBitCast({ [weak self] (note: Notification) -> () in
            self?.managedObjectContextDidChange(notification: note)
        }, to: (@Sendable (Notification) -> ()).self)
#endif
        let notificationCenter = NotificationCenter.default
        if let contexts = mode.nonEmptyContexts {
            observers = contexts.map {
                notificationCenter.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: $0, queue: workerQueue, using: observerBlock)
            }
        } else {
            observers = [
                notificationCenter.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: nil, queue: workerQueue, using: observerBlock)
            ]
        }
        if fireInitially {
            fire(with: .init())
        }
    }

    private func managedObjectContextDidChange(notification: Notification) {
        guard let changes = MOCObservedChanges(notification: notification, filter: filter) else { return }
        fire(with: changes)
    }

    private func fire(with changes: MOCObservedChanges) {
#if compiler(>=6.2)
        let block = unsafe unsafeBitCast({ self.handler(self, changes) }, to: (@Sendable () -> ()).self)
#else
        let block = unsafeBitCast({ self.handler(self, changes) }, to: (@Sendable () -> ()).self)
#endif
        queue.addOperation(block)
    }
}

@available(*, unavailable)
extension MOCBlockObserver: Sendable {}

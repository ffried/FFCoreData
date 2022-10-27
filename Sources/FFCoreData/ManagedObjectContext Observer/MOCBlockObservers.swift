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

import struct Foundation.Notification
import class Foundation.NotificationCenter
import class Foundation.OperationQueue
import CoreData

public final class MOCBlockObserver<Filter: MOCObserverFilter> {
    public typealias Handler = (MOCBlockObserver, MOCObservedChanges) -> ()

    public let mode: MOCObservationMode
    public var queue: OperationQueue
    public var handler: Handler

    private let filter: Filter
    private let workerQueue = OperationQueue()
    private var observers = Array<NSObjectProtocol>()

    public init(mode: MOCObservationMode,
                filter: Filter,
                queue: OperationQueue = .current ?? .main,
                fireInitially: Bool,
                handler: @escaping Handler) {
        self.mode = mode
        self.filter = filter
        self.handler = handler
        self.queue = queue
        let observerBlock = { [weak self] (note: Notification) -> () in
            self?.managedObjectContextDidChange(notification: note)
        }
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
        queue.addOperation { self.handler(self, changes) }
    }
}

//
//  ManagedObjectContextObserver.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 24.1.15.
//  Copyright 2015 Florian Friedrich
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
import class FFFoundation.NotificationObserver
import CoreData

public class MOCObserver {
    public typealias MOCObserverBlock = (MOCObserver, _ changes: [String: [NSManagedObjectID]]?) -> ()
    
    private let notificationCenter = NotificationCenter.default
    
    public private(set) final var contexts: [NSManagedObjectContext]?
    
    private var observers = [NotificationObserver]()

    private let workerQueue = OperationQueue()
    public final var queue: OperationQueue
    public final var handler: MOCObserverBlock

    public init(contexts: [NSManagedObjectContext]? = nil, fireInitially: Bool = false, block: @escaping MOCObserverBlock) {
        self.contexts = contexts
        self.handler = block
        self.queue = OperationQueue.current ?? OperationQueue.main
        let observerBlock = { [unowned self] (note: Notification) in
            self.managedObjectContextDidChange(notification: note)
        }
        if let contexts = contexts, !contexts.isEmpty {
            observers = contexts.map {
                NotificationObserver(center: notificationCenter, name: .NSManagedObjectContextObjectsDidChange, queue: workerQueue, object: $0, block: observerBlock)
            }
        } else {
            observers = [
                NotificationObserver(center: notificationCenter, name: .NSManagedObjectContextObjectsDidChange, queue: workerQueue, block: observerBlock)
                ]
        }
        if fireInitially {
            block(self, nil)
        }
    }
    
    internal func include(managedObject: NSManagedObject) -> Bool {
        return true
    }
    
    private final func managedObjectContextDidChange(notification: Notification) {
        if let userInfo = notification.userInfo, let changes = filtered(changeDictionary: userInfo) {
            queue.addOperation {
                self.handler(self, changes)
            }
        }
    }
    
    private final func filtered(changeDictionary changes: [AnyHashable: Any]) -> [String: [NSManagedObjectID]]? {
        let inserted = changes[NSInsertedObjectsKey] as? Set<NSManagedObject>
        let updated = changes[NSUpdatedObjectsKey] as? Set<NSManagedObject>
        let deleted = changes[NSDeletedObjectsKey] as? Set<NSManagedObject>
        
        let insertedIDs = inserted?.filter(include).map { $0.objectID }
        let updatedIDs = updated?.filter(include).map { $0.objectID }
        let deletedIDs = deleted?.filter(include).map { $0.objectID }
        
        let newChanges = [
            (insertedIDs, NSInsertedObjectsKey),
            (updatedIDs, NSUpdatedObjectsKey),
            (deletedIDs, NSDeletedObjectsKey)
            ].reduce([String: [NSManagedObjectID]]()) {
                var newResult = $0
                if let objIds = $1.0, !objIds.isEmpty {
                    newResult[$1.1] = objIds
                }
                return newResult
        }
        return (newChanges.isEmpty) ? nil : newChanges
    }
}

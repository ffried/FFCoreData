//
//  ManagedObjectContextObserver.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 24.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFCoreData

public class MOCObserver {
    public typealias MOCObserverBlock = (observer: MOCObserver, changes: [String: [NSManagedObjectID]]?) -> ()
    
    private struct MOCNotificationObserver {
        let observer: NSObjectProtocol
        let object: NSObject?
    }
    
    private let notificationCenter = NSNotificationCenter.defaultCenter()
    
    public private(set) var contexts: [NSManagedObjectContext]?
    
    private let workerQueue = NSOperationQueue()
    private var observers = [MOCNotificationObserver]()
    
    public var queue: NSOperationQueue
    public var handler: MOCObserverBlock
    
    public init(contexts: [NSManagedObjectContext]? = nil, fireInitially: Bool = false, block: MOCObserverBlock) {
        self.contexts = contexts
        self.handler = block
        self.queue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        let observerBlock: (note: NSNotification!) -> Void = { [unowned self] (note) in
            self.managedObjectContextDidChange(note)
        }
        if contexts?.count > 0 {
            for ctx in contexts! {
                let obsObj = notificationCenter.addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: ctx, queue: workerQueue, usingBlock: observerBlock)
                observers.append(MOCNotificationObserver(observer: obsObj, object: ctx))
            }
        } else {
            let obsObj = notificationCenter.addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: nil, queue: workerQueue, usingBlock: observerBlock)
            observers.append(MOCNotificationObserver(observer: obsObj, object: nil))
        }
        if fireInitially {
            block(observer: self, changes: nil)
        }
    }
    
    deinit {
        for observer in observers {
            notificationCenter.removeObserver(observer.observer, name: NSManagedObjectContextObjectsDidChangeNotification, object: observer.object)
        }
    }
    
    internal func includeManagedObject(object: NSManagedObject) -> Bool {
        return true
    }
    
    private func managedObjectContextDidChange(notification: NSNotification) {
        if let userInfo = notification.userInfo, let changes = filteredChangeDictionary(userInfo) {
            queue.addOperationWithBlock {
                self.handler(observer: self, changes: changes)
            }
        }
    }
    
    private func filteredChangeDictionary(changes: [NSObject: AnyObject]) -> [String: [NSManagedObjectID]]? {
        let inserted = changes[NSInsertedObjectsKey] as? Set<NSManagedObject>
        let updated = changes[NSUpdatedObjectsKey] as? Set<NSManagedObject>
        let deleted = changes[NSDeletedObjectsKey] as? Set<NSManagedObject>
        
        let insertedIDs = inserted?.filter(includeManagedObject).map { $0.objectID }
        let updatedIDs = updated?.filter(includeManagedObject).map { $0.objectID }
        let deletedIDs = deleted?.filter(includeManagedObject).map { $0.objectID }
        
        var newChanges = [String: [NSManagedObjectID]]()
        let objectIDsAndKeys = [
            (insertedIDs, NSInsertedObjectsKey),
            (updatedIDs, NSUpdatedObjectsKey),
            (deletedIDs, NSDeletedObjectsKey)
        ]
        for (objIDs, key) in objectIDsAndKeys {
            if objIDs?.count > 0 { newChanges[key] = objIDs }
        }
        return (newChanges.count > 0) ? newChanges : nil
    }
}

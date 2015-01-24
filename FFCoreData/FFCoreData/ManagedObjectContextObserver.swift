//
//  ManagedObjectContextObserver.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 24.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFCoreData

public typealias MOCObserverBlock = (observer: MOCObserver, changes: [String: [NSManagedObjectID]]?) -> ()

public class MOCObserver {
    private let notificationCenter = NSNotificationCenter.defaultCenter()
    
    public private(set) var contexts: [NSManagedObjectContext]?
    
    public var queue: NSOperationQueue
    public var handler: MOCObserverBlock
    
    public init(contexts: [NSManagedObjectContext]? = nil, fireInitially: Bool = false, block: MOCObserverBlock) {
        self.contexts = contexts
        self.handler = block
        self.queue = NSOperationQueue.currentQueue() ?? NSOperationQueue.mainQueue()
        if contexts?.count > 0 {
            for ctx in contexts! {
                notificationCenter.addObserver(self, selector: "managedObjectContextDidChange:", name: NSManagedObjectContextObjectsDidChangeNotification, object: ctx)
            }
        } else {
            notificationCenter.addObserver(self, selector: "managedObjectContextDidChange:", name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
        }
        if fireInitially {
            block(observer: self, changes: nil)
        }
    }
    
    deinit {
        if let contexts = contexts {
            for ctx in contexts {
                notificationCenter.removeObserver(self, name: NSManagedObjectContextObjectsDidChangeNotification, object: ctx)
            }
        } else {
            notificationCenter.removeObserver(self, name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
        }
    }
    
    internal func includeManagedObject(object: NSManagedObject) -> Bool {
        return true
    }
    
    private func managedObjectContextDidChange(notification: NSNotification) {
        if let userInfo =  notification.userInfo {
            if let changes = filteredChangeDictionary(userInfo) {
                queue.addOperationWithBlock {
                    self.handler(observer: self, changes: changes)
                }
            }
        }
    }
    
    private func filteredChangeDictionary(changes: [NSObject: AnyObject]) -> [String: [NSManagedObjectID]]? {
        var inserted = changes[NSInsertedObjectsKey] as? NSSet
        var updated = changes[NSUpdatedObjectsKey] as? NSSet
        var deleted = changes[NSDeletedObjectsKey] as? NSSet
        
        let testBlock = { (object: AnyObject!, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
            return self.includeManagedObject(object as NSManagedObject)
        }
        
        inserted = inserted?.objectsPassingTest(testBlock).valueForKey("objectID") as? NSSet
        updated = updated?.objectsPassingTest(testBlock).valueForKey("objectID") as? NSSet
        deleted = deleted?.objectsPassingTest(testBlock).valueForKey("objectID") as? NSSet
        
        var newChanges = [String: [NSManagedObjectID]]()
        if let objIDs = inserted?.allObjects as? [NSManagedObjectID] {
            if countElements(objIDs) > 0 {
                newChanges[NSInsertedObjectsKey] = objIDs
            }
        }
        if let objIDs = updated?.allObjects as? [NSManagedObjectID] {
            if countElements(objIDs) > 0 {
                newChanges[NSUpdatedObjectsKey] = objIDs
            }
        }
        if let objIDs = deleted?.allObjects as? [NSManagedObjectID] {
            if countElements(objIDs) > 0 {
                newChanges[NSDeletedObjectsKey] = objIDs
            }
        }
        
        return (countElements(newChanges) > 0) ? newChanges : nil
    }
}

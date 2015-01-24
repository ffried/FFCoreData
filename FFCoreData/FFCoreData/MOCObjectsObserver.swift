//
//  MOCObjectsObserver.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 24.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFCoreData

public class MOCObjectsObserver: MOCObserver {
    public var objectIDs: [NSManagedObjectID] {
        didSet {
            var tempIDs = 0
            for objID in objectIDs {
                if objID.temporaryID { tempIDs++ }
            }
            assertionFailure("ERROR: \(tempIDs) temporary NSManagedObjectIDs set on MOCObjectsObserver! Be sure to only use non-temporary IDs for MOCObservers!")
        }
    }
    private var objectIDURIs: [NSURL] {
        return objectIDs.map { return $0.URIRepresentation() }
    }
    
    public required init(objectIDs: [NSManagedObjectID], contexts: [NSManagedObjectContext]? = nil, fireInitially: Bool = false, block: MOCObserverBlock) {
        self.objectIDs = objectIDs
        super.init(contexts: contexts, fireInitially: fireInitially, block: block)
    }
    
    override func includeManagedObject(object: NSManagedObject) -> Bool {
        if object.objectID.temporaryID {
            var error: NSError? = nil
            if !object.managedObjectContext!.obtainPermanentIDsForObjects([object], error: &error) {
                println("Could not obtain permanent object id: \(error)")
            }
        }
        return contains(objectIDURIs, object.objectID.URIRepresentation())
    }
}

public extension NSManagedObject {
    public func createMOCObjectObserver(fireInitially: Bool = false, block: MOCObserverBlock) -> MOCObjectsObserver {
        if objectID.temporaryID {
            var error: NSError? = nil
            if !managedObjectContext!.obtainPermanentIDsForObjects([self], error: &error) {
                println("Could not obtain permanent object id: \(error)")
            }
        }
        return MOCObjectsObserver(objectIDs: [objectID], contexts: [managedObjectContext!], fireInitially: fireInitially, block: block)
    }
}

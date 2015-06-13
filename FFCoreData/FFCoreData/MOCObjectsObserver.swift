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
            let tempIDs = objectIDs.reduce(0) { $0 + ($1.temporaryID ? 1 : 0) }
            if tempIDs > 0 {
                assertionFailure("ERROR: \(tempIDs) temporary NSManagedObjectIDs set on MOCObjectsObserver! Be sure to only use non-temporary IDs for MOCObservers!")
            }
        }
    }
    private var objectIDURIs: [NSURL] { return objectIDs.map { $0.URIRepresentation() } }
    
    public required init(objectIDs: [NSManagedObjectID], contexts: [NSManagedObjectContext]? = nil, fireInitially: Bool = false, block: MOCObserverBlock) {
        self.objectIDs = objectIDs
        super.init(contexts: contexts, fireInitially: fireInitially, block: block)
    }
    
    override func includeManagedObject(object: NSManagedObject) -> Bool {
        if object.objectID.temporaryID {
            do {
                try object.managedObjectContext!.obtainPermanentIDsForObjects([object])
            } catch {
                print("Could not obtain permanent object id: \(error)")
            }
        }
        return objectIDURIs.contains(object.objectID.URIRepresentation())
    }
}

public extension NSManagedObject {
    public func createMOCObjectObserver(fireInitially: Bool = false, block: MOCObserver.MOCObserverBlock) -> MOCObjectsObserver {
        if objectID.temporaryID {
            do {
                try managedObjectContext!.obtainPermanentIDsForObjects([self])
            } catch {
                print("Could not obtain permanent object id: \(error)")
            }
        }
        return MOCObjectsObserver(objectIDs: [objectID], contexts: [managedObjectContext!], fireInitially: fireInitially, block: block)
    }
}

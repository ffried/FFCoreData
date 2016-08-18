//
//  MOCObjectsObserver.swift
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

import Foundation
import CoreData

public final class MOCObjectsObserver: MOCObserver {
    public var objectIDs: [NSManagedObjectID] {
        didSet {
            #if swift(>=3.0)
                let tempIDs = objectIDs.filter { $0.isTemporaryID }
            #else
                let tempIDs = objectIDs.filter { $0.temporaryID }
            #endif
            if !tempIDs.isEmpty {
                assertionFailure("FFCoreData: ERROR: \(tempIDs) temporary NSManagedObjectIDs set on MOCObjectsObserver! Be sure to only use non-temporary IDs for MOCObservers!")
            }
        }
    }
    
    #if swift(>=3.0)
    private final var objectIDURIs: [URL] {
        return objectIDs.map { $0.uriRepresentation() }
    }
    #else
    private final var objectIDURIs: [NSURL] {
        return objectIDs.map { $0.URIRepresentation() }
    }
    #endif
    
    public required init(objectIDs: [NSManagedObjectID], contexts: [NSManagedObjectContext]? = nil, fireInitially: Bool = false, block: MOCObserverBlock) {
        self.objectIDs = objectIDs
        super.init(contexts: contexts, fireInitially: fireInitially, block: block)
    }
    
    #if swift(>=3.0)
    override func include(managedObject: NSManagedObject) -> Bool {
        if managedObject.objectID.isTemporaryID {
            do {
                try managedObject.managedObjectContext?.obtainPermanentIDs(for: [managedObject])
            } catch {
                print("FFCoreData: Could not obtain permanent object id: \(error)")
            }
        }
        return objectIDURIs.contains(managedObject.objectID.uriRepresentation())
    }
    #else
    override func includeManagedObject(object: NSManagedObject) -> Bool {
        if object.objectID.temporaryID {
            do {
                try object.managedObjectContext?.obtainPermanentIDsForObjects([object])
            } catch {
                print("FFCoreData: Could not obtain permanent object id: \(error)")
            }
        }
        return objectIDURIs.contains(object.objectID.URIRepresentation())
    }
    #endif
}

public extension NSManagedObject {
    public func createMOCObjectObserver(fireInitially: Bool = false, block: MOCObserver.MOCObserverBlock) -> MOCObjectsObserver {
        #if swift(>=3.0)
            if objectID.isTemporaryID {
                do {
                    try managedObjectContext?.obtainPermanentIDs(for: [self])
                } catch {
                    print("FFCoreData: Could not obtain permanent object id: \(error)")
                }
            }
        #else
            if objectID.temporaryID {
                do {
                    try managedObjectContext!.obtainPermanentIDsForObjects([self])
                } catch {
                    print("FFCoreData: Could not obtain permanent object id: \(error)")
                }
            }
        #endif
        return MOCObjectsObserver(objectIDs: [objectID], contexts: managedObjectContext.map { [$0] }, fireInitially: fireInitially, block: block)
    }
}

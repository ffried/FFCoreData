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

import struct Foundation.URL
import class CoreData.NSManagedObjectID
import class CoreData.NSManagedObject
import class CoreData.NSManagedObjectContext
#if canImport(os)
import func os.os_log
#else
import func FFFoundation.os_log
#endif

public final class MOCObjectsObserver: MOCObserver {
    public var objectIDs: [NSManagedObjectID] {
        didSet {
            precondition(!objectIDs.contains { $0.isTemporaryID },
                   "FFCoreData: ERROR: Temporary NSManagedObjectIDs set on MOCObjectsObserver! Be sure to only use non-temporary IDs for MOCObservers!")
        }
    }
    
    private final var objectIDURIs: [URL] {
        return objectIDs.map { $0.uriRepresentation() }
    }
    
    public required init(objectIDs: [NSManagedObjectID], contexts: [NSManagedObjectContext]? = nil, fireInitially: Bool = false, block: @escaping MOCObserverBlock) {
        self.objectIDs = objectIDs
        super.init(contexts: contexts, fireInitially: fireInitially, block: block)
    }

    override func include(managedObject: NSManagedObject) -> Bool {
        if managedObject.objectID.isTemporaryID {
            do {
                try managedObject.managedObjectContext?.obtainPermanentIDs(for: [managedObject])
            } catch {
                os_log("Could not obtain permanent object id: %@", log: .ffCoreData, type: .error, String(describing: error))
            }
        }
        return objectIDURIs.contains(managedObject.objectID.uriRepresentation())
    }
}

extension NSManagedObject {
    public func createMOCObjectObserver(fireInitially: Bool = false, block: @escaping MOCObserver.MOCObserverBlock) -> MOCObjectsObserver {
        if objectID.isTemporaryID {
            do {
                try managedObjectContext?.obtainPermanentIDs(for: [self])
            } catch {
                os_log("Could not obtain permanent object id: %@", log: .ffCoreData, type: .error, String(describing: error))
            }
        }
        
        return MOCObjectsObserver(objectIDs: [objectID], contexts: managedObjectContext.map { [$0] }, fireInitially: fireInitially, block: block)
    }
}

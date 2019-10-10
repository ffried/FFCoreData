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

public struct MOCObjectsFilter: MOCObserverFilter {
    var objectIDs: [NSManagedObjectID] {
        didSet {
            precondition(!objectIDs.contains { $0.isTemporaryID },
                         "FFCoreData: ERROR: Temporary NSManagedObjectIDs set on MOCObjectsObserver! Be sure to only use non-temporary IDs for MOCObservers!")
        }
    }

    private var objectIDURIs: [URL] { return objectIDs.map { $0.uriRepresentation() } }

    public init(objectIDs: [NSManagedObjectID]) {
        self.objectIDs = objectIDs
    }

    public func include(managedObject: NSManagedObject) -> Bool {
        managedObject.obtainPermanentID()
        return objectIDURIs.contains(managedObject.objectID.uriRepresentation())
    }
}

extension NSManagedObject {
    fileprivate final func obtainPermanentID() {
        guard !objectID.isTemporaryID else { return }
        do {
            try managedObjectContext?.obtainPermanentIDs(for: [self])
        } catch {
            os_log("Could not obtain permanent object id: %@", log: .ffCoreData, type: .error, String(describing: error))
        }
    }

    private var mocObservationMode: MOCObservationMode {
        return managedObjectContext.map { .singleContext($0) } ?? .allContexts
    }

    private var mocObjectsFilter: MOCObjectsFilter {
        obtainPermanentID()
        return MOCObjectsFilter(objectIDs: [objectID])
    }

    public func createMOCObjectObserver(fireInitially: Bool = false, handler: @escaping MOCBlockObserver<MOCObjectsFilter>.Handler) -> MOCBlockObserver<MOCObjectsFilter> {
        return MOCBlockObserver(mode: mocObservationMode, filter: mocObjectsFilter, fireInitially: fireInitially, handler: handler)
    }

    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func publishChanges() -> MOCChangePublisher<MOCObjectsFilter> {
        return MOCChangePublisher(mode: mocObservationMode, filter: mocObjectsFilter)
    }
}

fileprivate extension MOCObservationMode {
    init(contexts: [NSManagedObjectContext]) {
        if contexts.isEmpty {
            self = .allContexts
        } else if contexts.count == 1 {
            self = .singleContext(contexts[0])
        } else {
            self = .multipleContexts(contexts)
        }
    }
}

extension Sequence where Element: NSManagedObject {
    private func mocObservationModeAndObjectsFilter() -> (mode: MOCObservationMode, filter: MOCObjectsFilter) {
        var contexts = Array<NSManagedObjectContext>()
        contexts.reserveCapacity(underestimatedCount)
        var objectIDs = Array<NSManagedObjectID>()
        objectIDs.reserveCapacity(underestimatedCount)
        for obj in self {
            obj.obtainPermanentID()
            objectIDs.append(obj.objectID)
            if let moc = obj.managedObjectContext, !contexts.contains(moc) {
                contexts.append(moc)
            }
        }
        return (MOCObservationMode(contexts: contexts), MOCObjectsFilter(objectIDs: objectIDs))
    }

    public func createMOCObjectsObserver(fireInitially: Bool = false, handler: @escaping MOCBlockObserver<MOCObjectsFilter>.Handler) -> MOCBlockObserver<MOCObjectsFilter> {
        let (mode, filter) = mocObservationModeAndObjectsFilter()
        return MOCBlockObserver(mode: mode, filter: filter, fireInitially: fireInitially, handler: handler)
    }

    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func publishChanges() -> MOCChangePublisher<MOCObjectsFilter> {
        let (mode, filter) = mocObservationModeAndObjectsFilter()
        return MOCChangePublisher(mode: mode, filter: filter)
    }
}

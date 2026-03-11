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
public import CoreData
#if canImport(os)
import func os.os_log
#else
import func FFFoundation.os_log
#endif

public struct MOCObjectsFilter: MOCObserverFilter {
    var objectIDs: Array<NSManagedObjectID> {
        didSet {
            precondition(!objectIDs.contains(where: \.isTemporaryID),
                         "FFCoreData: ERROR: Temporary NSManagedObjectIDs set on MOCObjectsObserver! Be sure to only use non-temporary IDs for MOCObservers!")
        }
    }

    private var objectIDURIs: Array<URL> {
        objectIDs.map { $0.uriRepresentation() }
    }

    public init(objectIDs: Array<NSManagedObjectID>) {
        self.objectIDs = objectIDs
    }

    public func include(managedObject: NSManagedObject) -> Bool {
        managedObject.obtainPermanentID()
        return objectIDURIs.contains(managedObject.objectID.uriRepresentation())
    }
}

extension NSManagedObject {
    fileprivate final func obtainPermanentID() {
        guard objectID.isTemporaryID else { return }
#if compiler(>=6.2)
        do {
            try unsafe managedObjectContext?.obtainPermanentIDs(for: [self])
        } catch {
            unsafe os_log("Could not obtain permanent object id: %@", log: .ffCoreData, type: .error, String(describing: error))
        }
#else
        do {
            try managedObjectContext?.obtainPermanentIDs(for: [self])
        } catch {
            os_log("Could not obtain permanent object id: %@", log: .ffCoreData, type: .error, String(describing: error))
        }
#endif
    }

    private var mocObservationMode: MOCObservationMode {
#if compiler(>=6.2)
        unsafe managedObjectContext.map { .singleContext($0) } ?? .allContexts
#else
        managedObjectContext.map { .singleContext($0) } ?? .allContexts
#endif
    }

    private var mocObjectsFilter: MOCObjectsFilter {
        obtainPermanentID()
        return MOCObjectsFilter(objectIDs: [objectID])
    }

    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public var changes: MOCChanges<MOCObjectsFilter> {
        MOCChanges(mode: mocObservationMode, filter: mocObjectsFilter)
    }

    public func createMOCObjectObserver(fireInitially: Bool = false,
                                        handler: @escaping MOCBlockObserver<MOCObjectsFilter>.Handler) -> MOCBlockObserver<MOCObjectsFilter> {
        MOCBlockObserver(mode: mocObservationMode, filter: mocObjectsFilter, fireInitially: fireInitially, handler: handler)
    }

#if canImport(Combine)
    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func publishChanges() -> MOCChangePublisher<MOCObjectsFilter> {
        MOCChangePublisher(mode: mocObservationMode, filter: mocObjectsFilter)
    }
#endif
}

fileprivate extension MOCObservationMode {
    init(contexts: Array<NSManagedObjectContext>) {
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
#if compiler(>=6.2)
            if let moc = unsafe obj.managedObjectContext, !contexts.contains(moc) {
                contexts.append(moc)
            }
#else
            if let moc = obj.managedObjectContext, !contexts.contains(moc) {
                contexts.append(moc)
            }
#endif
        }
        return (MOCObservationMode(contexts: contexts), MOCObjectsFilter(objectIDs: objectIDs))
    }

    public func createMOCObjectsObserver(fireInitially: Bool = false, handler: @escaping MOCBlockObserver<MOCObjectsFilter>.Handler) -> MOCBlockObserver<MOCObjectsFilter> {
        let (mode, filter) = mocObservationModeAndObjectsFilter()
        return MOCBlockObserver(mode: mode, filter: filter, fireInitially: fireInitially, handler: handler)
    }

#if canImport(Combine)
    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func publishChanges() -> MOCChangePublisher<MOCObjectsFilter> {
        let (mode, filter) = mocObservationModeAndObjectsFilter()
        return MOCChangePublisher(mode: mode, filter: filter)
    }
#endif
}

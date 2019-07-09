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
import CoreData

public protocol MOCObserverFilter {
    func include(managedObject: NSManagedObject) -> Bool
}

public enum MOCObservationMode {
    case allContexts
    case singleContext(NSManagedObjectContext)
    case multipleContexts(Array<NSManagedObjectContext>)

    internal var nonEmptyContexts: Array<NSManagedObjectContext>? {
        switch self {
        case .allContexts: return nil
        case .singleContext(let context): return [context]
        case .multipleContexts(let contexts):
            assert(!contexts.isEmpty, "Found an empty array in `multipleContexts`. Use `allContexts` instead!")
            return contexts.isEmpty ? nil : contexts
        }
    }
}

public struct MOCObservedChanges {
    public private(set) var inserted: [NSManagedObjectID] = []
    public private(set) var updated: [NSManagedObjectID] = []
    public private(set) var deleted: [NSManagedObjectID] = []
}

extension MOCObservedChanges {
    fileprivate init(readingFrom changes: [AnyHashable: Any], filteringWith filter: (NSManagedObject) -> Bool) {
        changes.map(keysToKeyPaths: [(NSInsertedObjectsKey, \.inserted), (NSUpdatedObjectsKey, \.updated), (NSDeletedObjectsKey, \.deleted)],
                    to: &self,
                    transformingValuesTo: Set<NSManagedObject>.self,
                    with: { $0.filter(filter).map { $0.objectID } })
    }

    internal init?<Filter: MOCObserverFilter>(notification: Notification, filter: Filter) {
        assert(notification.name == .NSManagedObjectContextObjectsDidChange)
        guard let userInfo = notification.userInfo else { return nil }
        self.init(readingFrom: userInfo, filteringWith: filter.include)
    }
}

fileprivate extension Dictionary {
    func map<Input, Output, Object>(keysToKeyPaths: [(key: Key, keyPath: WritableKeyPath<Object, Output>)],
                                    to object: inout Object,
                                    transformingValuesTo input: Input.Type = Input.self,
                                    with transformClosure: (Input) throws -> Output) rethrows {
        try keysToKeyPaths.lazy
            .compactMap { mapping in (self[mapping.key] as? Input).map { (input: $0, keyPath: mapping.keyPath) } }
            .forEach { object[keyPath: $0.keyPath] = try transformClosure($0.input) }
    }
}

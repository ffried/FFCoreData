//
//  MOCEntitiesObserver.swift
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

import class CoreData.NSEntityDescription
import class CoreData.NSManagedObject
import class CoreData.NSManagedObjectContext

public struct MOCEntitiesFilter: MOCObserverFilter, Sendable {
    public var entityNames: Array<String>

    public init(entityNames: Array<String>) {
        self.entityNames = entityNames
    }

    public init(entities: Array<NSEntityDescription>) {
        self.init(entityNames: entities.map { $0.name ?? $0.managedObjectClassName })
    }

    public func include(managedObject: NSManagedObject) -> Bool {
        entityNames.contains(managedObject.entity.name ?? managedObject.entity.managedObjectClassName)
    }
}

extension Fetchable where Self: NSManagedObject {
    public static func createMOCEntitiesObserver(with mode: MOCObservationMode = .allContexts, fireInitially: Bool = false,
                                                 handler: @escaping MOCBlockObserver<MOCEntitiesFilter>.Handler) -> MOCBlockObserver<MOCEntitiesFilter> {
        .init(mode: mode, filter: MOCEntitiesFilter(entityNames: [entityName]), fireInitially: fireInitially, handler: handler)
    }

    #if canImport(Combine)
    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public static func publishEntityChanges(with mode: MOCObservationMode = .allContexts) -> MOCChangePublisher<MOCEntitiesFilter> {
        .init(mode: mode, filter: MOCEntitiesFilter(entityNames: [entityName]))
    }
    #endif

    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public static func changes(with mode: MOCObservationMode = .allContexts) -> MOCChanges<MOCEntitiesFilter> {
        .init(mode: mode, filter: MOCEntitiesFilter(entityNames: [entityName]))
    }
}

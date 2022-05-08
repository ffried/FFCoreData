//
//  KeyObjectDictionary.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 27.07.20.
//  Copyright © 2020 Florian Friedrich. All rights reserved.
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

import Foundation
import CoreData
import FFFoundation

extension NSPredicate {
    @inlinable
    public convenience init(format: String, arguments: Any...) {
        self.init(format: format, argumentArray: arguments)
    }
}

public typealias KeyObjectDictionary = Dictionary<String, Any>

internal extension NSCompoundPredicate {
    @usableFromInline
    convenience init(type: LogicalType, dictionary: KeyObjectDictionary) {
        self.init(type: type, subpredicates: dictionary.map {
            NSPredicate(format: "%K == %@", arguments: $0.key, $0.value)
        })
    }
}

internal extension KeyObjectDictionary {
    func apply<Object: Entity & NSManagedObject>(to object: Object, in context: NSManagedObjectContext) {
        forEach {
            if let id = $1 as? NSManagedObjectID {
                object.setValue(context.object(with: id), forKey: $0)
            } else {
                object.setValue($1, forKey: $0)
            }
        }
    }
}

public struct KeyObjectDictionaryExpression<Model: Entity> {
    @usableFromInline
    let dict: KeyObjectDictionary

    @usableFromInline
    init(dict: KeyObjectDictionary) { self.dict = dict }
}

extension KeyObjectDictionaryExpression where Model: Fetchable {
    @inlinable
    var filter: FetchableFilterExpression<Model> {
        .init(predicate: NSCompoundPredicate(type: .and, dictionary: dict))
    }
}

fileprivate extension AnyKeyPath {
    var keyObjectDictionaryKey: KeyObjectDictionary.Key {
        guard let kvcString = _kvcKeyPathString else { fatalError("Cannot get key value coding string from \(self)!") }
        return kvcString
    }
}

public func == <Model, Value: Equatable>(lhs: KeyPath<Model, Value>, rhs: Value) -> KeyObjectDictionaryExpression<Model> {
    .init(dict: [lhs.keyObjectDictionaryKey: rhs])
}

@inlinable
public func != <Model>(lhs: KeyPath<Model, Bool>, rhs: Bool) -> KeyObjectDictionaryExpression<Model> {
    lhs == !rhs
}

@inlinable
public func != <Model>(lhs: KeyPath<Model, Bool?>, rhs: Bool?) -> KeyObjectDictionaryExpression<Model> {
    lhs == rhs.map(!)
}

@inlinable
public func && <Model>(lhs: KeyObjectDictionaryExpression<Model>, rhs: KeyObjectDictionaryExpression<Model>) -> KeyObjectDictionaryExpression<Model> {
    .init(dict: lhs.dict.merging(rhs.dict, uniquingKeysWith: { $1 }))
}

//
//  FetchableFilterExpression.swift
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
//

import Foundation
import FFFoundation

public struct FetchableFilterExpression<Model: Fetchable> {
    @usableFromInline
    let predicate: NSPredicate

    @usableFromInline
    init(predicate: NSPredicate) { self.predicate = predicate }
}

// MARK: - Equatable
// MARK: KeyPath (left)
@inlinable
public func == <Model>(lhs: KeyPath<Model, Bool>, rhs: Bool?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model>(lhs: KeyPath<Model, Bool>, rhs: Bool?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

@inlinable
public func == <Model, Value: Equatable>(lhs: KeyPath<Model, Value>, rhs: Value?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model, Value: Equatable>(lhs: KeyPath<Model, Value>, rhs: Value?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

@inlinable
public func == <Model, Value: Equatable & ReferenceConvertible>(lhs: KeyPath<Model, Value>, rhs: Value?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model, Value: Equatable & ReferenceConvertible>(lhs: KeyPath<Model, Value>, rhs: Value?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

//@inlinable
//public func == <Model, Value: Equatable & ReferenceConvertible>(lhs: KeyPath<Model, Value?>, rhs: Value?) -> FetchableFilterExpression<Model> {
//    return .init(predicate: lhs == rhs)
//}
//
//@inlinable
//public func != <Model, Value: Equatable & ReferenceConvertible>(lhs: KeyPath<Model, Value?>, rhs: Value?) -> FetchableFilterExpression<Model> {
//    return .init(predicate: lhs != rhs)
//}

@inlinable
public func == <Model, Value: Equatable & SignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model, Value: Equatable & SignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

@inlinable
public func == <Model, Value: Equatable & UnsignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model, Value: Equatable & UnsignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

@inlinable
public func == <Model, Value: Equatable & FloatingPoint>(lhs: KeyPath<Model, Value>, rhs: Value?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model, Value: Equatable & FloatingPoint>(lhs: KeyPath<Model, Value>, rhs: Value?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

@inlinable
public func == <Model>(lhs: KeyPath<Model, NSNumber>, rhs: NSNumber?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model>(lhs: KeyPath<Model, NSNumber>, rhs: NSNumber?) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

//@inlinable
//public func == <Model>(lhs: KeyPath<Model, NSNumber?>, rhs: NSNumber?) -> FetchableFilterExpression<Model> {
//    return .init(predicate: lhs == rhs)
//}
//
//@inlinable
//public func != <Model>(lhs: KeyPath<Model, NSNumber?>, rhs: NSNumber?) -> FetchableFilterExpression<Model> {
//    return .init(predicate: lhs != rhs)
//}

// MARK: KeyPath (right)
@inlinable
public func == <Model>(lhs: Bool?, rhs: KeyPath<Model, Bool>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model>(lhs: Bool?, rhs: KeyPath<Model, Bool>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

@inlinable
public func == <Model, Value: Equatable>(lhs: Value?, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model, Value: Equatable>(lhs: Value?, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

@inlinable
public func == <Model, Value: Equatable & ReferenceConvertible>(lhs: Value?, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model, Value: Equatable & ReferenceConvertible>(lhs: Value?, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

//@inlinable
//public func == <Model, Value: Equatable & ReferenceConvertible>(lhs: Value?, rhs: KeyPath<Model, Value?>) -> FetchableFilterExpression<Model> {
//    return .init(predicate: lhs == rhs)
//}
//
//@inlinable
//public func != <Model, Value: Equatable & ReferenceConvertible>(lhs: Value?, rhs: KeyPath<Model, Value?>) -> FetchableFilterExpression<Model> {
//    return .init(predicate: lhs != rhs)
//}

@inlinable
public func == <Model, Value: Equatable & SignedInteger>(lhs: Value?, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model, Value: Equatable & SignedInteger>(lhs: Value?, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

@inlinable
public func == <Model, Value: Equatable & UnsignedInteger>(lhs: Value?, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model, Value: Equatable & UnsignedInteger>(lhs: Value?, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

@inlinable
public func == <Model, Value: Equatable & FloatingPoint>(lhs: Value?, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model, Value: Equatable & FloatingPoint>(lhs: Value?, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

@inlinable
public func == <Model>(lhs: NSNumber?, rhs: KeyPath<Model, NSNumber>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs == rhs)
}

@inlinable
public func != <Model>(lhs: NSNumber?, rhs: KeyPath<Model, NSNumber>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs != rhs)
}

//@inlinable
//public func == <Model>(lhs: NSNumber?, rhs: KeyPath<Model, NSNumber?>) -> FetchableFilterExpression<Model> {
//    return .init(predicate: lhs == rhs)
//}
//
//@inlinable
//public func != <Model>(lhs: NSNumber?, rhs: KeyPath<Model, NSNumber?>) -> FetchableFilterExpression<Model> {
//    return .init(predicate: lhs != rhs)
//}

// MARK: - Comparable
// MARK: KeyPath (left)
@inlinable
public func < <Model, Value: Comparable>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model, Value: Comparable>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model, Value: Comparable>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model, Value: Comparable>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

@inlinable
public func < <Model, Value: Comparable & ReferenceConvertible>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model, Value: Comparable & ReferenceConvertible>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model, Value: Comparable & ReferenceConvertible>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model, Value: Comparable & ReferenceConvertible>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

@inlinable
public func < <Model, Value: Comparable & SignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model, Value: Comparable & SignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model, Value: Comparable & SignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model, Value: Comparable & SignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

@inlinable
public func < <Model, Value: Comparable & UnsignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model, Value: Comparable & UnsignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model, Value: Comparable & UnsignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model, Value: Comparable & UnsignedInteger>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

@inlinable
public func < <Model, Value: Comparable & FloatingPoint>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model, Value: Comparable & FloatingPoint>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model, Value: Comparable & FloatingPoint>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model, Value: Comparable & FloatingPoint>(lhs: KeyPath<Model, Value>, rhs: Value) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

@inlinable
public func < <Model>(lhs: KeyPath<Model, NSNumber>, rhs: NSNumber) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model>(lhs: KeyPath<Model, NSNumber>, rhs: NSNumber) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model>(lhs: KeyPath<Model, NSNumber>, rhs: NSNumber) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model>(lhs: KeyPath<Model, NSNumber>, rhs: NSNumber) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

// MARK: KeyPath (right)
@inlinable
public func < <Model, Value: Comparable>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model, Value: Comparable>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model, Value: Comparable>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model, Value: Comparable>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

@inlinable
public func < <Model, Value: Comparable & ReferenceConvertible>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model, Value: Comparable & ReferenceConvertible>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model, Value: Comparable & ReferenceConvertible>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model, Value: Comparable & ReferenceConvertible>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

@inlinable
public func < <Model, Value: Comparable & SignedInteger>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model, Value: Comparable & SignedInteger>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model, Value: Comparable & SignedInteger>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model, Value: Comparable & SignedInteger>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

@inlinable
public func < <Model, Value: Comparable & UnsignedInteger>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model, Value: Comparable & UnsignedInteger>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model, Value: Comparable & UnsignedInteger>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model, Value: Comparable & UnsignedInteger>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

@inlinable
public func < <Model, Value: Comparable & FloatingPoint>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model, Value: Comparable & FloatingPoint>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model, Value: Comparable & FloatingPoint>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model, Value: Comparable & FloatingPoint>(lhs: Value, rhs: KeyPath<Model, Value>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

@inlinable
public func < <Model>(lhs: NSNumber, rhs: KeyPath<Model, NSNumber>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs < rhs)
}

@inlinable
public func > <Model>(lhs: NSNumber, rhs: KeyPath<Model, NSNumber>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs > rhs)
}

@inlinable
public func <= <Model>(lhs: NSNumber, rhs: KeyPath<Model, NSNumber>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs <= rhs)
}

@inlinable
public func >= <Model>(lhs: NSNumber, rhs: KeyPath<Model, NSNumber>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs >= rhs)
}

// MARK: - Negation
@inlinable
public prefix func ! <Model>(lhs: KeyPath<Model, Bool>) -> FetchableFilterExpression<Model> { return lhs != true }

@inlinable
public prefix func ! <Model>(lhs: FetchableFilterExpression<Model>) -> FetchableFilterExpression<Model> {
    return .init(predicate: !lhs.predicate)
}

// MARK: - Combination
@inlinable
public func && <Model>(lhs: FetchableFilterExpression<Model>, rhs: FetchableFilterExpression<Model>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs.predicate && rhs.predicate)
}

@inlinable
public func || <Model>(lhs: FetchableFilterExpression<Model>, rhs: FetchableFilterExpression<Model>) -> FetchableFilterExpression<Model> {
    return .init(predicate: lhs.predicate || rhs.predicate)
}

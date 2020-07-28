//
//  FetchableSortExpression.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 28.07.20.
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

public struct FetchableSortExpression<Model: Fetchable> {
    @usableFromInline
    let sortDescriptor: NSSortDescriptor

    @usableFromInline
    init(sortDescriptor: NSSortDescriptor) { self.sortDescriptor = sortDescriptor }
}

public prefix func ^ <Model, Value: Comparable>(rhs: KeyPath<Model, Value>) -> FetchableSortExpression<Model> {
    .init(sortDescriptor: ^rhs)
}

public prefix func !^ <Model, Value: Comparable>(rhs: KeyPath<Model, Value>) -> FetchableSortExpression<Model> {
    .init(sortDescriptor: !^rhs)
}

public prefix func ^ <Model, Value: Comparable>(rhs: KeyPath<Model, Value?>) -> FetchableSortExpression<Model> {
    .init(sortDescriptor: .init(keyPath: rhs, ascending: true))
}

public prefix func !^ <Model, Value: Comparable>(rhs: KeyPath<Model, Value?>) -> FetchableSortExpression<Model> {
    .init(sortDescriptor: .init(keyPath: rhs, ascending: false))
}

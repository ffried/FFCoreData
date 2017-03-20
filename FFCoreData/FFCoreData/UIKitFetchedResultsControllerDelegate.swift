//
//  UIKitFetchedResultsControllerDelegate.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 13/06/15.
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

#if os(iOS)
import struct Foundation.IndexPath
import protocol CoreData.NSFetchRequestResult

public class UIKitFetchedResultsControllerManager<Result: NSFetchRequestResult>: FetchedResultsControllerManager<Result> {
    public final var preserveSelection = true
    
    internal final var selectedIndexPaths = Set<IndexPath>()
    
    internal final func reapplySelection() {
        let indexPaths = selectedIndexPaths
        selectedIndexPaths.removeAll()
        if preserveSelection { select(indexPaths: indexPaths) }
    }
    
    internal func select(indexPaths: Set<IndexPath>) {}
}
#endif

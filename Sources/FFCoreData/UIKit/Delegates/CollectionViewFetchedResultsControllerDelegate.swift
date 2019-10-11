//
//  CollectionViewFetchedResultsControllerDelegate.swift
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

#if canImport(UIKit) && !os(watchOS)
import struct Foundation.IndexSet
import struct Foundation.IndexPath
import protocol CoreData.NSFetchRequestResult
import class CoreData.NSFetchedResultsController
import class UIKit.UICollectionView

public final class CollectionViewFetchedResultsControllerManager<Result: NSFetchRequestResult>: UIKitFetchedResultsControllerManager<Result> {
    
    public private(set) weak var collectionView: UICollectionView?
    
    public required init(fetchedResultsController: Controller, collectionView: UICollectionView, delegate: Delegate? = nil) {
        self.collectionView = collectionView
        super.init(fetchedResultsController: fetchedResultsController, delegate: delegate)
    }
    
    // MARK: - Begin / End Updates
    override func beginUpdates() {
        super.beginUpdates()
    }
    
    override func endUpdates() {
        super.endUpdates()
        reapplySelection()
    }
    
    // MARK: - Selection
    override func select(indexPaths: Set<IndexPath>) {
        super.select(indexPaths: indexPaths)
        indexPaths.forEach { self.collectionView?.selectItem(at: $0, animated: false, scrollPosition: []) }
    }
    
    // MARK: Sections
    override func insertSection(at index: Int) {
        super.insertSection(at: index)
        collectionView?.insertSections(IndexSet(integer: index))
    }
    
    override func updateSection(at index: Int) {
        super.updateSection(at: index)
        collectionView?.reloadSections(IndexSet(integer: index))
    }
    
    override func removeSection(at index: Int) {
        super.removeSection(at: index)
        collectionView?.deleteSections(IndexSet(integer: index))
    }
    
    override func moveSection(from oldIndex: Int, to newIndex: Int) {
        super.moveSection(from: oldIndex, to: newIndex)
        collectionView?.moveSection(oldIndex, toSection: newIndex)
    }
    
    // MARK: - Items
    override func insertSubobject(at indexPath: IndexPath) {
        super.insertSubobject(at: indexPath)
        collectionView?.insertItems(at: [indexPath])
    }
    
    override func updateSubobject(at indexPath: IndexPath) {
        super.updateSubobject(at: indexPath)
        let selected = collectionView?.indexPathsForSelectedItems?.contains(indexPath)
        collectionView?.reloadItems(at: [indexPath])
        if let s = selected, s { selectedIndexPaths.insert(indexPath) }
    }
    
    override func removeSubobject(at indexPath: IndexPath) {
        super.removeSubobject(at: indexPath)
        collectionView?.deleteItems(at: [indexPath])
    }
    
    override func moveSubobject(from oldIndexPath: IndexPath, to newIndexPath: IndexPath) {
        super.moveSubobject(from: oldIndexPath, to: newIndexPath)
        collectionView?.moveItem(at: oldIndexPath, to: newIndexPath)
    }
}
#endif

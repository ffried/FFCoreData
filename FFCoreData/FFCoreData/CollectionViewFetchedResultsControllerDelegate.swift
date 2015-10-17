//
//  CollectionViewFetchedResultsControllerDelegate.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 13/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

#if os(iOS)
import Foundation
import UIKit
import CoreData

public class CollectionViewFetchedResultsControllerDelegate: UIKitFetchedResultsControllerDelegate {
    
    public private(set) weak var collectionView: UICollectionView?
    
    public required init(fetchedResultsController: NSFetchedResultsController, collectionView: UICollectionView, delegate: FetchedResultsControllerDelegateDelegate? = nil) {
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
    override func selectIndexPaths(indexPaths: [NSIndexPath]) {
        super.selectIndexPaths(indexPaths)
        indexPaths.forEach { self.collectionView?.selectItemAtIndexPath($0, animated: false, scrollPosition: .None) }
    }
    
    // MARK: Sections
    override func insertSectionAtIndex(index: Int) {
        super.insertSectionAtIndex(index)
        collectionView?.insertSections(NSIndexSet(index: index))
    }
    
    override func updateSectionAtIndex(index: Int) {
        super.updateSectionAtIndex(index)
        collectionView?.reloadSections(NSIndexSet(index: index))
    }
    
    override func removeSectionAtIndex(index: Int) {
        super.removeSectionAtIndex(index)
        collectionView?.deleteSections(NSIndexSet(index: index))
    }
    
    override func moveSectionFromIndex(fromIndex: Int, toIndex: Int) {
        super.moveSectionFromIndex(fromIndex, toIndex: toIndex)
        collectionView?.moveSection(fromIndex, toSection: toIndex)
    }
    
    // MARK: - Items
    override func insertSubobjectAtIndexPath(indexPath: NSIndexPath) {
        super.insertSubobjectAtIndexPath(indexPath)
        collectionView?.insertItemsAtIndexPaths([indexPath])
    }
    
    override func updateSubobjectAtIndexPath(indexPath: NSIndexPath) {
        super.updateSubobjectAtIndexPath(indexPath)
        let selected = collectionView?.indexPathsForSelectedItems()?.contains(indexPath)
        collectionView?.reloadItemsAtIndexPaths([indexPath])
        if let s = selected where s == true { selectedIndexPaths.insert(indexPath) }
    }
    
    override func removeSubobjectAtIndexPath(indexPath: NSIndexPath) {
        super.removeSubobjectAtIndexPath(indexPath)
        collectionView?.deleteItemsAtIndexPaths([indexPath])
    }
    
    override func moveSubobjectFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        super.moveSubobjectFromIndexPath(fromIndexPath, toIndexPath: toIndexPath)
        collectionView?.moveItemAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
    }
}
#endif

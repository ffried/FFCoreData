//
//  CollectionViewDataSource.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 13/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

#if os(iOS)
import Foundation
import UIKit
import CoreData

@objc public protocol CollectionViewDataSourceDelegate: NSObjectProtocol {
    func collectionView(collectionView: UICollectionView, cellIdentifierForItemAtIndexPath: NSIndexPath) -> String
    func collectionView(collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forRowAtIndexPath indexPath: NSIndexPath, withObject: NSManagedObject?)
    
    // See UICollectionViewDataSource
    optional func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    @available(iOS 9.0, *)
    optional func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    @available(iOS 9.0, *)
    optional func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
}

public class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    public private(set) weak var collectionView: UICollectionView?
    public private(set) weak var fetchedResultsController: NSFetchedResultsController?
    
    public weak var delegate: CollectionViewDataSourceDelegate?
    
    public required init(collectionView: UICollectionView, controller: NSFetchedResultsController, delegate: CollectionViewDataSourceDelegate) {
        self.fetchedResultsController = controller
        self.collectionView = collectionView
        self.delegate = delegate
        super.init()
        self.collectionView?.dataSource = self
    }
    
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        if aSelector == "collectionView:viewForSupplementaryElementOfKind:atIndexPath:" {
            return delegate?.respondsToSelector(aSelector) ?? false
        }
        return super.respondsToSelector(aSelector)
    }
    
    // MARK: - UICollectionViewDataSource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = delegate?.collectionView(collectionView, cellIdentifierForItemAtIndexPath: indexPath) ?? "Cell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        let object = fetchedResultsController?.objectAtIndexPath(indexPath) as? NSManagedObject
        delegate?.collectionView(collectionView, configureCell: cell, forRowAtIndexPath: indexPath, withObject: object)
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return delegate!.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
    }
    
    @available(iOS 9.0, *)
    public func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return delegate?.collectionView?(collectionView, canMoveItemAtIndexPath: indexPath) ?? delegate?.respondsToSelector("collectionView:moveItemAtIndexPath:toIndexPath:") ?? false
    }
    
    @available(iOS 9.0, *)
    public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        delegate?.collectionView?(collectionView, moveItemAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
}
#endif

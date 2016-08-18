//
//  CollectionViewDataSource.swift
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

import Foundation
import UIKit
import CoreData

@objc public protocol CollectionViewDataSourceDelegate: class, NSObjectProtocol {
    #if swift(>=3.0)
    func collectionView(_ collectionView: UICollectionView, cellIdentifierForItemAt: IndexPath) -> String
    func collectionView(_ collectionView: UICollectionView, configure cell: UICollectionViewCell, forItemAt indexPath: IndexPath, with: NSFetchRequestResult?)
    
    // See UICollectionViewDataSource
    @objc optional func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    @available(iOS 9.0, *)
    @objc optional func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    @available(iOS 9.0, *)
    @objc optional func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    #else
    func collectionView(collectionView: UICollectionView, cellIdentifierForItemAtIndexPath: NSIndexPath) -> String
    func collectionView(collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forRowAtIndexPath indexPath: NSIndexPath, withObject: NSManagedObject?)
    
    // See UICollectionViewDataSource
    optional func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    @available(iOS 9.0, *)
    optional func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    @available(iOS 9.0, *)
    optional func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    #endif
}

#if swift(>=3.0)
public final class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    public private(set) weak var collectionView: UICollectionView?
    public private(set) weak var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    public weak var delegate: CollectionViewDataSourceDelegate?
    
    public required init(collectionView: UICollectionView, controller: NSFetchedResultsController<NSFetchRequestResult>, delegate: CollectionViewDataSourceDelegate? = nil) {
        self.fetchedResultsController = controller
        self.collectionView = collectionView
        self.delegate = delegate
        super.init()
        self.collectionView?.dataSource = self
    }
    
    @objc public override func responds(to aSelector: Selector) -> Bool {
        let selectorToCheck = #selector(CollectionViewDataSourceDelegate.collectionView(_:viewForSupplementaryElementOfKind:at:))
        if selectorToCheck == aSelector {
            return delegate?.responds(to: aSelector) ?? false
        }
        return super.responds(to: aSelector)
    }
    
    // MARK: - UICollectionViewDataSource
    @objc public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = delegate?.collectionView(collectionView, cellIdentifierForItemAt: indexPath) ?? "Cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        let object = fetchedResultsController?.object(at: indexPath)
        delegate?.collectionView(collectionView, configure: cell, forItemAt: indexPath, with: object)
        return cell
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return delegate!.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    @available(iOS 9.0, *)
    @objc public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        let delegateResponds = delegate?.responds(to: #selector(CollectionViewDataSourceDelegate.collectionView(_:moveItemAt:to:)))
        return delegate?.collectionView?(collectionView, canMoveItemAt: indexPath) ?? delegateResponds ?? false
    }
    
    @available(iOS 9.0, *)
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        delegate?.collectionView?(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
    }
}
#else
public final class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
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
        #if swift(>=2.2)
            let selectorToCheck = #selector(CollectionViewDataSourceDelegate.collectionView(_:viewForSupplementaryElementOfKind:atIndexPath:))
        #else
            let selectorToCheck = "collectionView:viewForSupplementaryElementOfKind:atIndexPath:"
        #endif
        if selectorToCheck == aSelector {
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
        #if swift(>=2.2)
            let delegateResponds = delegate?.respondsToSelector(#selector(CollectionViewDataSourceDelegate.collectionView(_:moveItemAtIndexPath:toIndexPath:)))
        #else
            let delegateResponds = delegate?.respondsToSelector("collectionView:moveItemAtIndexPath:toIndexPath:")
        #endif
        return delegate?.collectionView?(collectionView, canMoveItemAtIndexPath: indexPath) ?? delegateResponds ?? false
    }
    
    @available(iOS 9.0, *)
    public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        delegate?.collectionView?(collectionView, moveItemAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
}
#endif

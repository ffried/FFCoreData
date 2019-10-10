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

#if canImport(UIKit) && !os(watchOS)
import protocol Foundation.NSObjectProtocol
import struct Foundation.Selector
import class Foundation.NSObject
import struct Foundation.IndexPath
import protocol UIKit.UICollectionViewDataSource
import class UIKit.UICollectionView
import class UIKit.UICollectionViewCell
import class UIKit.UICollectionReusableView
import protocol CoreData.NSFetchRequestResult
import class CoreData.NSFetchedResultsController

@objc public protocol CollectionViewDataSourceDelegate: class, NSObjectProtocol {
    func collectionView(_ collectionView: UICollectionView, cellIdentifierForItemAt: IndexPath) -> String
    func collectionView(_ collectionView: UICollectionView, configure cell: UICollectionViewCell, forItemAt indexPath: IndexPath, with: NSFetchRequestResult?)
    
    // See UICollectionViewDataSource
    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)
    optional func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    @available(iOS 9.0, *)
    @objc(collectionView:canMoveItemAtIndexPath:)
    optional func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    @available(iOS 9.0, *)
    @objc(collectionView:moveItemAtIndexPath:toIndexPath:)
    optional func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

public final class CollectionViewDataSource<Result: NSFetchRequestResult>: NSObject, UICollectionViewDataSource {
    public private(set) weak var collectionView: UICollectionView?
    public private(set) weak var fetchedResultsController: NSFetchedResultsController<Result>?
    
    public weak var delegate: CollectionViewDataSourceDelegate?
    
    public required init(collectionView: UICollectionView, controller: NSFetchedResultsController<Result>, delegate: CollectionViewDataSourceDelegate? = nil) {
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
    @objc(numberOfSectionsInCollectionView:)
    public dynamic func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    @objc public dynamic func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    @objc(collectionView:cellForItemAtIndexPath:)
    public dynamic func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = delegate?.collectionView(collectionView, cellIdentifierForItemAt: indexPath) ?? "Cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        let object = fetchedResultsController?.object(at: indexPath)
        delegate?.collectionView(collectionView, configure: cell, forItemAt: indexPath, with: object)
        return cell
    }
    
    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)
    public dynamic func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return delegate!.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    @available(iOS 9.0, *)
    @objc(collectionView:canMoveItemAtIndexPath:)
    public dynamic func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        let delegateResponds = delegate?.responds(to: #selector(CollectionViewDataSourceDelegate.collectionView(_:moveItemAt:to:)))
        return delegate?.collectionView?(collectionView, canMoveItemAt: indexPath) ?? delegateResponds ?? false
    }
    
    @available(iOS 9.0, *)
    @objc(collectionView:moveItemAtIndexPath:toIndexPath:)
    public dynamic func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        delegate?.collectionView?(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
    }
}
#endif

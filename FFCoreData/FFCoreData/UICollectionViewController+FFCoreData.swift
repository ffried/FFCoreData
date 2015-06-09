//
//  UICollectionViewController+FFCoreData.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 09/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

#if os(iOS)
import FFCoreData
import UIKit

public extension UICollectionViewController {
    private struct PropertyKeys {
        static var ManagedObjectContext = "UICollectionViewController+FFCoreData.ManagedObjectContext"
        static var FetchedResultsController = "UICollectionViewController+FFCoreData.FetchedResultsController"
        static var DataSource = "UICollectionViewController+FFCoreData.DataSource"
        static var FetchedResultsControllerDelegate = "UICollectionViewController+FFCoreData.FetchedResultsControllerDelegate"
    }
    /**
    *  The managed object context of the UICollectionViewController (used for the NSFetchedResultsController).
    */
    public var managedObjectContext: NSManagedObjectContext {
        get {
            if let moc = objc_getAssociatedObject(self, &PropertyKeys.ManagedObjectContext) as? NSManagedObjectContext
            {
                return moc
            } else {
                self.managedObjectContext = FFCDMainContext()
                return self.managedObjectContext
            }
        }
        set {
            objc_setAssociatedObject(self, &PropertyKeys.ManagedObjectContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
    *  The fetched results controller for the collectionView.
    */
    public var fetchedResultsController: NSFetchedResultsController? {
        get {
            return objc_getAssociatedObject(self, &PropertyKeys.FetchedResultsController) as? NSFetchedResultsController
        }
        set {
            objc_setAssociatedObject(self, &PropertyKeys.FetchedResultsController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
    *  The delegate of the fetched results controller.
    */
    public var fetchedResultsControllDelegate: FFCDCollectionViewFetchedResultsControllerDelegate? {
        get {
            return objc_getAssociatedObject(self, &PropertyKeys.FetchedResultsControllerDelegate) as? FFCDCollectionViewFetchedResultsControllerDelegate
        }
        set {
            objc_setAssociatedObject(self, &PropertyKeys.FetchedResultsControllerDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
    *  The data source for the tableview.
    */
    public var dataSource: FFCDCollectionViewDataSource? {
        get {
            return objc_getAssociatedObject(self, &PropertyKeys.DataSource) as? FFCDCollectionViewDataSource
        }
        set {
            objc_setAssociatedObject(self, &PropertyKeys.DataSource, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
    *  Sets up the fetchedResultsControllerDelegate and the dataSource with its delegates.
    *  The managedObjectContext and the fetchedResultsController must be set before this method is called!
    *  @param frcDelegate        The delegate for the FFCDCollectionViewFetchedResultsControllerDelegate.
    *  @param dataSourceDelegate The delegate for the FFCDCollectinViewDataSource.
    */
    func setupWithFetchedResultsControllerDelegate(frcDelegate: FFCDFetchedResultsControllerDelegateProtocol, dataSourceDelegate: FFCDCollectionViewDataSourceDelegate) {
        if let frc = fetchedResultsController, let collectionView = collectionView {
            collectionView.delegate = self
            fetchedResultsControllDelegate = FFCDCollectionViewFetchedResultsControllerDelegate(fetchedResultsController: frc, delegate: frcDelegate, collectionView: collectionView)
            dataSource = FFCDCollectionViewDataSource(fetchedResultsController: frc, delegate: dataSourceDelegate, collectionView: collectionView)
        } else {
            
        }
    }
    
    /**
    *  Sets up the fetchedResultsControllerDelegate and the dataSource with the same delegate.
    *  @param delegate The delegate for both, the fetchedResultsControllerDelegate and the dataSource.
    */
    func setupWithDelegate(delegate: protocol<FFCDFetchedResultsControllerDelegateProtocol, FFCDCollectionViewDataSourceDelegate>) {
        setupWithFetchedResultsControllerDelegate(delegate, dataSourceDelegate: delegate)
    }
}
#endif

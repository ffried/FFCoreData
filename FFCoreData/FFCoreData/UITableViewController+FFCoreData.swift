//
//  UITableViewController+FFCoreData.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 09/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

#if os(iOS)
import FFCoreData
import UIKit
    
public extension UITableViewController {
    private struct PropertyKeys {
        static var ManagedObjectContext = "UITableViewController+FFCoreData.ManagedObjectContext"
        static var FetchedResultsController = "UITableViewController+FFCoreData.FetchedResultsController"
        static var DataSource = "UITableViewController+FFCoreData.DataSource"
        static var FetchedResultsControllerDelegate = "UITableViewController+FFCoreData.FetchedResultsControllerDelegate"
    }
    /**
    *  The managed object context of the UITableViewController (used for the NSFetchedResultsController).
    */
    public var managedObjectContext: NSManagedObjectContext {
        get {
            if let moc = objc_getAssociatedObject(self, &PropertyKeys.ManagedObjectContext) as? NSManagedObjectContext
            {
                return moc
            } else {
                self.managedObjectContext = CoreDataStack.MainContext
                return self.managedObjectContext
            }
        }
        set {
            objc_setAssociatedObject(self, &PropertyKeys.ManagedObjectContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
    *  The fetched results controller for the tableview.
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
    public var fetchedResultsControllDelegate: TableViewFetchedResultsControllerDelegate? {
        get {
            return objc_getAssociatedObject(self, &PropertyKeys.FetchedResultsControllerDelegate) as? TableViewFetchedResultsControllerDelegate
        }
        set {
            objc_setAssociatedObject(self, &PropertyKeys.FetchedResultsControllerDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
    *  The data source for the tableview.
    */
    public var dataSource: TableViewDataSource? {
        get {
            return objc_getAssociatedObject(self, &PropertyKeys.DataSource) as? TableViewDataSource
        }
        set {
            objc_setAssociatedObject(self, &PropertyKeys.DataSource, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
    *  Sets up the fetchedResultsControllerDelegate and the dataSource with its delegates.
    *  The managedObjectContext and the fetchedResultsController must be set before this method is called!
    *  @param frcDelegate        The delegate for the FFCDTableViewFetchedResultsControllerDelegate.
    *  @param dataSourceDelegate The delegate for the FFCDTableViewDataSource.
    */
    func setupWithFetchedResultsControllerDelegate(frcDelegate: FetchedResultsControllerDelegateDelegate, dataSourceDelegate: TableViewDataSourceDelegate) {
        tableView.delegate = self
        if let frc = fetchedResultsController, tableView = tableView {
            fetchedResultsControllDelegate = TableViewFetchedResultsControllerDelegate(fetchedResultsController: frc, tableView: tableView, delegate: frcDelegate)
            dataSource = TableViewDataSource(tableView: tableView, controller: frc, delegate: dataSourceDelegate)
        }
    }
    
    /**
    *  Sets up the fetchedResultsControllerDelegate and the dataSource with the same delegate.
    *  @param delegate The delegate for both, the fetchedResultsControllerDelegate and the dataSource.
    */
    func setupWithDelegate(delegate: protocol<FetchedResultsControllerDelegateDelegate, TableViewDataSourceDelegate>) {
        setupWithFetchedResultsControllerDelegate(delegate, dataSourceDelegate: delegate)
    }
}
#endif

//
//  UITableViewController+FFCoreData.h
//  FFCoreData
//
//  Created by Florian Friedrich on 26.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

@import Foundation;
@import UIKit;
@import CoreData;
@class FFCDTableViewFetchedResultsControllerDelegate;
@class FFCDTableViewDataSource;
@protocol FFCDFetchedResultsControllerDelegate;
@protocol FFCDTableViewDataSourceDelegate;

/**
 *  Adds convenience properties and methods to UITableViewController.
 */
@interface UITableViewController (FFCoreData) <UITableViewDelegate>

/**
 *  The managed object context of the UITableViewController (used for the NSFetchedResultsController).
 */
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
/**
 *  The fetched results controller for the tableview.
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
/**
 *  The delegate of the fetched results controller.
 */
@property (nonatomic, strong) FFCDTableViewFetchedResultsControllerDelegate *fetchedResultsControllerDelegate;
/**
 *  The data source for the tableview.
 */
@property (nonatomic, strong) FFCDTableViewDataSource *dataSoure;

/**
 *  Sets up the fetchedResultsControllerDelegate and the dataSource with its delegates.
 *  The managedObjectContext and the fetchedResultsController must be set before this method is called!
 *  @param frcd               The delegate for the FFCDTableViewFetchedResultsControllerDelegate.
 *  @param dataSourceDelegate The delegate for the FFCDTableViewDataSource.
 */
- (void)setupWithFetchedResultsControllerDelegate:(id<FFCDFetchedResultsControllerDelegate>)frcd
                      tableViewDataSourceDelegate:(id<FFCDTableViewDataSourceDelegate>)dataSourceDelegate;

/**
 *  Sets up the fetchedResultsControllerDelegate and the dataSource with the same delegate.
 *  @param delegate The delegate for both, the fetchedResultsControllerDelegate and the dataSource.
 */
- (void)setupWithDelegate:(id<FFCDFetchedResultsControllerDelegate, FFCDTableViewDataSourceDelegate>)delegate;

@end

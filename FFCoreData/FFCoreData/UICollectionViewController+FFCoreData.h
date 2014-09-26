//
//  UICollectionViewController+FFCoreData.h
//  FFCoreData
//
//  Created by Florian Friedrich on 26.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

@import Foundation;
@import UIKit;
@import CoreData;
@class FFCDCollectionViewFetchedResultsControllerDelegate;
@class FFCDCollectionViewDataSource;
@protocol FFCDFetchedResultsControllerDelegate;
@protocol FFCDCollectionViewDataSourceDelegate;

/**
 *  Adds convenience properties and methods to UICollectionViewController.
 */
@interface UICollectionViewController (FFCoreData) <UICollectionViewDelegate>

/**
 *  The managed object context of the UICollectionViewController (used for the NSFetchedResultsController).
 */
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
/**
 *  The fetched results controller for the collectionview.
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
/**
 *  The delegate of the fetched results controller.
 */
@property (nonatomic, strong) FFCDCollectionViewFetchedResultsControllerDelegate *fetchedResultsControllerDelegate;
/**
 *  The data source for the collectionview.
 */
@property (nonatomic, strong) FFCDCollectionViewDataSource *dataSoure;

/**
 *  Sets up the fetchedResultsControllerDelegate and the dataSource with its delegates.
 *  The managedObjectContext and the fetchedResultsController must be set before this method is called!
 *  @param frcd               The delegate for the FFCDCollectionViewFetchedResultsControllerDelegate.
 *  @param dataSourceDelegate The delegate for the FFCDCollectionViewDataSource.
 */
- (void)setupWithFetchedResultsControllerDelegate:(id<FFCDFetchedResultsControllerDelegate>)frcd
                 collectionViewDataSourceDelegate:(id<FFCDCollectionViewDataSourceDelegate>)dataSourceDelegate;

/**
 *  Sets up the fetchedResultsControllerDelegate and the dataSource with the same delegate.
 *  @param delegate The delegate for both, the fetchedResultsControllerDelegate and the dataSource.
 */
- (void)setupWithDelegate:(id<FFCDFetchedResultsControllerDelegate, FFCDCollectionViewDataSourceDelegate>)delegate;


@end

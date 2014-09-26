//
//  FFCDCollectionViewDataSource.h
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

@import Foundation;
@import UIKit.UICollectionView;
@class NSFetchedResultsController;

@protocol FFCDCollectionViewDataSourceDelegate <NSObject>

/**
 *  Asks for a reuse identifier for a cell at a given indexPath.
 *  @param collectionView The UICollectionView for which a cell reuse identifier is needed.
 *  @param indexPath      The NSIndexPath for which to provide a reuse identifier.
 *  @return A reuse identifier which is used to dequeue a cell for the given indexPath.
 */
- (NSString *)collectionView:(UICollectionView *)collectionView cellIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  Asks the delegate to configure a cell.
 *  @param collectionView The UICollectionView in which the cell is contained.
 *  @param cell           The UICollectionViewCell to configure.
 *  @param indexPath      The NSIndexPath of the cell.
 *  @param object         The object from the NSFetchedResultsController. Normally a NSManagedObject subclass.
 */
- (void)collectionView:(UICollectionView *)collectionView
    configureCell:(UICollectionViewCell *)cell
forItemAtIndexPath:(NSIndexPath *)indexPath
       withObject:(id)object;

@optional // See UICollectionViewDataSource for more info about the following methods.
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end

/**
 *  Handles the data source of a UICollectionView with a NSFetchedResultsController.
 */
@interface FFCDCollectionViewDataSource : NSObject <UICollectionViewDataSource>

/**
 *  The UICollectionView to update.
 */
@property (nonatomic, weak) UICollectionView *collectionView;
/**
 *  The NSFetchedResultsController from which to take the objects.
 */
@property (nonatomic, weak) NSFetchedResultsController *fetchedResultsController;
/**
 *  The delegate which to ask for the needed information.
 */
@property (nonatomic, weak) id<FFCDCollectionViewDataSourceDelegate> delegate;

/**
 *  Creates a new instance of FFCDCollectionViewDataSource.
 *  @param fetchedResultsController The NSFetchedResultsController to use for getting the objects.
 *  @param delegate                 The delegate to ask for information.
 *  @param collectionView           The UICollectionView to update.
 *  @return A new FFCDCollectionViewDataSource instance.
 */
- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDCollectionViewDataSourceDelegate>)delegate
                                  collectionView:(UICollectionView *)collectionView;

@end

//
//  FFCDCollectionViewFetchedResultsControllerDelegate.h
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import <FFCoreData/FFCDUIKitFetchedResultsControllerDelegate.h>
@class UICollectionView;

/**
 *  Manages a NSFetchedResultsController for a UICollectionView.
 */
@interface FFCDCollectionViewFetchedResultsControllerDelegate : FFCDUIKitFetchedResultsControllerDelegate

/**
 *  The UICollectionView on which the changes will be applied.
 */
@property (nonatomic, weak, readonly) UICollectionView *collectionView;

/**
 *  Creates a new FFCDCollectionViewFetchedResultsControllerDelegate with the given arguments.
 *  @param controller      The NSFetchedResultsController to use.
 *  @param delegate        The FFCDFetchedResultsControllerDelegate. Can be nil.
 *  @param collectionView  The UICollectionView on which to apply the changes.
 *  @return A new FFCDCollectionViewFetchedResultsControllerDelegate instance.
 */
+ (instancetype)delegateWithFetchedResultsController:(NSFetchedResultsController *)controller
                                            delegate:(id<FetchedResultsControllerDelegateDelegate>)delegate
                                      collectionView:(UICollectionView *)collectionView;

/**
 *  Creates a new FFCDCollectionViewFetchedResultsControllerDelegate with the given arguments.
 *  @param controller      The NSFetchedResultsController to use.
 *  @param delegate        The FFCDFetchedResultsControllerDelegate. May be nil.
 *  @param collectionView  The UICollectionView on which to apply the changes.
 *  @return A new FFCDCollectionViewFetchedResultsControllerDelegate instance.
 */
- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FetchedResultsControllerDelegateDelegate>)delegate
                                  collectionView:(UICollectionView *)collectionView NS_DESIGNATED_INITIALIZER;

@end

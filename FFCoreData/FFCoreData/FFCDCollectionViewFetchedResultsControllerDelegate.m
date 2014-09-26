//
//  FFCDCollectionViewFetchedResultsControllerDelegate.m
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import "FFCDCollectionViewFetchedResultsControllerDelegate.h"
#import "FFCDFetchedResultsControllerDelegate+Internal.h"
#import "FFCoreData.h"

@implementation FFCDCollectionViewFetchedResultsControllerDelegate

+ (instancetype)delegateWithFetchedResultsController:(NSFetchedResultsController *)controller
                                            delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate
                                      collectionView:(UICollectionView *)collectionView {
    return [[self alloc] initWithFetchedResultsController:controller
                                                 delegate:delegate
                                           collectionView:collectionView];
}

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate
                                  collectionView:(UICollectionView *)collectionView {
    NSParameterAssert(collectionView);
    self = [super initWithFetchedResultsController:fetchedResultsController delegate:delegate];
    if (self) {
        _collectionView = collectionView;
    }
    return self;
}

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate {
    return [self initWithFetchedResultsController:fetchedResultsController delegate:delegate collectionView:nil];
}

#pragma mark - Begin/End Updates
- (void)beginUpdates {
    [super beginUpdates];
}

- (void)endUpdates {
    [super endUpdates];
}

#pragma mark - Sections
- (void)insertSectionAtIndex:(NSUInteger)index {
    [super insertSectionAtIndex:index];
    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:index]];
}

- (void)updateSectionAtIndex:(NSUInteger)index {
    [super updateSectionAtIndex:index];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:index]];
}

- (void)removeSectionAtIndex:(NSUInteger)index {
    [super removeSectionAtIndex:index];
    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:index]];
}

- (void)moveSectionFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [super moveSectionFromIndex:fromIndex toIndex:toIndex];
    [self.collectionView moveSection:fromIndex toSection:toIndex];
}

#pragma mark - Items
- (void)insertSubobjectAtIndexPath:(NSIndexPath *)indexPath {
    [super insertSubobjectAtIndexPath:indexPath];
    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
}

- (void)updateSubobjectAtIndexPath:(NSIndexPath *)indexPath {
    [super updateSubobjectAtIndexPath:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)removeSubobjectAtIndexPath:(NSIndexPath *)indexPath {
    [super removeSubobjectAtIndexPath:indexPath];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

- (void)moveSubobjectFromIndexPath:(NSIndexPath *)fromIndexPath
                       toIndexPath:(NSIndexPath *)toIndexPath {
    [super moveSubobjectFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

@end

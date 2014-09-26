//
//  FFCDCollectionViewDataSource.m
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import "FFCDCollectionViewDataSource.h"

@interface FFCDCollectionViewDataSource ()
- (NSString *)collectionView:(UICollectionView *)collectionView cellIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation FFCDCollectionViewDataSource

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDCollectionViewDataSourceDelegate>)delegate
                                  collectionView:(UICollectionView *)collectionView {
    self = [super init];
    if (self) {
        self.fetchedResultsController = fetchedResultsController;
        self.delegate = delegate;
        self.collectionView = collectionView;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFetchedResultsController:nil delegate:nil collectionView:nil];
}

#pragma mark - Properties
- (void)setCollectionView:(UICollectionView *)collectionView {
    if (_collectionView != collectionView) {
        _collectionView = collectionView;
        _collectionView.dataSource = self;
    }
}

#pragma mark - Helpers
- (NSString *)collectionView:(UICollectionView *)collectionView
cellIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate collectionView:collectionView cellIdentifierForItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger sections = self.fetchedResultsController.sections.count;
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger rows = 0;
    NSArray *sections = self.fetchedResultsController.sections;
    if (sections.count > 0) {
        rows = [sections[section] numberOfObjects];
    }
    return rows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [self collectionView:collectionView cellIdentifierForItemAtIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                           forIndexPath:indexPath];
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate collectionView:collectionView
                    configureCell:cell
               forItemAtIndexPath:indexPath
                       withObject:object];
    return cell;
}

@end

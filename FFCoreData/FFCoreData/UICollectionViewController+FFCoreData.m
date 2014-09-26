//
//  UICollectionViewController+FFCoreData.m
//  FFCoreData
//
//  Created by Florian Friedrich on 26.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import "UICollectionViewController+FFCoreData.h"
#import <FFCoreData/FFCoreDataDefines.h>
#import <FFCoreData/FFCDCollectionViewFetchedResultsControllerDelegate.h>
#import <FFCoreData/FFCDCollectionViewDataSource.h>
#import <objc/objc-runtime.h>

@implementation UICollectionViewController (FFCoreData)

- (void)setupWithDelegate:(id<FFCDFetchedResultsControllerDelegate, FFCDCollectionViewDataSourceDelegate>)delegate {
    return [self setupWithFetchedResultsControllerDelegate:delegate collectionViewDataSourceDelegate:delegate];
}

- (void)setupWithFetchedResultsControllerDelegate:(id<FFCDFetchedResultsControllerDelegate>)frcd
                 collectionViewDataSourceDelegate:(id<FFCDCollectionViewDataSourceDelegate>)dataSourceDelegate {
    self.collectionView.delegate = self;
    self.fetchedResultsControllerDelegate = [[FFCDCollectionViewFetchedResultsControllerDelegate alloc]
                                             initWithFetchedResultsController:self.fetchedResultsController
                                             delegate:frcd
                                             collectionView:self.collectionView];
    self.dataSoure = [[FFCDCollectionViewDataSource alloc] initWithFetchedResultsController:self.fetchedResultsController
                                                                                   delegate:dataSourceDelegate
                                                                             collectionView:self.collectionView];
}

#pragma mark - Properties
- (NSManagedObjectContext *)managedObjectContext {
    return objc_getAssociatedObject(self, FFCDPropertyKey());
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    return objc_setAssociatedObject(self, FFCDPropertyKey(), managedObjectContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSFetchedResultsController *)fetchedResultsController {
    return objc_getAssociatedObject(self, FFCDPropertyKey());
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    return objc_setAssociatedObject(self, FFCDPropertyKey(), fetchedResultsController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FFCDCollectionViewFetchedResultsControllerDelegate *)fetchedResultsControllerDelegate {
    return objc_getAssociatedObject(self, FFCDPropertyKey());
}

- (void)setFetchedResultsControllerDelegate:(FFCDCollectionViewFetchedResultsControllerDelegate *)fetchedResultsControllerDelegate {
    return objc_setAssociatedObject(self, FFCDPropertyKey(), fetchedResultsControllerDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FFCDCollectionViewDataSource *)dataSoure {
    return objc_getAssociatedObject(self, FFCDPropertyKey());
}

- (void)setDataSoure:(FFCDCollectionViewDataSource *)dataSoure {
    return objc_setAssociatedObject(self, FFCDPropertyKey(), dataSoure, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end

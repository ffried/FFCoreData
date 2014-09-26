//
//  UITableViewController+FFCoreData.m
//  FFCoreData
//
//  Created by Florian Friedrich on 26.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import "UITableViewController+FFCoreData.h"
#import "FFCoreData.h"
#import <objc/runtime.h>

@implementation UITableViewController (FFCoreData)

- (void)setupWithDelegate:(id<FFCDFetchedResultsControllerDelegate, FFCDTableViewDataSourceDelegate>)delegate {
    return [self setupWithFetchedResultsControllerDelegate:delegate tableViewDataSourceDelegate:delegate];
}

- (void)setupWithFetchedResultsControllerDelegate:(id<FFCDFetchedResultsControllerDelegate>)frcd
                      tableViewDataSourceDelegate:(id<FFCDTableViewDataSourceDelegate>)dataSourceDelegate {
    self.tableView.delegate = self;
    self.fetchedResultsControllerDelegate = [[FFCDTableViewFetchedResultsControllerDelegate alloc]
                                             initWithFetchedResultsController:self.fetchedResultsController
                                             delegate:frcd
                                             tableView:self.tableView];
    self.dataSoure = [[FFCDTableViewDataSource alloc] initWithFetchedResultsController:self.fetchedResultsController
                                                                              delegate:dataSourceDelegate
                                                                             tableView:self.tableView];
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

- (FFCDTableViewFetchedResultsControllerDelegate *)fetchedResultsControllerDelegate {
    return objc_getAssociatedObject(self, FFCDPropertyKey());
}

- (void)setFetchedResultsControllerDelegate:(FFCDTableViewFetchedResultsControllerDelegate *)fetchedResultsControllerDelegate {
    return objc_setAssociatedObject(self, FFCDPropertyKey(), fetchedResultsControllerDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FFCDTableViewDataSource *)dataSoure {
    return objc_getAssociatedObject(self, FFCDPropertyKey());
}

- (void)setDataSoure:(FFCDTableViewDataSource *)dataSoure {
    return objc_setAssociatedObject(self, FFCDPropertyKey(), dataSoure, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

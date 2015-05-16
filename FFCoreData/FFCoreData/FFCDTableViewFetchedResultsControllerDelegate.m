//
//  FFCDTableViewFetchedResultsControllerDelegate.m
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import "FFCDTableViewFetchedResultsControllerDelegate.h"
#import "FFCDUIKitFetchedResultsControllerDelegate+Internal.h"
#import "FFCoreData.h"
#import "FFCoreDataDefines.h"

@implementation FFCDTableViewFetchedResultsControllerDelegate

+ (instancetype)delegateWithFetchedResultsController:(NSFetchedResultsController *)controller
                                            delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate
                                           tableView:(UITableView *)tableView {
    return [[self alloc] initWithFetchedResultsController:controller
                                                 delegate:delegate
                                                tableView:tableView];
}

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate
                                       tableView:(UITableView *)tableView {
    NSParameterAssert(tableView);
    self = [super initWithFetchedResultsController:fetchedResultsController delegate:delegate];
    if (self) {
        _tableView = tableView;
        self.animation = UITableViewRowAnimationAutomatic;
    }
    return self;
}

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate {
    return [self initWithFetchedResultsController:fetchedResultsController
                                         delegate:delegate
                                        tableView:nil];
}

#pragma mark - Begin/End Updates
- (void)beginUpdates {
    [super beginUpdates];
    [self.tableView beginUpdates];
}

- (void)endUpdates {
    [super endUpdates];
    [self.tableView endUpdates];
    [self reapplySelections];
}

- (void)selectIndexPaths:(NSArray *)indexPaths {
    [super selectIndexPaths:indexPaths];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
}

#pragma mark - Sections
- (void)insertSectionAtIndex:(NSUInteger)index {
    [super insertSectionAtIndex:index];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:self.animation];
}

- (void)updateSectionAtIndex:(NSUInteger)index {
    [super updateSectionAtIndex:index];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:self.animation];
}

- (void)removeSectionAtIndex:(NSUInteger)index {
    [super removeSectionAtIndex:index];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:self.animation];
}

- (void)moveSectionFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [super moveSectionFromIndex:fromIndex toIndex:toIndex];
    [self.tableView moveSection:fromIndex toSection:toIndex];
}

#pragma mark - Rows
- (void)insertSubobjectAtIndexPath:(NSIndexPath *)indexPath {
    [super insertSubobjectAtIndexPath:indexPath];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:self.animation];
}

- (void)updateSubobjectAtIndexPath:(NSIndexPath *)indexPath {
    [super updateSubobjectAtIndexPath:indexPath];
    BOOL selected = [self.tableView.indexPathsForSelectedRows containsObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:self.animation];
    if (selected) { [self.selectedIndexPaths addObject:indexPath]; }
}

- (void)removeSubobjectAtIndexPath:(NSIndexPath *)indexPath {
    [super removeSubobjectAtIndexPath:indexPath];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:self.animation];
}

- (void)moveSubobjectFromIndexPath:(NSIndexPath *)fromIndexPath
                       toIndexPath:(NSIndexPath *)toIndexPath {
    [super moveSubobjectFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

@end

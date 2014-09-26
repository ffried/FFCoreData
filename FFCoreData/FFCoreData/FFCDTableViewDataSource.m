//
//  FFCDTableViewDataSource.m
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import "FFCDTableViewDataSource.h"
#import "FFCoreData.h"

@interface FFCDTableViewDataSource ()
- (NSString *)tableView:(UITableView *)tableView cellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation FFCDTableViewDataSource

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDTableViewDataSourceDelegate>)delegate
                                       tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.fetchedResultsController = fetchedResultsController;
        self.delegate = delegate;
        self.tableView = tableView;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFetchedResultsController:nil delegate:nil tableView:nil];
}

#pragma mark - Properties
- (void)setTableView:(UITableView *)tableView {
    if (_tableView != tableView) {
        _tableView = tableView;
        _tableView.dataSource = self;
    }
}

#pragma mark - Helpers
- (NSString *)tableView:(UITableView *)tableView cellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate tableView:tableView cellIdentifierForRowAtIndexPath:indexPath];;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.fetchedResultsController.sections.count;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    NSArray *sections = self.fetchedResultsController.sections;
    if (sections.count > 0) rows = [sections[section] numberOfObjects];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [self tableView:tableView cellIdentifierForRowAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate tableView:tableView configureCell:cell forRowAtIndexPath:indexPath withObject:object];
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [self.delegate tableView:tableView titleForHeaderInSection:section];
    }
    if (self.fetchedResultsController.sections.count > 0) {
        return [self.fetchedResultsController.sections[section] name];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)]) {
        return [self.delegate tableView:tableView
            sectionForSectionIndexTitle:title
                                atIndex:index];
    }
    
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(sectionIndexTitlesForTableView:)]) {
        return [self.delegate sectionIndexTitlesForTableView:tableView];
    }
    
    return [self.fetchedResultsController sectionIndexTitles];
}

#pragma mark - pass to delegate methods
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *title = nil;
    if ([self.delegate respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        title = [self.delegate tableView:tableView titleForFooterInSection:section];
    }
    return title;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canEditRow = NO;
    if ([self.delegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        canEditRow = [self.delegate tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return canEditRow;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canMoveRow = NO;
    if ([self.delegate respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        canMoveRow = [self.delegate tableView:tableView canMoveRowAtIndexPath:indexPath];
    }
    return canMoveRow;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView
                     commitEditingStyle:editingStyle
                      forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
        return [self.delegate tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}

@end

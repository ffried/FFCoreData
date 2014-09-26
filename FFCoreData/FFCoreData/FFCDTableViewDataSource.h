//
//  FFCDTableViewDataSource.h
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

@import Foundation;
@import UIKit.UITableView;
@class NSFetchedResultsController;

/**
 *  The delegate protocol for FFTableViewDataSource.
 *  Allows to provide needed information as well as take control of data source methods not handled by the FFTableViewDataSource.
 */
@protocol FFCDTableViewDataSourceDelegate <NSObject>
@required
/**
 *  Asks for a reuse identifier for a cell at a given indexPath.
 *  @param tableView The UITableView for which a cell reuse identifier is needed.
 *  @param indexPath The NSIndexPath for which to provide a reuse identifier.
 *  @return A reuse identifier which is used to dequeue a cell for the given indexPath.
 */
- (NSString *)tableView:(UITableView *)tableView cellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  Asks the delegate to configure a cell.
 *  @param tableView The UITableView in which the cell is contained.
 *  @param cell      The UITableViewCell to configure.
 *  @param indexPath The NSIndexPath of the cell.
 *  @param object    The object from the NSFetchedResultsController. Normally a NSManagedObject subclass.
 */
- (void)tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object;

@optional // See UITableViewDataSource protocol documentation for more info about the following methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
@end

/**
 *  Handles the data source of a UITableView with a NSFetchedResultsController.
 */
@interface FFCDTableViewDataSource : NSObject <UITableViewDataSource>

/**
 *  The UITableView to update.
 */
@property (nonatomic, weak) UITableView *tableView;
/**
 *  The NSFetchedResultsController from which to take the objects.
 */
@property (nonatomic, weak) NSFetchedResultsController *fetchedResultsController;
/**
 *  The delegate which to ask for the needed information.
 */
@property (nonatomic, weak) id<FFCDTableViewDataSourceDelegate> delegate;

/**
 *  Creates a new instance of FFCDTableViewDataSource.
 *  @param fetchedResultsController The NSFetchedResultsController to use for getting the objects.
 *  @param delegate                 The delegate to ask for information.
 *  @param tableView                The UITableView to update.
 *  @return A new FFCDTableViewDataSource instance.
 */
- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDTableViewDataSourceDelegate>)delegate
                                       tableView:(UITableView *)tableView NS_DESIGNATED_INITIALIZER;

@end

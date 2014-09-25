//
//  FFCDTableViewFetchedResultsControllerDelegate.h
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

//#if FFCDTARGET_PHONE
#import <FFCoreData/FFCoreData.h>
@import UIKit.UITableView;

/**
 *  Manages a NSFetchedResultsController for a UITableView.
 */
@interface FFCDTableViewFetchedResultsControllerDelegate : FFCDFetchedResultsControllerDelegate

/**
 *  The UITableView on which the changes will be applied.
 */
@property (nonatomic, weak, readonly) UITableView *tableView;

/**
 *  The UITableViewRowAnimation to use for the updates.
 */
@property (nonatomic) UITableViewRowAnimation animation;

/**
 *  Creates a new FFCDTableViewFetchedResultsControllerDelegate with the given arguments.
 *  @param controller The NSFetchedResultsController to use.
 *  @param delegate   The FFCDFetchedResultsControllerDelegate. Cam be nil.
 *  @param tableView  The UITableView on which to apply the changes.
 *  @return A new FFCDTableViewFetchedResultsControllerDelegate instance.
 */
+ (instancetype)delegateWithFetchedResultsController:(NSFetchedResultsController *)controller
                                            delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate
                                           tableView:(UITableView *)tableView;

/**
 *  Creates a new FFCDTableViewFetchedResultsControllerDelegate with the given arguments.
 *  @param controller The NSFetchedResultsController to use.
 *  @param delegate   The FFCDFetchedResultsControllerDelegate. May be nil.
 *  @param tableView  The UITableView on which to apply the changes.
 *  @return A new FFCDTableViewFetchedResultsControllerDelegate instance.
 */
- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate
                                       tableView:(UITableView *)tableView NS_DESIGNATED_INITIALIZER;

@end
//#endif

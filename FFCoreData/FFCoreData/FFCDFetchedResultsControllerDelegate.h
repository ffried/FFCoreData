//
//  FFCDFetchedResultsControllerDelegate.h
//  FFCoreData
//
//  Created by Florian Friedrich on 14.12.13.
//  Copyright (c) 2013 Florian Friedrich. All rights reserved.
//

@import Foundation;
@import CoreData.NSFetchedResultsController;

/**
 *  The delegate protocol of FFNSFetchedResultsControllerDelegate.
 *  It's completely adopted from the NSFetchedResultsControllerDelegate protocol.
 */
@protocol FFCDFetchedResultsControllerDelegate <NSFetchedResultsControllerDelegate, NSObject>
@end

/**
 *  Handles the delegate of a NSFetchedResultsController but allows to override the methods to do work on yourself.
 */
@interface FFCDFetchedResultsControllerDelegate : NSObject <NSFetchedResultsControllerDelegate>

/**
 *  The NSFetchedResultsController to handle the delegate for.
 */
@property (nonatomic, weak) NSFetchedResultsController *fetchedResultsController;

/**
 *  The object to which the changes are applied. Subclasses override this with an actual type.
 */
@property (nonatomic, weak) id object;

/**
 *  The delegate to check for overridden NSFetchedResultsControllerDelegate methods.
 */
@property (nonatomic, assign) id<FFCDFetchedResultsControllerDelegate> delegate;

/**
 *  Creates a new FFCDFetchedResultsControllerDelegate instance.
 *  @param fetchedResultsController The NSFetchedResultsController to use.
 *  @param delegate                 A delegate or nil.
 *  @return A new instance of FFNSFetchedResultsControllerDelegate.
 */
- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

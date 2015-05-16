//
//  FFCDUIKitFetchedResultsControllerDelegate.m
//  FFCoreData
//
//  Created by Florian Friedrich on 16/05/15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

#import "FFCDUIKitFetchedResultsControllerDelegate.h"
#import "FFCDFetchedResultsControllerDelegate+Internal.h"

@interface FFCDUIKitFetchedResultsControllerDelegate ()
@property (nonatomic, strong, readonly) NSMutableSet *selectedIndexPaths;
@end

@implementation FFCDUIKitFetchedResultsControllerDelegate

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate {
    self = [super initWithFetchedResultsController:fetchedResultsController delegate:delegate];
    if (self) {
        self.preserveSelection = YES;
        _selectedIndexPaths = [NSMutableSet set];
    }
    return self;
}

@end

//
//  FFCDUIKitFetchedResultsControllerDelegate+Internal.m
//  FFCoreData
//
//  Created by Florian Friedrich on 16/05/15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

#import "FFCDUIKitFetchedResultsControllerDelegate+Internal.h"

@implementation FFCDUIKitFetchedResultsControllerDelegate (Internal)
@dynamic selectedIndexPaths;

- (void)reapplySelections {
    NSSet *selectedIndexPaths = [NSSet setWithSet:self.selectedIndexPaths];
    [self.selectedIndexPaths removeAllObjects];
    if (self.preserveSelection) {
        [self selectIndexPaths:selectedIndexPaths.allObjects];
    }
}

- (void)selectIndexPaths:(NSArray *)indexPaths {}

@end

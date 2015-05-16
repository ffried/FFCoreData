//
//  FFCDUIKitFetchedResultsControllerDelegate+Internal.h
//  FFCoreData
//
//  Created by Florian Friedrich on 16/05/15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

#import "FFCDUIKitFetchedResultsControllerDelegate.h"
#import "FFCDFetchedResultsControllerDelegate+Internal.h"

@interface FFCDUIKitFetchedResultsControllerDelegate (Internal)

@property (nonatomic, strong, readonly) NSMutableSet *selectedIndexPaths;

- (void)reapplySelections;
- (void)selectIndexPaths:(NSArray *)indexPaths;

@end

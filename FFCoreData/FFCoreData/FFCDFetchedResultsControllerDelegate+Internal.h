//
//  FFCDFetchedResultsControllerDelegate+Internal.h
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import "FFCDFetchedResultsControllerDelegate.h"

@interface FFCDFetchedResultsControllerDelegate (Internal)

- (void)beginUpdates;

- (void)insertSectionAtIndex:(NSUInteger)index;
- (void)removeSectionAtIndex:(NSUInteger)index;
- (void)updateSectionAtIndex:(NSUInteger)index;
- (void)moveSectionFromIndex:(NSUInteger)fromIndex
                     toIndex:(NSUInteger)toIndex;

- (void)insertSubobjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)removeSubobjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateSubobjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)moveSubobjectFromIndexPath:(NSIndexPath *)fromIndexPath
                       toIndexPath:(NSIndexPath *)toIndexPath;

- (void)endUpdates;

@end

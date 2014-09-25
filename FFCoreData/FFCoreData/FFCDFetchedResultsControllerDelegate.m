//
//  FFCDFetchedResultsControllerDelegate.m
//  FFCoreData
//
//  Created by Florian Friedrich on 14.12.13.
//  Copyright (c) 2013 Florian Friedrich. All rights reserved.
//

#import "FFCDFetchedResultsControllerDelegate.h"
#import "FFCDFetchedResultsControllerDelegate+Internal.h"
#import "FFCoreData.h"

@implementation FFCDFetchedResultsControllerDelegate

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                                        delegate:(id<FFCDFetchedResultsControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.fetchedResultsController = fetchedResultsController;
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFetchedResultsController:nil delegate:nil];
}

#pragma mark - manual properties
- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != fetchedResultsController) {
        _fetchedResultsController = fetchedResultsController;
        _fetchedResultsController.delegate = self;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if ([self.delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
        [self.delegate controllerWillChangeContent:controller];
    }
    
    [self beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self insertSectionAtIndex:sectionIndex];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self updateSectionAtIndex:sectionIndex];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self removeSectionAtIndex:sectionIndex];
            break;
            
        default:
            FFLog(@"Unsupported type (%lu)", (unsigned long)type);
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
        [self.delegate controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self insertSubobjectAtIndexPath:newIndexPath];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self updateSubobjectAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self removeSubobjectAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self moveSubobjectFromIndexPath:indexPath toIndexPath:newIndexPath];
            break;
            
        default:
            FFLog(@"Unsupported type (%lu)", (unsigned long)type);
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        [self.delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self endUpdates];
    
    if ([self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        [self.delegate controllerDidChangeContent:controller];
    }
}

- (NSString *)controller:(NSFetchedResultsController *)controller
sectionIndexTitleForSectionName:(NSString *)sectionName {
    if ([self.delegate respondsToSelector:@selector(controller:sectionIndexTitleForSectionName:)]) {
        return [self.delegate controller:controller sectionIndexTitleForSectionName:sectionName];
    } else {
        return [controller sectionIndexTitleForSectionName:sectionName];
    }
}

@end

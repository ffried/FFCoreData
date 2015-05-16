//
//  FFCDUIKitFetchedResultsControllerDelegate.h
//  FFCoreData
//
//  Created by Florian Friedrich on 16/05/15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

#import <FFCoreData/FFCDFetchedResultsControllerDelegate.h>

@interface FFCDUIKitFetchedResultsControllerDelegate: FFCDFetchedResultsControllerDelegate

/**
 *  Whether or not possible selections should be preserved. YES by default.
 */
@property (nonatomic) BOOL preserveSelection;

@end

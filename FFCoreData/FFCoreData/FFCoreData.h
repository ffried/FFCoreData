//
//  FFCoreData.h
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

@import Foundation;
@import CoreData;

//! Project version number for FFCoreData.
FOUNDATION_EXPORT double FFCoreDataVersionNumber;

//! Project version string for FFCoreData.
FOUNDATION_EXPORT const unsigned char FFCoreDataVersionString[];

#import <FFCoreData/FFCoreDataDefines.h>
#import <FFCoreData/FFCDFetchedResultsControllerDelegate.h>
#import <FFCoreData/NSManagedObject+FFCDFindAndOrCreate.h>

#if FFCDTARGET_PHONE
    #import <FFCoreData/FFCDTableViewFetchedResultsControllerDelegate.h>
    #import <FFCoreData/FFCDCollectionViewFetchedResultsControllerDelegate.h>
#endif


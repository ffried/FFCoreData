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

#ifndef NS_DESIGNATED_INITIALIZER
    #if __has_attribute(objc_designated_initializer)
        #define NS_DESIGNATED_INITIALIZER __attribute((objc_designated_initializer))
    #else
        #define NS_DESIGNATED_INITIALIZER
    #endif
#endif

#import <FFCoreData/FFCDDataManager.h>
#import <FFCoreData/FFCDFetchedResultsControllerDelegate.h>
#import <FFCoreData/NSManagedObject+FFCDFindAndOrCreate.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    #import <FFCoreData/FFCDTableViewFetchedResultsControllerDelegate.h>
    #import <FFCoreData/FFCDCollectionViewFetchedResultsControllerDelegate.h>

    #import <FFCoreData/FFCDTableViewDataSource.h>
    #import <FFCoreData/FFCDCollectionViewDataSource.h>
#endif

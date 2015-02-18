//
//  FFCDDataManager.h
//  FFCoreData
//
//  Created by Florian Friedrich on 1.2.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

@import Foundation;
@import CoreData;

#ifndef FFCDManagerAllowsStoreDeletion
#define FFCDManagerAllowsStoreDeletion 1
#endif
#ifndef FFCDManagerCrashesOnFailure
#define FFCDManagerCrashesOnFailure DEBUG
#endif

/**
 *  Returns the main context.
 *  @return The main managed object context.
 */
extern NSManagedObjectContext *FFCDMainContext();

/**
 *  Creates a temporary context on the main queue.
 *  @return A temporary managed object context on the main queue.
 */
extern NSManagedObjectContext *FFCDTemporaryMainContext();

/**
 *  Creates a temporary background context.
 *  @return A temporary managed object context on a background queue.
 */
extern NSManagedObjectContext *FFCDTemporaryBackgroundContext();

/**
 *  Saves a given context (recursively).
 *  @param context The context to save.
 */
extern void FFCDSaveContext(NSManagedObjectContext *context);

/**
 *  Saves the main context.
 */
extern void FFCDSaveMainContext();

#if FFCDManagerAllowsStoreDeletion
/**
 *  Deletes the data store!
 */
extern void FFCDClearDataStore();
#endif

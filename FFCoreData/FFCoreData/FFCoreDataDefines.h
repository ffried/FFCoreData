//
//  FFCoreDataDefines.h
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#ifndef FFCoreData_FFCoreDataDefines_h
#define FFCoreData_FFCoreDataDefines_h
@import Foundation;

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#define FFCDTARGET_PHONE 1
#define FFCDTARGET_OSX 0
#else
#define FFCDTARGET_PHONE 0
#define FFCDTARGET_OSX 1
#endif

#ifndef FFLog
#if DEBUG
#define FFLog(fmt, ...) NSLog((@"FFCoreData: %s[Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define FFLog(...)
#endif
#endif

extern const void *FFCDPropertyKeyFromSelector(SEL selector);
#define FFCDPropertyKey() FFCDPropertyKeyFromSelector(_cmd)

#endif

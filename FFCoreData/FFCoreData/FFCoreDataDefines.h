//
//  FFCoreDataDefines.h
//  FFCoreData
//
//  Created by Florian Friedrich on 25.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#ifndef FFCoreData_FFCoreDataDefines_h
#define FFCoreData_FFCoreDataDefines_h

#ifndef FFLog
#if DEBUG
#define FFLog(fmt, ...) NSLog((@"FFCoreData: %s[Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define FFLog(...)
#endif
#endif

#endif

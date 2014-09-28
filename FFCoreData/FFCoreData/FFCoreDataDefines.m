//
//  FFCoreDataDefines.m
//  FFCoreData
//
//  Created by Florian Friedrich on 26.09.14.
//  Copyright (c) 2014 Florian Friedrich. All rights reserved.
//

#import "FFCoreDataDefines.h"

const void *FFCDPropertyKeyFromSelector(SEL selector) {
    static NSString *const FFCDSetterPrefix = @"set";
    NSString *name = NSStringFromSelector(selector);
    NSString *key = name;
    if ([name hasPrefix:FFCDSetterPrefix]) {
        NSUInteger start = FFCDSetterPrefix.length;
        NSUInteger length = name.length - start - 1;
        key = [name substringWithRange:NSMakeRange(start, length)];
        NSString *firstLetter = [key substringToIndex:1];
        NSString *restOfKey = [key substringFromIndex:1];
        key = [[firstLetter lowercaseString] stringByAppendingString:restOfKey];
    }
    return NSSelectorFromString(key);
}

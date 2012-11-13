//
//  NSAttributedString-XCEditAdditions.m
//  XcodeEdit
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "NSAttributedString-XCEditAdditions.h"

@implementation NSAttributedString (XCEditAdditions)

- (NSUInteger)xcNextWordFromIndex: (NSUInteger)idx
                          forward: (BOOL)flag
{
    NSString *str = [self string];
    
    __block NSRange previousRange = NSMakeRange(NSNotFound, 0);
    __block BOOL found = NO;
    
    [str enumerateSubstringsInRange: NSMakeRange(0, [str length])
                            options: (  flag
                                      ? NSStringEnumerationByWords
                                      : (NSStringEnumerationByWords | NSStringEnumerationReverse)
                                      )
                         usingBlock: (^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
                                      {
                                          if (NSLocationInRange(idx, substringRange))
                                          {
                                              found = YES;
                                              *stop = YES;
                                          }
                                          previousRange = substringRange;
                                      })];
    
    if (found)
    {
        return previousRange.location;
    }else
    {
        return NSNotFound;
    }
    
}

- (NSUInteger)nextSubWordFromIndex: (NSUInteger)idx
                           forward: (BOOL)flag
{
    return NSNotFound;
}

@end

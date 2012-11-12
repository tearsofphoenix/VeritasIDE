//
//  NSMutableString-XCTextExtras.m
//  XcodeEdit
//
//  Created by tearsofphoenix on 12-11-11.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "NSMutableString-XCTextExtras.h"



@implementation NSMutableString (XCTextExtras)

- (void)XCStandardizeEndOfLineToCR
{
    [self replaceOccurrencesOfString: @"\n"
                          withString: @"\r"
                             options: 0
                               range: NSMakeRange(0, [self length])];

    [self replaceOccurrencesOfString: @"\r\n"
                          withString: @"\r"
                             options: 0
                               range: NSMakeRange(0, [self length])];
}

- (void)XCStandardizeEndOfLineToCRLF
{
    
}

- (void)XCStandardizeEndOfLineToLF
{
    [self replaceOccurrencesOfString: @"\r\n"
                          withString: @"\n"
                             options: 0
                               range: NSMakeRange(0, [self length])];

    [self replaceOccurrencesOfString: @"\r"
                          withString: @"\n"
                             options: 0
                               range: NSMakeRange(0, [self length])];

}

@end


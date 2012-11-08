//
//  OakDocumentMark.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakDocumentMark.h"



@implementation OakDocumentMark

- (id)init
{
    if ((self = [super init]))
    {
        [self setType: @"bookmark"];
        [self setInfo: @""];
    }
    
    return self;
}

- (void)dealloc
{
    [_type release];
    [_info release];
    
    [super dealloc];
}

- (BOOL)isEqual: (id)object
{
    if ([object isKindOfClass: [self class]])
    {
        return [_type isEqualToString: [(OakDocumentMark *)object type]] && [_info isEqualToString: [object info]];
    }
    
    return NO;
}

@end
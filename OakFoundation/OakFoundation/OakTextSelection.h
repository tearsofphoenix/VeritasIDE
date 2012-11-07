//
//  OakTextSelection.h
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OakTextPosition;
@class OakTextRange;

@interface OakTextSelection : NSObject
{
    NSMutableArray *_ranges;
}

- (id)initWithPosition: (OakTextPosition *)position;

- (id)initWithRange: (OakTextRange *)range;

- (id)initWithString: (NSString *)str;


- (NSString *)stringValue;

-(BOOL)isEmpty;

- (NSUInteger)count;

- (void)clear;

- (void)addRange: (OakTextRange *)range;

@end

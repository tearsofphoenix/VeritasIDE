//
//  OakLayoutParagraphSoftLine.m
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import "OakLayoutParagraphSoftLine.h"

@implementation OakLayoutParagraphSoftLine

+ (id)lineWithOffset: (NSUInteger)offset
                   x: (CGFloat)x
                   y: (CGFloat)y
            baseline: (CGFloat)baseline
              height: (CGFloat)height
               first: (NSUInteger)first
                last: (NSUInteger)last
{
    OakLayoutParagraphSoftLine *softline = [[self alloc] init];
    
    [softline setOffset: offset];
    [softline setX: x];
    [softline setY: y];
    [softline setBaseline: baseline];
    [softline setHeight: height];
    [softline setFirst: first];
    [softline setLast: last];
    
    return [softline autorelease];

}

@end

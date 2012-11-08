//
//  OakLayoutParagraphSoftLine.h
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakLayoutParagraphSoftLine : NSObject

+ (id)lineWithOffset: (NSUInteger)offset
                   x: (CGFloat)x
                   y: (CGFloat)y
            baseline: (CGFloat)baseline
              height: (CGFloat)height
               first: (NSUInteger)first
                last: (NSUInteger)last;

@property (nonatomic)    NSUInteger offset;
@property (nonatomic)     CGFloat x;
@property (nonatomic)     CGFloat y;
@property (nonatomic)     CGFloat baseline;
@property (nonatomic)     CGFloat height;
@property (nonatomic)     NSUInteger first;
@property (nonatomic)     NSUInteger last;

@end

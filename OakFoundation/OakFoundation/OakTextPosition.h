//
//  OakTextPosition.h
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-3.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakTextPosition : NSObject<NSCopying>

@property (nonatomic) NSUInteger line;
@property (nonatomic) NSUInteger column;
@property (nonatomic) NSUInteger offset;

- (id)initWithString: (NSString *)str;

- (id)positionByStripOffset;

- (NSComparisonResult)compare: (id)object;

@end

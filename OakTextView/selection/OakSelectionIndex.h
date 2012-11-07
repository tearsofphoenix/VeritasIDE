//
//  OakSelectionIndex.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakSelectionIndex : NSObject

@property (nonatomic) NSInteger index;

@property (nonatomic) NSInteger carry;

- (BOOL)boolValue;

- (NSComparisonResult)compare: (id)object;

@end

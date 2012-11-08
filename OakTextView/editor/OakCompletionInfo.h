//
//  OakCompletionInfo.h
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OakSelectionRangeArray;

@interface OakCompletionInfo : NSObject
{
    NSMutableArray *_suggestions;
    NSUInteger _index;
}

@property (nonatomic) NSUInteger revision;

@property (nonatomic, retain) OakSelectionRangeArray *ranges;

@property (nonatomic, retain) OakSelectionRangeArray *prefixRanges;

@property (nonatomic, retain) NSArray *suggestions;

- (NSString *)current;

- (void)advance;

- (void)retreat;

@end

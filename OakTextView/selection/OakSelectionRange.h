//
//  OakSelectionRange.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OakSelectionIndex;

@interface OakSelectionRange : NSObject

+ (id)rangeWithFirstIndex: (OakSelectionIndex *)first
                lastIndex: (OakSelectionIndex *)last;

@property (nonatomic, retain) OakSelectionIndex * first;
@property (nonatomic, retain) OakSelectionIndex * last;

@property (nonatomic) BOOL columnar;
@property (nonatomic) BOOL freehanded;
@property (nonatomic) BOOL unanchored;



- (id)initWithFirstIndex: (OakSelectionIndex *)firstIndex
               lastIndex: (OakSelectionIndex *)lastIndex;

- (OakSelectionIndex *)minIndex;

- (OakSelectionIndex *)maxIndex;

- (OakSelectionRange *)sortedRange;

- (BOOL)isEmpty;

- (OakSelectionRange *)normalizedRange;

@end


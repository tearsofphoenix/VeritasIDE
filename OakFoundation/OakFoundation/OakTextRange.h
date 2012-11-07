//
//  OakTextRange.h
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-3.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

@class OakTextPosition;

@interface OakTextRange : NSObject

- (id)initWithString: (NSString *)str;

- (OakTextPosition *)minPosition;

- (OakTextPosition *)maxPosition;

- (BOOL)isEmpty;

- (id)rangeByNomalized;

- (void)clear;

- (id)rangeByStripOffset;

@end


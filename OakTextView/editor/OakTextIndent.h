//
//  OakTextIndent.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakTextIndent : NSObject

@property (nonatomic) NSUInteger tabSize;
@property (nonatomic) NSUInteger indentSize;
@property (nonatomic) BOOL useSoftTabs;
@property (nonatomic) BOOL tabFollowsIndent;

@end

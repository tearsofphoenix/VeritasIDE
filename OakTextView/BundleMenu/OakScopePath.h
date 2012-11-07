//
//  OakScopePath.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakScopePath : NSObject
{
    BOOL _anchor_to_bol;
    BOOL _anchor_to_eol;
    NSMutableArray *_scopes;
}

@property (nonatomic, retain) NSArray *scopes;

@end

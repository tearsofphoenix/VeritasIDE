//
//  OakGrammar.h
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OakBundleItem;
@class OakParseRule;

@interface OakGrammar : NSObject
{
    OakBundleItem * _item;
    NSMutableDictionary * _old_plist;
    id _bundles_callback;
    NSMutableArray *_callbacks;
    OakParseRule *_rule;
}
@end

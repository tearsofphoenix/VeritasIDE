//
//  OakBundleItem.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    kFieldGrammarScope,
    kFieldTabTrigger,
};

typedef NSInteger OakBundleItemField;

@interface OakBundleItem : NSObject

+ (id)menu_item_separator;

@end

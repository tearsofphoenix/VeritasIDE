//
//  OakLayoutParagraph.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    kNodeTypeText,
    kNodeTypeTab,
    kNodeTypeUnprintable,
    kNodeTypeFolding,
    kNodeTypeSoftBreak,
    kNodeTypeNewline
};

typedef NSInteger node_type_t;

@interface OakLayoutParagraph : NSObject

@end

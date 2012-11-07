//
//  OakBasicTree.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakBasicTreeNode : NSObject
{
    OakBasicTreeNode* _left;
    OakBasicTreeNode* _right;
    OakBasicTreeNode* _parent;
    NSUInteger _level;
    
    id _relative_key;			// relative to parent->left->_key_offset + parent->_relative_key + left->_key_offset
    id _key_offset;			// left->_key_offset + _relative_key + right->_key_offset
    id _value;
}

@end

extern id OakBasicTreeNodeMake(id key, id value);

@interface OakBasicTree : NSObject

@end

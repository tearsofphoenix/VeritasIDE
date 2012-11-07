//
//  OakBasicTree.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakBasicTree.h"

@implementation OakBasicTreeNode

id OakBasicTreeNodeMake(id key, id value)
{
    OakBasicTreeNode *node = [[OakBasicTreeNode alloc] init];
    [node setKey: key];
    [node setKeyOffset: key];
    [node setValue: value];
    
    return [node autorelease];
}


- (BOOL)isNull
{
    return _level == 0;
}

- (void)updateKeyOffset
{
    ///TODO:
    //_key_offset = _left->_key_offset + _relative_key + _right->_key_offset;
}
    
    _KeyT  relative_key () const { return _relative_key; }
    _KeyT  key_offset () const   { return _key_offset; }
    
    static void skew (node_t*& node)
    {
        if(node->_level == node->_left->_level)
        {
            //      A              B
            //     / \            / \
            //    B   C   ===>   D   A
            //   / \                / \
            //  D   E              E   C
            
            if(!node->_left->_right->is_null())
                node->_left->_right->_parent = node;
            node->_left->_parent = node->_parent;
            node->_parent = node->_left;
            
            node_t* oldLeft = node->_left;
            node->_left = oldLeft->_right;
            oldLeft->_right = node;
            node = oldLeft;
            
            node->_right->update_key_offset();
            node->update_key_offset();
        }
    }
    
    static void split (node_t*& node)
    {
        if(node->_level == node->_right->_right->_level)
        {
            //      A              C¹
            //     / \            / \
            //    B   C   ===>   A   E
            //       / \        / \
            //      D   E      B   D    ¹Increase level by one.
            
            if(!node->_right->_left->is_null())
                node->_right->_left->_parent = node;
            node->_right->_parent = node->_parent;
            node->_parent = node->_right;
            
            node_t* oldRight = node->_right;
            node->_right = oldRight->_left;
            oldRight->_left = node;
            node = oldRight;
            
            node->_level++;
            
            node->_left->update_key_offset();
            node->update_key_offset();
        }
    }
    
};

static bool eq (node_t* lhs, node_t* rhs) { return (lhs->is_null() && rhs->is_null()) || lhs == rhs; }


@end

@implementation OakBasicTree

@end

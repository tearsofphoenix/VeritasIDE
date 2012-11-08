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

- (id)relative_key
{
    return _relative_key;
}

- (id)key_offset
{
    return _key_offset;
}

static void skew (OakBasicTreeNode *node)
{
    if([node level] == [[node left] level])
    {
        //      A              B
        //     / \            / \
        //    B   C   ===>   D   A
        //   / \                / \
        //  D   E              E   C
        
        if(![[[node left] right] is_null])
        {
            [[[node left] right] setParent: node];
        }
        
        [[node left] setParent: [node parent]];
        
        [node setParent: [node left]];
        
        OakBasicTreeNode* oldLeft = [node left];
        [node setLeft: [oldLeft right]];
        [oldLeft setRight: node];
        node = oldLeft;
        
        [[node right] update_key_offset];
        [node update_key_offset];
    }
}

static void split (OakBasicTreeNode *node)
{
    if([node level] == [[[node right] right] level])
    {
        //      A              C¹
        //     / \            / \
        //    B   C   ===>   A   E
        //       / \        / \
        //      D   E      B   D    ¹Increase level by one.
        
        if(![[[node right] left] is_null])
        {
            [[[node right] left] setParent: node];
        }
        
        [[node right] setParent: [node parent]];
        
        [node setParent: [node right]];
        
        OakBasicTreeNode *oldRight = [node right];
        [node setRight: [oldRight left]];
        [oldRight setLeft: node];
        node = oldRight;
        
        [node setLevel: [node level] + 1];
        
        [[node left] updateKeyOffset];
        [node updateKeyOffset];
    }
}

static BOOL eq (OakBasicTreeNode* lhs, OakBasicTreeNode* rhs)
{
    return ([lhs is_null] && [rhs is_null]) || lhs == rhs;
}


@end

@implementation OakBasicTree

@end

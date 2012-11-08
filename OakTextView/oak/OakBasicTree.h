//
//  OakBasicTree.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakBasicTreeNode : NSObject

@property (nonatomic, retain) OakBasicTreeNode* left;
@property (nonatomic, retain) OakBasicTreeNode* right;
@property (nonatomic, assign) OakBasicTreeNode* parent;
@property (nonatomic) NSUInteger level;

@property (nonatomic, retain) id relative_key;			// relative to parent->left->_key_offset + parent->_relative_key + left->_key_offset
@property (nonatomic, retain) id key_offset;			// left->_key_offset + _relative_key + right->_key_offset
@property (nonatomic, retain) id value;

@end

extern id OakBasicTreeNodeMake(id key, id value);

@interface OakBasicTree : NSObject

@end

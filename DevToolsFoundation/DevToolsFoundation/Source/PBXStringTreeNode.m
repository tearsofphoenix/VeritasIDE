//
//  PBXStringTreeNode.m
//  DevToolsFoundation
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "PBXStringTreeNode.h"

@implementation PBXStringTreeNode

+ (id)nodeWithString: (NSString *)str
   representedObject:(id)representedObject
{
    return [[[self alloc] initWithString: str representedObject: representedObject] autorelease];
}

- (PBXStringTreeNode *)subnodeWithString: (NSString *)str
{
    if (str)
    {
        PBXStringTreeNode *nodeLooper = _firstChild;
        while (nodeLooper)
        {
            if ([nodeLooper->_string isEqualToString: str])
            {
                return nodeLooper;
            }
        
            nodeLooper = nodeLooper->_nextSibling;
        }
    
        return nodeLooper;
    }
    
    return nil;
}

- (void)removeSubnode: (PBXStringTreeNode *)subnode
{
    if (subnode)
    {
        PBXStringTreeNode *nodeLooper = _firstChild;
        PBXStringTreeNode *previousNode = nil;

        while (nodeLooper)
        {
            if (nodeLooper == subnode)
            {
                //the first subnode
                if (nil == previousNode)
                {
                    nodeLooper->_nextSibling = nil;
                    _firstChild = nodeLooper;
                }else
                {
                    previousNode->_nextSibling = nodeLooper->_nextSibling;
                    nodeLooper->_nextSibling = nil;
                }
                
                return;
            }
            
            previousNode = nodeLooper;
            nodeLooper = nodeLooper->_nextSibling;
        }
    }
}

- (void)addSubnode:(PBXStringTreeNode *)subnode
{
    [self addSubnode: subnode
              sorted: NO
            sortHint: nil];
}

- (void)addSubnode: (PBXStringTreeNode *)subnode
            sorted: (BOOL)flag
{
    [self addSubnode: subnode
              sorted: flag
            sortHint: nil];
}

- (void)addSubnode: (PBXStringTreeNode *)subnode
            sorted: (BOOL)flag
          sortHint: (id)hint
{
    
}

- (NSUInteger)indexOfSubnode: (PBXStringTreeNode *)subnode
{
    if (subnode)
    {
        PBXStringTreeNode *nodeLooper = _firstChild;
        NSUInteger idx = 0;

        while (nodeLooper)
        {
            if (nodeLooper == subnode)
            {
                return idx;
            }
            
            nodeLooper = nodeLooper->_nextSibling;
            ++idx;
        }
    }
    
    return NSNotFound;
}

- (PBXStringTreeNode *)subnodeAtIndex: (NSUInteger)idx
{
    PBXStringTreeNode *nodeLooper = _firstChild;
    NSUInteger idxLooper = 0;
    
    while (nodeLooper)
    {
        if (idx == idxLooper)
        {
            return nodeLooper;
        }
        
        nodeLooper = nodeLooper->_nextSibling;
        ++idxLooper;
    }
    
    return nil;
}

- (NSArray *)subnodes
{
    NSMutableArray *nodes = [NSMutableArray array];
    
    PBXStringTreeNode *nodeLooper = _firstChild;
    
    while (nodeLooper)
    {
        [nodes addObject: nodeLooper];
        
        nodeLooper = nodeLooper->_nextSibling;
    }
    
    return nodes;
}

- (NSUInteger)numSubnodes
{
    NSUInteger count = 0;
    PBXStringTreeNode *nodeLooper = _firstChild;
    
    while (nodeLooper)
    {
        nodeLooper = nodeLooper->_nextSibling;
        ++count;
    }
    
    return count;
}

- (BOOL)isLeaf
{
    return (nil == _firstChild);
}

- (id)treeDescriptionWithPrefix: (id)arg1
{
    
}

- (NSString *)description
{
    
}

- (id)init
{
    return [self initWithString: nil
              representedObject: nil];
}

- (void)dealloc
{
    [_string release];
    [_representedObject release];
    
    [super dealloc];
}

- (id)initWithString: (NSString *)str
   representedObject: (id)representedObject
{
    if ((self = [super init]))
    {
        [self setString: str];
        [self setRepresentedObject: representedObject];
    }
    
    return self;
}

@synthesize representedObject = _representedObject;
@synthesize string = _string;

@end
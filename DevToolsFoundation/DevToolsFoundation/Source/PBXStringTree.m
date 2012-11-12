//
//  PBXStringTree.m
//  DevToolsFoundation
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "PBXStringTree.h"
#import "PBXStringTreeNode.h"

@implementation PBXStringTree
//
//    NSString *_pathSeparator;
//    PBXStringTreeNode *_rootNode;
//    NSMutableDictionary *_sortHintsForPaths;

- (void)removeAllNodes
{
    ;
}

- (void)setObject: (id)hint
          forPath: (NSString *)path
{
    [_sortHintsForPaths setObject: hint
                           forKey: path];
}

- (id)objectForPath: (NSString *)path
{
    return [_sortHintsForPaths objectForKey: path];
}

- (PBXStringTreeNode *)rootNode
{
    return _rootNode;
}

- (NSString *)pathSeparator
{
    return _pathSeparator;
}

- (void)setPreferredNodesOrder: (id)arg1
                       forPath: (NSString *)path
{
    
}

@synthesize  keepsNodesSorted = _keepsNodesSorted;

@synthesize  sortAllButTopLevel = _sortAllButTopLevel;

- (id)_lookupNode: (id *)outValue
          forPath: (NSString *)path
{
    
}

- (NSString * )description
{
    
}

- (void)dealloc
{
    
    [super dealloc];
}

- (id)init
{
    return [self initWithPathSeparator: nil];
}

- (id)initWithPathSeparator: (NSString *)separator
{
    if ((self = [super init]))
    {
        _pathSeparator = [separator retain];
    }
    
    return self;
}

@end

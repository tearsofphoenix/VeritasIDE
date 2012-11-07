//
//  OakDependencyGraph.m
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakDependencyGraph.h"

@interface OakDependencyGraph()
{
    NSMutableDictionary *_dependencies;
}

@end

@implementation OakDependencyGraph

- (id)init
{
    if ((self = [super init]))
    {
        _dependencies = [[NSMutableDictionary alloc] init];
    }
    
    return  self;
}

- (void)dealloc
{
    [_dependencies release];
    
    [super dealloc];
}

- (void)addNode: (id)node
{
    NSMutableSet *value = [[NSMutableSet alloc] init];
    
    [_dependencies setObject: value
                      forKey: node];
}

// an edge establishes a dependency from one node (first argument) to another (second argument)
// e.g. if node RUN depends on node BUILD we call: add_edge(RUN, NODE)
- (void)addEdge: (id)dependsOn
        forNode: (id) node
{
    id key = node;
    NSMutableSet *set = [_dependencies objectForKey: key];
    
    if (!set)
    {
        set = [[NSMutableSet alloc] init];
        [_dependencies setObject: set
                          forKey: key];
        [set release];
    }
    
    [set addObject: dependsOn];
}

// mark a node as “modified” and return all nodes which in effect are then also modified
- (NSSet *)touchNode: (id)node
{
    NSMutableSet *res = [NSMutableSet set];
    
    NSMutableArray *active = [NSMutableArray arrayWithObject: node];
    
    while([active count] > 0)
    {
        id lastObj = [active lastObject];
        [res addObject: lastObj];
        
        [active removeLastObject];
        
        [_dependencies enumerateKeysAndObjectsUsingBlock: (^(NSNumber *key, NSSet *obj, BOOL *stop)
                                                           {
                                                               if(!(![obj containsObject: lastObj]
                                                                    || [res containsObject: key]))
                                                               {
                                                                   [active addObject: key];
                                                               }
                                                           })];
    }
    
    return res;
}

// return list of all nodes ordered so that for each node, all it depends on is before that node in this list
- (NSArray *)topologicalOrder
{
    NSMutableArray *res = [NSMutableArray array];
    NSMutableArray *active = [NSMutableArray array];
    
    [_dependencies enumerateKeysAndObjectsUsingBlock: (^(NSNumber *key, NSSet *obj, BOOL *stop)
                                                       {
                                                           if([obj count] == 0)
                                                           {
                                                               [active addObject: key];
                                                           }
                                                       })];
    
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary: _dependencies];
    while([active count] > 0)
    {
        id objLooper = [active lastObject];
        
        [res addObject: objLooper];
        
        [active removeLastObject];
        
        [tmp enumerateKeysAndObjectsUsingBlock: (^(NSNumber *key, NSMutableSet *obj, BOOL *stop)
                                                 {
                                                     if([obj containsObject: objLooper])
                                                     {
                                                         [obj removeObject: objLooper];
                                                         
                                                         if([obj count] == 0)
                                                         {
                                                             [active addObject: key];
                                                         }
                                                     }
                                                 })];
    }
    
    return res;
}

@end

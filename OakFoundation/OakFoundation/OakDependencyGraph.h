//
//  OakDependencyGraph.h
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakDependencyGraph : NSObject


- (void)addNode: (id)node;

// an edge establishes a dependency from one node (first argument) to another (second argument)
// e.g. if node RUN depends on node BUILD we call: add_edge(RUN, NODE)
- (void)addEdge: (id)dependsOn
        forNode: (id) node;

// mark a node as “modified” and return all nodes which in effect are then also modified
- (NSSet *)touchNode: (id)node;

// return list of all nodes ordered so that for each node, all it depends on is before that node in this list
- (NSArray *)topologicalOrder;

@end

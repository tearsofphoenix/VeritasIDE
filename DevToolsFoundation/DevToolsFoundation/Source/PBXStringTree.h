/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

@class PBXStringTreeNode;

@interface PBXStringTree : NSObject
{
    NSString *_pathSeparator;
    PBXStringTreeNode *_rootNode;
    NSMutableDictionary *_sortHintsForPaths;
}

- (void)removeAllNodes;

- (void)setObject: (id)hint
          forPath: (NSString *)path;

- (id)objectForPath: (NSString *)path;

- (PBXStringTreeNode *)rootNode;

- (NSString *)pathSeparator;

- (void)setPreferredNodesOrder: (id)arg1
                       forPath: (NSString *)path;

@property BOOL keepsNodesSorted;

@property BOOL sortAllButTopLevel;

- (NSString * )description;

- (void)dealloc;

- (id)init;

- (id)initWithPathSeparator: (NSString *)separator;

@end


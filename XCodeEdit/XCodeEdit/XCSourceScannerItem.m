//
//  XCSourceScannerItem.m
//  XcodeEdit
//
//  Created by tearsofphoenix on 12-11-10.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "XCSourceScannerItem.h"

@implementation XCSourceScannerItem

- (BOOL)isDeclaration
{
    return [_children count] == 0;
}

- (NSInteger)numberOfChildren
{
    return [_children count];
}

- (id)childAtIndex: (NSInteger)arg1
{
    return [_children objectAtIndex: arg1];
}

- (void)addChild:(id)arg1
{
    [_children addObject: arg1];
}

- (NSComparisonResult)compareWithScannerItem: (id)obj
{
    if (obj && [obj conformsToProtocol: @protocol(XCScannerItem)])
    {
        id<XCScannerItem> value = obj;
        if ([value type] == _type
            && [[value name] isEqualToString: _name])
        {
            return NSOrderedSame;
        }else
        {
            return [[value name] compare: _name];
        }
    }
    
    return NSOrderedAscending;
}

- (NSString *)nameWithIndent
{
    return _name;
}

- (id)description
{
    NSMutableString *str = [NSMutableString stringWithFormat: @"name: %@, children:\n", _name];
    
    for (XCSourceScannerItem *item in _children)
    {
        [str appendString: [item description]];
    }
    [str appendString: @"\n"];
    
    return str;
}

- (void)dealloc
{
    [_children release];
    [super dealloc];
}

- (id)initWithName: (NSString *)name
              type: (NSInteger)type
{
    if ((self = [super init]))
    {
        _children = [[NSMutableArray alloc] init];
        
        [self setName: name];
        [self setType: (int)type];
    }
    
    return self;
}

@end


//
//  OakTextIndent.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakTextIndent.h"
#import <OakFoundation/OakFoundation.h>

@implementation OakTextIndent

- (id)init
{
    if ((self = [super init]))
    {
        _tabSize = 8;
        _indentSize = UINT_MAX;
        _useSoftTabs = NO;
        _tabFollowsIndent = YES;
    }
    
    return self;
}

- (void)setTabSize: (NSUInteger)tabSize
{
    if (_tabSize != tabSize)
    {
        _tabSize = tabSize;
        if (_tabFollowsIndent)
        {
            _indentSize = tabSize;
        }
    }
}

- (void)setIndentSize: (NSUInteger)indentSize
{
    if (_indentSize != indentSize)
    {
        _indentSize = indentSize;
        if (_tabFollowsIndent)
        {
            _tabSize = indentSize;
        }
    }
}

- (NSString *)createAtColumn: (NSUInteger)atColumn
                       units: (NSUInteger)units
{
    NSUInteger baseColumn    = atColumn - (atColumn % _indentSize);
    NSUInteger desiredColumn = baseColumn + units * _indentSize;
    
    if(_useSoftTabs)
    {
        return [NSString stringWithChar: ' '
                            repeatCount: desiredColumn - atColumn];
    }
    else if(_indentSize == _tabSize)
    {
        return [NSString stringWithChar: '\t'
                            repeatCount: units];
    }
    else
    {
        NSUInteger desiredBase = desiredColumn - (desiredColumn % _tabSize);
        if(desiredBase <= atColumn)
        {
            return [NSString stringWithChar: ' '
                                repeatCount: desiredColumn - atColumn];
        }
        
        NSString *front = [NSString stringWithChar: '\t'
                                       repeatCount: (desiredBase / _tabSize - baseColumn / _tabSize)];
        
        NSString *follow = [NSString stringWithChar: ' '
                                        repeatCount: (desiredColumn - desiredBase)];
        
        return [front stringByAppendingString: follow];
    }
}

@end

//
//  OakPosition.m
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-3.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakTextPosition.h"

@implementation OakTextPosition

- (id)initWithString: (NSString *)str
{
    if ((self = [super init]))
    {
        static NSUInteger pos[] = { 1, 1, 0 };
        
        const char * cString = [str UTF8String];
        
        if(1 == sscanf(cString, "%zu:%zu+%zu", &pos[0], &pos[1], &pos[2]))
        {
            sscanf(cString, "%zu+%zu", &pos[0], &pos[2]);
        }
        
        _line = pos[0] - 1;
        _column = pos[1] - 1;
        _offset = pos[2];
    }
    
    return self;
}

- (id)positionByStripOffset
{
    OakTextPosition *value = [[[self class] alloc] init];
    
    [value setLine: _line];
    [value setColumn: _column];
    
    return [value autorelease];
}

- (BOOL)isEqual: (id)object
{
    if (!object)
    {
        return NO;
    }else
    {
        if ([object isKindOfClass: [self class]])
        {
            return ([object line] == _line && [object column] == _column && [object offset] == _offset);
        }
        
        return NO;
    }
}

- (NSComparisonResult)compare: (id)object
{
    if ([object isKindOfClass: [self class]])
    {
        NSUInteger oLine = [object line];
        NSUInteger oColumn = [object column];
        NSUInteger offset = [object offset];
        
        if (oLine > _line)
        {
            return NSOrderedAscending;
            
        }else if (oLine < _line)
        {
            return NSOrderedDescending;
            
        }else
        {
            if (oColumn > _column)
            {
                return NSOrderedAscending;
                
            }else if (oColumn < _column)
            {
                return NSOrderedDescending;
            }else
            {
                if (offset > _offset)
                {
                    return NSOrderedAscending;
                    
                }else if (offset < _offset)
                {
                    return NSOrderedDescending;
                }else
                {
                    return NSOrderedSame;
                }
            }
            
        }
    }
    
    return NSOrderedAscending;
}


- (NSString *)description
{
    return [NSString stringWithFormat: @"%ld:%@+%@", _line + 1, (_column ? @(_column + 1) : @"") , (_offset ? @(_offset) : @"")];
}

- (id)copyWithZone: (NSZone *)zone
{
    id copy = [[[self class] allocWithZone: zone] init];
    [copy setLine: _line];
    [copy setColumn: _column];
    [copy setOffset: _offset];
    
    return copy;
}

@end

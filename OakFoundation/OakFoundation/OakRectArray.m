//
//  OakRectArray.m
//  OakFoundation
//
//  Created by LeixSnake on 11/9/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import "OakRectArray.h"
#import "OakMutableRectArray.h"

@implementation OakRectArray

+ (void)initialize
{
    
}

- (NSRect)lastRect
{
    return [self rectAtIndex: _count - 1];
}

- (NSRect)firstRect
{
    return [self rectAtIndex: 0];
}

- (NSUInteger)indexOfRect: (NSRect)rect
{
    for (NSUInteger iLooper = 0; iLooper < _count; ++iLooper)
    {
        if (NSEqualRects(rect, _rects[iLooper]))
        {
            return iLooper;
        }
    }
    
    return NSNotFound;
}

- (NSRect)rectAtIndex: (NSUInteger)idx
{
    if (idx < _count)
    {
        return _rects[idx];
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", idx, _count]
                                     userInfo: nil];
    }
}

- (id)objectAtIndex: (NSUInteger)idx
{
    if (idx < _count)
    {
        return [NSValue valueWithRect: _rects[idx]];
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", idx, _count]
                                     userInfo: nil];
    }
}

- (NSUInteger)count
{
    return _count;
}

- (id)descriptionWithLocale: (NSLocale *)locale
{
    NSMutableString *des = [NSMutableString stringWithString: @"("];
    
    for (NSUInteger iLooper = 0; iLooper < _count; ++iLooper)
    {
        [des appendFormat: @"\n%@,", NSStringFromRect(_rects[iLooper]) ];
    }
    
    [des appendString: @"\n)"];
    
    return des;
}

- (id)mutableCopyWithZone: (NSZone *)zone
{
    OakMutableRectArray *mutableCopy = [[OakMutableRectArray allocWithZone: zone] initWithRects: _rects
                                                                                          count: _count];    
    return mutableCopy;
}

- (id)copyWithZone: (NSZone *)zone
{
    OakRectArray *copy = [[[self class] allocWithZone: zone] initWithRects: _rects
                                                                     count: _count];
    return copy;
}

- (BOOL)isEqualToArray: (id)arg1
{
    
    if (arg1)
    {
        if([arg1 isKindOfClass: [self class]])
        {
            return ([arg1 count] == _count)
            && (memcmp(_rects, ((OakRectArray *)arg1)->_rects, _count * sizeof(NSRect)) == 0);
            
        }else if ([arg1 isKindOfClass: [OakMutableRectArray class]])
        {
            const NSRect *data = [arg1 rectData];
            
            BOOL result = memcmp(_rects, data, sizeof(NSRect) * _count) == 0;
            
            free((void *)data);
            
            return result;
        }
        
        return NO;
    }
    
    return NO;

}

- (void)dealloc
{
    if (_rects)
    {
        free(_rects);
    }
    
    [super dealloc];
}

- (id)init
{
    return [self initWithRects: NULL
                         count: 0];
}

- (id)initWithRects: (const NSRect *)rects
              count: (NSUInteger)count
{
    if ((self = [super init]))
    {
        if (rects)
        {
            _count = count;
            _rects = malloc(_count * sizeof(NSRect));
            
            memcpy(_rects, rects, _count * sizeof(NSRect));
        }else
        {
            _count = 0;
            _rects = NULL;
        }
    }
    
    return self;
}

- (id)initWithObjects: (const id *)objects
                count: (NSUInteger)count
{
    if ((self = [super init]))
    {
        if (objects)
        {
            _count = count;
            _rects = malloc(sizeof(NSRect) * _count);
            
            for (NSUInteger iLooper = 0; iLooper < _count; ++iLooper)
            {
                id obj = obj[iLooper];
                
                if ([obj isKindOfClass: [NSString class]])
                {
                    _rects[iLooper] = NSRectFromString(obj);
                    
                }else if ([obj isKindOfClass: [NSValue class]])
                {
                    _rects[iLooper] = [obj rectValue];
                    
                }else
                {
                    _rects[iLooper] = NSZeroRect;
                }
            }
            
        }else
        {
            _rects = NULL;
            _count = 0;
        }
    }
    
    return self;
}

- (const NSRect *)rectData
{
    return _rects;
}

@end

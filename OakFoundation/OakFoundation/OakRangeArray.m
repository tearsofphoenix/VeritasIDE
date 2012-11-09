//
//  OakRangeArray.m
//  OakFoundation
//
//  Created by LeixSnake on 11/9/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import "OakRangeArray.h"
#import "OakMutableRangeArray.h"

@implementation OakRangeArray

static Class s_OakRangeArrayStringClass = nil;
static Class s_OakRangeArrayValueClass = nil;
static NSRange s_OakRangeArrayInvalidRange;

+ (void)initialize
{
    s_OakRangeArrayStringClass = [NSString class];
    s_OakRangeArrayValueClass = [NSValue class];
    s_OakRangeArrayInvalidRange = NSMakeRange(NSNotFound, NSNotFound);
}

- (id)normalizedRangeArray
{
    return nil;
}

#define M_OakRangeArray(op)    { for (NSUInteger iLooper = 0; iLooper < _count; ++iLooper)\
                                 {\
                                    NSRange rangeLooper = _ranges[iLooper];\
                                    if (rangeLooper.location + rangeLooper.length op arg1)\
                                    {\
                                        return iLooper;\
                                    }\
                                }\
                                return NSNotFound;\
                              }

- (NSUInteger)indexOfRangeContainingOrFollowing: (NSUInteger)arg1
{
    M_OakRangeArray(>=);
}

- (NSUInteger)indexOfRangeContainingOrPreceding: (NSUInteger)arg1
{
    M_OakRangeArray(<=);
}

- (NSUInteger)indexOfRangeFollowing: (NSUInteger)arg1
{
    M_OakRangeArray(>);
}

- (NSUInteger)indexOfRangePreceding: (NSUInteger)arg1
{
    M_OakRangeArray(<);
}

- (NSRange)lastRange
{
    return [self rangeAtIndex: _count - 1];
}

- (NSRange)firstRange
{
    return [self rangeAtIndex: 0];
}

- (NSUInteger)indexOfRange: (NSRange)arg1
{
    for (NSUInteger iLooper = 0; iLooper < _count; ++iLooper)
    {
        NSRange rangeLooper = _ranges[iLooper];
        if (rangeLooper.location == arg1.location
            && rangeLooper.length == arg1.length)
        {
            return iLooper;
        }
    }
    
    return NSNotFound;
}

- (NSRange)rangeAtIndex: (NSUInteger)arg1
{
    if(arg1 < _count)
    {
        return _ranges[arg1];
        
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", arg1, _count]
                                     userInfo: nil];
    }
}

- (id)objectAtIndex: (NSUInteger)arg1
{
    if(arg1 < _count)
    {
        return [NSValue valueWithRange: _ranges[arg1]];
        
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", arg1, _count]
                                     userInfo: nil];
    }
}

- (NSUInteger)count
{
    return _count;
}

- (id)descriptionWithLocale: (id)locale
{
    NSMutableString *des = [NSMutableString stringWithString: @"("];
    
    for (NSUInteger iLooper = 0; iLooper < _count; ++iLooper)
    {
        [des appendFormat: @"\n%@,", NSStringFromRange(_ranges[iLooper]) ];
    }
    
    [des appendString: @"\n)"];
    
    return des;
}

- (id)mutableCopyWithZone: (NSZone *)arg1
{
    OakMutableRangeArray *mutableCopy = [[OakMutableRangeArray allocWithZone: arg1] initWithRanges: _ranges
                                                                                             count: _count];
    return mutableCopy;
}

- (id)copyWithZone: (NSZone *)arg1
{
    OakRangeArray *copy = [[[self class] allocWithZone: arg1] initWithRanges: _ranges
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
                    && (memcmp(_ranges, ((OakRangeArray *)arg1)->_ranges, _count * sizeof(NSRange)) == 0);
            
        }else if ([arg1 isKindOfClass: [OakMutableRangeArray class]])
        {
            const void *data = [arg1 rangeData];
            
            BOOL result = memcmp(_ranges, data, sizeof(NSRange) * _count) == 0;
            free((void *)data);
            
            return result;

        }

        return NO;
    }
    
    return NO;
}

- (NSUInteger)hash
{
    return _count;
}

- (void)dealloc
{
    if (_ranges)
    {
        _count = 0;
        free(_ranges);
    }
    
    [super dealloc];
}

- (id)init
{
    return [self initWithRanges: NULL
                          count: 0];
}

- (id)initWithRanges: (const NSRange *)arg1
               count: (NSUInteger)arg2
{
    if ((self = [super init]))
    {
        if (arg1)
        {
            _count = arg2;
            _ranges = malloc(sizeof(NSRange) * _count);
            memcpy(_ranges, arg1, sizeof(NSRange) * _count);
        }else
        {
            _ranges = NULL;
            _count = 0;
        }
    }
    
    return self;
}

- (id)initWithObjects: (const id *)arg1
                count: (NSUInteger)arg2
{
    if ((self = [super init]))
    {
        if (arg1)
        {
            _count = arg2;
            _ranges = malloc(sizeof(NSRange) * _count);
            
            for (NSUInteger iLooper = 0; iLooper < _count; ++iLooper)
            {
                id obj = arg1[iLooper];

                if ([obj isKindOfClass: s_OakRangeArrayStringClass])
                {
                    _ranges[iLooper] = NSRangeFromString(obj);
                    
                }else if ([obj isKindOfClass: s_OakRangeArrayValueClass])
                {
                    _ranges[iLooper] = [obj rangeValue];
                    
                }else
                {
                    _ranges[iLooper] = s_OakRangeArrayInvalidRange;
                }
            }
            
        }else
        {
            _ranges = NULL;
            _count = 0;
        }
    }
    
    return self;
}

- (const NSRange *)rangeData
{
    return _ranges;
}

@end

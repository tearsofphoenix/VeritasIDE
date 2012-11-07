//
//  OakSelectionRange.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakSelectionRange.h"
#import "OakSelectionIndex.h"

@implementation OakSelectionRange

+ (id)rangeWithFirstIndex: (OakSelectionIndex *)first
                lastIndex: (OakSelectionIndex *)last
{
    return [[[self alloc] initWithFirstIndex: first
                                   lastIndex: last] autorelease];
}

- (id)initWithFirstIndex: (OakSelectionIndex *)firstIndex
               lastIndex: (OakSelectionIndex *)lastIndex
{
    if ((self = [super init]))
    {
        _first = [firstIndex retain];
        _last = [(lastIndex ?: firstIndex) retain];
    }
    
    return self;
}

- (OakSelectionIndex *)minIndex
{
    if([_first compare: _last] == NSOrderedDescending)
    {
        return _first;
    }else
    {
        return _last;
    }
}

- (OakSelectionIndex *)maxIndex
{
    if([_first compare: _last] == NSOrderedDescending)
    {
        return _last;
    }else
    {
        return _first;
    }
}

- (OakSelectionRange *)sortedRange
{
    OakSelectionRange *range = [[OakSelectionRange alloc] initWithFirstIndex: [self minIndex]
                                                                   lastIndex: [self maxIndex]];
    [range setColumnar: _columnar];
    [range setFreehanded: _freehanded];
    
    return [range autorelease];
}

- (BOOL)isEmpty
{
    return _freehanded ? ([_first isEqual: _last]) : ([[_first index] isEqual: [_last index]]);
}

- (OakSelectionRange *)normalizedRange
{
    BOOL strip = !_columnar && !_freehanded;
    
    if (strip)
    {
        OakSelectionRange *range = [[OakSelectionRange alloc] initWithFirstIndex: [[self minIndex] index]
                                                                       lastIndex: [[self maxIndex] index]];
        [range setColumnar: _columnar];
        [range setFreehanded: _freehanded];
        [range setUnanchored: _unanchored];
        return [range autorelease];
    }else
    {
        OakSelectionRange *range = [[OakSelectionRange alloc] initWithFirstIndex: [self minIndex]
                                                                       lastIndex: [self maxIndex]];
        [range setColumnar: _columnar];
        [range setFreehanded: _freehanded];
        [range setUnanchored: _unanchored];
        return [range autorelease];
        
    }
}

//		bool operator== (range_t  tmp) const { auto lhs = normalized(), rhs = tmp.normalized(); return lhs.first == rhs.first && lhs.last == rhs.last && lhs.columnar == rhs.columnar && lhs.freehanded == rhs.freehanded; }
//		bool operator!= (range_t  tmp) const { auto lhs = normalized(), rhs = tmp.normalized(); return lhs.first != rhs.first || lhs.last != rhs.last || lhs.columnar != rhs.columnar || lhs.freehanded != rhs.freehanded; }
//		bool operator< (range_t  tmp) const  { auto lhs = normalized(), rhs = tmp.normalized(); return lhs.first < rhs.first || (lhs.first == rhs.first && lhs.last < rhs.last); }
//		range_t operator+ (ssize_t i) const        { return range_t(first + i, last + i, columnar, freehanded); }
//
//		range_t& operator= (index_t  rhs)    { first = last = rhs; return *this; }
//

@end

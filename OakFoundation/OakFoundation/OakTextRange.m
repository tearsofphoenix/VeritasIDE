//
//  OakRange.m
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-3.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakTextRange.h"
#import "OakTextPosition.h"

@interface OakTextRange ()
{
@private
    OakTextPosition *_from;
    OakTextPosition *_to;
    BOOL _columnar;
}
@end

@implementation OakTextRange

- (id)initWithString: (NSString *)str
{
    if ((self = [super init]))
    {
        NSRange range = [str rangeOfString: @"-x"];
        _from = [[OakTextPosition alloc] initWithString: [str substringWithRange: NSMakeRange(0, range.location)]];
        _to = [[OakTextPosition alloc] initWithString: [str substringFromIndex: range.location + 1]];
        
        _columnar = (range.location != NSNotFound && [str UTF8String][range.location] == 'x');
    }
    
    return self;
}

- (BOOL)isEmpty
{
    return [_from isEqual: _to];
}

- (id)reversedRange
{
    OakTextRange *range = [[[self class] alloc] init];
    range->_from = [_to copy];
    range->_to = [_from copy];
    range->_columnar = _columnar;
    
    return [range autorelease];
}

- (id)rangeByNomalized
{
    OakTextRange *range = [[[self class] alloc] init];
    range->_from = [[self minPosition] copy];
    range->_to = [[self maxPosition] copy];
    range->_columnar = _columnar;

    return [range autorelease];
}

- (void)clear
{
    [_from release];
    _from = [_to copy];
}

- (id)rangeByStripOffset
{
    OakTextRange *range = [[[self class] alloc] init];
    range->_from = [[_from positionByStripOffset] copy];
    range->_to = [[_to positionByStripOffset] copy];
    range->_columnar = _columnar;
    
    return [range autorelease];
}

- (BOOL)columnar
{
    return _columnar;
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
            return ([[object minPosition] isEqual: [self minPosition]]
                    && [[object maxPosition] isEqual: [self maxPosition]]
                    && [object columnar] == _columnar);
        }
        
        return NO;
    }
}

- (OakTextPosition *)minPosition
{
    if ([_to compare: _from] == NSOrderedAscending)
    {
        return _to;
    }else
    {
        return _from;
    }
}

- (OakTextPosition *)maxPosition
{
    if ([_to compare: _from] == NSOrderedAscending)
    {
        return _from;
    }else
    {
        return _to;
    }
}

- (NSString *)description
{
    if ([self isEmpty])
    {
        return [_from description];
    }else
    {
        return [NSString stringWithFormat: @"%@%@%@", _from, (_columnar ? @"x" : @"-"), _to];
    }
}

@end

//
//  OakSelectionIndex.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakSelectionIndex.h"


@implementation OakSelectionIndex

- (BOOL)boolValue
{
    return _index != SIZE_T_MAX;
}

- (BOOL)isEqual: (id)object
{
    if ([object isKindOfClass: [self class]])
    {
        return _index == [object index] && _carry == [object carry];
    }
    
    return NO;
}

- (NSComparisonResult)compare: (id)object
{
    if (_index < [object index])
    {
        return NSOrderedAscending;
        
    }else if (_index == [object index])
    {
        if (_carry < [object carry])
        {
            return NSOrderedAscending;
            
        }else if(_carry == [object carry])
        {
            return NSOrderedSame;
            
        }else
        {
            return NSOrderedDescending;
        }
        
    }else
    {
        return NSOrderedDescending;
    }
}
//		BOOL operator< (index_t  rhs) const  { return index < rhs.index || (index == rhs.index && carry < rhs.carry); }
//		BOOL operator<= (index_t  rhs) const { return *this < rhs || *this == rhs; }
//		index_t operator+ (ssize_t i) const        { return index_t(index + i, carry); }
@end

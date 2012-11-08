//
//  OakScopePath.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakScopePath.h"
#import "OakScope.h"

@implementation OakScopePath

- (id)init
{
    if ((self = [super init]))
    {
        _anchor_to_bol = NO;
        _anchor_to_eol = NO;
        _scopes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)doesMatch: (OakScopePath *)lhs
             path: (OakScopePath *)path
             rank: (double *)rank
{
    //printf("scope selector:%s\n", this->to_s().c_str());
    NSUInteger i = [[path scopes] count]; // “source.ruby string.quoted.double constant.character”
    const NSUInteger size_i = i;
    NSUInteger j = [_scopes count];      // “string > constant $”
    const NSUInteger size_j = j;
    
    BOOL anchor_to_bol = _anchor_to_bol;
    BOOL anchor_to_eol = _anchor_to_eol;
    //printf("scope selector: anchor_to_bol:%s anchor_to_eol:%s\n", anchor_to_bol?"yes":"no", anchor_to_eol?"yes":"no");
    
    BOOL check_next = false;
    NSUInteger reset_i, reset_j;
    double reset_score = 0;
    double score = 0;
    double power = 0;
    while(j <= i && j)
    {
        assert(i); assert(j);
        assert(i-1 < [[path scopes] count]);
        assert(j-1 < [_scopes count]);
        
        BOOL anchor_to_previous = [[_scopes objectAtIndex: j-1] anchor_to_previous];
        //printf("scope selector:%s anchor_to_previous:%s check_next:%s\n", types::to_s(scopes[j-1]).c_str(), anchor_to_previous?"yes":"no", check_next?"yes":"no");
        
        if((anchor_to_previous || (anchor_to_bol && j == 1)) && !check_next)
        {
            reset_score = score;
            reset_i = i;
            reset_j = j;
        }
        
        power += [[[[path scopes] objectAtIndex: i-1] atoms] count];
        if([[[_scopes objectAtIndex: j-1] atoms] isEqual: [[[path scopes] objectAtIndex: i-1] atoms]])
        {
            for(NSUInteger k = 0; k < [[[_scopes objectAtIndex: j-1] atoms] count]; ++k)
                score += 1 / pow(2, power - k);
            --j;
            check_next = anchor_to_previous;
        }
        else if(check_next)
        {
            i = reset_i;
            j = reset_j;
            score = reset_score;
            check_next = false;
        }
        --i;
        // if the outer loop has run once but the inner one has not, it is not an anchor to eol
        if(anchor_to_eol)
        {
            //printf("anchor_to_eol: i:%zd size_i:%zd j:%zd size_j:%zd\n",i,size_i,j,size_j);
            if(i != size_i && j == size_j)
                break;
            else
                anchor_to_eol = false;
        }
        
        
        if(anchor_to_bol && j == 0 && i != 0)
        {
            i = reset_i - 1;
            j = reset_j;
            score = reset_score;
            check_next = false;
        }
        
    }
    if(j == 0 && rank)
        *rank = score;
    return j == 0;
}

- (BOOL)isEqual: (id)object
{
    if ([object isKindOfClass: [self class]])
    {
        return [_scopes isEqualToArray: [object scopes]];
    }
    
    return NO;
}

- (NSArray *)scopes
{
    return [NSArray arrayWithArray: _scopes];
}

- (void)setScopes: (NSArray *)scopes
{
    if (_scopes != scopes)
    {
        [_scopes setArray: scopes];
    }
}

@end

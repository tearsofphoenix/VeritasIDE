//
//  XCFold.m
//  XcodeEdit
//
//  Created by tearsofphoenix on 12-11-11.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "XCFold.h"

@implementation XCFold

+ (id)foldsFromString:(NSString *)str
{
    
}

+ (id)decodeFold: (id)arg1
forParent: (id)parent
{
    
}

@synthesize foldStyle = _foldStyle;

@synthesize label = _label;

@synthesize parent = _parent;

- (id)foldedIconString
{
    return @"...";
}

- (NSArray *)children
{
    return _children;
}

- (NSUInteger)numberOfChildren
{
    return [_children count];
}

- (id)removeChildren:(NSArray *)children
{
    for (XCFold *iLooper in children)
    {
        NSUInteger idx = [_children indexOfObject: iLooper];
        if (idx != NSNotFound)
        {
            [iLooper setParent: nil];
            [_children removeObjectAtIndex: idx];
        }
    }

    return _children;
}

- (void)addChild: (id)child
{
    [child setParent: self];
    [_children addObject: child];
}

- (id)findFoldContainingRange: (NSRange)range
{
    for (XCFold *iLooper in _children)
    {
        NSRange rangeLooper = [iLooper range];
        if (NSLocationInRange(rangeLooper.location, range)
            && NSLocationInRange(rangeLooper.location + rangeLooper.length, range))
        {
            return iLooper;
        }
    }
    
    return nil;
}

- (id)findFoldWithRange: (NSRange)range
{
    for (XCFold *iLooper in _children)
    {
        if (NSEqualRanges([iLooper range], range))
        {
            return iLooper;
        }
    }
    
    return nil;
}

- (NSUInteger)subtractOutFolds: (NSUInteger)arg1
{
    
}

- (NSUInteger)addInFolds:(NSUInteger)arg1
{
    
}

- (NSArray *)adjustFoldsForRange: (NSRange)arg1
           changeInLength: (NSInteger)arg2
{
    
}

- (NSArray *)foldsEnclosingRange:(NSRange)arg1
{
    
}

- (void)_addFoldsEnclosingRange: (NSRange)arg1
                        toArray: (NSArray *)arg2
{
    
}

- (NSArray *)foldsTouchingRange:(NSRange)arg1
{
    
}

- (BOOL)rangeIsInsideAFold:(NSRange)arg1
{
    
}

- (void)offsetBy:(NSInteger)arg1
{
    
}

- (void)setRange:(NSRange)arg1
{
    _relativeLocation = arg1;
}

- (NSRange)range
{
    return _relativeLocation;
}

- (BOOL)validate
{
    
}

- (NSString *)description
{
    return [self stringValue];
}
- (NSString *)innerDescription:(id)arg1
{
    return [self stringValue];
}

- (NSString *)stringValue
{
    
}

- (id)_pList
{
    
}

- (void)dealloc
{
    [_children release];
    [super dealloc];
}

- (id)initWithRange:(NSRange)arg1
{
    if ((self = [super init]))
    {
        _children = [[NSMutableArray alloc] initWithCapacity: 8];
        
        [self setRange: arg1];
    }
    
    return self;
}

@end


//
//  OakLayoutContext.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakLayoutContext.h"

@implementation OakLayoutContext

- (id)init
{
    if ((self = [super init]))
    {
        _imageCache = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_spellingDotImage release];
    [_imageCache release];
    
    [super dealloc];
}

- (NSImage *)foldingDotsWithSize: (CGSize)size
{
    if(_foldingFunction)
    {
        id key = [NSValue valueWithSize: size];
        NSImage *it = [_imageCache objectForKey: key];
        
        if(!it)
        {
            it = _foldingFunction(size.width, size.height);
            
            [_imageCache setObject: it
                            forKey: key];
        }
        
        return it;
    }
    
    return nil;
}

@end

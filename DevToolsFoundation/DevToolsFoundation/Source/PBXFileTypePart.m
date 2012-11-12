//
//  PBXFileTypePart.m
//  DevToolsFoundation
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "PBXFileTypePart.h"

@implementation PBXFileTypePart


+ (id)fileTypePartFromSpecificationArray: (NSArray *)array
                              identifier: (NSString *)ID
{
    return [[[self alloc] initFromSpecificationArray: array
                                          identifier: ID] autorelease];
}

- (BOOL)isSymbolicLink
{
    
}

- (BOOL)isFolder
{
    
}

- (BOOL)isPlainFile
{
    
}

- (NSArray *)subparts
{
    return _subparts;
}

- (void)setSuperpart: (NSArray *)parts
{
    [_subparts setArray: parts];
}

- (PBXFileTypePart *)superpart
{
    return _superpart;
}

- (NSString *)identifier
{
    return _identifier;
}

- (void)dealloc
{
    [_subparts release];
    
    [super dealloc];
}

- (id)init
{
    return [self initFromSpecificationArray: nil
                                 identifier: nil];
}

- (id)initFromSpecificationArray: (NSArray *)array
                      identifier: (NSString *)ID
{
    if ((self = [super init]))
    {
        _subparts = [[NSMutableArray alloc] initWithArray: array];
        _identifier = [ID retain];
    }
    
    return self;
    
}


@end
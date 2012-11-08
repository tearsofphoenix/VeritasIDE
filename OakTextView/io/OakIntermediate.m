//
//  OakIntermediate.m
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import "OakIntermediate.h"
#import <OakFoundation/OakFoundation.h>

@implementation OakIntermediate

static NSString * create_path (NSString * path)
{
	if(![path existsAsPath])
    {
		return path::make_dir(path::parent(path)), path;
    }
	else if(path::device(path) != path::device(path::temp()) && access(path::parent(path).c_str(), W_OK) == 0)
		return path + "~";
	return path::temp("atomic_save");
}


- (id)initWithString: (NSString *)str
{
    if ((self = [super init]))
    {
		_resolved     = path::resolve_head(dest);
		_intermediate = create_path(_resolved);
    }
    return self;
}


- (BOOL)commit
{
    return _intermediate == _resolved ? true : path::swap_and_unlink(_intermediate, _resolved);
}

@end

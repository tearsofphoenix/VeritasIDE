//
//  OakIntermediate.h
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakIntermediate : NSObject

- (id)initWithString: (NSString *)str;

- (BOOL)commit;

@property (nonatomic, retain) NSString * resolved;
@property (nonatomic, retain) NSString * intermediate;

@end

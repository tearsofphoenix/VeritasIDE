//
//  NSMutableDictionary+BlockExtension.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-1.
//
//

#import "NSMutableDictionary+BlockExtension.h"

@implementation NSMutableDictionary (BlockExtension)

- (void)setBlock: (id)block
          forKey: (id<NSCopying>)key
{
    block = Block_copy(block);
    
    [self setObject: block
             forKey: key];
    
    Block_release(block);
}

@end

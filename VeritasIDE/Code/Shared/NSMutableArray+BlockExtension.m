//
//  NSMutableArray+BlockExtension.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-1.
//
//

#import "NSMutableArray+BlockExtension.h"

@implementation NSMutableArray (BlockExtension)

- (void)addBlock: (id)block
{
    block = Block_copy(block);
    
    [self addObject: block];
    
    Block_release(block);
}

@end

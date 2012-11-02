//
//  NSMutableDictionary+BlockExtension.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-1.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (BlockExtension)

- (void)setBlock: (id)block
          forKey: (id<NSCopying>)key;

@end

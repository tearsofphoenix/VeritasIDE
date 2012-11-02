/*
     File: NSArray+VDEExtensions.h 
 Abstract: Category extension to NSArray.
 
 */

#import <Foundation/Foundation.h>

@interface NSArray (VDEExtensions)

- (BOOL)containsObjectIdenticalTo: (id)object;

- (BOOL)containsAnyObjectsIdenticalTo: (NSArray *)objects;

- (NSIndexSet *)indexesOfObjects: (NSArray *)objects;

@end

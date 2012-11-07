#import "NSArray+Additions.h"

@implementation NSArray (Other)

- (id)firstObject
{
	return [self count] ? [self objectAtIndex:0] : nil;
}

- (NSArray *)differenceArrayWithArray: (NSArray *)array
{
    NSMutableArray *selfArray = [NSMutableArray arrayWithArray: self];
    NSMutableArray *otherArray = [NSMutableArray arrayWithArray: array];
    
    [selfArray removeObjectsInArray: array];
    [otherArray removeObjectsInArray: self];
    
    NSMutableArray *result = [NSMutableArray arrayWithArray: selfArray];
    [result addObjectsFromArray: otherArray];

    return [NSArray arrayWithArray: result];
}

- (NSArray *)intersectArrayWithArray: (NSArray *)array
{
    NSSet *selfSet = [NSSet setWithArray: self];
    NSMutableSet *otherSet = [NSMutableSet setWithArray: array];
    [otherSet intersectSet: selfSet];
    return [otherSet allObjects];
}

@end


@implementation NSMutableArray (Resize)

- (void)resizeToCount: (NSUInteger)count
{
    while ([self count] > count)
    {
        [self removeLastObject];
    }
}

@end

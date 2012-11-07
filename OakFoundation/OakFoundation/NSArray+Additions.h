
@interface NSArray (Other)

- (id)firstObject;

- (NSArray *)differenceArrayWithArray: (NSArray *)array;

- (NSArray *)intersectArrayWithArray: (NSArray *)array;

@end


@interface NSMutableArray(Resize)

- (void)resizeToCount: (NSUInteger)count;

@end
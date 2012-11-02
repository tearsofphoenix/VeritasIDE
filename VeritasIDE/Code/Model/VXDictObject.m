//
//  VXDictObject.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-27.
//
//

#import "VXDictObject.h"
#import "VDEResourceService.h"

@implementation VXDictObject

@synthesize identity;
@synthesize absolutePath;
@synthesize name;
@synthesize parentObject;
@synthesize indexInParent;
@synthesize children;

- (id)initWithDictionary: (NSDictionary *)dict
{
    if((self = [super init]))
    {
        [dict enumerateKeysAndObjectsUsingBlock: (^(id key, id obj, BOOL *stop)
                                                  {
                                                      [self setValue: obj
                                                              forKey: key];
                                                  })];
    }
    
    return self;
}

- (id)valueForUndefinedKey: (NSString *)key
{
    return nil;
}

- (NSImage *)icon
{
    return [VDEResourceService imageForFileType: VDEResourceFolderIcon];
}

- (void)_markIndexPathDirty
{
    _indexPathIsClean = NO;
    
    [children makeObjectsPerformSelector: @selector(_markIndexPathDirty)];
}

- (NSIndexPath *)indexPath
{
    if (!_indexPathIsClean)
    {        
        NSMutableArray *indexes = [[NSMutableArray alloc] init];
        
        VXDictObject *objLooper = self;
        
        while (objLooper)
        {
            [indexes addObject: [NSNumber numberWithUnsignedInteger: [objLooper indexInParent]]];
            
            objLooper = [objLooper parentObject];
        }
        
        NSUInteger count = [indexes count];
        
        NSUInteger *data = malloc(sizeof(NSUInteger) * count);
        
        [indexes enumerateObjectsWithOptions: NSEnumerationReverse
                                  usingBlock: (^(NSNumber *obj, NSUInteger idx, BOOL *stop)
                                               {
                                                   data[count - 1 - idx] = [obj unsignedIntegerValue];
                                               })];
        
        [_indexPathCache release];
        _indexPathCache = [[NSIndexPath indexPathWithIndexes: data
                                                      length: count] retain];
        free(data);
        [indexes release];
        
        _indexPathIsClean = YES;
    }
    
    return _indexPathCache;
}

- (void)enumerateChildrenUsingBlock: (void(^)(id obj, BOOL *stop))block
                           recusive: (BOOL)recusive
                               stop: (BOOL *)stop
{
    for (id obj in [self children])
    {
        block(self, stop);
        
        if (stop)
        {
            return;
        }
        
        if (recusive)
        {
            [obj enumerateChildrenUsingBlock: block
                                    recusive: recusive
                                        stop: stop];
        }
    }
}

@end

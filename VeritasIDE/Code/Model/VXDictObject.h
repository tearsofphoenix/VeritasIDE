//
//  VXDictObject.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-27.
//
//

#import <Foundation/Foundation.h>

@interface VXDictObject : NSObject
{
    BOOL _indexPathIsClean;
    NSIndexPath *_indexPathCache;
}

@property (nonatomic, strong) NSString * identity;
@property (nonatomic, strong) NSString * absolutePath;
@property (nonatomic, strong) NSString * name;

@property (nonatomic, assign) VXDictObject *parentObject;
@property (nonatomic) NSUInteger indexInParent;
@property (nonatomic, strong) NSArray *children;

- (void)enumerateChildrenUsingBlock: (void(^)(id obj, BOOL *stop))block
                           recusive: (BOOL)recusive
                               stop: (BOOL *)stop;

- (NSIndexPath *)indexPath;

- (NSImage *)icon;

- (id)initWithDictionary: (NSDictionary *)dict;

@end

//
//  VXGroup.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-27.
//
//

#import "VXDictObject.h"

@class VDEProjectConfiguration;

@interface VXGroup : VXDictObject

@property (nonatomic, strong) NSMutableArray *children;

@property (nonatomic, strong) NSString *sourceTree;

@property (nonatomic, strong) NSString *path;

@end

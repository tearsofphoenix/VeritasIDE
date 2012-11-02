//
//  VXFileReference.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-27.
//
//

#import "VXDictObject.h"

@interface VXFileReference : VXDictObject

@property (nonatomic) NSStringEncoding fileEncoding;

@property (nonatomic, strong) NSString * lastKnownFileType;

@property (nonatomic, strong) NSString * path;

@property (nonatomic, strong) NSString * sourceTree;

- (BOOL)isFolder;

@end

extern NSString * VXKnowFileTypeFolder;
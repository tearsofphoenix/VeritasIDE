//
//  VXFileReference.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-27.
//
//

#import "VXFileReference.h"
#import "VDEResourceService.h"

@implementation VXFileReference

@synthesize fileEncoding;
@synthesize lastKnownFileType;
@synthesize path;
@synthesize sourceTree;

- (NSImage *)icon
{    
    return [VDEResourceService imageForFileType: lastKnownFileType];
}

- (void)setName: (NSString *)name
{
    [super setName: name];
    [self setPath: name];
}

- (BOOL)isFolder
{
    return [lastKnownFileType isEqualToString: VXKnowFileTypeFolder];
}

@end

NSString * VXKnowFileTypeFolder = @"resource.file.foler";
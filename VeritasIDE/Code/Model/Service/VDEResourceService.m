//
//  VDEResourceService.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-27.
//
//

#import "VDEServices.h"

#define VDEResourceServiceIdentifier "com.veritas.ide.service.resource"

#define VDEResourceServiceQueueID  VDEResourceServiceIdentifier".queue"


static  NSMutableDictionary *_resources = nil;
static CFMutableDictionaryRef _paths = NULL;

@interface VDEResourceService ()
{
@private
    dispatch_queue_t _queue;
}
@end


@implementation VDEResourceService

+ (id)identity
{
    return VDEResourceServiceID;
}

+ (void)load
{
    [super registerService: self];
}

- (id)init
{
    if ((self = [super init]))
    {
        _queue = dispatch_queue_create(VDEResourceServiceQueueID, DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(_queue,
                       (^
                        {
                            _resources = [[NSMutableDictionary alloc] init];
                            NSString *path = [[NSBundle mainBundle] resourcePath];
                            
                            NSArray *resourceLoadList = [NSArray arrayWithContentsOfFile: [path stringByAppendingPathComponent:  @"VDEResourceLoadList.plist"]];
                            
                            for (NSString *item in resourceLoadList)
                            {
                                //NSImage *imageLooper = [NSImage imageNamed: [path stringByAppendingFormat: @"/%@.icns", item]];
                                NSImage *imageLooper = [NSImage imageNamed: item];
                                [_resources setObject: imageLooper
                                               forKey: item];
                            }
                            
                            NSImage *image = [NSImage imageNamed: @"icon.navigator.group"];
                            
                            [_resources setObject: image
                                           forKey: VDEResourceFolderIcon];
                           
                            //application support
                            //
                            _paths = (CFMutableDictionaryRef)[[NSMutableDictionary alloc] init];
                            
                           path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)
                                   objectAtIndex: 0];
                            
                            NSString *applicationName = [[NSRunningApplication currentApplication] localizedName];
                            
                            path = [path stringByAppendingPathComponent: applicationName];
                            
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            
                            if (![fileManager fileExistsAtPath: path])
                            {
                                NSError *error = nil;
                                [fileManager createDirectoryAtPath: path
                                       withIntermediateDirectories: YES
                                                        attributes: nil
                                                             error: &error];
                                if (error)
                                {
                                    VDEExceptionServiceHandleError(error);
                                }
                            }
                            
                            [(NSMutableDictionary *)_paths setObject: path
                                                              forKey: VDEResourceServiceApplicationSupportPath];

                        }));
    }
    return self;
}

- (void)dealloc
{
    [_resources release];
    CFRelease(_paths);
    
    [super dealloc];
}

+ (NSImage *)imageForFileType: (NSString *)fileType
{
    return CFDictionaryGetValue((CFDictionaryRef)_resources, fileType);
}

+ (NSString *)applicationSupportPath
{
    return CFDictionaryGetValue(_paths, VDEResourceServiceApplicationSupportPath);
}

@end

NSString * const VDEResourceServiceID = @VDEResourceServiceIdentifier;

NSString * const VDEResourceFolderIcon = @"resource.icon.folder";

NSString * const VDEResourceServiceApplicationSupportPath = @"resource.applicationSupportPath";

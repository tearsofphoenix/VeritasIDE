//
//  VDEDataService.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-25.
//
//

#import "VDEServices.h"
#import "VDEProjectConfiguration.h"
#import "VDEProjectNavigatorPrivateHandler.h"
#import "NSString+RandomHexString.h"

@interface VDEDataService ()
{
@private
    NSMutableDictionary *_projectConfigurations;
}
@end

@implementation VDEDataService

+ (id)identity
{
    return VDEDataServiceID;
}

+ (void)load
{
    [super registerService: self];
}

- (id)init
{
    if ((self = [super init]))
    {
        _projectConfigurations = [[NSMutableDictionary alloc] init];
                
    }
    
    return self;
}

- (void)initProcessors
{
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              NSString *filePath = [arguments objectAtIndex: 0];
                              VDEProjectConfiguration *projectConguration = [[VDEProjectConfiguration alloc] initWithFilePath: filePath];
                              
                              NSString *workingPath = [[VDEResourceService applicationSupportPath] stringByAppendingPathComponent: [projectConguration rootObjectID]];
                              
                              workingPath = [workingPath stringByAppendingString: [NSString randomLowerAlphabetStringWithLength: 28]];
                              
                              NSFileManager *fileManager = [NSFileManager defaultManager];
                              
                              NSError *error = nil;
                              
                              [fileManager createDirectoryAtPath: workingPath
                                     withIntermediateDirectories: YES
                                                      attributes: nil
                                                           error: &error];
                              
                              VDEExceptionServiceHandleError(error);

                              [projectConguration setWorkingPath: workingPath];
                              
                              [_projectConfigurations setObject: projectConguration
                                                         forKey: filePath];
                              
                              [[VDENotificationService serviceCenter] postNotificationName: VDEDataServiceDidLoadProjectNotification
                                                                                    object: nil
                                                                                  userInfo: (@{
                                                                                             @"project" : projectConguration
                                                                                             })];
                              [projectConguration release];
                          })
              forAction: VDEDataServiceLoadProjectFileAction];
    
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              if(callback)
                              {
                                  callback(arguments);
                              }
                          })
              forAction: VDEDatsaServiceAddBlockAction];
}

@end

NSString * const VDEDataServiceID = @"com.veritas.ide.service.data";

NSString * const VDEDataServiceLoadProjectFileAction = @"action.loadProject";

NSString * const VDEDataServiceDidLoadProjectNotification = @"notification.didLoadProject";

NSString * const VDEDatsaServiceAddBlockAction = @"action.addBlock";

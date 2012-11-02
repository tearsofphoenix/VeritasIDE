//
//  VDEMainWindowControllerPrivateHandler.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-29.
//
//

#import "VDEMainWindowControllerPrivateHandler.h"

#import "DMTabBarItem.h"

#import "VDEToolBarItemView.h"

#import "VDEFoundation.h"

#import "VDEServices.h"

#import "VDEProjectConfiguration.h"
#import "VDEMainWindowController.h"

@interface VDEMainWindowControllerPrivateHandler ()<VDEToolBarItemViewDelegate>
{
@private
    VDEMainWindowController *_controller;
    VDEProjectConfiguration *_projectConfiguration;
    CFMutableDictionaryRef _toolbarProcessors;
}
@end

@implementation VDEMainWindowControllerPrivateHandler

static NSArray *s_NavigatorTabBarConfiguration = nil;

+ (void)initialize
{
    s_NavigatorTabBarConfiguration = [(@[
                                       [NSImage imageNamed: @"FolderRef"],
                                       [NSImage imageNamed: @"hud_buttonDebug_TurnOffBreakpoints"] ]
                                       ) retain];
}

- (id)init
{
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id)initWithController: (VDEMainWindowController *)controller
{
    if ((self = [super init]))
    {
        _controller = controller;
        
        NSMutableDictionary *processors = [[NSMutableDictionary alloc] init];
        
        [processors setBlock: (^(NSArray *argument)
                               {
                                   VSC(VDEDebugServiceID,
                                       VDEDebugServiceBeginDebugSessionAction,
                                       (^(NSArray *arguments)
                                        {
                                            
                                        }), @[ _projectConfiguration ]);
                               })
                      forKey: VDEToolbarEventRunButtonPressed];
        
        [processors setBlock: (^(NSArray *argument)
                               {
                                   
                               })
                      forKey: VDEToolbarEventStopButtonPressed];
        
        [processors setBlock: (^(NSArray *argument)
                               {
                                   
                               })
                      forKey: VDEToolbarEventToggleBreakPoint];
        
        _toolbarProcessors = (CFMutableDictionaryRef)processors;
        
        [[VDENotificationService serviceCenter] addObserver: self
                                                   selector: @selector(notificationForDidLoadProject:)
                                                       name: VDEDataServiceDidLoadProjectNotification
                                                     object: nil];
    }
    
    return self;
}

- (void)dealloc
{
    CFRelease(_toolbarProcessors);
    
    [super dealloc];
}

#pragma mark - DMTabBarDataSource

- (NSUInteger)numberOfItemInTabBar: (DMTabBar *)tabBar
{
    return [s_NavigatorTabBarConfiguration count];
}

- (DMTabBarItem *)tabBar: (DMTabBar *)tabBar
             itemAtIndex: (NSUInteger)index
{
    NSImage *image = [s_NavigatorTabBarConfiguration objectAtIndex: index];
    
    DMTabBarItem *item = [[DMTabBarItem alloc] init];
    
    [item setImage: image];
    
    return [item autorelease];
}

#pragma mark - toolbar

- (void)toolbarItemView: (VDEToolBarItemView *)view
              sendEvent: (NSString *)event
               userInfo: (id)info
{
    VCallbackBlock block = CFDictionaryGetValue(_toolbarProcessors, event);
    
    if(block)
    {
        block( info ? @[ info ] : info);
    }
        
}

#pragma mark - notifications

- (void)notificationForDidLoadProject: (NSNotification *)notification
{
    VDEProjectConfiguration *configuration = [[notification userInfo] objectForKey: @"project"];
    
    if (_projectConfiguration != configuration)
    {
        [_projectConfiguration release];
        _projectConfiguration = [configuration retain];
        
        [_controller reloadProjectConfiguration];
    }
}

- (VDEProjectConfiguration *)currentProjectConfiguration
{
    return _projectConfiguration;
}

@end

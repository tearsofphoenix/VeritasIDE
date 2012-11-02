//
//  NSMenu+VDEProjectConfigurationExtension.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-29.
//
//

#import "NSMenu+VDEProjectConfigurationExtension.h"
#import "VDEProjectConfiguration.h"
#import "VXGroup.h"
#import "VXFileReference.h"

@implementation NSMenu (VDEProjectConfigurationExtension)

static void NSMenuBuildItemForGrop(NSMenu *self, id group, VDEProjectConfiguration *configuration)
{
    NSString *groupName = [group valueForKey: @"path"];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: (groupName ? groupName : [group valueForKey: @"name"])
                                                  action: NULL
                                           keyEquivalent: @""];
    [item setImage: [group icon]];
    [self addItem: item];
    
    [item release];
    
    NSMenu *subMenu = [[NSMenu alloc] init];
    
    [item setSubmenu: subMenu];
    
    [subMenu release];
    
    for (VXDictObject *objLooper in [group children])
    {
        if ([objLooper isKindOfClass: [VXGroup class]])
        {
            
            NSMenuBuildItemForGrop(subMenu, objLooper, configuration);
                        
            
        }else if ([objLooper isKindOfClass: [VXFileReference class]])
        {
            item = [[NSMenuItem alloc] initWithTitle: [objLooper valueForKey: @"path"]
                                              action: NULL
                                       keyEquivalent: @""];
            [item setImage: [objLooper icon]];
            
            [subMenu addItem: item];
            
            [item release];
        }
    }
    
}

- (void)buildMenuItemWithConfiguration: (VDEProjectConfiguration *)configuration
{
    [self removeAllItems];
    
    VXGroup *mainGroup = [configuration mainGroup];
    
    NSMenuBuildItemForGrop(self, mainGroup, configuration);
}

@end

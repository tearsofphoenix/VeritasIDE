//
//  AppDelegate.m
//  TestGUI
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "AppDelegate.h"
#import <OakFoundation/OakFoundation.h>

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString: @"Hello world!"];

    [str setFont: [NSFont fontWithName: @"Menlo"
                                  size: 14]
           range: NSMakeRange(0, [str length])];
    [str setBackgroundColor: [NSColor redColor]
                      range: NSMakeRange(0, [str length])];

    [str setForegroundColor: [NSColor blueColor]
                      range: NSMakeRange(0, [str length])];

    [str drawAtPoint: NSMakePoint(0, 0)];
    
}

@end

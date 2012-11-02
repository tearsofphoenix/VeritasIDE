//
//  VXProject.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-27.
//
//

#import "VXProject.h"

@implementation VXProject

@synthesize mainGroup;
@synthesize projectDirPath;
@synthesize projectRoot;
@synthesize targets;


- (void)dealloc
{
    [mainGroup release];
    [projectDirPath release];
    [projectRoot release];
    [targets release];
    
    [super dealloc];
}

@end

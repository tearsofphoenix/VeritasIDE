//
//  VDEMainWindowControllerPrivateHandler.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-29.
//
//

#import "DMTabBar.h"
#import "VDEToolBarItemView.h"

@class VDEMainWindowController;
@class VDEProjectConfiguration;

@interface VDEMainWindowControllerPrivateHandler : NSObject<DMTabBarDataSource, VDEToolBarItemViewDelegate>

- (id)initWithController: (VDEMainWindowController *)controller;

- (VDEProjectConfiguration *)currentProjectConfiguration;

@end

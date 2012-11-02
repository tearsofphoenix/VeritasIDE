//
//  VDEProjectNavigatorPrivateHandler.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-25.
//
//

#import <Cocoa/Cocoa.h>

@class VDEProjectConfiguration;

@interface VDEProjectNavigatorPrivateHandler : NSObject


- (id)initWithOutlineView: (NSOutlineView *)outlineView;

@property (nonatomic, assign) VDEProjectConfiguration *projectConfiguration;

@end

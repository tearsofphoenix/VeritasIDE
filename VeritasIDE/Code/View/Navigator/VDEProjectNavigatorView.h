//
//  VDEProjectNavigatorView.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-25.
//
//

#import <Cocoa/Cocoa.h>

@class VDEProjectConfiguration;

@interface VDEProjectNavigatorView : NSScrollView
{
@private
    NSOutlineView *_outlineView;
}

@property (nonatomic, strong) VDEProjectConfiguration *projectConfiguration;

@end

extern NSString * VDEProjectNavigatorViewDidSelectSingleFileNotification;
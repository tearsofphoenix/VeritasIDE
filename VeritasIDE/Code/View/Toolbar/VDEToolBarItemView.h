//
//  VDEToolBarItemView.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import <Cocoa/Cocoa.h>

@class VDEToolBarItemView;

@protocol VDEToolBarItemViewDelegate <NSObject>

@required

- (void)toolbarItemView: (VDEToolBarItemView *)view
              sendEvent: (NSString *)event
               userInfo: (id)info;

@end

@interface VDEToolBarItemView : NSView

@property (nonatomic, assign) id<VDEToolBarItemViewDelegate> delegate;

@end

extern NSString * const VDEToolbarEventRunButtonPressed;

extern NSString * const VDEToolbarEventStopButtonPressed;

extern NSString * const VDEToolbarEventToggleBreakPoint;
//
//  VDEToolBarView.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import "VDEToolBarItemView.h"
#import "VDEPushButton.h"

@interface VDEToolBarItemView ()
{
@private
    NSButton *_runButton;
    NSButton *_stopButton;
    NSButton *_breakpointCheckBox;
}
@end

@implementation VDEToolBarItemView

static void VDEToolBarItemViewInitialize(VDEToolBarItemView *self)
{
    //run button
    //
    NSButton *runButton = [[NSButton alloc] initWithFrame: NSMakeRect(0, 0, 32, 32)];

    [runButton setImage: [NSImage imageNamed: @"DVTRunButtonRun"]];
    [runButton setBordered: NO];
    [runButton setTarget: self];
    [runButton setAction: @selector(_handleRunButtonTapedEvent:)];
    [self addSubview: runButton];

    self->_runButton = runButton;
    
    //stop button
    //
    CGRect frame = [runButton frame];
    NSButton *stopButton = [[NSButton alloc] initWithFrame: NSMakeRect(frame.origin.x + frame.size.width + 10, 0, 32, 32)];

    [stopButton setImage: [NSImage imageNamed: @"DVTRunButtonStopD"]];
    [stopButton setBordered: NO];
    [stopButton setTarget: self];
    [stopButton setAction: @selector(_handleStopButtonTapedEvent:)];
    
    [self addSubview: stopButton];
    
    self->_stopButton = stopButton;
    
    frame = [stopButton frame];

    VDEPushButton *breakpointButton = [[VDEPushButton alloc] initWithFrame: NSMakeRect(frame.origin.x + frame.size.width + 10, 0, 20, 32)];
    
    
    //[cell setButtonType: NSOnOffButton];
    [breakpointButton setBordered: NO];

    [breakpointButton setSelectedImage: [NSImage imageNamed: @"hud_buttonDebug_TurnOnBreakpoints"]];
    [breakpointButton setImage: [breakpointButton selectedImage]];    
    [breakpointButton setAlternateImage: [NSImage imageNamed: @"hud_buttonDebug_TurnOffBreakpoints"]];
    [breakpointButton setTarget: self];
    [breakpointButton setAction: @selector(_handleToggleBreakpointButtonPressedEvent:)];
    
    [self addSubview: breakpointButton];
    
    self->_breakpointCheckBox = breakpointButton;
}

- (id)initWithFrame: (NSRect)frame
{
    if ((self = [super initWithFrame: frame]))
    {
        VDEToolBarItemViewInitialize(self);
    }
    
    return self;
}

- (id)initWithCoder: (NSCoder *)aDecoder
{
    if ((self = [super initWithCoder: aDecoder]))
    {
        VDEToolBarItemViewInitialize(self);
    }
    
    return self;
}

- (void)dealloc
{
    [_runButton release];
    [_stopButton release];
    
    [super dealloc];
}

@synthesize delegate = _delegate;

#pragma mark - button actions

- (void)_handleRunButtonTapedEvent: (id)sender
{
    [_delegate toolbarItemView: self
                     sendEvent: VDEToolbarEventRunButtonPressed
                      userInfo: nil];
}

- (void)_handleStopButtonTapedEvent: (id)sender
{
    [_delegate toolbarItemView: self
                     sendEvent: VDEToolbarEventStopButtonPressed
                      userInfo: nil];
}

- (void)_handleToggleBreakpointButtonPressedEvent: (id)sender
{
    VDEPushButton *button = sender;
    
    [_delegate toolbarItemView: self
                     sendEvent: VDEToolbarEventToggleBreakPoint
                      userInfo: @([button isSelected])
     ];
}

@end

NSString * const VDEToolbarEventRunButtonPressed = @"toolbar.event.run";

NSString * const VDEToolbarEventStopButtonPressed = @"toolbar.event.stop";

NSString * const VDEToolbarEventToggleBreakPoint = @"toolbar.event.toggleBreakpoint";

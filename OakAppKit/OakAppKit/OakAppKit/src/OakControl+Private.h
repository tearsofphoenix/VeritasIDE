#import "OakControl.h"
//
//

enum 
{
    no_requisite         = (      0),
    mouse_inside         = (1 <<  1),
    mouse_down           = (1 <<  2),
    menu_gesture         = (1 <<  3),
    mouse_dragged        = (1 <<  4),
    mouse_clicked        = (1 <<  5),
    mouse_double_clicked = (1 <<  6),
    control              = (1 <<  7),
    option               = (1 <<  8),
    shift                = (1 <<  9),
    command              = (1 << 10),
    window_key           = (1 << 11),
    window_main          = (1 << 12),
    window_main_or_key   = (1 << 13),
    app_active           = (1 << 14),
    last_requisite       = (1 << 15),
};

typedef NSInteger requisite_t;

enum
{
    OakTextOptionNone,
    OakTextOptionShadow
};

typedef NSInteger text_options_t;


enum
{
    OakImageOptionNoRepeat,
    OakImageOptionStretch,
    /* repeat_x, repeat_y, repeat_xy */
};

typedef NSInteger image_options_t;

/*
 // TODO these are unsupported and unrequired, but can be added if needed.
 enum alignment_t { left, center, right };
 uint32_t alignment;
 enum vertical_alignment_t { top, middle, bottom };
 uint32_t vertical_alignment;
 */

@interface OakLayer * : NSObject

@property (nonatomic) NSRect rect;

@property (nonatomic) requisite_t requisite;
@property (nonatomic) requisite_t requisite_mask;
@property (nonatomic) NSInteger tag;
@property (nonatomic) SEL action;
@property (nonatomic) SEL menuAction;

@property (nonatomic, retain) NSColor * color;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSImage * image;
@property (nonatomic, retain) NSString * tool_tip;
@property (nonatomic, retain) NSView * view;

@property (nonatomic) text_options_t text_options;
@property (nonatomic) image_options_t image_options;
@property (nonatomic) NSPoint content_offset;
@property (nonatomic) BOOL prevent_window_ordering;


@end


@interface OakControl ()

@property (nonatomic, assign) NSInteger tag; // tag of the most recent layer causing an action

@property (nonatomic, assign) BOOL mouseTrackingDisabled;

- (uint32_t)currentState;

- (NSInteger)tagForLayerContainingPoint:(NSPoint)aPoint;

- (void)drawLayer:(OakLayer * *)aLayer;

- (NSArray *)layers;

- (void)setLayers: (NSArray *)aLayout;

- (void)sendAction: (SEL)action
         fromLayer: (OakLayer * *)aLayer;

@end

extern double WidthOfText (NSString* string);

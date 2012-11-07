#import "OakControl.h"



enum
{
    OakLayerNoRequisite         = (      0),
    OakLayerMouseInside         = (1 <<  1),
    OakLayerMouseDown           = (1 <<  2),
    OakLayerMenuGesture         = (1 <<  3),
    OakLayerMouseDragged        = (1 <<  4),
    OakLayerMouseClicked        = (1 <<  5),
    OakLayerMouseDoubleClicked = (1 <<  6),
    OakLayerControl              = (1 <<  7),
    OakLayerOption               = (1 <<  8),
    OakLayerShift                = (1 <<  9),
    OakLayerCommand              = (1 << 10),
    OakLayerWindowKey           = (1 << 11),
    OakLayerWindowMain          = (1 << 12),
    OakLayerWindowMainOrKey   = (1 << 13),
    OakLayerAppActive           = (1 << 14),
    OakLayerLastRequisite       = (1 << 15),
};

typedef NSInteger OakLayerRequisite;

enum
{
    OakLayerTextNone,
    OakLayerTextShadow
};

typedef NSInteger OakLayerTextOption;

enum
{
    OakLayerImageNoRepeat,
    OakLayerImageStretch, /* repeat_x, repeat_y, repeat_xy */
};

typedef NSInteger OakLayerImageOption;

@interface OakLayer : NSObject
{
	/*
     // TODO these are unsupported and unrequired, but can be added if needed.
     enum alignment_t { left, center, right };
     uint32_t alignment;
     enum vertical_alignment_t { top, middle, bottom };
     uint32_t vertical_alignment;
     */

	// ===========================================================================================================
	// = Probably makes sense to use boost::any_t or a base class with different subclasses for different things =
	// ===========================================================================================================
}

@property (nonatomic) NSRect rect;

@property (nonatomic) OakLayerRequisite requisite;
@property (nonatomic) OakLayerRequisite requisiteMask;
@property (nonatomic) NSInteger tag;
@property (nonatomic) SEL action;
@property (nonatomic) SEL menuAction;


@property (nonatomic, retain) NSColor * color;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSImage *  image;
@property (nonatomic, retain) NSString *  toolTip;
@property (nonatomic, retain) NSView * view;

@property (nonatomic) OakLayerTextOption textOptions;
@property (nonatomic) OakLayerTextOption imageOptions;
@property (nonatomic) NSPoint contentOffset;
@property (nonatomic) BOOL preventWindowOrdering;



@end

@interface OakControl ()

@property (nonatomic, assign) NSInteger tag; // tag of the most recent layer causing an action

@property (nonatomic, assign) BOOL mouseTrackingDisabled;

- (uint32_t)currentState;

- (NSInteger)tagForLayerContainingPoint:(NSPoint)aPoint;

- (void)drawLayer: (OakLayer *)aLayer;

@property (nonatomic, copy) NSArray *layers;

- (void)sendAction: (SEL)action
         fromLayer: (OakLayer *)aLayer;

@end

double WidthOfText (NSString* string);

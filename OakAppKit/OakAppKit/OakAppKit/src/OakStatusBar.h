#import "OakControl.h"



@class OakStatusBar;

const CGFloat OakStatusBarHeight = 16;

enum
{
    OakStatusBarInfo,
    OakStatusBarPopup,
    OakStatusBarDropdown,
    OakStatusBarButton
};

typedef NSInteger OakStatusBarType;


enum
{
    OakStatusBarBorderTop = 1,
    OakStatusBarBorderBottom = 2
};

typedef NSInteger OakStatusBarBorderType;


@interface OakStatusBarCell : NSObject

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSImage *disabledImage;
@property (nonatomic, retain) NSImage *pressedImage;
@property (nonatomic, retain) NSString *toolTip;
@property (nonatomic, retain) NSString *text;

@property (nonatomic, retain) NSView *view;

@property (nonatomic) NSInteger tag;

@property (nonatomic) SEL menuAction;

@property (nonatomic, assign) id target;

@property (nonatomic) SEL action;

@property (nonatomic) CGFloat minSize;

@property (nonatomic) CGFloat maxSize;

@property (nonatomic) CGFloat padding;

@property (nonatomic) OakStatusBarType type;

@property (nonatomic) BOOL skipTrailingSeparator;
@property (nonatomic) NSCellStateValue state;
@property (nonatomic) BOOL allowsHold;

+ (id)cellWithType: (OakStatusBarType)type
            target: (id)target
            action: (SEL)action;

- (void)noPadding;

- (void)noSeparator;

@end


@interface OakStatusBar : OakControl
{
	NSMutableArray *_cells;
	NSInteger _borderEdges;
}
@property (nonatomic, readonly) CGFloat minimumWidth;
@property (nonatomic, assign) NSInteger borderEdges;

- (void)setCells: (NSArray *)newCells;

- (void)showMenu: (NSMenu*)menu
withSelectedIndex: (NSUInteger)index
  forCellWithTag: (NSInteger)cellTag
            font: (NSFont*)font
           popup: (BOOL)isPopup;
@end

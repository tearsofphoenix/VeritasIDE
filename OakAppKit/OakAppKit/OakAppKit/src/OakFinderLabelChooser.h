

@interface OakFinderLabelChooser : NSView
{
	NSInteger highlightedIndex;
	NSMutableArray* labelNames;
}

@property (nonatomic) BOOL enabled;

@property (nonatomic, assign) id target;

@property (nonatomic) SEL action;

@property (nonatomic) NSInteger selectedIndex;

@end

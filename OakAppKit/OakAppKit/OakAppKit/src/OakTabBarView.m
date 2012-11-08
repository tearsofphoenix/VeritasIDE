#import "OakTabBarView.h"
#import "OakControl Private.h"
#import "NSColor+Additions.h"
#import "NSImage+Additions.h"
#import <OakFoundation/OakFoundation.h>

NSString* const kUserDefaultsDisableTabBarCollapsingKey = @"disableTabBarCollapsing";
NSString* const OakTabBarViewTabType                    = @"OakTabBarViewTabType";

@interface OakTabBarRecord : NSObject

@property (nonatomic) double start;
@property (nonatomic) double duration;
@property (nonatomic) double source;
@property (nonatomic) double target;

@end

@implementation OakTabBarRecord

@end

static id OakTabBarRecordMake(double s, double d, double source, double t)
{
    OakTabBarRecord *record = [[OakTabBarRecord alloc] init];
    [record setStart: s];
    [record setDuration: d];
    [record setSource: source];
    [record setTarget: t];
    
    return [record autorelease];
}

@interface OakTabBarValue : NSObject
{
    NSMutableArray *_records;
}

@end

@implementation OakTabBarValue

- (id)initWithTime: (double)t
{
    if ((self = [super init]))
    {
        _records = [[NSMutableArray alloc] init];
        [_records addObject: OakTabBarRecordMake(0, 0, t, t)];
    }
        
    return self;
}

- (void)dealloc
{
    [_records release];
    
    [super dealloc];
}

- (double)current: (double)t
{
    double target = [(OakTabBarRecord *)[_records lastObject] target];
	for(OakTabBarRecord *it in _records)
    {
		target = [it source] + (target - [it source]) * OakSlowInOut((t - [it start]) / [it duration]);
    }
	return round(target);

}

- (double)setTime: (double)t
{
    while([_records count] > 1 && [(OakTabBarRecord *)[_records objectAtIndex: 0] start] + [[_records objectAtIndex: 0] duration] < t)
    {
        [_records removeObjectAtIndex: 0];
    }
    
	return [self current: t];

}

- (void)setNewTarget: (double)target
                 now: (double)now
            duration: (double)duration
{
    double lastTarget = [(OakTabBarRecord *)[_records lastObject] target];
    
	if(lastTarget != target)
    {
		[_records addObject: OakTabBarRecordMake(now, duration, lastTarget, target)];
    }
}

@end


enum
{
	OakTabBarRequisiteModified = OakLayerLastRequisite << 0,
    OakTabBarRequisiteFirst    = OakLayerLastRequisite << 1,
    OakTabBarRequisiteDragged  = OakLayerLastRequisite << 2,
    
	OakTabBarRequisiteAll      = (OakTabBarRequisiteModified
                                  | OakTabBarRequisiteFirst
                                  | OakTabBarRequisiteDragged)
    
};

typedef NSInteger OakTabBarRequisite;

// ==================
// = Layout Metrics =
// ==================

@interface OakRawLayer : NSObject
{
    NSMutableArray *_padding;
}
@property (nonatomic, retain) OakLayer *layer;

@property (nonatomic) BOOL hasLabel;

@property (nonatomic) BOOL hasToolTip;

//@property (nonatomic, retain) NSArray *padding;

- (void)setPadding: (NSArray *)padding;

- (NSMutableArray *)padding;

@end

@implementation OakRawLayer

- (id)init
{
    if ((self = [super init]))
    {
        _padding = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_padding release];
    [_layer release];
    [super dealloc];
}

- (NSMutableArray *)padding
{
    return _padding;
}

- (void)setPadding: (NSArray *)padding
{
    [_padding setArray: padding];
}

@end

@interface OakTabBarLayoutMetrics : NSObject
{
	NSMutableDictionary *_layers;
}

@property (nonatomic) double tabSpacing;
@property (nonatomic) double firstTabOffset;
@property (nonatomic) double minTabSize;
@property (nonatomic) double maxTabSize;

- (NSMutableDictionary *)layers;

+ (id)layoutMetricsFromDictionary: (NSDictionary *)dict;

- (NSArray *)layersForLayer: (NSString *) layer_id
                     inRect: (CGRect)rect
                        tag: (NSInteger)tag
                      label: (NSString *) label
                    toolTip: (NSString *) toolTip
                     filter: (OakLayerRequisite) requisiteFilter;

@end


static id ExpandVariables (id obj, NSDictionary *someVariables);
static void AddItemsForKeyToArray (NSDictionary* dict, NSString* key, NSDictionary *values, NSMutableArray* array);

static OakRawLayer * parse_layer (NSDictionary* item);
static uint32_t parse_requisite (char const* str);
static NSInteger requisite_from_string (char const* str);

// ===========================================
// = Parsing and querying the layout metrics =
// ===========================================

@implementation OakTabBarLayoutMetrics

- (id)init
{
    if ((self = [super init]))
    {
        _layers = [[NSMutableDictionary alloc] init];
    }
    
    return  self;
}

- (void)dealloc
{
    [_layers release];
    
    [super dealloc];
}

- (NSMutableDictionary *)layers
{
    return _layers;
}

+ (id)layoutMetricsFromDictionary: (NSDictionary *)dict
{
	OakTabBarLayoutMetrics *r = [[OakTabBarLayoutMetrics alloc] init];
    
	r.tabSpacing     = [[dict objectForKey:@"tabSpacing"] floatValue];
	r.firstTabOffset = [[dict objectForKey:@"firstTabOffset"] floatValue];
	r.minTabSize     = [[dict objectForKey:@"minTabSize"] floatValue];
	r.maxTabSize     = [[dict objectForKey:@"maxTabSize"] floatValue] ?: DBL_MAX;
    
	NSMutableDictionary *variables = [NSMutableDictionary dictionary];
    
    [dict enumerateKeysAndObjectsUsingBlock: (^(NSString *key, id obj, BOOL *stop)
                                              {
                                                  if([obj isKindOfClass: [NSString class]])
                                                  {
                                                      [variables setObject: obj
                                                                    forKey: key];
                                                  }
                                              })];
    
    [dict enumerateKeysAndObjectsUsingBlock: (^(id key, id obj, BOOL *stop)
                                              {
                                                  if([obj isKindOfClass:[NSArray class]])
                                                  {
                                                      NSMutableArray* array = [NSMutableArray array];
                                                      
                                                      AddItemsForKeyToArray(dict, key, variables, array);
                                                      for(NSDictionary* item in array)
                                                      {
                                                          NSMutableArray *layers = [r.layers objectForKey: key];
                                                          if (!layers)
                                                          {
                                                              layers = [[NSMutableArray alloc] init];
                                                              [r.layers setObject: layers
                                                                           forKey: key];
                                                              [layers release];
                                                          }
                                                          
                                                          [layers addObject: parse_layer(item)];
                                                      }
                                                  }
                                              })];
    
	return [r autorelease];
}

- (NSArray *)layersForLayer: (NSString *) layer_id
                     inRect: (CGRect)rect
                        tag: (NSInteger)tag
                      label: (NSString *) label
                    toolTip: (NSString *) toolTip
                     filter: (OakLayerRequisite) requisiteFilter
{
	NSMutableArray *res = [NSMutableArray array];

	id l = [_layers objectForKey: layer_id];
	if(!l)
    {
		return res;
    }

	for(OakRawLayer *it in l)
	{
		if(([[it layer] requisiteMask] & OakTabBarRequisiteAll) != OakLayerNoRequisite) // layer is testing on OTBV requisite flags
		{
			if(([[it layer] requisite] & OakTabBarRequisiteAll) != (requisiteFilter & [[it layer] requisiteMask]))
				continue;
		}

		if([[it padding] count] != 4)
        {
			continue;
        }
        
		CGFloat values[4] = { };
		for(NSUInteger i = 0; i < sizeof(values) / sizeof(values[0]); ++i)
		{
			NSString * str = [[it padding] objectAtIndex: i];
            
            const char *cString = [str UTF8String];
            
			switch([str length] == 0 ? '\0' : cString[0])
			{
				case 'W': values[i] = CGRectGetWidth(rect)  + [[str substringFromIndex: 1] doubleValue]; break;
				case 'H': values[i] = CGRectGetHeight(rect) + [[str substringFromIndex: 1] doubleValue]; break;
				default:  values[i] = [str doubleValue];               break;
			}
		}

		[res addObject: [it layer]];
        
        OakLayer *lastLayer =  [res lastObject];
		lastLayer.requisite  &= ~OakTabBarRequisiteAll;
		lastLayer.requisiteMask &= ~OakTabBarRequisiteAll;

		if([it hasLabel])
        {
			[lastLayer setText: label];
        }
		if([it hasToolTip])
        {
            [lastLayer setToolTip: toolTip];
        }
        
        [lastLayer setTag: tag];
        [lastLayer setRect: CGRectMake(CGRectGetMinX(rect) + values[0], CGRectGetMinY(rect) + values[2], values[1]-values[0] + 1, values[3]-values[2] + 1)];
	}
	return res;
}

@end


id ExpandVariables (id obj, NSDictionary *someVariables)
{
	if([obj isKindOfClass:[NSArray class]])
	{
		NSMutableArray* array = [NSMutableArray array];
		for(id item in obj)
			[array addObject:ExpandVariables(item, someVariables)];
		obj = array;
	}
	else if([obj isKindOfClass:[NSDictionary class]])
	{
		NSMutableDictionary* dict = [NSMutableDictionary dictionary];
		for(NSString* key in obj)
			[dict setObject:ExpandVariables(obj[key], someVariables) forKey:key];
		obj = dict;
	}
	else if([obj isKindOfClass: [NSString class]])
	{
        ///TODO
        //
		obj =  @"";//[NSString stringWithCxxString: format_string::expand([obj UTF8String], someVariables)];
	}
	return obj;
}

void AddItemsForKeyToArray (NSDictionary* dict, NSString* key, NSDictionary *values, NSMutableArray* array)
{
	for(NSDictionary* item in [dict objectForKey:key])
	{
        NSString* includeKey = [item objectForKey:@"include"];
		if(includeKey)
		{
			NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary: values];
            
			NSDictionary* values = [item objectForKey:@"values"];
			for(NSString* key in values)
            {
                ///TODO
                //
				[tmp setObject: @""
                        forKey: key];
                //format_string::expand([values[key] UTF8String], tmp);
            }
            
			AddItemsForKeyToArray(dict, includeKey, tmp, array);
		}
		else
		{
			[array addObject: ExpandVariables(item, values)];
		}
	}
}

NSInteger requisite_from_string (char const* str)
{
	static struct { const char * name; NSInteger value; } mapping[] =
	{
		{ "no_requisite",         OakLayerNoRequisite       },
		{ "mouse_inside",         OakLayerMouseInside       },
		{ "mouse_down",           OakLayerMouseDown         },
		{ "mouse_dragged",        OakLayerMouseDragged      },
		{ "mouse_clicked",        OakLayerMouseClicked      },
		{ "mouse_double_clicked", OakLayerMouseDoubleClicked      },
		{ "control",              OakLayerControl            },
		{ "option",               OakLayerOption             },
		{ "shift",                OakLayerShift              },
		{ "command",              OakLayerCommand            },
		{ "window_key",           OakLayerWindowKey         },
		{ "window_main",          OakLayerWindowMain        },
		{ "window_main_or_key",   OakLayerWindowMainOrKey },

		{ "modified",            OakTabBarRequisiteModified},
		{ "first",               OakTabBarRequisiteFirst   },
		{ "dragged",             OakTabBarRequisiteDragged },
	};

	for(NSUInteger i = 0; i < sizeof(mapping) / sizeof(mapping[0]); ++i)
	{
		if(strcmp(mapping[i].name, str) == 0)
        {
			return mapping[i].value;
        }
	}
        
	return OakLayerNoRequisite;
}

uint32_t parse_requisite (char const* str)
{
	uint32_t res = 0;

	char* mutableStr = strdup(str);
	char* arr[] = { mutableStr };
	char* req;
	while((req = strsep(arr, "|")) && *req)
		res |= requisite_from_string(req);
	free(mutableStr);
	return res;
}

OakRawLayer * parse_layer (NSDictionary* item)
{
	OakRawLayer * res = [[OakRawLayer alloc] init];

    NSString* color = [item objectForKey: @"color"];
	if(color)
    {
		res.layer.color = [NSColor colorWithString: color];
    }
    
    NSString* requisite = [item objectForKey: @"requisite"];
	if(requisite)
    {
		res.layer.requisite = parse_requisite([requisite UTF8String]);
    }
	
    res.layer.requisiteMask = res.layer.requisite;
	
    NSString* requisiteMask = [item objectForKey:@"requisiteMask"];
    if(requisiteMask)
    {
		res.layer.requisiteMask = parse_requisite([requisiteMask UTF8String]);
    }
    
    NSString* action = [item objectForKey:@"action"];
	if(action)
    {
		res.layer.action = NSSelectorFromString(action);
    }
	if([[item objectForKey:@"preventWindowOrdering"] boolValue])
    {
		res.layer.preventWindowOrdering = YES;
    }
	
    NSDictionary* textOptions = [item objectForKey:@"text"];
    if(textOptions) // TODO we probably want to read some text options…
	{
		res.hasLabel = YES;
		if([[textOptions objectForKey:@"shadow"] boolValue])
        {
			res.layer.textOptions = res.layer.textOptions | OakLayerTextShadow;
        }
	}
    
	if([[item objectForKey:@"toolTip"] boolValue])
    {
		res.hasToolTip = YES;
    }
    
    NSString* imageName = [item objectForKey:@"image"];
	if(imageName) // TODO we probably want to read some image options…
    {
		res.layer.image = [NSImage imageNamed: imageName
                          inSameBundleAsClass: [OakTabBarView class]];
    }

	for(NSString* pos in [item objectForKey:@"rect"])
    {
		[[res padding] addObject: pos];
    }

	return res;
}

// ===========================================

static id SafeObjectAtIndex (NSArray* array, NSUInteger index)
{
	return (index < [array count] && [array objectAtIndex:index] != [NSNull null]) ? [array objectAtIndex:index] : nil;
}


@interface OakTabBarView ()

- (void)updateLayout;

@property (nonatomic, retain) OakTimer* slideAroundAnimationTimer;

@property (nonatomic) BOOL layoutNeedsUpdate;

@property (nonatomic) BOOL shouldCollapse;

@end

@implementation OakTabBarView
{
	NSMutableArray* tabTitles;
	NSMutableArray* tabToolTips;
	NSMutableArray* tabModifiedStates;

	BOOL layoutNeedsUpdate;
	NSUInteger selectedTab;
	NSUInteger hiddenTab;

	OakTabBarLayoutMetrics *metrics;
	NSMutableArray *tabRects;
	NSMutableDictionary *tabDropSpacing;
	OakTimer* slideAroundAnimationTimer;

	id <OakTabBarViewDelegate> delegate;
	id <OakTabBarViewDataSource> dataSource;
}

@synthesize delegate, dataSource, slideAroundAnimationTimer, layoutNeedsUpdate;

- (BOOL)performKeyEquivalent: (NSEvent*)anEvent
{
	// this should be in the window controller, but there we need subclassing mojo to get key events
	NSString * keyStr = OakStringFromEventAndFlag(anEvent, NO);
	if([keyStr isEqualToString: @"~@\uF702"]) // ⌥⌘⇠
    {
		return [NSApp sendAction: @selector(selectPreviousTab:)
                              to: nil
                            from: self];
    }
	else if([keyStr isEqualToString: @"~@\uF703"]) // ⌥⌘⇢
    {
		return [NSApp sendAction: @selector(selectNextTab:)
                              to: nil
                            from: self];
    }
    
	return NO;
}

- (id)initWithFrame:(NSRect)aRect
{
	if(self = [super initWithFrame:aRect])
	{
        tabRects = [[NSMutableArray alloc] init];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle bundleForClass:[self class]] pathForResource: @"TabBar"
                                                                                                                          ofType: @"plist"]];
		metrics           = [OakTabBarLayoutMetrics layoutMetricsFromDictionary: dict];
		hiddenTab         = NSNotFound;
		tabTitles         = [NSMutableArray new];
		tabToolTips       = [NSMutableArray new];
		tabModifiedStates = [NSMutableArray new];

		[self userDefaultsDidChange:nil];

		[[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(viewFrameChanged:)
                                                     name: NSViewFrameDidChangeNotification
                                                   object: self];
        
		[[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(userDefaultsDidChange:)
                                                     name: NSUserDefaultsDidChangeNotification
                                                   object: [NSUserDefaults standardUserDefaults]];
        
		[self registerForDraggedTypes: @[ OakTabBarViewTabType ]];
        
	}
	return self;
}

- (void)dealloc
{
	self.slideAroundAnimationTimer = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[tabTitles release];
	[tabToolTips release];
	[tabModifiedStates release];
	[super dealloc];
}

- (void)userDefaultsDidChange:(NSNotification*)aNotification
{
	self.shouldCollapse = ![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDisableTabBarCollapsingKey];
	self.expanded       = self.shouldCollapse ? [tabTitles count] > 1 : YES;
}

- (void)viewDidMoveToWindow
{
	self.layoutNeedsUpdate = YES;
	[super viewDidMoveToWindow];
}

- (NSString *)layerNameForTabIndex:(NSUInteger)tabIndex
{
	NSMutableString * str = [NSMutableString stringWithString: @"tab"];

	if(tabIndex == selectedTab)
    {
		[str appendString: @"Selected"];
    }
    
	return str;
}

- (uint32_t)filterForTabIndex:(NSUInteger)tabIndex
{
	uint32_t filter = 0;
	if([SafeObjectAtIndex(tabModifiedStates, tabIndex) boolValue])
    {
		filter |= OakTabBarRequisiteModified;
    }
	if(tabIndex == 0)
    {
		filter |= OakTabBarRequisiteFirst;
    }
	return filter;
}

- (double)putDefaultTabWidthsInto:(NSMutableArray *)tabSizes
{
	double totalWidth = 0;
	for(NSUInteger tabIndex = 0; tabIndex < tabTitles.count; ++tabIndex)
	{
		double width = WidthOfText(SafeObjectAtIndex(tabTitles, tabIndex));
        
		for(OakLayer *it in [metrics layersForLayer: [self layerNameForTabIndex:tabIndex]
                                             inRect: CGRectZero
                                                tag: tabIndex
                                              label: @"LabelPlaceholder"
                                            toolTip: nil
                                             filter: OakLayerNoRequisite])
		{
			if([it text])
            {
				width -= [it rect].size.width - 1;
            }
		}
        
		width = OakCap([metrics minTabSize], width, [metrics maxTabSize]);
		
        [tabSizes addObject: @(width)];
        
		totalWidth += width;
	}
	return totalWidth;
}

- (NSUInteger)countOfVisibleTabs
{
	NSRect rect = NSInsetRect([self bounds], [metrics firstTabOffset], 0);
	NSUInteger maxNumberOfTabs = floor((NSWidth(rect) + [metrics tabSpacing]) / ([metrics minTabSize] + [metrics tabSpacing]));
	return MAX(maxNumberOfTabs, 8);
}

- (void)updateLayout
{
	NSRect rect = [self bounds];
	[tabRects removeAllObjects];

	if(!self.isExpanded)
    {
		return [self setLayers: [metrics layersForLayer: @"backgroundCollapsed"
                                                 inRect: rect
                                                    tag: -1
                                                  label: nil
                                                toolTip: nil
                                                 filter: OakLayerNoRequisite]];
    }

	NSMutableArray *selectedTabLayers = [NSMutableArray array];
    
	NSMutableArray *newLayout = [NSMutableArray arrayWithArray: [metrics layersForLayer: @"background"
                                                                                 inRect: rect
                                                                                    tag: -1
                                                                                  label: nil
                                                                                toolTip: nil
                                                                                 filter: OakLayerNoRequisite]];

	// ==========

	NSMutableArray *tabSizes = [NSMutableArray array];
    
	double totalWidth = [self putDefaultTabWidthsInto: tabSizes];

	rect.origin.x   += 1 * [metrics firstTabOffset];
	rect.size.width -= 2 * [metrics firstTabOffset];

	NSUInteger numberOfTabs = [tabSizes count];
    
	if(NSWidth(rect) < totalWidth + ([tabSizes count] - 1) * [metrics tabSpacing])
	{
		NSUInteger maxNumberOfTabs = floor((NSWidth(rect) + [metrics tabSpacing]) / ([metrics minTabSize] + [metrics tabSpacing]));
		if(numberOfTabs > maxNumberOfTabs)
		{
			numberOfTabs = maxNumberOfTabs ?: 1;
			[tabSizes resizeToCount: numberOfTabs];
			totalWidth = 0;
			for(NSNumber *it in tabSizes)
            {
				totalWidth += [it doubleValue];
            }
		}

		double fat  = totalWidth - (numberOfTabs * [metrics minTabSize]);
		double cut  = totalWidth - (NSWidth(rect) - ((numberOfTabs-1) * [metrics tabSpacing]));
		double keep = fat - cut;

		double aggregatedFat = 0;
		for(NSUInteger i = 0; i < numberOfTabs; ++i)
		{
			double from    = floor(aggregatedFat * keep/fat);
			
            aggregatedFat += [[tabSizes objectAtIndex: i] doubleValue] - [metrics minTabSize];
			
            double to      = floor(aggregatedFat * keep/fat);

			[tabSizes insertObject: @([metrics minTabSize] + to - from)
                           atIndex: i];
		}
	}

	// ==========

	for(NSUInteger tabIndex = 0; tabIndex < numberOfTabs; ++tabIndex)
	{
        OakTabBarValue *value = [tabDropSpacing objectForKey: @(tabIndex)];
		rect.origin.x += value ? [value setTime: CFAbsoluteTimeGetCurrent()] : 0;
        
		if(tabIndex == hiddenTab)
		{
			[tabRects addObject: [NSValue valueWithRect: NSZeroRect]];
			continue;
		}

		rect.size.width = [[tabSizes objectAtIndex: tabIndex]  doubleValue];

		NSString * layer_id  = [self layerNameForTabIndex:tabIndex];
		NSString* toolTipText = SafeObjectAtIndex(tabToolTips, tabIndex);
		NSString* title       = SafeObjectAtIndex(tabTitles, tabIndex);

		NSArray *layers = [metrics layersForLayer: layer_id
                                           inRect: rect
                                              tag: tabIndex
                                            label: title
                                          toolTip: toolTipText
                                           filter: [self filterForTabIndex:tabIndex]];
        
		if(tabIndex == selectedTab)
        {
            [selectedTabLayers addObjectsFromArray: layers];
            
        }else
        {
            [newLayout addObjectsFromArray: layers];
        }

		[tabRects addObject: [NSValue valueWithRect: rect]];
		rect.origin.x += rect.size.width + [metrics tabSpacing];
	}
	
    [newLayout addObjectsFromArray: selectedTabLayers];

	[self setLayers: newLayout];
}

- (NSSize)intrinsicContentSize
{
	return NSMakeSize(NSViewNoInstrinsicMetric, self.isExpanded ? 23 : 1);
}

- (void)viewFrameChanged:(NSNotification*)aNotification
{
	self.layoutNeedsUpdate = YES;
}

- (void)setExpanded:(BOOL)flag
{
	if(_expanded == flag)
		return;

	_expanded = flag;
	self.layoutNeedsUpdate = YES;
	[self invalidateIntrinsicContentSize];
}

- (void)selectTab:(id)sender
{
	if(self.tag != selectedTab)
	{
		if(delegate && [delegate respondsToSelector:@selector(tabBarView:shouldSelectIndex:)] && ![delegate tabBarView:self shouldSelectIndex:self.tag])
			return;

		selectedTab = self.tag;
		self.layoutNeedsUpdate = YES;
	}
}

- (void)didDoubleClickTab:(id)sender
{
	if([delegate respondsToSelector:@selector(tabBarView:didDoubleClickIndex:)])
		[delegate tabBarView:self didDoubleClickIndex:selectedTab];
}

- (void)didDoubleClickTabBar:(id)sender
{
	if([delegate respondsToSelector:@selector(tabBarViewDidDoubleClick:)])
		[delegate tabBarViewDidDoubleClick:self];
}

- (void)performClose:(id)sender
{
	self.tag = selectedTab; // performCloseTab: asks for [sender tag]
    
	[NSApp sendAction: @selector(performCloseTab:)
                   to: nil
                 from: self];
}

- (NSMenu*)menuForEvent:(NSEvent*)anEvent
{
	NSPoint pos = [self convertPoint: [anEvent locationInWindow]
                            fromView: nil];
    
	self.tag = [self tagForLayerContainingPoint: pos];
    
	if(self.tag != NSNotFound && [delegate respondsToSelector: @selector(menuForTabBarView:)])
    {
		return [delegate menuForTabBarView: self];
    }
    
	return [super menuForEvent: anEvent];
}

- (void)setSelectedTab:(NSUInteger)anIndex
{
	if(selectedTab == anIndex)
		return;
	selectedTab = anIndex;
	self.layoutNeedsUpdate = YES;
}

- (void)reloadData
{
	if(!dataSource)
		return;

	NSMutableArray* titles         = [NSMutableArray array];
	NSMutableArray* toolTips       = [NSMutableArray array];
	NSMutableArray* modifiedStates = [NSMutableArray array];

	NSUInteger count = [dataSource numberOfRowsInTabBarView:self];
	for(NSUInteger i = 0; i < count; ++i)
	{
		[titles addObject:[dataSource tabBarView:self titleForIndex:i]];
		[toolTips addObject:[dataSource tabBarView:self toolTipForIndex:i]];
		[modifiedStates addObject:@([dataSource tabBarView:self isEditedAtIndex:i])];
	}

	[tabTitles setArray:titles];
	[tabToolTips setArray:toolTips];
	[tabModifiedStates setArray:modifiedStates];

	selectedTab = [tabToolTips count] && selectedTab != NSNotFound ? MIN(selectedTab, [tabToolTips count]-1) : NSNotFound;

	BOOL shouldBeExpanded = self.shouldCollapse ? [tabTitles count] > 1 : YES;
	if(shouldBeExpanded != self.isExpanded)
			self.expanded = shouldBeExpanded;
	else	self.layoutNeedsUpdate = YES;
}

// ============
// = Dragging =
// ============

- (void)drawRect:(NSRect)aRect
{
	if(layoutNeedsUpdate)
    {
		[self updateLayout];
    }
	
    self.layoutNeedsUpdate = NO;
    
	[super drawRect: aRect];
}

- (void)setLayoutNeedsUpdate:(BOOL)flag
{
	if(layoutNeedsUpdate != flag)
    {
        layoutNeedsUpdate = flag;
        
        if(layoutNeedsUpdate)
        {
            [self setNeedsDisplay: YES];
        }
    }
}

- (void)hideTabAtIndex:(NSUInteger)anIndex
{
	if(hiddenTab == anIndex)
		return;
	hiddenTab = anIndex;
	self.layoutNeedsUpdate = YES;
}

- (void)setDropAreaWidth:(CGFloat)aWidth beforeTabAtIndex:(NSUInteger)anIndex animate:(BOOL)flag
{
	double t = CFAbsoluteTimeGetCurrent();
	
    double duration = flag ? (([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) == NSShiftKeyMask ? 3 : 0.5) : 0;
    
	for(NSUInteger i = 0; i < [tabRects count]; ++i)
    {
        OakTabBarValue *value = [tabDropSpacing objectForKey: @(i)];
        
		[value setNewTarget: (i == anIndex ? aWidth + [metrics tabSpacing] : 0)
                        now: t
                   duration: duration];
    }
    
	self.slideAroundAnimationTimer = flag ? (self.slideAroundAnimationTimer ?: [OakTimer scheduledTimerWithTimeInterval: 0.02
                                                                                                                 target: self
                                                                                                               selector: @selector(updateSlideAroundAnimation:)
                                                                                                                repeats: YES]) : nil;
	
    if(aWidth == 0 && !flag)
    {
		[tabDropSpacing removeAllObjects];
    }
    
	self.layoutNeedsUpdate = YES;
}

- (void)updateSlideAroundAnimation:(NSTimer*)aTimer
{
	self.layoutNeedsUpdate = YES;
}

- (NSUInteger)dropIndexForMouse:(NSPoint)mousePos
{
	NSRect rect = [self bounds];
	rect.origin.x += [metrics firstTabOffset];
	NSUInteger tabIndex = 0;
    
	for(; tabIndex < [tabRects count]; ++tabIndex)
	{
		if(tabIndex == hiddenTab)
			continue;
		rect.size.width = NSWidth([[tabRects objectAtIndex: tabIndex] rectValue]);
		if(mousePos.x < NSMaxX(rect))
			break;
		rect.origin.x += rect.size.width + [metrics tabSpacing];
	}
	return tabIndex;
}

- (void)dragTab:(id)sender
{
	NSUInteger draggedTab = self.tag;
	NSRect tabRect = [[tabRects objectAtIndex: draggedTab] rectValue];

	NSImage* image = [[[NSImage alloc] initWithSize: tabRect.size] autorelease];
	[image lockFocus];

	uint32_t state = [self currentState] | OakLayerMouseInside | OakLayerMouseDown;
	for(OakLayer * it in [metrics layersForLayer: [self layerNameForTabIndex: draggedTab]
                                          inRect: (NSRect){NSZeroPoint, tabRect.size}
                                             tag: draggedTab
                                           label: [tabTitles objectAtIndex: draggedTab]
                                         toolTip: nil
                                          filter: [self filterForTabIndex: draggedTab] | OakTabBarRequisiteDragged])
	{
		if((state & [it requisiteMask]) == [it requisite])
        {
			[self drawLayer: it];
        }
	}
    
	[image unlockFocus];

	NSImage* dragImage = [[[NSImage alloc] initWithSize:image.size] autorelease];
	[dragImage lockFocus];
	[image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:0.8];
	[dragImage unlockFocus];

	NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[pboard declareTypes:@[ OakTabBarViewTabType ] owner:self];
	[pboard setString:[NSString stringWithFormat:@"%lu", draggedTab] forType:OakTabBarViewTabType];
	[delegate setupPasteboard:pboard forTabAtIndex:draggedTab];

	[self hideTabAtIndex:draggedTab];
	[self setDropAreaWidth:[dragImage size].width beforeTabAtIndex:draggedTab animate:NO];
	self.mouseTrackingDisabled = YES;

	[self dragImage:dragImage
                at:tabRect.origin
            offset:NSZeroSize
             event:[NSApp currentEvent]
        pasteboard:[NSPasteboard pasteboardWithName:NSDragPboard]
            source:self
         slideBack:YES];
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationMove|NSDragOperationCopy|NSDragOperationLink;
}

- (void)draggedImage:(NSImage*)image endedAt:(NSPoint)point operation:(NSDragOperation)operation
{
	[self hideTabAtIndex:NSNotFound];
	[self setDropAreaWidth:0 beforeTabAtIndex:NSNotFound animate:NO];
	self.mouseTrackingDisabled = NO;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	[self hideTabAtIndex:NSNotFound];
	[self setDropAreaWidth:0 beforeTabAtIndex:NSNotFound animate:NO];

	NSDragOperation mask = [sender draggingSourceOperationMask];
	NSPoint mousePos = [self convertPoint:[sender draggingLocation] fromView:nil];
	BOOL success = [delegate performTabDropFromTabBar:[sender draggingSource]
                                             atIndex:[self dropIndexForMouse:mousePos]
                                      fromPasteboard:[NSPasteboard pasteboardWithName:NSDragPboard]
                                           operation:(mask & NSDragOperationMove) ?: (mask & NSDragOperationCopy)];
	return success;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	NSDragOperation operation = [sender draggingSourceOperationMask];
	operation = (operation & NSDragOperationMove) ?: (operation & NSDragOperationCopy);
	if(operation == NSDragOperationNone)
		return operation;

	if([sender draggingSource] == self)
		[self hideTabAtIndex:operation == NSDragOperationCopy ? NSNotFound : [[[sender draggingPasteboard] stringForType:OakTabBarViewTabType] intValue]];

	NSPoint mousePos = [self convertPoint:[sender draggingLocation] fromView:nil];
	[self setDropAreaWidth:[[sender draggedImage] size].width beforeTabAtIndex:[self dropIndexForMouse:mousePos] animate:YES];

	return operation;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	[self setDropAreaWidth:0 beforeTabAtIndex:NSNotFound animate:YES];
}
@end


#import "OakScopeContext.h"
#import "BundleMenu.h"
#import "OakBundleItem.h"

@interface NSObject (HasSelection)

- (BOOL)hasSelection;

- (OakScopeContext *)scopeContext;

@end

@interface BundleMenuDelegate ()

@property (nonatomic, retain) NSMutableArray* subdelegates;

@end

@implementation BundleMenuDelegate
{
	OakBundleItem * umbrellaItem;
}

- (id)initWithBundleItem:(OakBundleItem *)aBundleItem
{
	if(self = [super init])
	{
		umbrellaItem = aBundleItem;
		self.subdelegates = [NSMutableArray new];
	}
	return self;
}

- (BOOL)menuHasKeyEquivalent:(NSMenu*)aMenu forEvent:(NSEvent*)theEvent target:(id*)aTarget action:(SEL*)anAction
{
	return NO;
}

- (void)menuNeedsUpdate:(NSMenu*)aMenu
{
	[aMenu removeAllItems];
	[_subdelegates removeAllObjects];

	BOOL hasSelection = NO;
	if(id textView = [NSApp targetForAction:@selector(hasSelection)])
		hasSelection = [textView hasSelection];

    OakScopeContext *scope = [[OakScopeContext alloc] initWithString: @""];

	if(id textView = [NSApp targetForAction: @selector(scopeContext)])
    {
		scope = [textView scopeContext];
    }
    
	for(OakBundleItem *item in [umbrellaItem menu])
	{
		switch([item kind])
		{
			case kItemTypeMenu:
			{
				NSMenuItem* menuItem = [aMenu addItemWithTitle: [item name]
                                                        action: NULL
                                                 keyEquivalent: @""];

				menuItem.submenu = [NSMenu new];
				BundleMenuDelegate* delegate = [[BundleMenuDelegate alloc] initWithBundleItem: item];
				menuItem.submenu.delegate = delegate;
				[self.subdelegates addObject:delegate];
                
                break;
			}

			case kItemTypeMenuItemSeparator:
            {
				[aMenu addItem:[NSMenuItem separatorItem]];
                
                break;
            }
			case kItemTypeProxy:
			{
				NSArray *items = bundles::items_for_proxy(item, scope);
				OakAddBundlesToMenu(items, hasSelection, true, aMenu, @selector(performBundleItemWithUUIDStringFrom:));

				if([items count] == 0)
				{
					NSMenuItem* menuItem = [aMenu addItemWithTitle: name_with_selection(item, hasSelection)
                                                            action: @selector(nop:)
                                                     keyEquivalent: @""];
                    
					[menuItem setKeyEquivalentCxxString: key_equivalent(item)];
                    
					[menuItem setTabTriggerCxxString: [item value_for_field: kFieldTabTrigger]];
				}
                
                break;

			}
                
			default:
			{
				NSMenuItem* menuItem = [aMenu addItemWithTitle:  name_with_selection(item, hasSelection)
                                                        action: @selector(performBundleItemWithUUIDStringFrom:)
                                                 keyEquivalent: @""];
                
				[menuItem setKeyEquivalentCxxString: key_equivalent(item)];
                
				[menuItem setTabTriggerCxxString: [item value_for_field:  kFieldTabTrigger]];
				[menuItem setRepresentedObject: [item uuid]];
			}
			break;
		}
	}
}
@end

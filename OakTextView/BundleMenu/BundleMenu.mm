#import "Private.h"
#import <OakFoundation/NSString+Additions.h>
#import <OakAppKit/NSMenuItem+Additions.h>
#import <text/OakTextCtype.h>
#import "OakBundleItem.h"
#import <ns/ns.h>


@interface BundlePopupMenuTarget : NSObject

@property (nonatomic, retain) NSString* selectedItemUUID;

@end

@implementation BundlePopupMenuTarget

- (BOOL)validateMenuItem:(NSMenuItem*)menuItem
{
	return [menuItem action] == @selector(takeItemUUIDFrom:);
}

- (void)takeItemUUIDFrom:(id)sender
{
	assert([sender isKindOfClass:[NSMenuItem class]]);
	self.selectedItemUUID = [(NSMenuItem*)sender representedObject];
}
@end

static NSArray *filtered_menu (OakBundleItem * menuItem, NSMutableSet* includedItems)
{
	NSMutableArray *res = [NSMutableArray array];
    
	for(id item in [menuItem menu])
	{
		if([item kind] == kItemTypeMenuItemSeparator)
		{
			[res addObject: item];
		}
		else if([item kind] == kItemTypeMenu)
		{
			[res addObject: [OakBundleItem menu_item_separator]];
            
			NSArray *tmp = filtered_menu(item, includedItems);
            
            [res addObjectsFromArray: tmp];
            
			[res addObject: [OakBundleItem menu_item_separator]];
		}
		else if([includedItems containsObject: item])
		{
			[res addObject: item];
			[includedItems removeObject: item];
		}
	}
    
	return res;
}

void OakAddBundlesToMenu (NSArray *items, BOOL hasSelection, BOOL setKeys, NSMenu* menu, SEL menuAction, id menuTarget)
{
	bool onlyGrammars = true;
	for(OakBundleItem *item in items)
    {
		onlyGrammars = onlyGrammars &&  [item kind] == kItemTypeGrammar;
    }
    
	if(onlyGrammars)
	{
		NSMutableDictionary *ordering = [NSMutableDictionary dictionary];
		for(OakBundleItem *item in items)
        {
			[ordering setObject: item
                         forKey: [item name]];
        }
        
        [ordering enumerateKeysAndObjectsUsingBlock: (^(NSString *key, OakBundleItem *obj, BOOL *stop)
                                                      {
                                                          
                                                          NSMenuItem* menuItem = [menu addItemWithTitle: key
                                                                                                 action: menuAction
                                                                                          keyEquivalent: @""];
                                                          [menuItem setTarget: menuTarget];
                                                          [menuItem setRepresentedObject: [obj uuid]];
                                                          
                                                          if(setKeys)
                                                          {
                                                              [menuItem setKeyEquivalentCxxString: key_equivalent(obj)];
                                                              [menuItem setTabTriggerCxxString: [obj value_for_field: kFieldTabTrigger]];
                                                          }
                                                      })];
	}
	else
	{
        
		NSMutableDictionary *byBundle = [NSMutableDictionary dictionary];
		for(OakBundleItem *item in items)
        {
            [byBundle setObject: [item bundle]
                         forKey: item];
        }
        
		std::multimap<NSString *, std::vector<OakBundleItem *>, text::less_t> menus;
		while(!byBundle.empty())
		{
			OakBundleItem * bundle = byBundle.begin()->first;
			std::set<OakBundleItem *> includedItems;
			foreach(pair, byBundle.lower_bound(bundle), byBundle.upper_bound(bundle))
            includedItems.insert(pair->second);
			byBundle.erase(bundle);
            
			std::vector<OakBundleItem *> menuItems = filtered_menu(bundle, &includedItems);
            
			std::multimap<NSString *, OakBundleItem *, text::less_t> ordering;
			iterate(item, includedItems)
            ordering.insert(std::make_pair(name_with_selection(*item, hasSelection), *item));
			std::transform(ordering.begin(), ordering.end(), back_inserter(menuItems), [](std::pair<NSString *, OakBundleItem *>  p){ return p.second; });
            
			menus.insert(std::make_pair(bundle->name(), menuItems));
		}
        
		bool showBundleHeadings = menus.size() > 1;
		iterate(pair, menus)
		{
			if(showBundleHeadings)
				[menu addItemWithTitle:[NSString stringWithCxxString:pair->first] action:NULL keyEquivalent:@""];
            
			bool suppressSeparator = true;
			bool pendingSeparator  = false;
			iterate(item, pair->second)
			{
				if((*item)->kind() == bundles::kItemTypeMenuItemSeparator)
				{
					if(!suppressSeparator)
						pendingSeparator = true;
				}
				else
				{
					if(pendingSeparator)
						[menu addItem:[NSMenuItem separatorItem]];
					pendingSeparator = false;
                    
					NSMenuItem* menuItem = [menu addItemWithTitle:[NSString stringWithCxxString:name_with_selection(*item, hasSelection)] action:menuAction keyEquivalent:@""];
					[menuItem setTarget:menuTarget];
					[menuItem setRepresentedObject:[NSString stringWithCxxString:(*item)->uuid()]];
                    
					if(setKeys)
					{
						[menuItem setKeyEquivalentCxxString: [NSString stringWithCxxString: key_equivalent(*item)]];
						[menuItem setTabTriggerCxxString: [NSString stringWithCxxString: (*item)->value_for_field(bundles::kFieldTabTrigger)]];
					}
                    
					if(showBundleHeadings)
						[menuItem setIndentationLevel:1];
                    
					suppressSeparator = false;
				}
			}
		}
	}
}

OakBundleItem * OakShowMenuForBundleItems (NSArray *items, CGPoint  pos, bool hasSelection)
{
	if(items.empty())
		return OakBundleItem *();
	else if(items.size() == 1)
		return items.front();
    
	BundlePopupMenuTarget* menuTarget = [BundlePopupMenuTarget new];
	NSMenu* menu = [NSMenu new];
	[menu setFont:[NSFont menuFontOfSize:[NSFont smallSystemFontSize]]];
	OakAddBundlesToMenu(items, hasSelection, false, menu, @selector(takeItemUUIDFrom:), menuTarget);
    
	int key = 1;
	for(NSMenuItem* menuItem in [menu itemArray])
	{
		if(menuItem.action)
		{
			[menuItem setKeyEquivalent: [NSString stringWithFormat:@"%d", key % 10]];
			[menuItem setKeyEquivalentModifierMask: 0];
			if(++key == 10)
				break;
		}
	}
    
	if([menu popUpMenuPositioningItem: nil
                           atLocation: NSPointFromCGPoint(pos)
                               inView: nil])
    {
		return bundles::lookup(to_s(menuTarget.selectedItemUUID));
    }
    
	return OakBundleItem *();
}

#ifndef BUNDLEMENU_H_BI4UDOAR
#define BUNDLEMENU_H_BI4UDOAR

@class OakBundleItem;

enum
{
    kItemTypeProxy,
    kItemTypeGrammar,
    kItemTypeMenu,
    kItemTypeMenuItemSeparator
};

typedef NSInteger OakBundleItemMenuType;

@interface BundleMenuDelegate : NSObject <NSMenuDelegate>

- (id)initWithBundleItem: (OakBundleItem *)aBundleItem;

@end

extern OakBundleItem * OakShowMenuForBundleItems (NSArray *items, CGPoint pos, BOOL hasSelection);

void OakAddBundlesToMenu (NSArray *items, BOOL hasSelection, BOOL setKeys, NSMenu* aMenu, SEL menuAction, id menuTarget = nil);

#endif /* end of include guard: BUNDLEMENU_H_BI4UDOAR */

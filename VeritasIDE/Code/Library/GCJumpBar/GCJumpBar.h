//
//  GCJumpBar.h
//  GCJumpBarDemo
//
//  Created by Guillaume Campagna on 11-05-24.
//  Copyright 2011 LittleKiwi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GCJumpBarDelegate;

@interface GCJumpBar : NSControl
{
    BOOL _delegateRespondsToDidSelectItemAtIndexPath;
    BOOL _delegateRespondsToDidSelectAccessoryMenuItemAtIndex;
}

@property (nonatomic, assign) IBOutlet id<GCJumpBarDelegate> delegate;

@property (nonatomic, retain) IBOutlet NSMenu* menu;
@property (nonatomic, retain) IBOutlet NSMenu* accessoryMenu;

@property (nonatomic, retain) NSIndexPath* selectedIndexPath;
@property (nonatomic) NSUInteger accessoryMenuSelectedIndex;

 //Change automatically the font in the menu to be the same as the Jump Bar and resize the image to 16x16
@property (nonatomic) BOOL changeFontAndImageInMenu;

@property (nonatomic, retain) NSMenuItem* selectedMenuItem;
@property (nonatomic, retain) NSMenuItem* selectedAccessoryMenuItem;

- (id) initWithFrame: (NSRect)frameRect
                menu: (NSMenu *)aMenu;

- (NSMenuItem *)menuItemAtIndexPath: (NSIndexPath *)indexPath;

- (void)changeFontAndImageInMenu: (NSMenu *)subMenu;

@end

@protocol GCJumpBarDelegate <NSObject>

@optional

- (void)jumpBar: (GCJumpBar *)jumpBar didSelectItemAtIndexPath: (NSIndexPath*)indexPath;
- (void)jumpBar: (GCJumpBar *)jumpBar didSelectAccessoryMenuItemAtIndex: (NSUInteger)index;

@end

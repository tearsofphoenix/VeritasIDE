//
//  DMTabBar.h
//  DMTabBar - XCode like Segmented Control
//
//  Created by Daniele Margutti on 6/18/12.
//  Copyright (c) 2012 Daniele Margutti (http://www.danielemargutti.com - daniele.margutti@gmail.com). All rights reserved.
//  Licensed under MIT License
//

#import <Cocoa/Cocoa.h>

@class DMTabBarItem;

@protocol DMTabBarDelegate, DMTabBarDataSource;

@interface DMTabBar : NSView

// change selected item by passing a new index { 0 < index < tabBarItems.count }
@property (nonatomic) NSUInteger         selectedIndex;

@property (nonatomic, assign) id<DMTabBarDelegate> delegate;

@property (nonatomic, assign) id<DMTabBarDataSource> dataSource;

- (DMTabBarItem *)selectedTabBarItem;

- (void)reloadData;

@end

@protocol DMTabBarDelegate <NSObject>

@optional

- (void)tabBar: (DMTabBar *)tabBar
willSelectItem: (DMTabBarItem *)item
       atIndex: (NSUInteger)idx;

- (void)tabBar: (DMTabBar *)tabBar
 didSelectItem: (DMTabBarItem *)item
       atIndex: (NSUInteger)idx;

@end

@protocol DMTabBarDataSource <NSObject>

@required

- (NSUInteger)numberOfItemInTabBar: (DMTabBar *)tabBar;

- (DMTabBarItem *)tabBar: (DMTabBar *)tabBar itemAtIndex: (NSUInteger)index;

@end


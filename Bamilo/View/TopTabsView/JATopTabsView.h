//
//  JATopTabsView.h
//  Jumia
//
//  Created by telmopinto on 15/03/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JATopTabsViewDelegate <NSObject>

- (void)selectedIndex:(NSInteger)index animated:(BOOL)animated;

@end

@interface JATopTabsView : UIView

@property (nonatomic, assign) NSInteger startingIndex;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, readonly) BOOL isLoaded;
@property (nonatomic, assign)id<JATopTabsViewDelegate>delegate;

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
- (void)setupWithTabNames:(NSArray*)tabNamesArray;
- (void)scrollLeft;
- (void)scrollRight;

@end

//
//  JAPickerScrollView.h
//  Jumia
//
//  Created by Telmo Pinto on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JAPickerScrollViewDelegate <NSObject>

@optional
- (void)selectedIndex:(NSInteger)index;

@end

@interface JAPickerScrollView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign)id<JAPickerScrollViewDelegate> delegate;
@property (nonatomic, assign) BOOL disableDelagation; // used in undefined search therm

- (void)setOptions:(NSArray*)options;

- (void)scrollLeft;
- (void)scrollRight;

@end
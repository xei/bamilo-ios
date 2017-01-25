//
//  JATabBarView.h
//  Jumia
//
//  Created by Telmo Pinto on 21/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTabBarHeight 53.0f

@interface JATabBarView : UIView

@property (nonatomic, strong) NSMutableArray* tabButtonsArray;

- (void)initialSetup;
- (void)selectButtonAtIndex:(NSInteger)index;

- (void)updateCartNumber:(NSInteger)cartNumber;

@end

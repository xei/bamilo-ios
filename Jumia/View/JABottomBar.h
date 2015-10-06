//
//  JABottomBar.h
//  Jumia
//
//  Created by josemota on 10/2/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JABottomBar : UIView

- (void)reloadFrame:(CGRect)frame;
- (void)addSmallButton:(UIImage *)image target:(id)target action:(SEL)action;
- (void)addButton:(NSString*)name target:(id)target action:(SEL)action;

@end

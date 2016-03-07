//
//  JABottomBar.h
//  Jumia
//
//  Created by josemota on 10/2/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBottomDefaultHeight 49

@interface JABottomBar : UIView

- (UIButton *)addSmallButton:(UIImage *)image target:(id)target action:(SEL)action;
- (UIButton *)addButton:(NSString*)name target:(id)target action:(SEL)action;

@end

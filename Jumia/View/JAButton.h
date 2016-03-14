//
//  JAButton.h
//  Jumia
//
//  Created by Jose Mota on 11/03/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAButton : UIButton

- (instancetype)initButtonWithTitle:(NSString *)title;
- (instancetype)initButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@end

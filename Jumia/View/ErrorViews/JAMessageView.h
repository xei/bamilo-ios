//
//  JAMessageView.h
//  Jumia
//
//  Created by Jose Mota on 15/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMessageViewHeight 44.f

@interface JAMessageView : UIView

- (void)setupView;

- (void)setTitle:(NSString *)title success:(BOOL)success;

@end

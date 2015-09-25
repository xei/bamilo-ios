//
//  JAProductInfoBaseLine.h
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAProductInfoBaseLine : UIView

@property (nonatomic) BOOL clickable;
@property (nonatomic, readonly) UILabel *label;

- (void)setTitle:(NSString *)title;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end

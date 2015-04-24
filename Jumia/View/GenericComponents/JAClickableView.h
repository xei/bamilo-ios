//
//  JAClickableView.h
//  Jumia
//
//  Created by Telmo Pinto on 13/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAClickableView : UIView

@property (nonatomic, assign)BOOL selected;
@property (nonatomic, assign)BOOL enabled;
@property (nonatomic, readonly)NSString* title;

- (void)setImage:(UIImage*)image forState:(UIControlState)state;
- (void)setImageWithURL:(NSURL*)url placeholderImage:(UIImage*)image;
- (void)setTitle:(NSString*)title forState:(UIControlState)state;
- (void)setTitleColor:(UIColor*)color forState:(UIControlState)state;
- (void)setFont:(UIFont*)font;
- (void)addTarget:(id)target
           action:(SEL)action
 forControlEvents:(UIControlEvents)controlEvents;

@end

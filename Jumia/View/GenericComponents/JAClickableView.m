//
//  JAClickableView.m
//  Jumia
//
//  Created by Telmo Pinto on 13/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAClickableView.h"
#import "JAUtils.h"
#import "UIButton+WebCache.h"

@interface JAClickableView()

@property (nonatomic, strong)UIButton* overlayButton;

//redefinition
@property (nonatomic, strong)NSString* title;

@end

@implementation JAClickableView

- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets
{
    self.overlayButton.imageEdgeInsets = imageEdgeInsets;
}
- (UIEdgeInsets)imageEdgeInsets
{
    return self.overlayButton.imageEdgeInsets;
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
{
    self.overlayButton.titleEdgeInsets = titleEdgeInsets;
}
- (UIEdgeInsets)titleEdgeInsets
{
    return self.overlayButton.titleEdgeInsets;
}

- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment
{
    self.overlayButton.contentHorizontalAlignment = contentHorizontalAlignment;
}
- (UIControlContentHorizontalAlignment)contentHorizontalAlignment
{
    return self.overlayButton.contentHorizontalAlignment;
}

- (void)setSelected:(BOOL)selected
{
    self.overlayButton.selected = selected;
}
- (BOOL)selected
{
    return self.overlayButton.selected;
}

- (void)setEnabled:(BOOL)enabled
{
    self.overlayButton.enabled = enabled;
}
- (BOOL)enabled
{
    return self.overlayButton.enabled;
}

- (void)setTag:(NSInteger)tag
{
    self.overlayButton.tag = tag;
}
- (NSInteger)tag
{
    return self.overlayButton.tag;
}

- (UIImageView*)imageView
{
    return self.overlayButton.imageView;
}

- (UILabel*)titleLabel
{
    return self.overlayButton.titleLabel;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        [self initializeOverlayButton];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        [self initializeOverlayButton];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        [self initializeOverlayButton];
        [self.overlayButton setFrame:self.bounds];
    }
    return self;
}

- (void)initializeOverlayButton
{
    self.overlayButton = [UIButton new];
    [self.overlayButton setFrame:self.bounds];
//    UIImage* backgroundImageNormal = [JAUtils imageWithColor:[UIColor colorWithWhite:0.0f alpha:1.0f]];
//    [self.overlayButton setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
    UIImage* backgroundImageSelected = [JAUtils imageWithColor:[UIColor colorWithWhite:0.0f alpha:0.06f]];
    [self.overlayButton setBackgroundImage:backgroundImageSelected forState:UIControlStateSelected];
    [self.overlayButton setBackgroundImage:backgroundImageSelected forState:UIControlStateHighlighted];
    self.overlayButton.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.overlayButton];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.overlayButton setFrame:self.bounds];
}

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
    [self bringSubviewToFront:self.overlayButton];
}

- (void)setImage:(UIImage*)image forState:(UIControlState)state;
{
    [self.overlayButton setImage:image forState:state];
}
- (void)setImageWithURL:(NSURL*)url placeholderImage:(UIImage*)image;
{
    [self.overlayButton setImageWithURL:url placeholderImage:image];
}
- (void)setTitle:(NSString*)title forState:(UIControlState)state;
{
    self.title = title;
    [self.overlayButton setTitle:title forState:state];
}
- (void)setTitleColor:(UIColor*)color forState:(UIControlState)state;
{
    [self.overlayButton setTitleColor:color forState:state];
}
- (void)setFont:(UIFont*)font;
{
    [self.overlayButton.titleLabel setFont:font];
}
- (void)addTarget:(id)target
           action:(SEL)action
forControlEvents:(UIControlEvents)controlEvents
{
    [self.overlayButton addTarget:target action:action forControlEvents:controlEvents];
}

- (UIImage*)imageForState:(UIControlState)controlState;
{
    return [self.overlayButton imageForState:controlState];
}

@end

//
//  JAClickableView.m
//  Jumia
//
//  Created by Telmo Pinto on 13/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAClickableView.h"
#import "JAUtils.h"

@interface JAClickableView()

@property (nonatomic, strong)UIButton* overlayButton;

@end

@implementation JAClickableView

- (void)setSelected:(BOOL)selected
{
    self.overlayButton.selected = selected;
}
- (BOOL)selected
{
    return self.overlayButton.selected;
}


- (void)setTag:(NSInteger)tag
{
    self.overlayButton.tag = tag;
}
- (NSInteger)tag
{
    return self.overlayButton.tag;
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

- (void)addTarget:(id)target
           action:(SEL)action
forControlEvents:(UIControlEvents)controlEvents
{
    [self.overlayButton addTarget:target action:action forControlEvents:controlEvents];
}

@end

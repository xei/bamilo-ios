//
//  JAButtonWithBlur.m
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAButtonWithBlur.h"
#import "FXBlurView.h"

@interface JAButtonWithBlur ()

@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation JAButtonWithBlur

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup
{
    self.buttons = [[NSMutableArray alloc] init];
    [self setTintColor:[UIColor clearColor]];
    [self setBlurEnabled:YES];
    [self setBlurRadius:3.5f];
    [self setDynamic:YES];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              320.0f,
                              60.0f)];
}

- (void) addButton:(NSString*)name target:(id)target action:(SEL)action
{
    CGFloat buttonWidth = 308.0f;
    CGFloat buttonSpace = 4.0f;
    if(VALID_NOTEMPTY(self.buttons, NSMutableArray))
    {
        if(2 == [self.buttons count])
        {
            return;
        }
        
        buttonWidth = ((buttonWidth - (buttonSpace * [self.buttons count])) / ([self.buttons count] + 1));
    }
    
    CGFloat originX = 6.0f;
    for(UIButton *button in self.buttons)
    {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"greyHalf_normal"];
        [button setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"greyHalf_highlighted"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageNamed:@"greyHalf_highlighted"] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:@"greyHalf_disabled"] forState:UIControlStateDisabled];
        [button setFrame:CGRectMake(originX, 6.0f, buttonWidth, button.frame.size.height)];
        originX += (buttonWidth + buttonSpace);
    }
    
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [newButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [newButton setTitle:name forState:UIControlStateNormal];
    [newButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    if(0 == [self.buttons count])
    {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"orangeBig_normal"];
        [newButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        [newButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
        [newButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
        [newButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
        [newButton setFrame:CGRectMake(originX, 6.0f, buttonWidth, buttonImageNormal.size.height)];
    }
    else
    {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"orangeHalf_normal"];
        [newButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        [newButton setBackgroundImage:[UIImage imageNamed:@"orangeHalf_highlighted"] forState:UIControlStateHighlighted];
        [newButton setBackgroundImage:[UIImage imageNamed:@"orangeHalf_highlighted"] forState:UIControlStateSelected];
        [newButton setBackgroundImage:[UIImage imageNamed:@"orangeHalf_disabled"] forState:UIControlStateDisabled];
        [newButton setFrame:CGRectMake(originX, 6.0f, buttonWidth, buttonImageNormal.size.height)];
    }
    
    [self addSubview:newButton];
    [self.buttons addObject:newButton];
}

@end

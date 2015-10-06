//
//  JABottomBar.m
//  Jumia
//
//  Created by josemota on 10/2/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JABottomBar.h"

#define kSmallButtonWidth 76

@interface JABottomBar ()

@property (nonatomic) NSMutableArray *buttonsArray;
@property (nonatomic) NSMutableArray *smallButtonsArray;

@end

@implementation JABottomBar

- (NSMutableArray *)buttonsArray
{
    if (!VALID(_buttonsArray, NSMutableArray)) {
        _buttonsArray = [NSMutableArray new];
    }
    return _buttonsArray;
}

- (NSMutableArray *)smallButtonsArray
{
    if (!VALID(_smallButtonsArray, NSMutableArray)) {
        _smallButtonsArray = [NSMutableArray new];
    }
    return _smallButtonsArray;
}

- (void)reloadFrame:(CGRect)frame
{
    [self setBackgroundColor:JABlackColor];
    CGFloat xOffset = 0;
    for (UIButton *smallButton in self.smallButtonsArray) {
        [smallButton setFrame:CGRectMake(xOffset, 0, kSmallButtonWidth, self.height)];
        xOffset += kSmallButtonWidth +1;
    }
    CGFloat sizeLeft = self.width - xOffset;
    NSInteger buttonsCount = self.buttonsArray.count;
    CGFloat buttonSize = sizeLeft/buttonsCount - buttonsCount+1;
    for (UIButton *button in self.buttonsArray) {
        [button setFrame:CGRectMake(xOffset, 0, buttonSize, self.height)];
        xOffset += buttonSize + 1;
    }
}

- (void)addButton:(NSString *)name target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:name forState:UIControlStateNormal];
    [button.titleLabel setFont:JABody2Font];
    [button setBackgroundColor:JAOrange1Color];
    [button setTintColor:[UIColor whiteColor]];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [self.buttonsArray addObject:button];
    [self reloadFrame:self.frame];
}

- (void)addSmallButton:(UIImage *)image target:(id)target action:(SEL)action
{
    UIButton *smallButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [[smallButton imageView] setContentMode:UIViewContentModeCenter];
    [smallButton setImage:image forState:UIControlStateNormal];
    [smallButton setBackgroundColor:JABlack900Color];
    [smallButton setTintColor:[UIColor whiteColor]];
    [smallButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:smallButton];
    [self.smallButtonsArray addObject:smallButton];
    [self reloadFrame:self.frame];
}

@end

//
//  JABottomBar.m
//  Jumia
//
//  Created by josemota on 10/2/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JABottomBar.h"
#import "JAButton.h"

#define kSmallButtonWidth 60

@interface JABottomBar ()

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

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self reloadFrame:frame];
}

- (void)reloadFrame:(CGRect)frame
{
    [self setBackgroundColor:[Theme color:kColorExtraDarkBlue]];
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

- (JAButton *)addButton:(NSString *)name target:(id)target action:(SEL)action {
    JAButton *button = [[JAButton alloc] initButtonWithTitle:name target:target action:action];
    [self addSubview:button];
    [button setBackgroundColor:[Theme color:kColorDarkGreen]];
    [self.buttonsArray addObject:button];
    [self reloadFrame:self.frame];
    return button;
}

- (JAButton *)addAlternativeButton:(NSString*)name target:(id)target action:(SEL)action
{
    JAButton *button = [[JAButton alloc] initAlternativeButtonWithTitle:name target:target action:action];
    [self addSubview:button];
    [self.buttonsArray addObject:button];
    [self reloadFrame:self.frame];
    return button;
}

- (JAButton *)addSmallButton:(UIImage *)image target:(id)target action:(SEL)action
{
    JAButton *smallButton = [[JAButton alloc] initSmallButtonWithImage:image target:target action:action];
    [self addSubview:smallButton];
    [self.smallButtonsArray addObject:smallButton];
    [self reloadFrame:self.frame];
    return smallButton;
}

@end

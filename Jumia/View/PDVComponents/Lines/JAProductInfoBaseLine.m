//
//  JAProductInfoBaseLine.m
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoBaseLine.h"
#import "JAClickableView.h"

@interface JAProductInfoBaseLine ()

@property (nonatomic) JAClickableView *clickableView;
@property (nonatomic) UILabel *arrow;

@end

@implementation JAProductInfoBaseLine

@synthesize label = _label;

- (UILabel *)label
{
    if (!VALID_NOTEMPTY(_label, UILabel)) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(16, 6, self.width-12, self.height-12)];
        [_label setTextColor:JABlackColor];
        [_label setText:@"set your text here."];
        [_label sizeToFit];
        [_label setY:self.height/2-_label.height/2];
        [self addSubview:_label];
    }
    return _label;
}

- (void)setLabel:(UILabel *)label
{
    _label = label;
    [_label sizeToFit];
    [_label setY:self.height/2-_label.height/2];
}

- (void)setClickable:(BOOL)clickable
{
    _clickable = clickable;
    [self.clickableView setEnabled:_clickable];
    [self.arrow setEnabled:_clickable];
    [self setUserInteractionEnabled:YES];
}

- (JAClickableView *)clickableView
{
    if (!VALID_NOTEMPTY(_clickableView, JAClickableView)) {
        _clickableView = [[JAClickableView alloc] initWithFrame:self.frame];
        [self addSubview:_clickableView];
    }
    return _clickableView;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self setClickable:YES];
    [self setUserInteractionEnabled:YES];
    [self.clickableView addTarget:target action:action forControlEvents:controlEvents];
}

- (UILabel *)arrow
{
    if (!VALID_NOTEMPTY(_arrow, UILabel)) {
        _arrow = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 16, 6, 10, self.height-12)];
        [_arrow setTextColor:JABlack400Color];
        [_arrow setText:@">"];
        [_arrow sizeToFit];
        [_arrow setX:self.width - 16 - _arrow.width];
        [_arrow setY:self.height/2 - _arrow.height/2];
        [self addSubview:_arrow];
    }
    return _arrow;
}

- (void)setTitle:(NSString *)title
{
    [_label setText:title];
    [_label sizeToFit];
    [_label setY:self.height/2-_label.height/2];
}

@end

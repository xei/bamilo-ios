//
//  JAMessageView.m
//  Jumia
//
//  Created by Jose Mota on 15/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAMessageView.h"

@interface JAMessageView ()

@property (strong, nonatomic) UIView *messageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *errorImageView;

@property (assign, nonatomic) CGFloat messageViewHeight;
@property (assign, nonatomic) CGFloat errorImageViewHeight;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL successState;

@end

@implementation JAMessageView

- (UIView *)messageView
{
    if(!VALID(_messageView, UIView))
    {
        _messageView = [[UIView alloc] initWithFrame:self.bounds];
        [self setClipsToBounds:YES];
    }
    return _messageView;
}

- (UILabel *)titleLabel
{
    if (!VALID(_titleLabel, UILabel)) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, self.width-90, self.height)];
        _titleLabel.font = JABody2Font;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _titleLabel;
}

- (UIImageView *)errorImageView
{
    if (!VALID(_errorImageView, UIImageView)) {
        _errorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_error_notificationbar"]];
        [_errorImageView setFrame:CGRectMake(15, 13, 22, 17)];
    }
    return _errorImageView;
}

- (void)setupView
{
    [self.messageView setHidden:YES];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(removeView)];
    [self addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)setTitle:(NSString *)title success:(BOOL)success
{
    if (!VALID(self.messageView.superview, UIView)) {
        [self addSubview:self.messageView];
    }else{
        [self.messageView setFrame:self.bounds];
    }
    if (!VALID(self.titleLabel.superview, UIView)) {
        [self.messageView addSubview:self.titleLabel];
    }else{
        [self.titleLabel setFrame:CGRectMake(45, 0, self.width-90, self.height)];
    }
    if (!VALID(self.errorImageView.superview, UIView)) {
        [self.messageView addSubview:self.errorImageView];
    }
    [self.titleLabel setText:title];
    
    if (success) {
        self.messageView.backgroundColor = UIColorFromRGB(0x7dcb7d);
        [self.errorImageView setHidden:YES];
    }else{
        self.messageView.backgroundColor = UIColorFromRGB(0xe77979);
        [self.errorImageView setHidden:NO];
    }
    
    [self.messageView setY:-self.height];
    [self setHidden:NO];
    [self.messageView setHidden:NO];
    [UIView animateWithDuration:.3 animations:^{
        [self.messageView setY:0.f];
    }];
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0f
                                                  target:self
                                                selector:@selector(removeView)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeView
{
    if ((self.hidden == NO) && (self != nil))
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [self.messageView setY:-self.height];
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             [self setHidden:YES];
                         }];
    }
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self.timer invalidate];
    [self removeFromSuperview];
}

@end

//
//  JAFilteredNoResultsView.m
//  Jumia
//
//  Created by jcarreira on 19/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAFilteredNoResultsView.h"
#import "JABottomBar.h"

#define kLateralMargin 16
#define kTopMargin 48
#define kImageTopMargin 28
#define kImageBottomMargin 28
#define kButtonTopMargin 48
#define kButtonWidth 288

@interface JAFilteredNoResultsView ()
{
    UIImage *_image;
}

@property (nonatomic) JABottomBar *ctaView;
@property (nonatomic) UILabel *topMessageLabel;
@property (nonatomic) UIImageView *filterImageView;
@property (nonatomic) UILabel *messageLabel;

@end

@implementation JAFilteredNoResultsView

- (UILabel *)topMessageLabel
{
    if (!_topMessageLabel) {
        _topMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, kTopMargin, self.width - 2*kLateralMargin, 100)];
        [_topMessageLabel setNumberOfLines:0];
        [_topMessageLabel setTextAlignment:NSTextAlignmentCenter];
        [_topMessageLabel setFont:JADisplay2Font];
        [_topMessageLabel setTextColor:JABlackColor];
        [_topMessageLabel setText:STRING_FILTER_NO_RESULTS];
        [_topMessageLabel sizeToFit];
        [_topMessageLabel setWidth:self.width - 2*kLateralMargin];
    }
    return _topMessageLabel;
}

- (UIImageView *)filterImageView
{
    if (!_filterImageView) {
        _image = [UIImage imageNamed:@"emptyFilter"];
        _filterImageView = [[UIImageView alloc] initWithImage:_image highlightedImage:_image];
        [_filterImageView setFrame:CGRectMake((self.width - _image.size.width)/2, CGRectGetMaxY(self.topMessageLabel.frame) + kImageTopMargin, _image.size.width, _image.size.height)];
        if (RI_IS_RTL) {
            [_filterImageView flipViewImage];
        }
    }
    return _filterImageView;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.filterImageView.frame) + kImageBottomMargin, self.width - 2*kLateralMargin, 100)];
        [_messageLabel setNumberOfLines:0];
        [_messageLabel setTextAlignment:NSTextAlignmentCenter];
        [_messageLabel setFont:JABody2Font];
        [_messageLabel setTextColor:JABlack800Color];
        [_messageLabel setText:STRING_FILTER_NO_RESULTS_TIP];
        [_messageLabel sizeToFit];
        [_messageLabel setWidth:self.width - 2*kLateralMargin];
    }
    return _messageLabel;
}

- (JABottomBar *)ctaView
{
    if (!_ctaView) {
        _ctaView = [[JABottomBar alloc] initWithFrame:CGRectMake((self.width - kButtonWidth)/2, CGRectGetMaxY(self.messageLabel.frame) + kButtonTopMargin, kButtonWidth, kBottomDefaultHeight)];
        [_ctaView addButton:[STRING_CATALOG_EDIT_FILTERS uppercaseString] target:self action:@selector(editFiltersButtonPressed)];
    }
    return _ctaView;
}

- (void)setupView:(CGRect)frame
{
    if (!self.topMessageLabel.superview) {
        [self addSubview:self.topMessageLabel];
    }else{
        [self.topMessageLabel sizeToFit];
        [self.topMessageLabel setFrame:CGRectMake(kLateralMargin, kTopMargin, frame.size.width - 2*kLateralMargin, self.topMessageLabel.height)];
    }
    
    if (!self.filterImageView.superview) {
        [self addSubview:self.filterImageView];
    }else{
        [self.filterImageView setFrame:CGRectMake((frame.size.width - _image.size.width)/2, CGRectGetMaxY(self.topMessageLabel.frame) + kImageTopMargin, _image.size.width, _image.size.height)];
    }
    
    if (!self.messageLabel.superview) {
        [self addSubview:self.messageLabel];
    }else{
        [self.messageLabel sizeToFit];
        [self.messageLabel setFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.filterImageView.frame) + kImageBottomMargin, frame.size.width - 2*kLateralMargin, self.messageLabel.height)];
    }
    
    if (!self.ctaView.superview) {
        [self addSubview:self.ctaView];
    }else{
        [self.ctaView setFrame:CGRectMake((frame.size.width - kButtonWidth)/2, CGRectGetMaxY(self.messageLabel.frame) + kButtonTopMargin, kButtonWidth, kBottomDefaultHeight)];
    }
}


- (void)editFiltersButtonPressed
{
    [self.delegate pressedEditFiltersButton:self];
}


@end

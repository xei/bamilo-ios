//
//  JAMyOrderCell.m
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//


#import "JAMyOrderCell.h"

#define kMyOrderHeight 58.0f
#define KPadding 16.f
#define KIPADPadding 24.f
#define KPricePadding 20.f
#define KSeperatorHeight 1.f

@interface JAMyOrderCell ()
{
    CGFloat padding;
}

@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *orderNumberLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UIView *seperator;
@property (strong, nonatomic) UIImageView *arrow;

@end

@implementation JAMyOrderCell

- (void)setupWithOrder:(RITrackOrder*)order {
    
    if ((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)) {
        padding = KIPADPadding;
    } else
        padding = KPadding;
    
    [self.priceLabel setText:order.totalFormatted];
    [self.priceLabel sizeToFit];
    
    [self.orderNumberLabel setText:[NSString stringWithFormat:@"%@ %@",STRING_ORDER_NUMBER,order.orderId]];
    [self.orderNumberLabel sizeToFit];
    
    [self.dateLabel setText:order.creationDate];
    [self.dateLabel sizeToFit];
    
    [self orderNumberLabel];
    [self dateLabel];
    [self priceLabel];
    [self seperator];
    
    if (RI_IS_RTL) {
        [self.arrow flipViewImage];
        [self.clickableView flipAllSubviews];
    }
    
}

-(JAClickableView *)clickableView {
    if (!VALID_NOTEMPTY(_clickableView, JAClickableView)) {
        _clickableView = [JAClickableView new];
        [self addSubview:_clickableView];
    }
    [_clickableView setFrame:CGRectMake(0, 0, self.width, self.height)];
    return _clickableView;
}

- (UILabel *)orderNumberLabel {
    if (!VALID_NOTEMPTY(_orderNumberLabel, UILabel)) {
        _orderNumberLabel = [UILabel new];
        [_orderNumberLabel setFont:JACaption2Font];
        [_orderNumberLabel setTextColor:JABlackColor];
        [self.clickableView addSubview:_orderNumberLabel];
    }
    [_orderNumberLabel setFrame:CGRectMake(padding, KPadding, _orderNumberLabel.width, _orderNumberLabel.height)];
    return _orderNumberLabel;
}

-(UILabel *)dateLabel {
    if (!VALID_NOTEMPTY(_dateLabel, UILabel)) {
        _dateLabel = [UILabel new];
        [_dateLabel setFont:JACaptionFont];
        [_dateLabel setTextColor:JABlackColor];
        [self.clickableView addSubview:_dateLabel];
    }
    [_dateLabel setFrame:CGRectMake(padding, kMyOrderHeight - _dateLabel.height - KPadding,
                                    _dateLabel.width, _dateLabel.height)];
    return _dateLabel;
}

-(UILabel *)priceLabel {
    if (!VALID_NOTEMPTY(_priceLabel, UILabel)) {
        _priceLabel = [UILabel new];
        [_priceLabel setFont:JACaptionFont];
        [_priceLabel setTextColor:JABlackColor];
        [self.clickableView addSubview:_priceLabel];
    }
    [_priceLabel setFrame:CGRectMake(self.arrow.frame.origin.x - _priceLabel.width - KPricePadding, 0,
                                     _priceLabel.width, kMyOrderHeight)];
    return _priceLabel;
}

-(UIView *)seperator {
    if (!VALID_NOTEMPTY(_seperator, UIView)) {
        _seperator = [UIView new];
        [_seperator setBackgroundColor:JABlack300Color];
        [self.clickableView addSubview:_seperator];
    }
    [_seperator setFrame:CGRectMake(0, self.height - KSeperatorHeight,
                                    self.width, KSeperatorHeight)];
    return _seperator;
}

-(UIImageView *)arrow {
    if (!VALID_NOTEMPTY(_arrow, UIImageView)) {
        _arrow = [UIImageView new];
        UIImage *img = [UIImage imageNamed:@"arrow_moreinfo"];
        [_arrow setImage:img];
        [_arrow setFrame:CGRectMake(_arrow.x, _arrow.y,
                                    img.size.width, img.size.height)];
        [self.clickableView addSubview:_arrow];
    }
    [_arrow setFrame:CGRectMake(self.width - _arrow.width - padding, (self.height - _arrow.height) / 2,
                                _arrow.width, _arrow.height)];
    return _arrow;
}

+ (CGFloat)getCellHeight
{
    return kMyOrderHeight;
}

@end

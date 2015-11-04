//
//  JAPDVProductInfoSellerInfo.m
//  Jumia
//
//  Created by josemota on 9/30/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVProductInfoSellerInfo.h"
#import "JAProductInfoRatingLine.h"
#import "JAClickableView.h"

@interface JAPDVProductInfoSellerInfo ()

@property (nonatomic) UIImageView *arrow;
@property (nonatomic) UILabel *sellerNameLabel;
@property (nonatomic) UILabel *sellerDeliveryLabel;
@property (nonatomic) UILabel *sellerDeliveryTimeLabel;
@property (nonatomic) UILabel *shippingGlobalLabel;
@property (nonatomic) UIImageView *shippingIcon;
@property (nonatomic) UIButton* linkGlobalButton;
@property (nonatomic) JAClickableView *clickableView;

@end

@implementation JAPDVProductInfoSellerInfo

- (JAClickableView *)clickableView
{
    if (!VALID_NOTEMPTY(_clickableView, JAClickableView)) {
        _clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:_clickableView];
    }
    return _clickableView;
}

- (UIImageView *)arrow
{
    CGRect frame = CGRectMake(self.width - 16, self.height/2 - 6, 8, 12);
    if (!VALID_NOTEMPTY(_arrow, UIImageView)) {
        _arrow = [[UIImageView alloc] initWithFrame:frame];
        [_arrow setImage:[UIImage imageNamed:@"arrow_moreinfo"]];
        [_arrow setHidden:YES];
        [_arrow setX:self.width - 16 - _arrow.width];
        [_arrow setY:self.height/2 - _arrow.height/2];
        if (RI_IS_RTL) {
            [_arrow flipViewImage];
        }
        [self.clickableView addSubview:_arrow];
    }else if(!CGRectEqualToRect(frame, _arrow.frame)) {
        [_arrow setFrame:frame];
    }
    return _arrow;
}

- (UILabel *)sellerNameLabel
{
    if (!VALID_NOTEMPTY(_sellerNameLabel, UILabel)) {
        _sellerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, self.width-32, 20)];
        [_sellerNameLabel setFont:JABody1Font];
        [_sellerNameLabel setTextColor:JABlack900Color];
        [self.clickableView addSubview:_sellerNameLabel];
    }
    return _sellerNameLabel;
}

- (UILabel *)sellerDeliveryLabel
{
    if (!VALID_NOTEMPTY(_sellerDeliveryLabel, UILabel)) {
        _sellerDeliveryLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.sellerNameLabel.frame) + 8.f, self.width-32, 20)];
        [_sellerDeliveryLabel setFont:JABody3Font];
        [_sellerDeliveryLabel setTextColor:JABlack800Color];
        [self.clickableView addSubview:_sellerDeliveryLabel];
    }
    return _sellerDeliveryLabel;
}

- (UILabel *)sellerDeliveryTimeLabel
{
    if (!VALID_NOTEMPTY(_sellerDeliveryTimeLabel, UILabel)) {
        _sellerDeliveryTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.sellerDeliveryLabel.frame) + 8.f, self.width-32, 20)];
        _sellerDeliveryTimeLabel.numberOfLines = 0;
        [_sellerDeliveryTimeLabel setFont:JACaptionFont];
        [_sellerDeliveryTimeLabel setTextColor:JABlack800Color];
        [_sellerDeliveryTimeLabel setTextAlignment:NSTextAlignmentLeft];
        [self.clickableView addSubview:_sellerDeliveryTimeLabel];
    }
    return _sellerDeliveryTimeLabel;
}

- (UILabel *)shippingGlobalLabel
{
    if (!VALID_NOTEMPTY(_shippingGlobalLabel, UILabel)) {
        _shippingGlobalLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, CGRectGetMaxY(self.sellerDeliveryLabel.frame) + 8.f, self.width-32, 20)];
        [_shippingGlobalLabel setFont:JACaptionFont];
        [_shippingGlobalLabel setTextColor:JAOrange1Color];
        _shippingGlobalLabel.numberOfLines = 0;
        [_shippingGlobalLabel setTextAlignment:NSTextAlignmentLeft];
        [_shippingGlobalLabel setHidden:YES];
        [self.clickableView addSubview:_shippingGlobalLabel];
    }
    return _shippingGlobalLabel;
}

- (UIImageView *)shippingIcon
{
    if (!VALID_NOTEMPTY(_shippingIcon, UIImageView)) {
        _shippingIcon = [UIImageView new];
        [_shippingIcon setImage:[UIImage imageNamed:@"plane"]];
        [_shippingIcon sizeToFit];
        [_shippingIcon setX:self.sellerNameLabel.x];
        [_shippingIcon setY:CGRectGetMaxY(self.sellerNameLabel.frame)+16.f];
        if (RI_IS_RTL) {
            [_shippingIcon flipViewImage];
        }
        [self.clickableView addSubview:_shippingIcon];
        [_shippingIcon setHidden:YES];
    }
    return _shippingIcon;
}

- (UIButton *)linkGlobalButton
{
    if (!VALID_NOTEMPTY(_linkGlobalButton, UIButton)) {
        _linkGlobalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_linkGlobalButton setFrame:CGRectMake(48, CGRectGetMaxY(self.shippingIcon.frame) + 16.f, self.width-32, 20)];
        [_linkGlobalButton.titleLabel setFont:JACaptionFont];
        [_linkGlobalButton.titleLabel setTextColor:JAOrange1Color];
        [_linkGlobalButton setHidden:YES];
        [self addSubview:_linkGlobalButton];
    }
    return _linkGlobalButton;
}
- (void)setSeller:(RISeller *)seller
{
    _seller = seller;
    [self.sellerNameLabel setText:seller.name];
    [self.sellerNameLabel sizeToFit];
    
    [self.sellerDeliveryLabel setText:seller.deliveryTime];
    [self.sellerDeliveryLabel setFont:JACaption2Font];
    [self.sellerDeliveryLabel setTextColor:JABlackColor];
    [self.sellerDeliveryLabel sizeToFit];
    
    if (seller.isGlobal) {
        [self.sellerDeliveryLabel setX:self.shippingGlobalLabel.x];

        [self.sellerDeliveryTimeLabel setText:seller.cmsInfo];
        [self.sellerDeliveryTimeLabel setTextColor:JABlackColor];
        [self.sellerDeliveryTimeLabel sizeToFit];
        [self.sellerDeliveryTimeLabel setX:self.shippingGlobalLabel.x];
        [self.sellerDeliveryTimeLabel setY:CGRectGetMaxY(self.sellerDeliveryLabel.frame)+.4f];

        [self.shippingGlobalLabel setHidden:NO];
        [self.shippingGlobalLabel setText:[seller.shippingGlobal stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]]];
        [self.shippingGlobalLabel sizeToFit];
        [self.shippingGlobalLabel setY:CGRectGetMaxY(self.sellerDeliveryTimeLabel.frame)+.4f];

        [self.shippingIcon setHidden:NO];
        [self.shippingIcon setY:self.sellerDeliveryLabel.y];
        
        [self.linkGlobalButton setHidden:NO];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        [self.linkGlobalButton setAttributedTitle:[[NSAttributedString alloc] initWithString:seller.linkTextGlobal
                                                                            attributes:underlineAttribute]
                                   forState:UIControlStateNormal];
        [self.linkGlobalButton.titleLabel sizeToFit];
        [self.linkGlobalButton setY:CGRectGetMaxY(self.shippingGlobalLabel.frame)+8.f];
        [self.linkGlobalButton sizeToFit];
    }
    
    if (!seller.isGlobal) {
        [self setHeight:CGRectGetMaxY(self.sellerDeliveryLabel.frame) + 16.f];
    } else {
        [self setHeight:CGRectGetMaxY(self.linkGlobalButton.frame) + 16.f];
    }
    
    [self.clickableView setHeight:[self height]];
    
    [self arrow];
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self.clickableView addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.arrow setHidden:NO];
}

- (void)addLinkTarget:(id)target action:(SEL)action
{
    [self.linkGlobalButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end

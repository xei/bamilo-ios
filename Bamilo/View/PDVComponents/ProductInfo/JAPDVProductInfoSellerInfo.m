////
////  JAPDVProductInfoSellerInfo.m
////  Jumia
////
////  Created by josemota on 9/30/15.
////  Copyright © 2015 Rocket Internet. All rights reserved.
////
//
//#import "JAPDVProductInfoSellerInfo.h"
//#import "JAProductInfoRatingLine.h"
//#import "JAProductInfoBaseLine.h"
//#import "JAClickableView.h"
//
//@interface JAPDVProductInfoSellerInfo ()
//
//@property (nonatomic) UIImageView *arrow;
//@property (nonatomic) UILabel *sellerNameLabel;
////@property (nonatomic) UILabel *sellerDeliveryLabel;
////@property (nonatomic) UILabel *sellerDeliveryTimeLabel;
//@property (nonatomic) UILabel *shippingGlobalLabel;
//@property (nonatomic) UILabel *sellerWarrantyLabel;
//@property (nonatomic) UIImageView *shippingIcon;
//@property (nonatomic) UIImageView *warrantyIcon;
//@property (nonatomic) JAProductInfoBaseLine* linkGlobalButton;
//@property (nonatomic) JAClickableView *clickableView;
//
//@end
//
//@implementation JAPDVProductInfoSellerInfo
//
//- (JAClickableView *)clickableView {
//    if (!VALID_NOTEMPTY(_clickableView, JAClickableView)) {
//        _clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        [self addSubview:_clickableView];
//    }
//    return _clickableView;
//}
//
//- (UIImageView *)arrow {
//    CGRect frame = CGRectMake(self.width - 8 - 16, self.clickableView.height/2 - 6, 8, 12);
//    if (!VALID_NOTEMPTY(_arrow, UIImageView)) {
//        _arrow = [[UIImageView alloc] initWithFrame:frame];
//        [_arrow setImage:[UIImage imageNamed:@"arrow_moreinfo"]];
//        [_arrow setHidden:YES];
//        [_arrow setX:self.width - 16 - _arrow.width];
//        [_arrow setY:self.clickableView.height/2 - _arrow.height/2];
//        if (RI_IS_RTL) {
//            [_arrow flipViewImage];
//        }
//        [self.clickableView addSubview:_arrow];
//    } else if(!CGRectEqualToRect(frame, _arrow.frame)) {
//        [_arrow setFrame:frame];
//    }
//    return _arrow;
//}
//
//- (UILabel *)sellerNameLabel {
//    if (!VALID_NOTEMPTY(_sellerNameLabel, UILabel)) {
//        _sellerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, self.width - 32, 20)];
//        [_sellerNameLabel setFont:[Theme font:kFontVariationRegular size:12]];
//        [_sellerNameLabel setTextColor:JABlackColor];
//        [_sellerNameLabel setTextAlignment:NSTextAlignmentLeft];
//        [self.clickableView addSubview:_sellerNameLabel];
//    }
//    return _sellerNameLabel;
//}
//
//- (UILabel *)shippingGlobalLabel {
//    if (!VALID_NOTEMPTY(_shippingGlobalLabel, UILabel)) {
//        _shippingGlobalLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, CGRectGetMaxY(self.sellerNameLabel.frame) + 8.f, self.width-(self.width-self.arrow.x)-48, 20)];
//        [_shippingGlobalLabel setFont:JACaptionFont];
//        [_shippingGlobalLabel setTextColor:JABlack800Color];
//        _shippingGlobalLabel.numberOfLines = 0;
//        [_shippingGlobalLabel setTextAlignment:NSTextAlignmentLeft];
//        [_shippingGlobalLabel setHidden:YES];
//        [self.clickableView addSubview:_shippingGlobalLabel];
//    }
//    return _shippingGlobalLabel;
//}
//
//- (UIImageView *)shippingIcon {
//    if (!VALID_NOTEMPTY(_shippingIcon, UIImageView)) {
//        _shippingIcon = [UIImageView new];
//        [_shippingIcon setImage:[UIImage imageNamed:@"plane"]];
//        [_shippingIcon sizeToFit];
//        [_shippingIcon setX:self.sellerNameLabel.x];
//        [_shippingIcon setY:CGRectGetMaxY(self.sellerNameLabel.frame)+16.f];
//        if (RI_IS_RTL) {
//            [_shippingIcon flipViewImage];
//        }
//        [self.clickableView addSubview:_shippingIcon];
//        [_shippingIcon setHidden:YES];
//    }
//    return _shippingIcon;
//}
//
//- (JAProductInfoBaseLine *)linkGlobalButton {
//    if (!VALID_NOTEMPTY(_linkGlobalButton, JAProductInfoBaseLine)) {
//        _linkGlobalButton = [[JAProductInfoBaseLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shippingIcon.frame) + 16.f, self.width, kProductInfoSingleLineHeight)];
//        [_linkGlobalButton setTopSeparatorXOffset:16.f];
//        [_linkGlobalButton setTopSeparatorVisibility:YES];
//        [_linkGlobalButton.titleLabel setFont:JABodyFont];
//        [_linkGlobalButton.titleLabel setTextColor:JABlue1Color];
//        [_linkGlobalButton setHidden:YES];
//        [self addSubview:_linkGlobalButton];
//    }
//    return _linkGlobalButton;
//}
//
//- (UIImageView *)warrantyIcon {
//    if (!VALID_NOTEMPTY(_warrantyIcon, UIImageView)) {
//        _warrantyIcon = [UIImageView new];
//        [_warrantyIcon setImage:[UIImage imageNamed:@"warranty"]];
//        [_warrantyIcon sizeToFit];
//        [_warrantyIcon setX:16.f];
//        [_warrantyIcon setY:CGRectGetMaxY(self.sellerNameLabel.frame)+16.f];
//        if (RI_IS_RTL) {
////            [_warrantyIcon flipViewImage];
//        }
//        [self.clickableView addSubview:_warrantyIcon];
//        [_warrantyIcon setHidden:YES];
//    }
//    return _warrantyIcon;
//}
//
//- (UILabel *)sellerWarrantyLabel {
//    if (!VALID_NOTEMPTY(_sellerWarrantyLabel, UILabel)) {
//        _sellerWarrantyLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.shippingGlobalLabel.frame) + 16.f, self.width-32, 20)];
//        [_sellerWarrantyLabel setNumberOfLines:2];
//        [_sellerWarrantyLabel setFont:[Theme font:kFontVariationRegular size:12]];
//        [_sellerWarrantyLabel setTextColor:JABlackColor];
//        [_sellerWarrantyLabel setTextAlignment:NSTextAlignmentLeft];
//        [self.clickableView addSubview:_sellerWarrantyLabel];
//    }
//    return _sellerWarrantyLabel;
//}
//
//- (UIImageView *)shopFirstLogo {
//    if (!_shopFirstLogo) {
//        _shopFirstLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop_first_logo"]];
//        [_shopFirstLogo sizeToFit];
//        [_shopFirstLogo setXRightAligned:10.f];
//        [_shopFirstLogo setY:self.sellerNameLabel.y];
//        [_shopFirstLogo setUserInteractionEnabled:YES];
//        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shopFirstLogoTapped:)];
//        [_shopFirstLogo addGestureRecognizer:singleTap];
//        [self bringSubviewToFront:_shopFirstLogo];
//        [self addSubview:_shopFirstLogo];
//    }
//    return _shopFirstLogo;
//}
//
//- (void)setSeller:(RISeller *)seller {
//    _seller = seller;
//    [self.sellerNameLabel setText: [NSString stringWithFormat:@"%@:  %@", STRING_SELLER, seller.name]];
//    [self.sellerNameLabel sizeToFit];
//    if (CGRectGetMaxX(self.sellerNameLabel.frame) > self.width - self.sellerNameLabel.x) {
//        [self.sellerNameLabel setWidth:self.width - 2*self.sellerNameLabel.x];
//    }
//    
//    [self checkIsShopFirst];
//    
//    [self setHeight:CGRectGetMaxY(self.sellerNameLabel.frame) + 16.f];
//    [self.clickableView setHeight:CGRectGetMaxY(self.sellerNameLabel.frame) + 16.f];
////    [self.sellerDeliveryLabel setY:CGRectGetMaxY(self.sellerNameLabel.frame) + 16.f];
//    
//    if (VALID_NOTEMPTY(seller.warranty, NSString)) {
//        [self.sellerWarrantyLabel setText:[NSString stringWithFormat:@"%@:         %@", STRING_SELLER_INFO_WARRANTY, [seller.warranty uppercaseString]]];
//        
//        [self.sellerWarrantyLabel setFrame:CGRectMake(self.sellerNameLabel.x, CGRectGetMaxY(self.sellerNameLabel.frame) + 16.f, self.width + (self.width - self.arrow.x), [self.sellerWarrantyLabel sizeThatFits:CGSizeMake(self.sellerWarrantyLabel.width, CGFLOAT_MAX)].height)];
//        [self.warrantyIcon setX:70];
//        [self.warrantyIcon setY:CGRectGetMidY(self.sellerWarrantyLabel.frame) - self.warrantyIcon.height/2];
//        [self.warrantyIcon setHidden:NO];
//        [self setHeight:CGRectGetMaxY(self.sellerWarrantyLabel.frame) + 16.f];
//        [self.clickableView setHeight:CGRectGetMaxY(self.sellerWarrantyLabel.frame) + 16.f];
////        [self.sellerDeliveryLabel setY:CGRectGetMaxY(self.sellerWarrantyLabel.frame) + 16.f];
//    }
//    
////    if (VALID_NOTEMPTY(seller.deliveryTime, NSString)) {
////        
////        [self.sellerDeliveryLabel setText:[seller.deliveryTime uppercaseString]];
////        CGFloat sellerDeliveryLabelWidth = self.width - self.sellerDeliveryLabel.x - (self.width - self.arrow.x);
////        [self.sellerDeliveryLabel setWidth:sellerDeliveryLabelWidth];
////        [self.sellerDeliveryLabel setHeight:[self.sellerDeliveryLabel sizeThatFits:CGSizeMake(sellerDeliveryLabelWidth, CGFLOAT_MAX)].height];
////        [self setHeight:CGRectGetMaxY(self.sellerDeliveryLabel.frame) + 16.f];
////        [self.clickableView setHeight:CGRectGetMaxY(self.sellerDeliveryLabel.frame) + 16.f];
////        [self.sellerDeliveryTimeLabel setY:CGRectGetMaxY(self.sellerDeliveryLabel.frame) + 16.f];
////    }
//    
//    if (seller.isGlobal) {
////        [self.sellerDeliveryLabel setX:self.shippingGlobalLabel.x];
////        CGFloat sellerDeliveryLabelWidth = self.width - self.sellerDeliveryLabel.x - (self.width - self.arrow.x);
////        [self.sellerDeliveryLabel setWidth:sellerDeliveryLabelWidth];
////        [self.sellerDeliveryLabel setHeight:[self.sellerDeliveryLabel sizeThatFits:CGSizeMake(sellerDeliveryLabelWidth, CGFLOAT_MAX)].height];
////
////        [self.sellerDeliveryTimeLabel setText:[seller.cmsInfo uppercaseString]];
////        [self.sellerDeliveryTimeLabel setX:self.shippingGlobalLabel.x];
////        [self.sellerDeliveryTimeLabel setWidth:self.width - self.sellerDeliveryTimeLabel.frame.origin.x - 18.f];
////        [self.sellerDeliveryTimeLabel setY:CGRectGetMaxY(self.sellerDeliveryLabel.frame)+.4f];
////        [self.sellerDeliveryTimeLabel sizeToFit];
//
//        [self.shippingGlobalLabel setHidden:NO];
//        [self.shippingGlobalLabel setText:[seller.shippingGlobal stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]]];
//        [self.shippingGlobalLabel setHeight:[self.shippingGlobalLabel sizeThatFits:CGSizeMake(self.shippingGlobalLabel.width, CGFLOAT_MAX)].height];
////        [self.shippingGlobalLabel setY:CGRectGetMaxY(self.sellerDeliveryTimeLabel.frame)+.4f];
//        
//        [self.shippingIcon setX:CGRectGetMinX(self.warrantyIcon.frame)];
//        [self.shippingIcon setHidden:NO];
////        [self.shippingIcon setY:CGRectGetMidY(self.sellerDeliveryLabel.frame)-self.shippingIcon.height/2];
//        
//        [self.linkGlobalButton setHidden:NO];
//        [self.linkGlobalButton setTitle:seller.linkTextGlobal];
//        [self.linkGlobalButton setY:CGRectGetMaxY(self.shippingGlobalLabel.frame)+16.f];
//        
//        [self setHeight:CGRectGetMaxY(self.linkGlobalButton.frame)];
//        [self.clickableView setHeight:CGRectGetMaxY(self.shippingGlobalLabel.frame) + 16.f];
//    }
//    
//    [self arrow];
//}
//
//- (void)addTarget:(id)target action:(SEL)action {
//    [self.clickableView addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
//    [self.arrow setHidden:NO];
//}
//
//- (void)addLinkTarget:(id)target action:(SEL)action {
//    [self.linkGlobalButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (void)checkIsShopFirst {
//    if ([self.isShopFirst boolValue]) {
//        if (self.sellerNameLabel.width > self.width-2*self.sellerNameLabel.x-self.shopFirstLogo.width-10.f) {
//            [self.sellerNameLabel setWidth:self.width-2*self.sellerNameLabel.x-self.shopFirstLogo.width-10.f];
//        }
//        [self.shopFirstLogo setXRightOf:self.sellerNameLabel at:10.f];
//        [self.shopFirstLogo setHidden:NO];
//    } else {
//        [self.shopFirstLogo setHidden:YES];
//    }
//}
//
//- (void)shopFirstLogoTapped:(UIGestureRecognizer *)gestureRecognizer {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:self.shopFirstOverlayText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//}
//
//@end

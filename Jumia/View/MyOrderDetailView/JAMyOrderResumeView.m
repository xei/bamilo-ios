//
//  JAMyOrderResumeView.m
//  Jumia
//
//  Created by Jose Mota on 11/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAMyOrderResumeView.h"
#import "JAProductInfoHeaderLine.h"
#import "JAProductInfoPriceLine.h"

#define kTopMargin 16.f
#define kLateralMargin 16.f

@interface JAMyOrderResumeView ()

@property (nonatomic) JAProductInfoHeaderLine *orderNumberHeader;
@property (nonatomic) UILabel *orderDate;

@property (nonatomic) UIView *resumeOrderView;
@property (nonatomic) UILabel *itemsNumberLabel;
@property (nonatomic) JAProductInfoPriceLine *priceLine;

@property (nonatomic) UIView *paymentView;
@property (nonatomic) UILabel *paymentTitle;
@property (nonatomic) UILabel *paymentType;
@property (nonatomic) UILabel *paymentDescrition;

@property (nonatomic) UIView *shippingView;
@property (nonatomic) UILabel *shippingTitle;
@property (nonatomic) UILabel *shippingName;
@property (nonatomic) UILabel *shippingAddress;
@property (nonatomic) UILabel *shippingCity;
@property (nonatomic) UILabel *shippingPhone;

@property (nonatomic) UIView *billingView;
@property (nonatomic) UILabel *billingTitle;
@property (nonatomic) UILabel *billingName;
@property (nonatomic) UILabel *billingAddress;
@property (nonatomic) UILabel *billingCity;
@property (nonatomic) UILabel *billingPhone;

@property (nonatomic) UIView *horizontalCrossView;
@property (nonatomic) UIView *verticalCrossView;

@end

@implementation JAMyOrderResumeView

- (JAProductInfoHeaderLine *)orderNumberHeader
{
    if (!VALID(_orderNumberHeader, JAProductInfoHeaderLine)) {
        _orderNumberHeader = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.width, kProductInfoHeaderLineHeight)];
        [_orderNumberHeader addSubview:self.orderDate];
    }
    return _orderNumberHeader;
}

- (UILabel *)orderDate
{
    if (!VALID(_orderDate, UILabel)) {
        _orderDate = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, 0, self.width-2*kLateralMargin, self.orderNumberHeader.height)];
        [_orderDate setFont:[UIFont fontWithName:kFontRegularName size:10]];
        [_orderDate setTextColor:JABlackColor];
    }
    return _orderDate;
}




- (UIView *)resumeOrderView
{
    if (!VALID(_resumeOrderView, UIView)) {
        _resumeOrderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.orderNumberHeader.frame), self.width/2-1, self.height/2)];
        [_resumeOrderView addSubview:self.itemsNumberLabel];
        [_resumeOrderView addSubview:self.priceLine];
    }
    return _resumeOrderView;
}

- (UILabel *)itemsNumberLabel
{
    if (!VALID(_itemsNumberLabel, UILabel)) {
        _itemsNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, kTopMargin, self.resumeOrderView.width-2*kLateralMargin, 15.f)];
        [_itemsNumberLabel setFont:JABody1Font];
        [_itemsNumberLabel setTextColor:JABlackColor];
    }
    return _itemsNumberLabel;
}

- (JAProductInfoPriceLine *)priceLine
{
    if (!VALID(_priceLine, JAProductInfoPriceLine)) {
        _priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.itemsNumberLabel.frame), self.resumeOrderView.width-2*kLateralMargin, 15.f)];
        [_priceLine setPriceSize:kPriceSizeSmall];
        [_priceLine setLineContentXOffset:0.f];
    }
    return _priceLine;
}




- (UIView *)paymentView
{
    if (!VALID(_paymentView, UIView)) {
        _paymentView = [[UIView alloc] initWithFrame:CGRectMake(self.width/2, CGRectGetMaxY(self.orderNumberHeader.frame), self.width/2, self.height/2)];
        [_paymentView addSubview:self.paymentTitle];
        [_paymentView addSubview:self.paymentType];
    }
    return _paymentView;
}

- (UILabel *)paymentTitle
{
    if (!VALID(_paymentTitle, UILabel)) {
        _paymentTitle = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, kTopMargin, self.paymentView.width-2*kLateralMargin, 15.f)];
        [_paymentTitle setFont:JACaptionFont];
        [_paymentTitle setTextColor:JABlack800Color];
    }
    return _paymentTitle;
}

- (UILabel *)paymentType
{
    if (!VALID(_paymentType, UILabel)) {
        _paymentType = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.paymentTitle.frame), self.paymentView.width-2*kLateralMargin, 15.f)];
        [_paymentType setFont:JABody2Font];
        [_paymentType setTextColor:JABlackColor];
    }
    return _paymentType;
}

- (UILabel *)paymentDescrition
{
    if (!VALID(_paymentDescrition, UILabel)) {
        _paymentDescrition = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.paymentType.frame), self.paymentView.width-2*kLateralMargin, 15.f)];
        [_paymentDescrition setFont:JACaptionFont];
        [_paymentDescrition setTextColor:JABlackColor];
    }
    return _paymentDescrition;
}




- (UIView *)shippingView
{
    if (!VALID(_shippingView, UIView)) {
        _shippingView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.resumeOrderView.frame), self.width/2-1, self.height/2)];
        [_shippingView addSubview:self.shippingTitle];
        [_shippingView addSubview:self.shippingName];
        [_shippingView addSubview:self.shippingAddress];
        [_shippingView addSubview:self.shippingCity];
        [_shippingView addSubview:self.shippingPhone];
    }
    return _shippingView;
}

- (UILabel *)shippingTitle
{
    if (!VALID(_shippingTitle, UILabel)) {
        _shippingTitle = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, kTopMargin, self.shippingView.width-2*kLateralMargin, 15.f)];
        [_shippingTitle setFont:JACaptionFont];
        [_shippingTitle setTextColor:JABlack800Color];
    }
    return _shippingTitle;
}

- (UILabel *)shippingName
{
    if (!VALID(_shippingName, UILabel)) {
        _shippingName = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.shippingTitle.frame), self.shippingView.width-2*kLateralMargin, 15.f)];
        [_shippingName setFont:JABody2Font];
        [_shippingName setTextColor:JABlackColor];
    }
    return _shippingName;
}

- (UILabel *)shippingAddress
{
    if (!VALID(_shippingAddress, UILabel)) {
        _shippingAddress = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.shippingName.frame), self.shippingView.width-2*kLateralMargin, 15.f)];
        [_shippingAddress setFont:JACaptionFont];
        [_shippingAddress setTextColor:JABlackColor];
        [_shippingAddress setNumberOfLines:2];
    }
    return _shippingAddress;
}

- (UILabel *)shippingCity
{
    if (!VALID(_shippingCity, UILabel)) {
        _shippingCity = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.shippingAddress.frame), self.shippingView.width-2*kLateralMargin, 15.f)];
        [_shippingCity setFont:JACaptionFont];
        [_shippingCity setTextColor:JABlackColor];
    }
    return _shippingCity;
}

- (UILabel *)shippingPhone
{
    if (!VALID(_shippingPhone, UILabel)) {
        _shippingPhone = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.shippingCity.frame), self.shippingView.width-2*kLateralMargin, 15.f)];
        [_shippingPhone setFont:JACaptionFont];
        [_shippingPhone setTextColor:JABlackColor];
    }
    return _shippingPhone;
}




- (UIView *)billingView
{
    if (!VALID(_billingView, UIView)) {
        _billingView = [[UIView alloc] initWithFrame:CGRectMake(self.width/2, CGRectGetMaxY(self.paymentView.frame), self.width/2, self.height/2)];
        [_billingView addSubview:self.billingTitle];
        [_billingView addSubview:self.billingName];
        [_billingView addSubview:self.billingAddress];
        [_billingView addSubview:self.billingCity];
        [_billingView addSubview:self.billingPhone];
    }
    return _billingView;
}

- (UILabel *)billingTitle
{
    if (!VALID(_billingTitle, UILabel)) {
        _billingTitle = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, kTopMargin, self.billingView.width-2*kLateralMargin, 15.f)];
        [_billingTitle setFont:JACaptionFont];
        [_billingTitle setTextColor:JABlack800Color];
    }
    return _billingTitle;
}

- (UILabel *)billingName
{
    if (!VALID(_billingName, UILabel)) {
        _billingName = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.billingTitle.frame), self.billingView.width-2*kLateralMargin, 15.f)];
        [_billingName setFont:JABody2Font];
        [_billingName setTextColor:JABlackColor];
    }
    return _billingName;
}

- (UILabel *)billingAddress
{
    if (!VALID(_billingAddress, UILabel)) {
        _billingAddress = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.billingName.frame), self.billingView.width-2*kLateralMargin, 15.f)];
        [_billingAddress setFont:JACaptionFont];
        [_billingAddress setTextColor:JABlackColor];
        [_billingAddress setNumberOfLines:2];
    }
    return _billingAddress;
}

- (UILabel *)billingCity
{
    if (!VALID(_billingCity, UILabel)) {
        _billingCity = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.billingAddress.frame), self.billingView.width-2*kLateralMargin, 15.f)];
        [_billingCity setFont:JACaptionFont];
        [_billingCity setTextColor:JABlackColor];
    }
    return _billingCity;
}

- (UILabel *)billingPhone
{
    if (!VALID(_billingPhone, UILabel)) {
        _billingPhone = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.billingCity.frame), self.billingView.width-2*kLateralMargin, 15.f)];
        [_billingPhone setFont:JACaptionFont];
        [_billingPhone setTextColor:JABlackColor];
    }
    return _billingPhone;
}




- (UIView *)horizontalCrossView
{
    if (!VALID(_horizontalCrossView, UIView)) {
        _horizontalCrossView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.paymentView.frame), self.width, 1)];
        [_horizontalCrossView setBackgroundColor:JABlack300Color];
    }
    return _horizontalCrossView;
}

- (UIView *)verticalCrossView
{
    if (!VALID(_verticalCrossView, UIView)) {
        _verticalCrossView = [[UIView alloc] initWithFrame:CGRectMake(self.width/2-1, 0, 1, self.height)];
        [_verticalCrossView setBackgroundColor:JABlack300Color];
    }
    return _verticalCrossView;
}





- (void)setOrder:(RITrackOrder *)order
{
    _order = order;
    
    if (!VALID(self.orderNumberHeader.superview, UIView)) {
        [self addSubview:self.orderNumberHeader];
    }
    
    [self.orderNumberHeader setTitle:[[NSString stringWithFormat:STRING_ORDER_NO, order.orderId] uppercaseString]];
    [self.orderDate setText:order.creationDate];
    
    
    
    if (!VALID(self.resumeOrderView.superview, UIView)) {
        [self addSubview:self.resumeOrderView];
    }else{
        [self.resumeOrderView setX:0.f];
    }
    
    [self.itemsNumberLabel setText:[NSString stringWithFormat:STRING_ITEMS_CART, order.itemCollection.count]];
    [self.priceLine setPrice:order.totalFormatted];
    
    
    
    if (!VALID(self.paymentView.superview, UIView)) {
        [self addSubview:self.paymentView];
    }else{
        [self.paymentView setX:self.width/2];
    }
    
    [self.paymentTitle setText:STRING_PAYMENT];
    [self.paymentType setText:order.paymentMethod];
    [self.paymentDescrition setText:order.paymentDescription];
    [self.paymentView setHeight:CGRectGetMaxY(self.paymentDescrition.frame) + 16.f];
    [self.resumeOrderView setHeight:CGRectGetMaxY(self.paymentDescrition.frame) + 16.f];
    
    
    if (!VALID(self.shippingView.superview, UIView)) {
        [self addSubview:self.shippingView];
    }else{
        [self.shippingView setX:0.f];
    }
    
    [self.shippingTitle setText:STRING_SHIPPING_ADDRESSES];
    [self.shippingName setText:[NSString stringWithFormat:@"%@ %@", order.shippingAddress.firstName, order.shippingAddress.lastName]];
    if (VALID_NOTEMPTY(order.shippingAddress.address2, NSString)) {
        [self.shippingAddress setText:[NSString stringWithFormat:@"%@, %@", order.shippingAddress.address, order.shippingAddress.address2]];
    }else{
        [self.shippingAddress setText:order.shippingAddress.address];
    }
    CGSize size = [self.shippingAddress sizeThatFits:CGSizeMake(self.shippingAddress.width, CGFLOAT_MAX)];
    [self.shippingAddress setHeight:size.height];
    [self.shippingCity setYBottomOf:self.shippingAddress at:0.f];
    [self.shippingCity setText:order.shippingAddress.city];
    [self.shippingPhone setYBottomOf:self.shippingCity at:0.f];
    [self.shippingPhone setText:order.shippingAddress.phone];
    
    
    
    if (!VALID(self.billingView.superview, UIView)) {
        [self addSubview:self.billingView];
    }else{
        [self.billingView setX:self.width/2];
    }
    
    [self.billingTitle setText:STRING_BILLING_ADDRESSES];
    [self.billingName setText:[NSString stringWithFormat:@"%@ %@", order.billingAddress.firstName, order.billingAddress.lastName]];
    if (VALID_NOTEMPTY(order.billingAddress.address2, NSString)) {
        [self.billingAddress setText:[NSString stringWithFormat:@"%@, %@", order.billingAddress.address, order.billingAddress.address2]];
    }else{
        [self.billingAddress setText:order.billingAddress.address];
    }
    size = [self.billingAddress sizeThatFits:CGSizeMake(self.billingAddress.width, CGFLOAT_MAX)];
    [self.billingAddress setHeight:size.height];
    [self.billingCity setYBottomOf:self.billingAddress at:0.f];
    [self.billingCity setText:order.billingAddress.city];
    [self.billingPhone setYBottomOf:self.billingCity at:0.f];
    [self.billingPhone setText:order.billingAddress.phone];
    
    
    
    if (!VALID(self.horizontalCrossView.superview, UIView)) {
        [self addSubview:self.horizontalCrossView];
    }
    
    if (!VALID(self.verticalCrossView.superview, UIView)) {
        [self addSubview:self.verticalCrossView];
    }
    
    [self.orderDate setTextAlignment:NSTextAlignmentRight];
    [self.itemsNumberLabel setTextAlignment:NSTextAlignmentLeft];
    [self.paymentTitle setTextAlignment:NSTextAlignmentLeft];
    [self.paymentType setTextAlignment:NSTextAlignmentLeft];
    [self.paymentDescrition setTextAlignment:NSTextAlignmentLeft];
    [self.shippingTitle setTextAlignment:NSTextAlignmentLeft];
    [self.shippingName setTextAlignment:NSTextAlignmentLeft];
    [self.shippingAddress setTextAlignment:NSTextAlignmentLeft];
    [self.shippingCity setTextAlignment:NSTextAlignmentLeft];
    [self.shippingPhone setTextAlignment:NSTextAlignmentLeft];
    [self.billingTitle setTextAlignment:NSTextAlignmentLeft];
    [self.billingName setTextAlignment:NSTextAlignmentLeft];
    [self.billingAddress setTextAlignment:NSTextAlignmentLeft];
    [self.billingCity setTextAlignment:NSTextAlignmentLeft];
    [self.billingPhone setTextAlignment:NSTextAlignmentLeft];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

@end

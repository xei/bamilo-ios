//
//  JAOrderItemCollectionViewCell.m
//  Jumia
//
//  Created by Jose Mota on 08/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAOrderItemCollectionViewCell.h"
#import "UIImageView+WebCache.h"


#define kImageSize CGSizeMake(82, 103)

@interface JAOrderItemCollectionViewCell ()
{
    CGFloat _labelsLeftMargin;
    CGFloat _labelsWidth;
}

@property (nonatomic) UIImageView *productImageView;
@property (nonatomic) UILabel *brandLabel;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *sizeLabel;
@property (nonatomic) UILabel *qtyLabel;
@property (nonatomic) JAProductInfoPriceLine *priceLine;
@property (nonatomic) UIImageView *estimateDeliveryIcon;
@property (nonatomic) UILabel *estimateDeliveryLabel;
@property (nonatomic) UILabel *shipmentTitleLabel;
@property (nonatomic) UILabel *shipmentLabel;
@property (nonatomic) UILabel *returnsTitleLabel;
@property (nonatomic) UILabel *returnsLabel;

@end

@implementation JAOrderItemCollectionViewCell

- (JAClickableView *)feedbackView
{
    if (!VALID_NOTEMPTY(_feedbackView, JAClickableView)) {
        _feedbackView = [[JAClickableView alloc] init];
        [self addSubview:_feedbackView];
    }
    return _feedbackView;
}

- (UIImageView *)productImageView
{
    if (!VALID(_productImageView, UIImageView)) {
        _productImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0f, 16.0f, kImageSize.width, kImageSize.height)];
        [self addSubview:_productImageView];
    }
    return _productImageView;
}

- (UILabel *)brandLabel
{
    if (!VALID(_brandLabel, UILabel)) {
        _brandLabel = [[UILabel alloc] init];
        [_brandLabel setFont:JABodyFont];
        _brandLabel.textColor = JABlack800Color;
        [self addSubview:_brandLabel];
    }
    return _brandLabel;
}

- (UILabel *)nameLabel
{
    if (!VALID(_nameLabel, UILabel)) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:JATitleFont];
        _nameLabel.textColor = JABlackColor;
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel
{
    if (!VALID(_sizeLabel, UILabel)) {
        _sizeLabel = [[UILabel alloc] init];
        [_sizeLabel setFont:JABodyFont];
        _sizeLabel.textColor = JABlack800Color;
        [self addSubview:_sizeLabel];
    }
    return _sizeLabel;
}

- (UILabel *)qtyLabel
{
    if (!VALID(_qtyLabel, UILabel)) {
        _qtyLabel = [[UILabel alloc] init];
        [_qtyLabel setFont:JABodyFont];
        _qtyLabel.textColor = JABlack800Color;
        [self addSubview:_qtyLabel];
    }
    return _qtyLabel;
}

- (JAProductInfoPriceLine *)priceLine
{
    if (!VALID(_priceLine, JAProductInfoPriceLine)) {
        _priceLine = [[JAProductInfoPriceLine alloc] init];
        [_priceLine setPriceSize:JAPriceSizeSmall];
        [_priceLine setLineContentXOffset:0.f];
        [self addSubview:_priceLine];
    }
    return _priceLine;
}

- (UIImageView *)estimateDeliveryIcon
{
    if (!VALID(_estimateDeliveryIcon, UIImageView)) {
        _estimateDeliveryIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_delivery_orderstatus"]];
        [self addSubview:_estimateDeliveryIcon];
        if (RI_IS_RTL) {
            [_estimateDeliveryIcon flipViewImage];
        }
    }
    return _estimateDeliveryIcon;
}

- (UILabel *)estimateDeliveryLabel
{
    if (!VALID(_estimateDeliveryLabel, UILabel)) {
        _estimateDeliveryLabel = [[UILabel alloc] init];
        [_estimateDeliveryLabel setFont:JABodyFont];
        _estimateDeliveryLabel.textColor = JABlack800Color;
        [_estimateDeliveryLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_estimateDeliveryLabel];
    }
    return _estimateDeliveryLabel;
}

- (UILabel *)shipmentTitleLabel
{
    if (!VALID(_shipmentTitleLabel, UILabel)) {
        _shipmentTitleLabel = [UILabel new];
        [_shipmentTitleLabel setFont:JABADGEFont];
        [_shipmentTitleLabel setTextColor:JABlackColor];
        [_shipmentTitleLabel setText:[STRING_SHIPMENT uppercaseString]];
        [self addSubview:_shipmentTitleLabel];
    }
    return _shipmentTitleLabel;
}

- (UILabel *)shipmentLabel
{
    if (!VALID(_shipmentLabel, UILabel)) {
        _shipmentLabel = [UILabel new];
        [_shipmentLabel setFont:JACaptionFont];
        [_shipmentLabel setTextColor:JABlack800Color];
        [_shipmentLabel setNumberOfLines:0];
        [self addSubview:_shipmentLabel];
    }
    return _shipmentLabel;
}

- (UILabel *)returnsTitleLabel
{
    if (!VALID(_returnsTitleLabel, UILabel)) {
        _returnsTitleLabel = [UILabel new];
        [_returnsTitleLabel setFont:JABADGEFont];
        [_returnsTitleLabel setTextColor:JABlackColor];
        [_returnsTitleLabel setText:[STRING_RETURNS uppercaseString]];
        [self addSubview:_returnsTitleLabel];
    }
    return _returnsTitleLabel;
}

- (UILabel *)returnsLabel
{
    if (!VALID(_returnsLabel, UILabel)) {
        _returnsLabel = [UILabel new];
        [_returnsLabel setFont:JACaptionFont];
        [_returnsLabel setTextColor:JABlack800Color];
        [_returnsLabel setNumberOfLines:0];
        [self addSubview:_returnsLabel];
    }
    return _returnsLabel;
}

- (JAButton *)reorderButton
{
    if (!VALID(_reorderButton, JAButton)) {
        _reorderButton = [[JAButton alloc] initButtonWithTitle:[STRING_REORDER uppercaseString]];
        [_reorderButton.titleLabel setFont:JABUTTON2Font];
        [_reorderButton setWidth:120.f];
        [_reorderButton setHeight:36];
        [self addSubview:_reorderButton];
    }
    return _reorderButton;
}

- (JAButton *)returnButton
{
    if (!VALID(_returnButton, JAButton)) {
        _returnButton = [[JAButton alloc] initAlternativeButtonWithTitle:[STRING_RETURN uppercaseString]];
        [_returnButton.titleLabel setFont:JABUTTON2Font];
        [_returnButton setWidth:120.f];
        [_returnButton setHeight:36];
        [self addSubview:_returnButton];
    }
    return _returnButton;
}

- (UIButton *)checkToReturnButton
{
    if (!VALID(_checkToReturnButton, UIButton)) {
        _checkToReturnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"round_checkbox_deselected"];
        [_checkToReturnButton setWidth:image.size.width];
        [_checkToReturnButton setHeight:image.size.height];
        [_checkToReturnButton setImage:image forState:UIControlStateNormal];
        [_checkToReturnButton setImage:[UIImage imageNamed:@"round_checkbox_selected"] forState:UIControlStateSelected];
        [self addSubview:_checkToReturnButton];
    }
    return _checkToReturnButton;
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self.feedbackView setTag:tag];
    [self.reorderButton setTag:tag];
    [self.returnButton setTag:tag];
    [self.checkToReturnButton setTag:tag];
}

- (void)setItem:(RIItemCollection *)item
{
    [self.feedbackView setFrame:self.bounds];
    _labelsLeftMargin = self.productImageView.width + 2*6.f + 40;
    _labelsWidth = self.width - _labelsLeftMargin - 20;
    
    [self.reorderButton setWidth:[self.reorderButton sizeWithMaxWidth:self.width/2].width + 20.f];
    [self.reorderButton setYBottomAligned:10.f];
    [self.reorderButton setXRightAligned:16.f];
    [self.returnButton sizeToFit];
    [self.returnButton setYBottomAligned:10.f];
    [self.returnButton setX:16.f];
    if (item.onlineReturn) {
        [self.checkToReturnButton setHidden:NO];
        self.returnButton.hidden = NO;
        [self.returnButton setTitle:[STRING_RETURN uppercaseString] forState:UIControlStateNormal];
    }else if (item.callReturn){
        [self.checkToReturnButton setHidden:YES];
        self.returnButton.hidden = NO;
        [self.returnButton setTitle:[STRING_CALL_TO_RETURN uppercaseString] forState:UIControlStateNormal];
    }else{
        [self.checkToReturnButton setHidden:YES];
        self.returnButton.hidden = YES;
    }
    [self.returnButton setWidth:[self.returnButton sizeWithMaxWidth:self.width/2].width + 20.f];
    
    [self.productImageView setFrame:CGRectMake(46.0f, 16.0f, kImageSize.width, kImageSize.height)];
    [self.brandLabel setFrame:CGRectMake(_labelsLeftMargin, 16.f, _labelsWidth, 20)];
    [self.nameLabel setFrame:CGRectMake(_labelsLeftMargin, CGRectGetMaxY(self.brandLabel.frame), _labelsWidth, 20)];
    [self.sizeLabel setFrame:CGRectMake(_labelsLeftMargin, CGRectGetMaxY(self.nameLabel.frame), _labelsWidth, 15)];
    [self.qtyLabel setFrame:CGRectMake(_labelsLeftMargin, CGRectGetMaxY(self.sizeLabel.frame), _labelsWidth, 15)];
    [self.priceLine setFrame:CGRectMake(_labelsLeftMargin, CGRectGetMaxY(self.qtyLabel.frame), _labelsWidth, 15)];
    [self.estimateDeliveryIcon setFrame:CGRectMake(_labelsLeftMargin, CGRectGetMaxY(self.priceLine.frame)+6.f, self.estimateDeliveryIcon.width, self.estimateDeliveryIcon.height)];
    [self.estimateDeliveryLabel setTextAlignment:NSTextAlignmentLeft];
    [self.estimateDeliveryLabel setFrame:CGRectMake(CGRectGetMaxX(self.estimateDeliveryIcon.frame)+6.f, CGRectGetMaxY(self.priceLine.frame)+6.f, _labelsLeftMargin - self.estimateDeliveryIcon.width, self.estimateDeliveryIcon.height)];
    
    [self.brandLabel setText:item.brand];
    [self.brandLabel setTextAlignment:NSTextAlignmentLeft];
    [self.nameLabel setText:item.name];
    [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
    NSString *sizeString = @"";
    if (VALID(item.size, NSString)) {
        sizeString = [NSString stringWithFormat:STRING_SIZE_WITH_VALUE, item.size];
    }
    [self.sizeLabel setText:sizeString];
    [self.sizeLabel setTextAlignment:NSTextAlignmentLeft];
    [self.qtyLabel setText:[NSString stringWithFormat:STRING_QUANTITY, item.quantity]];
    [self.qtyLabel setTextAlignment:NSTextAlignmentLeft];
    [self.priceLine setTitle:item.totalFormatted];
    
    [self.checkToReturnButton setCenter:self.productImageView.center];
    [self.checkToReturnButton setX:16.f];
    
    [self.estimateDeliveryLabel setText:item.delivery];
    
    [self.shipmentTitleLabel setX:_labelsLeftMargin];
    CGSize size = [self.shipmentTitleLabel sizeThatFits:CGSizeMake(200.f, CGFLOAT_MAX)];
    [self.shipmentTitleLabel setHeight:size.height];
    [self.shipmentTitleLabel setWidth:size.width];
    [self.shipmentTitleLabel setYBottomOf:self.estimateDeliveryIcon at:6.f];
    [self.shipmentLabel setText:[NSString stringWithFormat:@"%@ %@", item.statusLabel, item.statusDate]];
    size = [self.shipmentLabel sizeThatFits:CGSizeMake(200.f, CGFLOAT_MAX)];
    [self.shipmentLabel setHeight:size.height];
    [self.shipmentLabel setWidth:size.width];
    [self.shipmentLabel setYBottomOf:self.shipmentTitleLabel at:0.f];
    [self.shipmentLabel setX:_labelsLeftMargin];
    
    
    [self.returnsTitleLabel setX:_labelsLeftMargin];
    size = [self.returnsTitleLabel sizeThatFits:CGSizeMake(200.f, CGFLOAT_MAX)];
    [self.returnsTitleLabel setHeight:size.height];
    [self.returnsTitleLabel setWidth:size.width];
    [self.returnsTitleLabel setYBottomOf:self.shipmentLabel at:6.f];
    
    NSMutableArray *returnActionStringArray = [NSMutableArray new];
    for (RIReturnAction *returnAction in item.returns) {
        [returnActionStringArray addObject:[NSString stringWithFormat:STRING_X_ITEMS_RETURNED_ON, returnAction.items.longValue, returnAction.lastChangeStatus]];
    }
    if (VALID_NOTEMPTY(returnActionStringArray, NSMutableArray)) {
        [self.returnsLabel setText:[returnActionStringArray componentsJoinedByString:@"\n"]];
        [self.returnsLabel setHidden:NO];
        [self.returnsTitleLabel setHidden:NO];
    }else{
        [self.returnsLabel setHidden:YES];
        [self.returnsTitleLabel setHidden:YES];
    }
    
    size = [self.returnsLabel sizeThatFits:CGSizeMake(200.f, CGFLOAT_MAX)];
    [self.returnsLabel setHeight:size.height];
    [self.returnsLabel setWidth:size.width];
    [self.returnsLabel setYBottomOf:self.returnsTitleLabel at:0.f];
    [self.returnsLabel setX:_labelsLeftMargin];
    
    [self.productImageView setImageWithURL:[NSURL URLWithString:item.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

@end

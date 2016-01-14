//
//  JAOrderItemCollectionViewCell.m
//  Jumia
//
//  Created by Jose Mota on 08/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAOrderItemCollectionViewCell.h"
#import "UIImageView+WebCache.h"


#define kImageSize CGSizeMake(68, 85)

@interface JAOrderItemCollectionViewCell ()
{
    CGFloat _labelsLeftMargin;
    CGFloat _labelsWidth;
}

@property (nonatomic) UIImageView *productImageView;
@property (nonatomic) UILabel *brandLabel;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *qtyLabel;
@property (nonatomic) JAProductInfoPriceLine *priceLine;
@property (nonatomic) UIImageView *estimateDeliveryIcon;
@property (nonatomic) UILabel *estimateDeliveryLabel;
@property (nonatomic) UILabel *deliveredLabel;

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
        [_brandLabel setFont:JACaptionFont];
        _brandLabel.textColor = UIColorFromRGB(0x808080);
        [self addSubview:_brandLabel];
    }
    return _brandLabel;
}

- (UILabel *)nameLabel
{
    if (!VALID(_nameLabel, UILabel)) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:JABody3Font];
        _nameLabel.textColor = UIColorFromRGB(0x000000);
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)qtyLabel
{
    if (!VALID(_qtyLabel, UILabel)) {
        _qtyLabel = [[UILabel alloc] init];
        [_qtyLabel setFont:JACaptionFont];
        _qtyLabel.textColor = UIColorFromRGB(0x808080);
        [self addSubview:_qtyLabel];
    }
    return _qtyLabel;
}

- (JAProductInfoPriceLine *)priceLine
{
    if (!VALID(_priceLine, JAProductInfoPriceLine)) {
        _priceLine = [[JAProductInfoPriceLine alloc] init];
        [_priceLine setPriceSize:kPriceSizeSmall];
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
        [_estimateDeliveryLabel setFont:[UIFont fontWithName:kFontRegularName size:10]];
        _estimateDeliveryLabel.textColor = UIColorFromRGB(0x808080);
        [self addSubview:_estimateDeliveryLabel];
    }
    return _estimateDeliveryLabel;
}

- (UILabel *)deliveredLabel
{
    if (!VALID(_deliveredLabel, UILabel)) {
        _deliveredLabel = [UILabel new];
        [_deliveredLabel setFont:[UIFont fontWithName:kFontRegularName size:10]];
        [_deliveredLabel setTextColor:JABlackColor];
        [_deliveredLabel setNumberOfLines:2];
        [self addSubview:_deliveredLabel];
    }
    return _deliveredLabel;
}

- (UIButton *)reorderButton
{
    if (!VALID(_reorderButton, UIButton)) {
        _reorderButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_reorderButton setTitle:[STRING_REORDER uppercaseString] forState:UIControlStateNormal];
        [_reorderButton.titleLabel setFont:JABody1Font];
        [_reorderButton setTintColor:JAOrange1Color];
        [self addSubview:_reorderButton];
    }
    return _reorderButton;
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self.feedbackView setTag:tag];
    [self.reorderButton setTag:tag];
}

- (void)setItem:(RIItemCollection *)item
{
    [self.feedbackView setFrame:self.bounds];
    _labelsLeftMargin = self.productImageView.width + 2*6.f;
    _labelsWidth = self.width - _labelsLeftMargin - 20;
    
    [self.reorderButton sizeToFit];
    [self.reorderButton setY:16.f];
    [self.reorderButton setXRightAligned:16.f];
    [self.productImageView setFrame:CGRectMake(6.0f, 16.0f, kImageSize.width, kImageSize.height)];
    [self.brandLabel setFrame:CGRectMake(_labelsLeftMargin, 16.f, _labelsWidth - self.reorderButton.width, 20)];
    [self.nameLabel setFrame:CGRectMake(_labelsLeftMargin, CGRectGetMaxY(self.brandLabel.frame), _labelsWidth, 20)];
    [self.qtyLabel setFrame:CGRectMake(_labelsLeftMargin, CGRectGetMaxY(self.nameLabel.frame), _labelsWidth, 15)];
    [self.priceLine setFrame:CGRectMake(_labelsLeftMargin, CGRectGetMaxY(self.qtyLabel.frame), _labelsWidth, 15)];
    [self.estimateDeliveryIcon setFrame:CGRectMake(_labelsLeftMargin, CGRectGetMaxY(self.priceLine.frame)+6.f, self.estimateDeliveryIcon.width, self.estimateDeliveryIcon.height)];
    [self.estimateDeliveryLabel setFrame:CGRectMake(CGRectGetMaxX(self.estimateDeliveryIcon.frame)+6.f, CGRectGetMaxY(self.priceLine.frame)+6.f, _labelsLeftMargin - self.estimateDeliveryIcon.width, self.estimateDeliveryIcon.height)];
    
    [self.brandLabel setText:item.brand];
    [self.brandLabel setTextAlignment:NSTextAlignmentLeft];
    [self.nameLabel setText:item.name];
    [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
    [self.qtyLabel setText:[NSString stringWithFormat:STRING_QUANTITY, item.quantity]];
    [self.qtyLabel setTextAlignment:NSTextAlignmentLeft];
    [self.priceLine setTitle:item.totalFormatted];
    [self.estimateDeliveryLabel setText:item.delivery];
    [self.deliveredLabel setText:[NSString stringWithFormat:@"%@\n%@", item.statusLabel, item.statusDate]];
    
    CGSize size = [self.deliveredLabel sizeThatFits:CGSizeMake(200.f, CGFLOAT_MAX)];
    [self.deliveredLabel setHeight:size.height];
    [self.deliveredLabel setWidth:size.width];
    [self.deliveredLabel setYBottomAligned:16.f];
    [self.deliveredLabel setXRightAligned:16.f];
    
    [self.productImageView setImageWithURL:[NSURL URLWithString:item.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

@end

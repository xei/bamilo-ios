//
//  JACartTableViewCell.m
//  Jumia
//
//  Created by Jose Mota on 13/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JACartTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface JACartTableViewCell () {
    CGFloat _lastWidth;
}

@end

@implementation JACartTableViewCell

- (JAClickableView *)feedbackView
{
    if (!VALID_NOTEMPTY(_feedbackView, JAClickableView)) {
        _feedbackView = [[JAClickableView alloc] initWithFrame:self.bounds];
    }
    return _feedbackView;
}

- (UIImageView *)productImageView
{
    if (!VALID_NOTEMPTY(_productImageView, UIImageView)) {
        _productImageView = [[UIImageView alloc] init];
    }
    return _productImageView;
}

- (UILabel *)brandLabel
{
    if (!VALID_NOTEMPTY(_brandLabel, UILabel)) {
        _brandLabel = [[UILabel alloc] init];
        [_brandLabel setFont:JACaptionFont];
        [_brandLabel setText:@"BrandLabel"];
        _brandLabel.textColor = JABlack800Color;
    }
    return _brandLabel;
}

- (UILabel *)nameLabel
{
    if (!VALID_NOTEMPTY(_nameLabel, UILabel)) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:JABodyFont];
        [_nameLabel setText:@"NameLabel"];
        _nameLabel.textColor = JABlackColor;
    }
    return _nameLabel;
}

- (UIImageView*)shopFirstImageView
{
    if (!VALID_NOTEMPTY(_shopFirstImageView, UIImageView)) {
        
        UIImage *shopFirstImage = [UIImage imageNamed:@"shop_first_logo"];
        _shopFirstImageView = [[UIImageView alloc] initWithImage:shopFirstImage];
        [_shopFirstImageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(shopFirstLogoTapped:)];
        [_shopFirstImageView addGestureRecognizer:singleTap];
    }
    return _shopFirstImageView;
}

- (UIView *)separatorView
{
    if (!VALID(_separatorView, UIView)) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(16.f, self.height-1, self.width-16.f, 1.f)];
        [_separatorView setBackgroundColor:JABlack400Color];
    }
    return _separatorView;
}

- (JADropdownControl *)quantityButton
{
    if (!VALID(_quantityButton, JADropdownControl)) {
        _quantityButton = [[JADropdownControl alloc] init];
        [_quantityButton.titleLabel setTextColor:JABlack800Color];
        [_quantityButton setTintColor:JABlack800Color];
        [_quantityButton setTintColor:JARed1Color];
        [_quantityButton.titleLabel setFont:JABodyFont];
        [_quantityButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    }
    return _quantityButton;
}

- (UILabel *)priceLabel
{
    if (!VALID(_priceLabel, UILabel)) {
        _priceLabel = [UILabel new];
        [_priceLabel setTextColor:JABlack800Color];
        [_priceLabel setFont:JABodyFont];
        [_priceLabel setTextAlignment:NSTextAlignmentRight];
    }
    return _priceLabel;
}

- (UILabel *)sizeLabel
{
    if (!VALID(_sizeLabel, UILabel)) {
        _sizeLabel = [UILabel new];
        [_sizeLabel setTextColor:JABlack800Color];
        [_sizeLabel setFont:JABodyFont];
        [_sizeLabel setTextAlignment:NSTextAlignmentLeft];
    }
    return _sizeLabel;
}

- (UIButton *)removeButton
{
    if (!VALID(_removeButton, UIButton)) {
        _removeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_removeButton.titleLabel setFont:JABUTTONFont];
        [_removeButton setTitle:[STRING_REMOVE uppercaseString] forState:UIControlStateNormal];
        [_removeButton setTitleColor:JABlue1Color forState:UIControlStateNormal];
        [_removeButton sizeToFit];
    }
    return _removeButton;
}

- (instancetype)init
{
    //    NSLog(@"init");
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    //    NSLog(@"initWithCoder");
    self = [super initWithCoder:coder];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    //    NSLog(@"initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)setTag:(NSInteger)tag
{
    [self.feedbackView setTag:tag];
    [self.removeButton setTag:tag];
    [self.quantityButton setTag:tag];
    [super setTag:tag];
}

- (void)initViews
{
    [self addSubview:self.feedbackView];
    [self addSubview:self.productImageView];
    [self addSubview:self.brandLabel];
    [self addSubview:self.nameLabel];
    [self addSubview:self.shopFirstImageView];
    [self addSubview:self.quantityButton];
    [self addSubview:self.priceLabel];
    [self addSubview:self.removeButton];
    [self addSubview:self.sizeLabel];
    [self addSubview:self.separatorView];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setClipsToBounds:YES];
}

- (void)reloadViews
{
    self.feedbackView.frame = self.bounds;
    _lastWidth = self.width;
    CGFloat distXImage = JACartListCellDistXImage;
    CGFloat marginAfterImage = JACartListCellDistXAfterImage;
    CGFloat distXAfterImage = JACartListCellImageSize.width + distXImage + marginAfterImage;
    CGFloat textWidth = self.width - distXAfterImage - distXImage;
    
    
    CGRect productImageViewRect = CGRectMake(distXImage, 10.f, JACartListCellImageSize.width, JACartListCellImageSize.height);
    if (!CGRectEqualToRect(productImageViewRect, self.productImageView.frame)) {
        [self.productImageView setFrame:productImageViewRect];
        [self setForRTL:self.productImageView];
    }
    
    CGRect brandLabelRect = CGRectMake(distXAfterImage, 10, textWidth, 15);
    if (!CGRectEqualToRect(brandLabelRect, self.brandLabel.frame)) {
        [self.brandLabel setTextAlignment:NSTextAlignmentLeft];
        [self.brandLabel setFrame:brandLabelRect];
        [self setForRTL:self.brandLabel];
    }
    
    [self.nameLabel setFont:JATitleFont];
    [self.nameLabel setNumberOfLines:1];
    CGRect nameLabelRect = CGRectMake(distXAfterImage, CGRectGetMaxY(brandLabelRect) + 1.0f, textWidth, 15);
    if (!CGRectEqualToRect(nameLabelRect, self.nameLabel.frame)) {
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setFrame:nameLabelRect];
        [self setForRTL:self.nameLabel];
    }
    
    CGRect shopFirstRect = CGRectMake(distXAfterImage, CGRectGetMaxY(nameLabelRect) + 6.f, self.shopFirstImageView.frame.size.width, self.shopFirstImageView.frame.size.height);
    if (!CGRectEqualToRect(shopFirstRect, self.self.shopFirstImageView.frame)) {
        [self.shopFirstImageView setFrame:shopFirstRect];
        [self setForRTL:self.shopFirstImageView];
    }
    
    CGRect quantityButtonRect = CGRectMake(distXAfterImage, CGRectGetMaxY(shopFirstRect) + 5.f, self.quantityButton.width, 16);
    if (!CGRectEqualToRect(quantityButtonRect, self.quantityButton.frame)) {
        [self.quantityButton setFrame:quantityButtonRect];
        [self setForRTL:self.quantityButton];
    }
    
    
    CGRect priceLabelRect = CGRectMake(distXAfterImage, CGRectGetMaxY(shopFirstRect) + 5.0f, textWidth, 16);
    if (!CGRectEqualToRect(priceLabelRect, self.priceLabel.frame)) {
        [self.priceLabel setTextAlignment:NSTextAlignmentRight];
        [self.priceLabel setFrame:priceLabelRect];
        [self setForRTL:self.priceLabel];
    }
    
    CGRect sizeLabelRect = CGRectMake(distXAfterImage, CGRectGetMaxY(priceLabelRect) + 6.0f, textWidth, self.removeButton.height);
    if (!CGRectEqualToRect(sizeLabelRect, self.sizeLabel.frame)) {
        [self.sizeLabel setTextAlignment:NSTextAlignmentLeft];
        [self.sizeLabel setFrame:sizeLabelRect];
        [self setForRTL:self.sizeLabel];
    }
    
    [self.removeButton setXRightAligned:16.f];
    [self.removeButton setY:self.sizeLabel.y];
    [self setForRTL:self.removeButton];
    
    
    [self.separatorView setFrame:CGRectMake(16.f, self.height-1, self.width-16.f, 1.f)];
    [self setForRTL:self.separatorView];
    
    _lastWidth = self.width;
}

- (void)setForRTL:(UIView *)view
{
    if (RI_IS_RTL) {
        [view flipViewPositionInsideSuperview];
        [view flipAllSubviews];
        if ([view isKindOfClass:[UILabel class]]) {
            if ([(UILabel *)view textAlignment] == NSTextAlignmentRight) {
                [(UILabel *)view setTextAlignment:NSTextAlignmentLeft];
            }else if ([(UILabel *)view textAlignment] == NSTextAlignmentLeft) {
                [(UILabel *)view setTextAlignment:NSTextAlignmentRight];
            }
        } else if ([view isKindOfClass:[UIButton class]] && [(UIButton*)view contentHorizontalAlignment] != UIControlContentHorizontalAlignmentCenter)
        {
            ((UIButton*)view).contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)setCartItem:(RICartItem *)cartItem
{
    _cartItem = cartItem;
    
    [self.brandLabel setText:cartItem.brand];
    [self.nameLabel setText:cartItem.name];
    
    [self.productImageView setImageWithURL:[NSURL URLWithString:cartItem.imageUrl]
                      placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    
    if (VALID_NOTEMPTY(cartItem.specialPrice, NSNumber)) {
        [self.priceLabel setText:[RICountryConfiguration formatPrice:cartItem.specialPrice country:[RICountryConfiguration getCurrentConfiguration]]];
    }else{
        [self.priceLabel setText:[RICountryConfiguration formatPrice:cartItem.price country:[RICountryConfiguration getCurrentConfiguration]]];
    }
    
    NSString *qtyString = [NSString stringWithFormat:STRING_QUANTITY, cartItem.quantity];
    NSInteger qtyPlaceholderLocation = [STRING_QUANTITY rangeOfString:@"%@"].location;
    NSRange qtyRange = [[qtyString substringFromIndex:qtyPlaceholderLocation] rangeOfString:cartItem.quantity.stringValue];
    qtyRange.location = qtyPlaceholderLocation;
    
    NSMutableAttributedString *quantityString = [[NSMutableAttributedString alloc] initWithString:qtyString];
    [quantityString addAttribute:NSForegroundColorAttributeName value:JABlackColor range:qtyRange];
    [quantityString addAttribute:NSFontAttributeName value:JAListFont range:qtyRange];
    [self.quantityButton setAttributedTitle:quantityString forState:UIControlStateNormal];
    [self.quantityButton sizeToFit];
    
    if (VALID_NOTEMPTY(cartItem.variation, NSString)) {
        NSString *szString = [NSString stringWithFormat:STRING_SIZE_WITH_VALUE, cartItem.variation];
        NSInteger sizePlaceholderLocation = [STRING_SIZE_WITH_VALUE rangeOfString:@"%@"].location;
        NSRange sizeRange = [[szString substringFromIndex:sizePlaceholderLocation] rangeOfString:cartItem.variation];
        sizeRange.location = sizePlaceholderLocation;
        
        NSMutableAttributedString *sizeString = [[NSMutableAttributedString alloc] initWithString:szString];
        [sizeString addAttribute:NSForegroundColorAttributeName value:JABlackColor range:sizeRange];
        [sizeString addAttribute:NSFontAttributeName value:JAListFont range:sizeRange];
        [self.sizeLabel setAttributedText:sizeString];
    }else{
        [self.sizeLabel setAttributedText:nil];
    }
    
    [self.shopFirstImageView setHidden:!cartItem.shopFirst.boolValue];
    [self reloadViews];
}

- (void)shopFirstLogoTapped:(UIGestureRecognizer *)gestureRecognizer
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:self.cartItem.shopFirstOverlayText
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end

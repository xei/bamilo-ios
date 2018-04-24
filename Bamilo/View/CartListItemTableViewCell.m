//
//  CartListItem.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartListItemTableViewCell.h"
#import "RICartItem.h"
#import "ImageManager.h"

@interface CartListItemTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@end

@implementation CartListItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.nameLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[Theme color:kColorDarkGray]];
    [self.quantityLabel applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorDarkGray]];
    [self.priceLabel applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorDarkGray]];
    [self.brandLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[Theme color:kColorLightGray]];
}

#pragma mark - Overrides
+ (CGFloat)cellHeight {
    return 95;
}

+ (NSString *)nibName {
    return @"CartListItemTableViewCell";
}

- (void)updateWithModel:(id)model {
    RICartItem *cartItem = (RICartItem *)model;
    
    self.nameLabel.text = cartItem.name;
    self.quantityLabel.text = [NSString stringWithFormat:STRING_QUANTITY, [cartItem.quantity.stringValue numbersToPersian]];
    self.priceLabel.text = cartItem.specialPriceFormatted ?: cartItem.priceFormatted;
    self.brandLabel.text = cartItem.brand;
    [self.itemImage sd_setImageWithURL:[ImageManager getCorrectedUrlForCartItemImageUrl:cartItem.imageUrl] placeholderImage:[ImageManager defaultPlaceholder]];
}

@end

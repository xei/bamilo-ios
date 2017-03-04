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

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.nameLabel applyStyle:kFontRegularName fontSize:12.0f color:cDARK_GRAY_COLOR];
    [self.quantityLabel applyStyle:kFontRegularName fontSize:11.0f color:cDARK_GRAY_COLOR];
    [self.priceLabel applyStyle:kFontRegularName fontSize:11.0f color:cDARK_GRAY_COLOR];
    [self.brandLabel applyStyle:kFontRegularName fontSize:12.0f color:cLIGHT_GRAY_COLOR];
}

#pragma mark - Overrides
+(CGFloat)cellHeight {
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

//
//  OrderProductListTableViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 3/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderProductListTableViewCell.h"
#import "ImageManager.h"
#import "IconButton.h"

@interface OrderProductListTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet IconButton *commentButton;

@end

@implementation OrderProductListTableViewCell {
@private OrderProduct *product;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.priceLabel applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorLightGray]];
    [self.quantityLabel applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorLightGray]];
    [self.productTitleLabel applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorLightGray]];
    [self.commentButton applyStyle:[Theme font:kFontVariationBold size:11.0f] color:[UIColor whiteColor]];
    [self.statusLabel applyStyle:[Theme font:kFontVariationBold size:11.0f] color:[Theme color:kColorExtraDarkGray]];
    
    [self.commentButton setBackgroundColor:[Theme color:kColorExtraDarkBlue]];
}

- (void)updateWithModel:(id)model {
    if (![model isKindOfClass:[OrderProduct class]]) {
        return;
    }
    product = model;
    
    self.statusLabel.text = product.status.label;
    self.productTitleLabel.text = product.name;
    self.priceLabel.text = [product.formatedPrice numbersToPersian];
    self.quantityLabel.text = [[NSString stringWithFormat:@"%@: %@", STRING_ORDER_QUANTITY, product.quantity] numbersToPersian];
    [self.productImage sd_setImageWithURL:[ImageManager getCorrectedUrlForCartItemImageUrl:product.imageURL] placeholderImage:[ImageManager defaultPlaceholder]];
}
- (IBAction)reviewButtonTapped:(id)sender {
    [self.delegate needsToShowProductReviewForProduct:product];
}

@end

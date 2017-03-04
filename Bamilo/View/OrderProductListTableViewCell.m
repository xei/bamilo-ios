//
//  OrderProductListTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 3/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderProductListTableViewCell.h"
#import "OrderProduct.h"
#import "ImageManager.h"

@interface OrderProductListTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation OrderProductListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateWithModel:(id)model {
    if (![model isKindOfClass:[OrderProduct class]]) {
        return;
    }
    OrderProduct *product = model;
    
    self.productTitleLabel.text = product.name;
    self.priceLabel.text = [[NSString stringWithFormat:@"%@: %@", STRING_PRICE, product.formatedPrice] numbersToPersian];
    self.quantityLabel.text = [[NSString stringWithFormat:@"%@: %@", STRING_ORDER_QUANTITY, product.quantity] numbersToPersian];
    [self.productImage sd_setImageWithURL:[ImageManager getCorrectedUrlForCartItemImageUrl:product.imageURL] placeholderImage:[ImageManager defaultPlaceholder]];
}

@end

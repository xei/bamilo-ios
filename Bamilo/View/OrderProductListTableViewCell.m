//
//  OrderProductListTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 3/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderProductListTableViewCell.h"
#import "ImageManager.h"
#import "IconButton.h"

#define cBLUE_COLOR [UIColor withHexString:@"4A90E2"]

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
    [self.priceLabel applyStyle:kFontRegularName fontSize:9 color:cLIGHT_GRAY_COLOR];
    [self.quantityLabel applyStyle:kFontRegularName fontSize:9 color:cLIGHT_GRAY_COLOR];
    [self.productTitleLabel applyStyle:kFontRegularName fontSize:9 color:cLIGHT_GRAY_COLOR];
    [self.commentButton applyStyle:kFontBoldName fontSize:10 color:[UIColor whiteColor]];
    [self.commentButton setBackgroundColor:cBLUE_COLOR];
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

//
//  CartTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartTableViewCell.h"
#import "NSString+Extensions.h"
#import "StepperViewControl.h"
#import "UIImageView+WebCache.h"


@interface CartTableViewCell () <StepperViewControlDelegate>
@property (nonatomic, weak) IBOutlet UILabel *discountValue;
@property (nonatomic, weak) IBOutlet UIButton *brandLabelButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel;
@property (nonatomic, weak) IBOutlet UILabel *productColorLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *colorLabelDismessConstraint;
@property (nonatomic, weak) IBOutlet StepperViewControl *stepper;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *discountLabel;
@property (nonatomic, weak) IBOutlet UIImageView *itemImage;
@end

@implementation CartTableViewCell

- (void)setCartItem:(RICartItem *)cartItem {
    _cartItem = cartItem;
    self.brandLabelButton.titleLabel.text = cartItem.brand;
    self.nameLabel.text = cartItem.name;
    
    //-------- this code must be implemented in server side not here! (refactor)
    NSString *imageUrl = [cartItem.imageUrl stringByReplacingOccurrencesOfString:@"cart" withString:@"catalog_grid_3"];
    
    
    [self.itemImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    self.stepper.quantity = cartItem.quantity.intValue;
    self.stepper.maxQuantity = cartItem.maxQuantity.intValue;
    NSString *realPrice = cartItem.priceFormatted;
    NSString *specialPrice = cartItem.specialPriceFormatted;
    self.priceLabel.text = specialPrice ?: realPrice;
    self.discountLabel.text = specialPrice ? realPrice : nil;
    self.discountValue.attributedText = [self.discountValue.text struckThroughText];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.stepper.delegate = self;
}

+ (NSString *)nibName {
    return @"CartTableViewCell";
}



- (void)quantityChangeTo:(int)newQuantity {
    NSMutableDictionary *quantitiesToChange = [[NSMutableDictionary alloc] init];
    [quantitiesToChange setValue:[NSString stringWithFormat:@"%d", newQuantity] forKey:@"quantity"];
    [quantitiesToChange setValue:[self.cartItem simpleSku] forKey:@"sku"];
    [self.delegate quantityWillChangeTo:newQuantity withCell:self];
    [RICart changeQuantityInProducts:quantitiesToChange
                    withSuccessBlock:^(RICart *cart) {
                        [self.delegate quantityHasBeenChangedTo:newQuantity withNewCart:cart withCell:self];
                    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                        [self.delegate quantityHasBeenChangedTo:newQuantity withErrorMessages:errorMessages withCell:self];
                    }];
}

- (IBAction)gotoCartItemProduct:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName: kDidSelectTeaserWithPDVUrlNofication
                                                        object: nil
                                                      userInfo: @{
                                                                  @"sku" : self.cartItem.sku,
                                                                  @"previousCategory" : STRING_CART,
                                                                  @"show_back_button" : [NSNumber numberWithBool:NO]
                                                                  }];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:[NSString stringWithFormat:@"cart_%@",self.cartItem.name]];
}

- (void)prepareForReuse {
    self.brandLabelButton.titleLabel.text = nil;
    self.nameLabel.text = nil;
    self.itemImage.image = nil;
    self.stepper.quantity = 0;
    self.stepper.maxQuantity = 0;
    self.priceLabel.text = nil;
    self.discountLabel.text = nil;
    self.discountValue.attributedText = nil;
}

- (IBAction)removeBtnTapped:(id)sender {
    [self.delegate wantsToRemoveCartItem:self.cartItem byCell:self];
}

- (IBAction)likeBtnTapped:(id)sender {
    [self.delegate wantsToLikeCartItem:self.cartItem byCell:self];
}

#pragma StepperViewController Delegate
- (void)valueHasBeenChanged:(id)stepperViewControl withNewValue:(int)value {
    [self quantityChangeTo:value];
}

@end

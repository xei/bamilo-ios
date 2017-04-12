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
#import "ImageManager.h"


@interface CartTableViewCell () <StepperViewControlDelegate>
@property (nonatomic, weak) IBOutlet UILabel *discountValue;
@property (nonatomic, weak) IBOutlet UIButton *brandLabelButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sizeLabel;
@property (nonatomic, weak) IBOutlet UILabel *productColorLabel;
@property (nonatomic, weak) IBOutlet StepperViewControl *stepper;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeLabelHeightConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *itemImage;
@end

@implementation CartTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView setBackgroundColor: [UIColor withHexString:@"EEF2F6"]];
    self.stepper.delegate = self;
}

- (void)setCartItem:(RICartItem *)cartItem {
    _cartItem = cartItem;
    [self.brandLabelButton setTitle:cartItem.brand forState:UIControlStateNormal];
    self.nameLabel.text = cartItem.name;
    
    [self.itemImage sd_setImageWithURL:[ImageManager getCorrectedUrlForCartItemImageUrl:cartItem.imageUrl] placeholderImage:[ImageManager defaultPlaceholder]];
    self.stepper.quantity = cartItem.quantity.intValue;
    self.stepper.maxQuantity = cartItem.maxQuantity.intValue;
    self.stepper.minQuantity = 1;
    NSString *realPrice = cartItem.priceFormatted;
    NSString *specialPrice = cartItem.specialPriceFormatted;
    self.priceLabel.text = specialPrice ?: realPrice;
    
    self.discountValue.attributedText = (NSAttributedString *)[(specialPrice ? realPrice : nil) struckThroughText];
    
    if (cartItem.variation && [cartItem.variationName isEqualToString:@"size"]) {
        self.sizeLabel.text = [[NSString stringWithFormat:@"اندازه:‌%@", cartItem.variation] numbersToPersian];
        self.sizeLabelHeightConstraint.constant = 10;
    } else {
        self.sizeLabel.text = nil;
        self.sizeLabelHeightConstraint.constant = 0;
    }
    
    self.productColorLabel.text = nil;
}

+ (NSString *)nibName {
    return @"CartTableViewCell";
}



- (void)quantityChangeTo:(int)newQuantity {
    NSMutableDictionary *quantitiesToChange = [[NSMutableDictionary alloc] init];
    [quantitiesToChange setValue:[NSString stringWithFormat:@"%d", newQuantity] forKey:@"quantity"];
    [quantitiesToChange setValue:[self.cartItem simpleSku] forKey:@"sku"];
    if ([self.delegate respondsToSelector:@selector(quantityWillChangeTo:withCell:)]) {
        [self.delegate quantityWillChangeTo:newQuantity withCell:self];
    }
    [RICart changeQuantityInProducts:quantitiesToChange
                    withSuccessBlock:^(RICart *cart) {
                        if ([self.delegate respondsToSelector:@selector(quantityHasBeenChangedTo:withNewCart:withCell:)]) {
                            [self.delegate quantityHasBeenChangedTo:newQuantity withNewCart:cart withCell:self];
                        }
                    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                        if ([self.delegate respondsToSelector:@selector(quantityHasBeenChangedTo:withErrorMessages:withCell:)]) {
                            [self.delegate quantityHasBeenChangedTo:newQuantity withErrorMessages:errorMessages withCell:self];
                        }
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
    [self.brandLabelButton setTitle:nil forState:UIControlStateNormal];
    self.nameLabel.text = nil;
    self.itemImage.image = nil;
    self.stepper.quantity = 0;
    self.stepper.maxQuantity = 0;
    self.priceLabel.text = nil;
    self.discountLabel.text = nil;
    self.discountValue.attributedText = nil;
}

- (IBAction)removeBtnTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(wantsToRemoveCartItem:byCell:)]) {
        [self.delegate wantsToRemoveCartItem:self.cartItem byCell:self];
    }
}

- (IBAction)likeBtnTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(wantsToLikeCartItem:byCell:)]) {
        [self.delegate wantsToLikeCartItem:self.cartItem byCell:self];
    }
}

#pragma StepperViewController Delegate
- (void)valueHasBeenChanged:(id)stepperViewControl withNewValue:(int)value {
    [self quantityChangeTo:value];
}

- (void)wantsToBeMoreThanMax:(id)stepperViewControl {
    if ([self.delegate respondsToSelector:@selector(wantToIncreaseCartItemCountMoreThanMax:byCell:)]) {
        [self.delegate wantToIncreaseCartItemCountMoreThanMax:self.cartItem byCell:self];
    }
}

- (void)wantsToBeLessThanMin:(id)stepperViewControl {
    
}

@end

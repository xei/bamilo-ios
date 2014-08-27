//
//  JACartViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@class JAPriceView;
@class RICart;
@class RICartItem;

@interface JACartViewController : JABaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) RICart *cart;
@property (strong, nonatomic) RICartItem *currentItem;

// Empty cart views
@property (weak, nonatomic) IBOutlet UIView *emptyCartView;
@property (weak, nonatomic) IBOutlet UILabel *emptyCartLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingButton;

// Cart views
@property (strong, nonatomic) UIScrollView *cartScrollView;

// Products
@property (strong, nonatomic) UICollectionView *productCollectionView;

// Coupon
@property (strong, nonatomic) UIView *couponView;
@property (strong, nonatomic) UILabel *couponTitle;
@property (strong, nonatomic) UIView *couponTitleSeparator;
@property (strong, nonatomic) UITextField *couponTextField;
@property (strong, nonatomic) UIButton *useCouponButton;

// Subtotal
@property (strong, nonatomic) UIView *subtotalView;
@property (strong, nonatomic) UILabel *subtotalTitle;
@property (strong, nonatomic) UIView *subtotalTitleSeparator;
@property (strong, nonatomic) UILabel *articlesCount;
@property (strong, nonatomic) JAPriceView *totalPriceView;
@property (strong, nonatomic) UILabel *priceRulesLabel;
@property (strong, nonatomic) UILabel *priceRulesValue;
@property (strong, nonatomic) UILabel *cartVatLabel;
@property (strong, nonatomic) UILabel *cartVatValue;
@property (strong, nonatomic) UILabel *cartShippingLabel;
@property (strong, nonatomic) UILabel *cartShippingValue;
@property (strong, nonatomic) UILabel *extraCostsLabel;
@property (strong, nonatomic) UILabel *extraCostsValue;
@property (strong, nonatomic) UILabel *couponLabel;
@property (strong, nonatomic) UILabel *couponValue;
@property (strong, nonatomic) UILabel *totalLabel;
@property (strong, nonatomic) UILabel *totalValue;
@property (strong, nonatomic) NSLayoutConstraint *subtotalViewConstrain;

@property (strong, nonatomic) UIButton *checkoutButton;
@property (strong, nonatomic) UIButton *callToOrderButton;

// quantity picker view
@property (strong, nonatomic) UIView *quantityPickerBackgroundView;
@property (strong, nonatomic) UIToolbar *quantityPickerToolbar;
@property (strong, nonatomic) UIPickerView *quantityPicker;

@end

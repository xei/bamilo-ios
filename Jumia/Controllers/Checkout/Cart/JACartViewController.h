//
//  JACartViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RICart.h"

@interface JACartViewController : JABaseViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) RICart *cart;

// Empty cart views
@property (weak, nonatomic) IBOutlet UIView *emptyCartView;
@property (weak, nonatomic) IBOutlet UILabel *emptyCartLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingButton;

// Cart views
@property (weak, nonatomic) IBOutlet UIScrollView *cartScrollView;

// Products
@property (weak, nonatomic) IBOutlet UICollectionView *productCollectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *productTableViewConstrain;


// Coupon
@property (weak, nonatomic) IBOutlet UIView *couponView;
@property (weak, nonatomic) IBOutlet UILabel *couponTitle;
@property (weak, nonatomic) IBOutlet UIView *couponTitleSeparator;
@property (weak, nonatomic) IBOutlet UITextField *couponTextField;
@property (weak, nonatomic) IBOutlet UIButton *useCouponButton;

// Subtotal
@property (weak, nonatomic) IBOutlet UIView *subtotalView;
@property (weak, nonatomic) IBOutlet UILabel *subtotalTitle;
@property (weak, nonatomic) IBOutlet UIView *subtotalTitleSeparator;
@property (weak, nonatomic) IBOutlet UILabel *articlesCount;
@property (weak, nonatomic) IBOutlet UILabel *cartPrice;
@property (weak, nonatomic) IBOutlet UILabel *cartVatLabel;
@property (weak, nonatomic) IBOutlet UILabel *cartVatValue;
@property (weak, nonatomic) IBOutlet UILabel *cartShippingLabel;
@property (weak, nonatomic) IBOutlet UILabel *cartShippingValue;
@property (weak, nonatomic) IBOutlet UILabel *extraCostsLabel;
@property (weak, nonatomic) IBOutlet UILabel *extraCostsValue;
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponValue;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalValue;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *subtotalViewConstrain;


@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UIButton *callToOrderButton;

@end

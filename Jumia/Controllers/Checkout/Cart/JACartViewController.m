//
//  JACartViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACartViewController.h"
#import "JALoginViewController.h"
#import "JAAddressesViewController.h"
#import "JACatalogListCell.h"
#import "JAPDVViewController.h"
#import "JAConstants.h"
#import "RIForm.h"
#import "RIField.h"
#import "RICartItem.h"
#import "RICustomer.h"

@implementation JACartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = JABackgroundGrey;
    
    [self.emptyCartView setHidden:YES];
    [self.emptyCartLabel setHidden:YES];
    [self.continueShoppingButton setHidden:YES];
    [self.cartScrollView setHidden:YES];
    
    UINib *cartListCellNib = [UINib nibWithNibName:@"JACartListCell" bundle:nil];
    [self.productCollectionView registerNib:cartListCellNib forCellWithReuseIdentifier:@"cartListCell"];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, 90.0f);
    [flowLayout setHeaderReferenceSize:CGSizeMake(308.0f, 26.0f)];
    [self.productCollectionView setCollectionViewLayout:flowLayout];
    
    [self.productCollectionView setDataSource:self];
    [self.productCollectionView setDelegate:self];
    
    [self showLoading];
    [RICart getCartWithSuccessBlock:^(RICart *cartData) {
        self.cart = cartData;
        [self loadCartInfo];
        [self hideLoading];
    } andFailureBlock:^(NSArray *errorMessages) {
        [self setupEmptyCart];
        [self hideLoading];
    }];
}

- (void)loadCartInfo
{
    if(0 == [[self.cart cartCount] integerValue])
    {
        [self setupEmptyCart];
    }
    else
    {
        [self setupCart];
    }
}

-(void)setupEmptyCart
{
    [self.emptyCartView setHidden:NO];
    [self.emptyCartLabel setHidden:NO];
    [self.continueShoppingButton setHidden:NO];
    
    [self.cartScrollView setHidden:YES];
    
    self.emptyCartView.layer.cornerRadius = 5.0f;
    [self.emptyCartLabel setText:@"You have no items in the cart"];
    [self.emptyCartLabel setTextColor:JALabelGrey];
    
    [self.continueShoppingButton setTitleColor:JAButtonTextOrange forState:UIControlStateNormal];
    [self.continueShoppingButton setTitle:@"Continue Shopping" forState:UIControlStateNormal];
    
    self.continueShoppingButton.layer.cornerRadius = 5.0f;
    
    [self.continueShoppingButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setupCart
{
    [self.emptyCartView setHidden:YES];
    [self.emptyCartLabel setHidden:YES];
    [self.continueShoppingButton setHidden:YES];
    
    [self.cartScrollView setHidden:NO];
    
    self.productCollectionView.layer.cornerRadius = 5.0f;
    self.productTableViewConstrain.constant = ([[self.cart cartCount] integerValue] * 90.0f) + 26.0f;
    
    // coupon
    self.couponView.layer.cornerRadius = 5.0f;
    [self.couponTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.couponTitleSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.couponTitle setText:@"Coupon"];
    [self.couponTextField setPlaceholder:@"Enter your coupon code here"];
    [self.couponTextField setTextColor:UIColorFromRGB(0xcccccc)];
    [self.useCouponButton setTitle:@"Use" forState:UIControlStateNormal];
    [self.useCouponButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.useCouponButton addTarget:self action:@selector(useCouponButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // subtotal
    self.subtotalView.layer.cornerRadius = 5.0f;
    [self.subtotalTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.subtotalTitleSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.subtotalTitle setText:@"Subtotal"];
    
    [self.articlesCount setTextColor:UIColorFromRGB(0x666666)];
    NSInteger cartCount = [[[self cart] cartCount] integerValue];
    if(1 == cartCount)
    {
        [self.articlesCount setText:@"1 article"];
    }
    else
    {
        [self.articlesCount setText:[NSString stringWithFormat:@"%d articles", cartCount]];
    }
    
#warning check prices
    [self.cartPrice setTextColor:UIColorFromRGB(0x666666)];
    [self.cartPrice setText:[[[self cart] cartCleanValue] stringValue]];
    
    // Check all values from products and put it if there is at least one with discount
    
    [self.cartVatLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.cartVatLabel setText:@"VAT"];
    [self.cartVatLabel setFrame:CGRectMake(self.cartVatLabel.frame.origin.x,
                                           CGRectGetMaxY(self.articlesCount.frame) + 4.0f,
                                           self.cartVatLabel.frame.size.width,
                                           self.cartVatLabel.frame.size.height)];
    
    
    [self.cartVatValue setTextColor:UIColorFromRGB(0x666666)];
    [self.cartVatValue setText:[[[self cart] vatValue] stringValue]];
    [self.cartVatValue setFrame:CGRectMake(self.cartVatValue.frame.origin.x,
                                           CGRectGetMaxY(self.cartPrice.frame) + 4.0f,
                                           self.cartVatValue.frame.size.width,
                                           self.cartVatValue.frame.size.height)];
    
    
    [self.cartShippingLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.cartShippingLabel setText:@"Shipping"];
    [self.cartShippingLabel setFrame:CGRectMake(self.cartShippingLabel.frame.origin.x,
                                                CGRectGetMaxY(self.cartVatLabel.frame),
                                                self.cartShippingLabel.frame.size.width,
                                                self.cartShippingLabel.frame.size.height)];
    
    [self.cartShippingValue setTextColor:UIColorFromRGB(0x666666)];
    if(0.0f == [[[self cart] shippingValue] floatValue])
    {
        [self.cartShippingValue setText:@"Free"];
    }
    else
    {
        [self.cartShippingValue setText:[[[self cart] shippingValue] stringValue]];
    }
    [self.cartShippingValue setFrame:CGRectMake(self.cartShippingValue.frame.origin.x,
                                                CGRectGetMaxY(self.cartVatValue.frame),
                                                self.cartShippingValue.frame.size.width,
                                                self.cartShippingValue.frame.size.height)];
    
    [self.extraCostsLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.extraCostsLabel setText:@"Extra Costs"];
    [self.extraCostsLabel setFrame:CGRectMake(self.extraCostsLabel.frame.origin.x,
                                              CGRectGetMaxY(self.cartShippingLabel.frame),
                                              self.extraCostsLabel.frame.size.width,
                                              self.extraCostsLabel.frame.size.height)];
    
    [self.extraCostsValue setTextColor:UIColorFromRGB(0x666666)];
    [self.extraCostsValue setText:[[[self cart] extraCosts] stringValue]];
    [self.extraCostsValue setFrame:CGRectMake(self.extraCostsValue.frame.origin.x,
                                              CGRectGetMaxY(self.cartShippingValue.frame),
                                              self.extraCostsValue.frame.size.width,
                                              self.extraCostsValue.frame.size.height)];
    
    
    [self.totalLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.totalLabel setText:@"Total"];
    
    [self.totalValue setTextColor:UIColorFromRGB(0x666666)];
    [self.totalValue setText:[[[self cart] cartValue] stringValue]];
    
    [self.couponLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.couponLabel setText:@"Coupon"];
    
    [self.couponValue setTextColor:UIColorFromRGB(0x666666)];
    [self.couponValue setText:[[[self cart] couponMoneyValue] stringValue]];
    
    if(VALID_NOTEMPTY([[self cart] couponMoneyValue], NSNumber) && 0.0f > [[[self cart] couponMoneyValue] floatValue])
    {
        [self.couponLabel setHidden:NO];
        [self.couponLabel setFrame:CGRectMake(self.couponLabel.frame.origin.x,
                                              CGRectGetMaxY(self.extraCostsLabel.frame),
                                              self.couponLabel.frame.size.width,
                                              self.couponLabel.frame.size.height)];
        [self.totalLabel setFrame:CGRectMake(self.totalLabel.frame.origin.x,
                                             CGRectGetMaxY(self.couponLabel.frame) + 4.0f,
                                             self.totalLabel.frame.size.width,
                                             self.totalLabel.frame.size.height)];
        
        
        [self.couponValue setHidden:NO];
        [self.couponValue setFrame:CGRectMake(self.couponValue.frame.origin.x,
                                              CGRectGetMaxY(self.extraCostsValue.frame),
                                              self.couponValue.frame.size.width,
                                              self.couponValue.frame.size.height)];
        [self.totalValue setFrame:CGRectMake(self.totalValue.frame.origin.x,
                                             CGRectGetMaxY(self.couponValue.frame) + 4.0f,
                                             self.totalValue.frame.size.width,
                                             self.totalValue.frame.size.height)];
    }
    else
    {
        [self.totalLabel setFrame:CGRectMake(self.totalLabel.frame.origin.x,
                                             CGRectGetMaxY(self.extraCostsLabel.frame) + 4.0f,
                                             self.totalLabel.frame.size.width,
                                             self.totalLabel.frame.size.height)];
        
        [self.totalValue setFrame:CGRectMake(self.totalValue.frame.origin.x,
                                             CGRectGetMaxY(self.extraCostsValue.frame) + 4.0f,
                                             self.totalValue.frame.size.width,
                                             self.totalValue.frame.size.height)];
    }
    
    self.subtotalViewConstrain.constant = CGRectGetMaxY(self.totalValue.frame) + 9.0f;
    
    [self.checkoutButton setTitle:@"Proceed to Checkout" forState:UIControlStateNormal];
    [self.checkoutButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.checkoutButton addTarget:self action:@selector(checkoutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.callToOrderButton setTitle:@"Call to Order" forState:UIControlStateNormal];
    [self.callToOrderButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.callToOrderButton addTarget:self action:@selector(callToOrderButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.cartScrollView setContentSize:CGSizeMake(320.0f, CGRectGetMaxY(self.callToOrderButton.frame) + 6.0f)];
}

-(void)goToHomeScreen
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

- (void)removeFromCartPressed:(UIButton*)button
{
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartItems, NSDictionary))
    {
        NSArray *cartItemsKeys = [self.cart.cartItems allKeys];
        NSString *key = [cartItemsKeys objectAtIndex:button.tag];
        RICartItem *product = [self.cart.cartItems objectForKey:key];
        
        [self showLoading];
        [RICart removeProductWithQuantity:[product.quantity stringValue]
                                      sku:product.simpleSku
                         withSuccessBlock:^(RICart *cart) {
                             self.cart = cart;
                             
                             NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                             [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                             
                             [self loadCartInfo];
                             
                             [self hideLoading];
                         } andFailureBlock:^(NSArray *errorMessages) {
                             [self hideLoading];
                         }];
    }
}

- (void)quantityPressed:(UIButton*)button
{
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartItems, NSDictionary))
    {
        NSArray *cartItemsKeys = [self.cart.cartItems allKeys];
        NSString *key = [cartItemsKeys objectAtIndex:button.tag];
        RICartItem *product = [self.cart.cartItems objectForKey:key];
        
        
    }
}

- (void)useCouponButtonPressed
{
    [self showLoading];
    NSString *voucherCode = [self.couponTextField text];
    [RICart addVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
        self.cart = cart;
        [self setupCart];
        [self hideLoading];
    } andFailureBlock:^(NSArray *errorMessages) {
        [self hideLoading];
        
#warning talk to jose
        [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                    message:@"Please imnput a valid Coupon Code"
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
    }];
}

- (void)checkoutButtonPressed
{
    if([RICustomer checkIfUserIsLogged])
    {
        JAAddressesViewController *addressesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesViewController"];
        
        [self.navigationController pushViewController:addressesVC
                                             animated:YES];
    }
    else
    {
        JALoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        
        [self.navigationController pushViewController:loginVC
                                             animated:YES];
    }
}

- (void)callToOrderButtonPressed
{
    [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
        UIDevice *device = [UIDevice currentDevice];
        if ([[device model] isEqualToString:@"iPhone"] ) {
            NSString *phoneNumber = [@"tel://" stringByAppendingString:configuration.phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }
    } andFailureBlock:^(NSArray *errorMessages) {
    }];
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = 0;
    if(VALID_NOTEMPTY(self.cart, RICart))
    {
        numberOfItemsInSection = [[self.cart cartCount] integerValue];
    }
    
    return numberOfItemsInSection;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JACatalogListCell *cell = nil;
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartItems, NSDictionary) && indexPath.row < [self.cart.cartCount integerValue])
    {
        NSArray *cartItemsKeys = [self.cart.cartItems allKeys];
        NSString *key = [cartItemsKeys objectAtIndex:indexPath.row];
        RICartItem *product = [self.cart.cartItems objectForKey:key];
        
        NSString *cellIdentifier = @"cartListCell";
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell loadWithCartItem:product];
        
        cell.quantityButton.tag = indexPath.row;
        [cell.quantityButton addTarget:self
                                action:@selector(quantityPressed:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        cell.deleteButton.tag = indexPath.row;
        [cell.deleteButton addTarget:self
                              action:@selector(removeFromCartPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        [cell.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
        
        if(indexPath.row < ([self.cart.cartCount integerValue] - 1))
        {
            [cell.separator setHidden:NO];
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader" forIndexPath:indexPath];
        
        [headerView setBackgroundColor:[UIColor redColor]];
        
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartItems, NSDictionary) && indexPath.row < [self.cart.cartCount integerValue])
    {
        NSArray *cartItemsKeys = [self.cart.cartItems allKeys];
        NSString *key = [cartItemsKeys objectAtIndex:indexPath.row];
        RICartItem *product = [self.cart.cartItems objectForKey:key];
        
        JAPDVViewController *pdv = [self.storyboard instantiateViewControllerWithIdentifier:@"pdvViewController"];
        pdv.productUrl = product.productUrl;
        pdv.fromCatalogue = NO;
        pdv.previousCategory = @"Cart";
        
        [self.navigationController pushViewController:pdv
                                             animated:YES];
    }
}

@end

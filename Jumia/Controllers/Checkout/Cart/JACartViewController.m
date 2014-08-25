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
#import "JACartListHeaderView.h"
#import "RIForm.h"
#import "RIField.h"
#import "RICart.h"
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
    
    NSArray *cartItemsKeys = [self.cart.cartItems allKeys];
    self.productCollectionView.layer.cornerRadius = 5.0f;
    self.productTableViewConstrain.constant = ([cartItemsKeys count] * 90.0f) + 26.0f;
    [self.productCollectionView reloadData];
    
    // coupon
    self.couponView.layer.cornerRadius = 5.0f;
    [self.couponView layoutIfNeeded];
    [self.couponTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.couponTitleSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.couponTitle setText:@"Coupon"];
    [self.couponTextField setPlaceholder:@"Enter your coupon code here"];
    [self.couponTextField setDelegate:self];
    [self.useCouponButton setTitle:@"Use" forState:UIControlStateNormal];
    [self.useCouponButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.useCouponButton addTarget:self action:@selector(useCouponButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if(!VALID_NOTEMPTY([self.couponTextField text], NSString))
    {
        [self.useCouponButton setEnabled:NO];
        [self.couponTextField setTextColor:UIColorFromRGB(0xcccccc)];
    }
    
    // subtotal
    self.subtotalView.layer.cornerRadius = 5.0f;
    [self.subtotalView layoutIfNeeded];
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
    
    [self.cartPrice setTextColor:UIColorFromRGB(0xcc0000)];
    
    if(VALID_NOTEMPTY([[self cart] cartUnreducedValueFormatted], NSString))
    {
        [self.cartPrice setText:[NSString stringWithFormat:@"%@ %@", [[self cart] cartUnreducedValueFormatted], [[self cart] cartCleanValueFormatted]]];
    }
    else
    {
        [self.cartPrice setText:[[self cart] cartCleanValueFormatted]];
    }
    
    NSString *priceRuleKeysString = @"";
    NSString *priceRuleValuesString = @"";
    if(VALID_NOTEMPTY([[self cart] priceRules], NSDictionary))
    {
        NSArray *priceRuleKeys = [[[self cart] priceRules] allKeys];
        
        for (NSString *priceRuleKey in priceRuleKeys)
        {
            if(ISEMPTY(priceRuleKeysString))
            {
                priceRuleKeysString = priceRuleKey;
                priceRuleValuesString = [[[self cart] priceRules] objectForKey:priceRuleKey];
            }
            else
            {
                priceRuleKeysString = [NSString stringWithFormat:@"%@\n%@", priceRuleKeysString, priceRuleKey];
                priceRuleValuesString = [NSString stringWithFormat:@"%@\n%@", priceRuleValuesString, [[[self cart] priceRules] objectForKey:priceRuleKey]];
            }
        }
    }
    
    if(VALID_NOTEMPTY(priceRuleKeysString, NSString) && VALID_NOTEMPTY(priceRuleValuesString, NSString))
    {
        [self.priceRulesLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.priceRulesLabel setText:priceRuleKeysString];
        [self.priceRulesLabel setNumberOfLines:0];
        [self.priceRulesLabel setFrame:CGRectMake(self.priceRulesLabel.frame.origin.x,
                                                  CGRectGetMaxY(self.articlesCount.frame) + 4.0f,
                                                  self.priceRulesLabel.frame.size.width,
                                                  self.priceRulesLabel.frame.size.height)];
        [self.priceRulesLabel setHidden:NO];
        
        [self.priceRulesValue setTextColor:UIColorFromRGB(0x666666)];
        [self.priceRulesValue setText:priceRuleValuesString];
        [self.priceRulesValue setNumberOfLines:0];
        [self.priceRulesValue setFrame:CGRectMake(self.priceRulesValue.frame.origin.x,
                                                  CGRectGetMaxY(self.cartPrice.frame) + 4.0f,
                                                  self.priceRulesValue.frame.size.width,
                                                  self.priceRulesValue.frame.size.height)];
        [self.priceRulesValue setHidden:NO];
        
        [self.cartVatLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.cartVatLabel setText:@"VAT"];
        [self.cartVatLabel setFrame:CGRectMake(self.cartVatLabel.frame.origin.x,
                                               CGRectGetMaxY(self.priceRulesLabel.frame),
                                               self.cartVatLabel.frame.size.width,
                                               self.cartVatLabel.frame.size.height)];
        
        
        [self.cartVatValue setTextColor:UIColorFromRGB(0x666666)];
        [self.cartVatValue setText:[[self cart] vatValueFormatted]];
        [self.cartVatValue setFrame:CGRectMake(self.cartVatValue.frame.origin.x,
                                               CGRectGetMaxY(self.priceRulesValue.frame),
                                               self.cartVatValue.frame.size.width,
                                               self.cartVatValue.frame.size.height)];
    }
    else
    {
        [self.priceRulesLabel setHidden:YES];
        [self.priceRulesLabel setHidden:YES];
        
        [self.cartVatLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.cartVatLabel setText:@"VAT"];
        [self.cartVatLabel setFrame:CGRectMake(self.cartVatLabel.frame.origin.x,
                                               CGRectGetMaxY(self.articlesCount.frame) + 4.0f,
                                               self.cartVatLabel.frame.size.width,
                                               self.cartVatLabel.frame.size.height)];
        
        
        [self.cartVatValue setTextColor:UIColorFromRGB(0x666666)];
        [self.cartVatValue setText:[[self cart] vatValueFormatted]];
        [self.cartVatValue setFrame:CGRectMake(self.cartVatValue.frame.origin.x,
                                               CGRectGetMaxY(self.cartPrice.frame) + 4.0f,
                                               self.cartVatValue.frame.size.width,
                                               self.cartVatValue.frame.size.height)];
    }
    
    
    
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
        [self.cartShippingValue setText:[[self cart] shippingValueFormatted]];
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
    [self.extraCostsValue setText:[[self cart] extraCostsFormatted]];
    [self.extraCostsValue setFrame:CGRectMake(self.extraCostsValue.frame.origin.x,
                                              CGRectGetMaxY(self.cartShippingValue.frame),
                                              self.extraCostsValue.frame.size.width,
                                              self.extraCostsValue.frame.size.height)];
    
    [self.totalLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.totalLabel setText:@"Total"];
    
    [self.totalValue setTextColor:UIColorFromRGB(0xcc0000)];
    [self.totalValue setText:[[self cart] cartValueFormatted]];
    
    [self.couponLabel setTextColor:UIColorFromRGB(0x3aaa35)];
    [self.couponLabel setText:@"Voucher"];
    
    [self.couponValue setTextColor:UIColorFromRGB(0x3aaa35)];
    [self.couponValue setText:[NSString stringWithFormat:@"- %@", [[self cart] couponMoneyValueFormatted]]];
    
    if(VALID_NOTEMPTY([[self cart] couponMoneyValue], NSNumber) && 0.0f < [[[self cart] couponMoneyValue] floatValue])
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
    [self.checkoutButton layoutIfNeeded];
    
    [self.callToOrderButton setTitle:@"Call to Order" forState:UIControlStateNormal];
    [self.callToOrderButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.callToOrderButton addTarget:self action:@selector(callToOrderButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.callToOrderButton layoutIfNeeded];
        
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
        self.currentItem = [self.cart.cartItems objectForKey:key];
        
        [self setupPickerView];
    }
}

- (void)setupPickerView
{
    self.quantityPickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                 0.0f,
                                                                                 self.view.frame.size.width,
                                                                                 self.view.frame.size.height)];
    [self.quantityPickerBackgroundView setBackgroundColor:[UIColor clearColor]];
    
    UITapGestureRecognizer *removePickerViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(removePickerView)];
    [self.quantityPickerBackgroundView addGestureRecognizer:removePickerViewTap];
    
    self.quantityPicker = [[UIPickerView alloc] init];
    [self.quantityPicker setFrame:CGRectMake(self.quantityPickerBackgroundView.frame.origin.x,
                                             CGRectGetMaxY(self.quantityPickerBackgroundView.frame) - self.quantityPicker.frame.size.height,
                                             self.quantityPicker.frame.size.width,
                                             self.quantityPicker.frame.size.height)];
    [self.quantityPicker setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.quantityPicker setAlpha:0.9];
    [self.quantityPicker setShowsSelectionIndicator:YES];
    [self.quantityPicker setDataSource:self];
    [self.quantityPicker setDelegate:self];
    
    self.quantityPickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.quantityPickerToolbar setTranslucent:NO];
    [self.quantityPickerToolbar setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.quantityPickerToolbar setAlpha:0.9];
    [self.quantityPickerToolbar setFrame:CGRectMake(0.0f,
                                                    CGRectGetMinY(self.quantityPicker.frame) - self.quantityPickerToolbar.frame.size.height,
                                                    self.quantityPickerToolbar.frame.size.width,
                                                    self.quantityPickerToolbar.frame.size.height)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0f, 0.0f, 0.0f)];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(selectQuantity:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.quantityPickerToolbar setItems:[NSArray arrayWithObjects:flexibleItem, doneButton, nil]];
    
    [self.quantityPicker selectRow:([[self.currentItem quantity] integerValue] - 1) inComponent:0 animated:NO];
    [self.quantityPickerBackgroundView addSubview:self.quantityPicker];
    [self.quantityPickerBackgroundView addSubview:self.quantityPickerToolbar];
    [self.view addSubview:self.quantityPickerBackgroundView];
}

- (void)selectQuantity:(UIButton*)sender
{
    NSInteger newQuantity = [self.quantityPicker selectedRowInComponent:0] + 1;
    if(newQuantity != [[self.currentItem quantity] integerValue])
    {
        [self showLoading];
        
        NSMutableDictionary *quantitiesToChange = [[NSMutableDictionary alloc] init];
        NSArray *cartItemsKeys = [[self.cart cartItems] allKeys];
        for (NSString *cartItemKey in cartItemsKeys)
        {
            RICartItem *cartItem = [[self.cart cartItems] objectForKey:cartItemKey];
            [quantitiesToChange setValue:[NSString stringWithFormat:@"%d", [[cartItem quantity] integerValue]] forKey:[NSString stringWithFormat:@"qty_%@", cartItemKey]];
        }
        
        [quantitiesToChange setValue:[NSString stringWithFormat:@"%d", newQuantity] forKey:[NSString stringWithFormat:@"qty_%@", [self.currentItem simpleSku]]];
        
        [RICart changeQuantityInProducts:quantitiesToChange
                        withSuccessBlock:^(RICart *cart) {
                            self.cart = cart;
                            
                            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                            
                            [self removePickerView];
                            [self setupCart];
                            [self hideLoading];
                        } andFailureBlock:^(NSArray *errorMessages) {
                            [self removePickerView];
                            [self hideLoading];
                            
                            [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                        message:@"Error changing quantity"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil] show];
                        }];
    }
    else
    {
        [self removePickerView];
    }
}

- (void)removePickerView
{
    [self.quantityPicker removeFromSuperview];
    self.quantityPicker = nil;
    
    [self.quantityPickerBackgroundView removeFromSuperview];
    self.quantityPickerBackgroundView = nil;
}

- (void)useCouponButtonPressed
{
    [self.couponTextField resignFirstResponder];
    
    [self showLoading];
    NSString *voucherCode = [self.couponTextField text];
    [RICart addVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
        self.cart = cart;
        [self setupCart];
        [self hideLoading];
    } andFailureBlock:^(NSArray *errorMessages) {
        [self hideLoading];
        
        [self.couponTextField setTextColor:UIColorFromRGB(0xcc0000)];
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
        JACartListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader" forIndexPath:indexPath];
        
        [headerView loadHeaderWithText:@"Items"];
        
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

#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.couponTextField setTextColor:UIColorFromRGB(0xcccccc)];
    
    if(VALID_NOTEMPTY(textField.text, NSString))
    {
        [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
    if (NSEqualRanges(range, textFieldRange) && [string length] == 0)
    {
        [self.useCouponButton setEnabled:NO];
    }
    else
    {
        [self.useCouponButton setEnabled:YES];
    }
    
    return YES;
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numberOfRowsInComponent = 0;
    
    if(VALID_NOTEMPTY(self.currentItem, RICartItem))
    {
        numberOfRowsInComponent = [[self.currentItem maxQuantity] integerValue];
    }
    
    return numberOfRowsInComponent;
}

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"%d", (row + 1)];
    return title;
}

@end

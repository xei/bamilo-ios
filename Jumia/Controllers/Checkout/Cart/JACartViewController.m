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
#import "JAPriceView.h"
#import "RIForm.h"
#import "RIField.h"
#import "RICart.h"
#import "RICartItem.h"
#import "RICustomer.h"
#import "RIAddress.h"

@interface JACartViewController ()

@property (nonatomic, strong) NSString *voucherCode;

@end

@implementation JACartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.navBarLayout.title = CART_LABEL;
    
    self.view.backgroundColor = JABackgroundGrey;
    
    [self.emptyCartView setHidden:YES];
    [self.emptyCartLabel setHidden:YES];
    [self.continueShoppingButton setHidden:YES];
    
    self.cartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f)];
    [self.cartScrollView setBackgroundColor:JABackgroundGrey];
    [self.cartScrollView setHidden:YES];
    [self.view addSubview:self.cartScrollView];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, 90.0f);
    [flowLayout setHeaderReferenceSize:CGSizeMake(308.0f, 26.0f)];
    
    self.productCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(6.0f,
                                                                                    6.0f,
                                                                                    308.0f,
                                                                                    0.0f) collectionViewLayout:flowLayout];
    
    self.productCollectionView.layer.cornerRadius = 5.0f;
    
    UINib *cartListCellNib = [UINib nibWithNibName:@"JACartListCell" bundle:nil];
    [self.productCollectionView registerNib:cartListCellNib forCellWithReuseIdentifier:@"cartListCell"];

    UINib *cartListHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    [self.productCollectionView registerNib:cartListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader"];
    
    [self.productCollectionView setDataSource:self];
    [self.productCollectionView setDelegate:self];
    
    [self.cartScrollView addSubview:self.productCollectionView];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    
    [self.emptyCartView setHidden:NO];
    [self.emptyCartLabel setHidden:NO];
    [self.continueShoppingButton setHidden:NO];
    
    [self.cartScrollView setHidden:YES];
    
    self.emptyCartView.layer.cornerRadius = 5.0f;
    [self.emptyCartLabel setText:WISHLIST_NOITEMS];
    [self.emptyCartLabel setTextColor:JALabelGrey];
    
    [self.continueShoppingButton setTitleColor:JAButtonTextOrange forState:UIControlStateNormal];
    [self.continueShoppingButton setTitle:CONTINUE_SHOPPING forState:UIControlStateNormal];
    
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
    [self.productCollectionView setFrame:CGRectMake(6.0f, 6.0f, 308.0f, ([cartItemsKeys count] * 90.0f) + 26.0f)];
    [self.productCollectionView reloadData];
    
    // coupon
    if(VALID_NOTEMPTY(self.couponView, UIView))
    {
        [self.couponView removeFromSuperview];
    }
    
    self.couponView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, CGRectGetMaxY(self.productCollectionView.frame) + 3.0f, 308.0f, 86.0f)];
    [self.couponView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.couponView.layer.cornerRadius = 5.0f;
    
    self.couponTitle = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 0.0f, 280.0f, 25.0f)];
    [self.couponTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.couponTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.couponTitle setText:@"Coupon"];
    [self.couponTitle setBackgroundColor:[UIColor clearColor]];
    [self.couponView addSubview:self.couponTitle];
    
    self.couponTitleSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.couponTitle.frame), 308.0f, 1.0f)];
    [self.couponTitleSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.couponView addSubview:self.couponTitleSeparator];
    
    self.couponTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0f, CGRectGetMaxY(self.couponTitleSeparator.frame) + 17.0f, 240.0f, 30.0f)];
    [self.couponTextField setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
    [self.couponTextField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    [self.couponTextField setPlaceholder:VOUCHER_MESSAGE_HINT];
    [self.couponTextField setDelegate:self];
    [self.couponView addSubview:self.couponTextField];
    
    self.useCouponButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *useCouponImageNormal = [UIImage imageNamed:@"useCoupon_normal"];
    [self.useCouponButton setBackgroundImage:useCouponImageNormal forState:UIControlStateNormal];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_highlighted"] forState:UIControlStateHighlighted];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_highlighted"] forState:UIControlStateSelected];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_disabled"] forState:UIControlStateDisabled];
    [self.useCouponButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.useCouponButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.useCouponButton addTarget:self action:@selector(useCouponButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.useCouponButton setFrame:CGRectMake(CGRectGetMaxX(self.couponTextField.frame) + 5.0f, CGRectGetMaxY(self.couponTitleSeparator.frame) + 17.0f, useCouponImageNormal.size.width, useCouponImageNormal.size.height)];
    [self.couponView addSubview:self.useCouponButton];
    
    [self.cartScrollView addSubview:self.couponView];
    
    if(VALID_NOTEMPTY([[self cart] couponMoneyValue], NSNumber) && 0.0f < [[[self cart] couponMoneyValue] floatValue])
    {
        [self.useCouponButton setTitle:VOUCHER_REMOVE forState:UIControlStateNormal];
    }
    else
    {
        [self.useCouponButton setTitle:VOUCHER_USE forState:UIControlStateNormal];
    }
    
    if(VALID_NOTEMPTY(self.voucherCode, NSString))
    {
        [self.couponTextField setText:self.voucherCode];
    }
    else if(!VALID_NOTEMPTY([self.couponTextField text], NSString))
    {
        [self.useCouponButton setEnabled:NO];
    }
    
    if(VALID_NOTEMPTY(self.subtotalView, UIView))
    {
        [self.subtotalView removeFromSuperview];
    }
    // subtotal
    self.subtotalView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, CGRectGetMaxY(self.couponView.frame) + 3.0f, 308.0f, 0.0f)];
    [self.subtotalView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.subtotalView.layer.cornerRadius = 5.0f;
    
    self.subtotalTitle = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 0.0f, 280.0f, 25.0f)];
    [self.subtotalTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.subtotalTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.subtotalTitle setText:@"Subtotal"];
    [self.subtotalTitle setBackgroundColor:[UIColor clearColor]];
    [self.subtotalView addSubview:self.subtotalTitle];
    
    self.subtotalTitleSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.subtotalTitle.frame), 308.0f, 1.0f)];
    [self.subtotalTitleSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.subtotalView addSubview:self.subtotalTitleSeparator];
    
    self.articlesCount = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.articlesCount setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.articlesCount setTextColor:UIColorFromRGB(0x666666)];
    [self.articlesCount setBackgroundColor:[UIColor clearColor]];
    NSInteger cartCount = [[[self cart] cartCount] integerValue];
    if(1 == cartCount)
    {
        [self.articlesCount setText:@"1 article"];
    }
    else
    {
        [self.articlesCount setText:[NSString stringWithFormat:@"%d articles", cartCount]];
    }
    [self.articlesCount sizeToFit];
    [self.articlesCount setFrame:CGRectMake(6.0f, CGRectGetMaxY(self.subtotalTitleSeparator.frame) + 10.0f, 140.0f, self.articlesCount.frame.size.height)];
    [self.subtotalView addSubview:self.articlesCount];
    
    self.totalPriceView = [[JAPriceView alloc] init];
    
    if(VALID_NOTEMPTY([[self cart] cartUnreducedValueFormatted], NSString))
    {
        [self.totalPriceView loadWithPrice:[[self cart] cartUnreducedValueFormatted]
                              specialPrice:[[self cart] cartCleanValueFormatted]
                                  fontSize:11.0f
                     specialPriceOnTheLeft:YES];
    }
    else
    {
        [self.totalPriceView loadWithPrice:[[self cart] cartCleanValueFormatted]
                              specialPrice:nil
                                  fontSize:11.0f
                     specialPriceOnTheLeft:YES];
    }
    
    self.totalPriceView.frame = CGRectMake(self.subtotalView.frame.size.width - self.totalPriceView.frame.size.width - 4.0f,
                                           CGRectGetMaxY(self.subtotalTitleSeparator.frame) + 10.0f,
                                           self.totalPriceView.frame.size.width,
                                           self.totalPriceView.frame.size.height);
    [self.subtotalView addSubview:self.totalPriceView];
    
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
    
    self.cartVatLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.cartVatLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.cartVatLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.cartVatLabel setText:@"VAT"];
    [self.cartVatLabel sizeToFit];
    [self.cartVatLabel setBackgroundColor:[UIColor clearColor]];
    
    self.cartVatValue = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.cartVatValue setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.cartVatValue setTextColor:UIColorFromRGB(0x666666)];
    [self.cartVatValue setText:[[self cart] vatValueFormatted]];
    [self.cartVatValue sizeToFit];
    [self.cartVatValue setBackgroundColor:[UIColor clearColor]];
    
    if(VALID_NOTEMPTY(priceRuleKeysString, NSString) && VALID_NOTEMPTY(priceRuleValuesString, NSString))
    {
        self.priceRulesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.priceRulesLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
        [self.priceRulesLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.priceRulesLabel setText:priceRuleKeysString];
        [self.priceRulesLabel setNumberOfLines:0];
        [self.priceRulesLabel setBackgroundColor:[UIColor clearColor]];
        [self.priceRulesLabel sizeToFit];
        [self.priceRulesLabel setFrame:CGRectMake(6.0f,
                                                  CGRectGetMaxY(self.articlesCount.frame) + 4.0f,
                                                  self.priceRulesLabel.frame.size.width,
                                                  self.priceRulesLabel.frame.size.height)];
        
        [self.subtotalView addSubview:self.priceRulesLabel];
        
        
        self.priceRulesValue = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.priceRulesValue setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
        [self.priceRulesValue setTextColor:UIColorFromRGB(0x666666)];
        [self.priceRulesValue setText:priceRuleValuesString];
        [self.priceRulesValue setNumberOfLines:0];
        [self.priceRulesValue setBackgroundColor:[UIColor clearColor]];
        [self.priceRulesValue sizeToFit];
        [self.priceRulesValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.priceRulesValue.frame.size.width - 4.0f,
                                                  CGRectGetMaxY(self.articlesCount.frame) + 4.0f,
                                                  self.priceRulesValue.frame.size.width,
                                                  self.priceRulesValue.frame.size.height)];
        
        [self.subtotalView addSubview:self.priceRulesValue];
        
        
        [self.cartVatLabel setFrame:CGRectMake(6.0f,
                                               CGRectGetMaxY(self.priceRulesLabel.frame),
                                               self.cartVatLabel.frame.size.width,
                                               self.cartVatLabel.frame.size.height)];
        
        
        [self.cartVatValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.cartVatValue.frame.size.width - 4.0f,
                                               CGRectGetMaxY(self.priceRulesValue.frame),
                                               self.cartVatValue.frame.size.width,
                                               self.cartVatValue.frame.size.height)];
    }
    else
    {
        if(VALID_NOTEMPTY(self.priceRulesLabel, UILabel))
        {
            [self.priceRulesLabel removeFromSuperview];
        }
        if(VALID_NOTEMPTY(self.priceRulesValue, UILabel))
        {
            [self.priceRulesValue removeFromSuperview];
        }
        
        [self.cartVatLabel setFrame:CGRectMake(6.0f,
                                               CGRectGetMaxY(self.articlesCount.frame) + 4.0f,
                                               self.cartVatLabel.frame.size.width,
                                               self.cartVatLabel.frame.size.height)];
        
        [self.cartVatValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.cartVatValue.frame.size.width - 4.0f,
                                               CGRectGetMaxY(self.articlesCount.frame) + 4.0f,
                                               self.cartVatValue.frame.size.width,
                                               self.cartVatValue.frame.size.height)];
    }
    [self.subtotalView addSubview:self.cartVatLabel];
    [self.subtotalView addSubview:self.cartVatValue];
    
    self.cartShippingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.cartShippingLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.cartShippingLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.cartShippingLabel setText:@"Shipping"];
    [self.cartShippingLabel sizeToFit];
    [self.cartShippingLabel setBackgroundColor:[UIColor clearColor]];
    [self.cartShippingLabel setFrame:CGRectMake(6.0f,
                                                CGRectGetMaxY(self.cartVatLabel.frame),
                                                self.cartShippingLabel.frame.size.width,
                                                self.cartShippingLabel.frame.size.height)];
    [self.subtotalView addSubview:self.cartShippingLabel];
    
    self.cartShippingValue = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.cartShippingValue setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.cartShippingValue setTextColor:UIColorFromRGB(0x666666)];
    if(0.0f == [[[self cart] shippingValue] floatValue])
    {
        [self.cartShippingValue setText:@"Free"];
    }
    else
    {
        [self.cartShippingValue setText:[[self cart] shippingValueFormatted]];
    }
    [self.cartShippingValue sizeToFit];
    [self.cartShippingValue setBackgroundColor:[UIColor clearColor]];
    [self.cartShippingValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.cartShippingValue.frame.size.width - 4.0f,
                                                CGRectGetMaxY(self.cartVatLabel.frame),
                                                self.cartShippingValue.frame.size.width,
                                                self.cartShippingValue.frame.size.height)];
    [self.subtotalView addSubview:self.cartShippingValue];
    
    self.extraCostsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.extraCostsLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.extraCostsLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.extraCostsLabel setText:@"Extra Costs"];
    [self.extraCostsLabel sizeToFit];
    [self.extraCostsLabel setBackgroundColor:[UIColor clearColor]];
    [self.extraCostsLabel setFrame:CGRectMake(6.0f,
                                              CGRectGetMaxY(self.cartShippingLabel.frame),
                                              self.extraCostsLabel.frame.size.width,
                                              self.extraCostsLabel.frame.size.height)];
    [self.subtotalView addSubview:self.extraCostsLabel];
    
    self.extraCostsValue = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.extraCostsValue setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.extraCostsValue setTextColor:UIColorFromRGB(0x666666)];
    [self.extraCostsValue setText:[[self cart] extraCostsFormatted]];
    [self.extraCostsValue sizeToFit];
    [self.extraCostsValue setBackgroundColor:[UIColor clearColor]];
    [self.extraCostsValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.extraCostsValue.frame.size.width - 4.0f,
                                              CGRectGetMaxY(self.cartShippingLabel.frame),
                                              self.extraCostsValue.frame.size.width,
                                              self.extraCostsValue.frame.size.height)];
    [self.subtotalView addSubview:self.extraCostsValue];
    
    self.totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.totalLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.totalLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.totalLabel setText:@"Total"];
    [self.totalLabel sizeToFit];
    [self.totalLabel setBackgroundColor:[UIColor clearColor]];
    
    self.totalValue = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.totalValue setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.totalValue setTextColor:UIColorFromRGB(0xcc0000)];
    [self.totalValue setText:[[self cart] cartValueFormatted]];
    [self.totalValue sizeToFit];
    [self.totalValue setBackgroundColor:[UIColor clearColor]];
    
    if(VALID_NOTEMPTY([[self cart] couponMoneyValue], NSNumber) && 0.0f < [[[self cart] couponMoneyValue] floatValue])
    {
        self.couponLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.couponLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
        [self.couponLabel setTextColor:UIColorFromRGB(0x3aaa35)];
        [self.couponLabel setText:@"Voucher"];
        [self.couponLabel sizeToFit];
        [self.couponLabel setBackgroundColor:[UIColor clearColor]];
        [self.couponLabel setFrame:CGRectMake(6.0f,
                                              CGRectGetMaxY(self.extraCostsLabel.frame),
                                              self.couponLabel.frame.size.width,
                                              self.couponLabel.frame.size.height)];
        [self.subtotalView addSubview:self.couponLabel];
        
        self.couponValue = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.couponValue setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
        [self.couponValue setTextColor:UIColorFromRGB(0x3aaa35)];
        [self.couponValue setText:[NSString stringWithFormat:@"- %@", [[self cart] couponMoneyValueFormatted]]];
        [self.couponValue sizeToFit];
        [self.couponValue setBackgroundColor:[UIColor clearColor]];
        [self.couponValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.couponValue.frame.size.width - 4.0f,
                                              CGRectGetMaxY(self.extraCostsLabel.frame),
                                              self.couponValue.frame.size.width,
                                              self.couponValue.frame.size.height)];
        [self.subtotalView addSubview:self.couponValue];
        
        [self.totalLabel setFrame:CGRectMake(6.0f,
                                             CGRectGetMaxY(self.couponLabel.frame) + 4.0f,
                                             self.totalLabel.frame.size.width,
                                             self.totalLabel.frame.size.height)];
        
        [self.totalValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.totalValue.frame.size.width - 4.0f,
                                             CGRectGetMaxY(self.couponLabel.frame) + 4.0f,
                                             self.totalValue.frame.size.width,
                                             self.totalValue.frame.size.height)];
    }
    else
    {
        if(VALID_NOTEMPTY(self.couponLabel, UILabel))
        {
            [self.couponLabel removeFromSuperview];
        }
        if(VALID_NOTEMPTY(self.couponValue, UILabel))
        {
            [self.couponValue removeFromSuperview];
        }
        
        [self.totalLabel setFrame:CGRectMake(6.0f,
                                             CGRectGetMaxY(self.extraCostsLabel.frame) + 4.0f,
                                             self.totalLabel.frame.size.width,
                                             self.totalLabel.frame.size.height)];
        
        [self.totalValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.totalValue.frame.size.width - 4.0f,
                                             CGRectGetMaxY(self.extraCostsLabel.frame) + 4.0f,
                                             self.totalValue.frame.size.width,
                                             self.totalValue.frame.size.height)];
    }
    
    [self.subtotalView addSubview:self.totalLabel];
    [self.subtotalView addSubview:self.totalValue];
    
    [self.subtotalView setFrame:CGRectMake(6.0f, CGRectGetMaxY(self.couponView.frame) + 3.0f, 308.0f, CGRectGetMaxY(self.totalValue.frame) + 10.0f)];
    [self.cartScrollView addSubview:self.subtotalView];
    
    if(VALID_NOTEMPTY(self.checkoutButton, UIButton))
    {
        [self.checkoutButton removeFromSuperview];
    }
    self.checkoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *checkoutButtonImageNormal = [UIImage imageNamed:@"orangeBig_normal"];
    [self.checkoutButton setBackgroundImage:checkoutButtonImageNormal forState:UIControlStateNormal];
    [self.checkoutButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.checkoutButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.checkoutButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.checkoutButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.checkoutButton setTitle:@"Proceed to Checkout" forState:UIControlStateNormal];
    [self.checkoutButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.checkoutButton addTarget:self action:@selector(checkoutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.checkoutButton setFrame:CGRectMake(6.0f, CGRectGetMaxY(self.subtotalView.frame) + 6.0f, checkoutButtonImageNormal.size.width, checkoutButtonImageNormal.size.height)];
    [self.cartScrollView addSubview:self.checkoutButton];
    
    if(VALID_NOTEMPTY(self.callToOrderButton, UIButton))
    {
        [self.callToOrderButton removeFromSuperview];
    }
    self.callToOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *callToOrderButtonImageNormal = [UIImage imageNamed:@"grayBig_normal"];
    [self.callToOrderButton setBackgroundImage:callToOrderButtonImageNormal forState:UIControlStateNormal];
    [self.callToOrderButton setBackgroundImage:[UIImage imageNamed:@"grayBig_highlighted"] forState:UIControlStateHighlighted];
    [self.callToOrderButton setBackgroundImage:[UIImage imageNamed:@"grayBig_highlighted"] forState:UIControlStateSelected];
    [self.callToOrderButton setBackgroundImage:[UIImage imageNamed:@"grayBig_disabled"] forState:UIControlStateDisabled];
    [self.callToOrderButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.callToOrderButton setTitle:CALL_TO_ORDER forState:UIControlStateNormal];
    [self.callToOrderButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.callToOrderButton addTarget:self action:@selector(callToOrderButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.callToOrderButton setFrame:CGRectMake(6.0f, CGRectGetMaxY(self.checkoutButton.frame) + 6.0f, callToOrderButtonImageNormal.size.width, callToOrderButtonImageNormal.size.height)];
    [self.cartScrollView addSubview:self.callToOrderButton];
    
    [self.cartScrollView setContentSize:CGSizeMake(308.0f, self.cartScrollView.frame.origin.y + CGRectGetMaxY(self.callToOrderButton.frame) + 6.0f)];
}

-(void)goToHomeScreen
{
    [[RITrackingWrapper sharedInstance] trackEvent:[RICustomer getCustomerId]
                                             value:nil
                                            action:@"ContinueShopping"
                                          category:@"Checkout"
                                              data:nil];
    
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
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
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
    
    if(VALID_NOTEMPTY([[self cart] couponMoneyValue], NSNumber) && 0.0f < [[[self cart] couponMoneyValue] floatValue])
    {
        [RICart removeVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
            self.cart = cart;
            self.voucherCode = voucherCode;
            
            [self setupCart];
            [self hideLoading];
        } andFailureBlock:^(NSArray *errorMessages) {
            [self hideLoading];
            
            [self.couponTextField setTextColor:UIColorFromRGB(0xcc0000)];
        }];
    }
    else
    {
        [RICart addVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
            self.cart = cart;
            self.voucherCode = voucherCode;
            
            [self setupCart];
            [self hideLoading];
        } andFailureBlock:^(NSArray *errorMessages) {
            [self hideLoading];
            
            [self.couponTextField setTextColor:UIColorFromRGB(0xcc0000)];
        }];
    }
}

- (void)checkoutButtonPressed
{
    if([RICustomer checkIfUserIsLogged])
    {
        [self showLoading];
        [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
            
            [[RITrackingWrapper sharedInstance] trackEvent:nil
                                                     value:nil
                                                    action:@"Started"
                                                  category:@"Checkout"
                                                      data:nil];
            
            [self hideLoading];

            if(VALID_NOTEMPTY(adressList, NSDictionary))
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                                    object:nil
                                                                  userInfo:nil];
            }
            else
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
            
        } andFailureBlock:^(NSArray *errorMessages) {
            
            [[RITrackingWrapper sharedInstance] trackEvent:[RICustomer getCustomerId]
                                                     value:nil
                                                    action:@"NativeCheckoutError"
                                                  category:@"NativeCheckout"
                                                      data:nil];
            
            [self hideLoading];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                object:nil
                                                              userInfo:userInfo];
        }];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutLoginScreenNotification
                                                            object:nil
                                                          userInfo:nil];
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
        pdv.previousCategory = CART_LABEL;
        
        [self.navigationController pushViewController:pdv
                                             animated:YES];
    }
}

#pragma mark UITextFieldDelegate

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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
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

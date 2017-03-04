//
//  JAOrderSummaryView.m
//  Jumia
//
//  Created by Telmo Pinto on 24/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAOrderSummaryView.h"
#import "RICartItem.h"
#import "RIAddress.h"
#import "JAProductInfoHeaderLine.h"

@interface JAOrderSummaryView()

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UIView* cartView;
@property (nonatomic, strong)UIView* shippingAddressView;
@property (nonatomic, strong)UIView* billingAddressView;
@property (nonatomic, strong)UIView* shippingMethodView;
@property (nonatomic, strong)NSString *extraCosts;
@property (nonatomic, strong)UIView* verticalSeparator;

@end

@implementation JAOrderSummaryView

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.scrollView setFrame:self.bounds];
}

- (void)loadWithCart:(RICart *)cart
{
    self.backgroundColor = JAWhiteColor;
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.scrollView];
    
    self.verticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      1.0f,
                                                                      800)];
    self.verticalSeparator.backgroundColor = JABlack400Color;
    [self addSubview:self.verticalSeparator];
    
    CGFloat topMargin = 0.0f;
    
    if (VALID_NOTEMPTY(cart, RICart) && VALID_NOTEMPTY(cart.cartEntity.cartItems, NSArray)) {
        
        self.cartView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                                                 self.scrollView.bounds.origin.y + topMargin,
                                                                 self.scrollView.bounds.size.width,
                                                                 self.scrollView.bounds.size.height)];
        self.cartView.backgroundColor = [UIColor whiteColor];
        
        CGFloat currentY = [self headerLoad:self.cartView title:STRING_ORDER_SUMMARY selector:nil];
        
        currentY += 9.0f; // Margin between title and products
        
        CGFloat startingX = 16.0f;
        
        UILabel* productsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.cartView.bounds.origin.x + startingX,
                                                                                currentY,
                                                                                self.cartView.bounds.size.width - 2*startingX,
                                                                                26.0f)];
        productsTitleLabel.textAlignment = NSTextAlignmentLeft;
        productsTitleLabel.text = STRING_PRODUCTS;
        productsTitleLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        productsTitleLabel.textColor = JAButtonTextOrange;
        [self.cartView addSubview:productsTitleLabel];
        
        currentY += productsTitleLabel.frame.size.height + 10.0f;
        
        for (RICartItem* cartItem in cart.cartEntity.cartItems) {
            if (VALID_NOTEMPTY(cartItem, RICartItem)) {
                
                NSString* priceString = cartItem.priceFormatted;
                if (VALID_NOTEMPTY(cartItem.specialPriceFormatted, NSString)) {
                    priceString = cartItem.specialPriceFormatted;
                }
                
                currentY = [self loadProductLabelInPositionY:currentY
                                                        name:cartItem.name
                                                    quantity:[cartItem.quantity integerValue]
                                                       price:priceString];
            }
        }
        
        NSString *shippingFeeValue = nil;
        if (0 == [cart.cartEntity.shippingValue integerValue])
        {
            shippingFeeValue = STRING_FREE;
        }
        else
        {
            shippingFeeValue = cart.cartEntity.shippingValueFormatted;
        }
        
        NSString *extraCostsValue = nil;
        if (0 == [cart.cartEntity.extraCosts integerValue])
        {
            extraCostsValue = STRING_FREE;
        }
        else
        {
            extraCostsValue = cart.cartEntity.extraCostsFormatted;
        }
        
        NSString *voucherCostsValue = nil;
        if (0 == [cart.cartEntity.couponMoneyValue integerValue])
        {
            voucherCostsValue = STRING_FREE;
        }
        else
        {
            voucherCostsValue = cart.cartEntity.couponMoneyValueFormatted;
        }
        
        currentY = [self loadTotalSectionInPositionY:currentY
                                            subtotal:cart.cartEntity.cartValueFormatted
                                          priceRules:cart.cartEntity.priceRules
                                               extra:extraCostsValue
                                         shippingFee:shippingFeeValue
                                             voucher:voucherCostsValue];
        
        self.extraCosts = cart.cartEntity.extraCostsFormatted;
        
        [self.cartView setFrame:CGRectMake(self.cartView.frame.origin.x,
                                           self.cartView.frame.origin.y,
                                           self.cartView.frame.size.width,
                                           currentY)];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                                 self.cartView.frame.origin.y + currentY);
    }
}

- (void)loadWithCart:(RICart*)cart shippingMethod:(BOOL)shippingMethod;
{
    if(VALID_NOTEMPTY(cart, RICart))
    {
        [self loadWithCart:cart];
        
        [self loadWithShippingAddress:cart.cartEntity.shippingAddress billingAddress:cart.cartEntity.billingAddress];
        
        if (shippingMethod) {
            [self loadWithShippingMethod:cart.cartEntity.shippingMethod];
        }        
    }
}

- (void)loadWithShippingAddress:(RIAddress*)shippingAddress billingAddress:(RIAddress*)billingAddress
{
    CGFloat startingY =  self.scrollView.contentSize.height;
    CGFloat currentY = 0.0f;
    
    if(VALID_NOTEMPTY(shippingAddress, RIAddress))
    {
        self.shippingAddressView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                                                            startingY,
                                                                            self.scrollView.bounds.size.width,
                                                                            0.0f)];
        self.shippingAddressView.backgroundColor = [UIColor whiteColor];
        
        currentY = [self headerLoad:self.shippingAddressView title:STRING_SHIPPING_ADDRESSES selector:@selector(editButtonForShippingAddress)];
        currentY = [self loadAddressInPositionY:currentY address:shippingAddress view:self.shippingAddressView];
        
        [self.shippingAddressView setFrame:CGRectMake(self.shippingAddressView.frame.origin.x,
                                                      self.shippingAddressView.frame.origin.y,
                                                      self.shippingAddressView.frame.size.width,
                                                      currentY)];
        
        startingY += currentY;
        
        if(VALID_NOTEMPTY(billingAddress, RIAddress) && ![[shippingAddress uid] isEqualToString:[billingAddress uid]])
        {
            self.billingAddressView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                                                               startingY,
                                                                               self.scrollView.bounds.size.width,
                                                                               0.0f)];
            self.billingAddressView.backgroundColor = [UIColor whiteColor];
            
            currentY = [self headerLoad:self.billingAddressView title:STRING_BILLING_ADDRESSES selector:@selector(editButtonForBillingAddress)];
            currentY = [self loadAddressInPositionY:currentY address:billingAddress view:self.billingAddressView];
            
            [self.billingAddressView setFrame:CGRectMake(self.billingAddressView.frame.origin.x,
                                                         self.billingAddressView.frame.origin.y,
                                                         self.billingAddressView.frame.size.width,
                                                         currentY)];
            startingY += currentY;
        }
    }
    else if(VALID_NOTEMPTY(billingAddress, RIAddress))
    {
        self.billingAddressView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                                                           startingY,
                                                                           self.scrollView.bounds.size.width,
                                                                           0.0f)];
        self.billingAddressView.backgroundColor = [UIColor whiteColor];
        
        currentY = [self headerLoad:self.billingAddressView title:STRING_BILLING_ADDRESSES selector:@selector(editButtonForBillingAddress)];
        currentY = [self loadAddressInPositionY:currentY address:billingAddress view:self.billingAddressView];
        
        [self.billingAddressView setFrame:CGRectMake(self.billingAddressView.frame.origin.x,
                                                     self.billingAddressView.frame.origin.y,
                                                     self.billingAddressView.frame.size.width,
                                                     currentY)];
        startingY += currentY;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             startingY);
}

- (void)loadWithShippingMethod:(NSString*)shippingMethod
{
    CGFloat startingY =  self.scrollView.contentSize.height;
    
    self.shippingMethodView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                                                       startingY,
                                                                       self.scrollView.bounds.size.width,
                                                                       0.0f)];
    self.shippingMethodView.backgroundColor = [UIColor whiteColor];
    
    CGFloat currentY = [self headerLoad:self.shippingMethodView title:STRING_SHIPPING selector:@selector(editButtonForShippingMethod)] + 15.0f;
    
    currentY += [self addLabelToView:self.shippingMethodView startX:16.0f startY:currentY text:shippingMethod font:JABodyFont color:JABlack800Color] + 16.0f;
    
    [self.shippingMethodView setFrame:CGRectMake(self.shippingMethodView.frame.origin.x,
                                                 self.shippingMethodView.frame.origin.y,
                                                 self.shippingMethodView.frame.size.width,
                                                 currentY)];
    
    startingY += currentY;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             startingY);
}

- (CGFloat)headerLoad:(UIView*)view
                title:(NSString*)title
             selector:(SEL)selector
{
    CGFloat currentY = 0.0f;
    
    [self.scrollView addSubview:view];
    
    JAProductInfoHeaderLine* headerLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, kProductInfoHeaderLineHeight)];
    [headerLine setTitle:title];
    [view addSubview:headerLine];
    
    currentY += headerLine.frame.size.height;
    
    CGFloat rightMargin = 16.0f;
    if (selector)
    {
        UIImage* buttonImage = [UIImage imageNamed:@"editAddress"];
        JAClickableView* editClickableView = [[JAClickableView alloc] init];
        [editClickableView setImage:buttonImage forState:UIControlStateNormal];
        [editClickableView addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        
        [editClickableView setFrame:CGRectMake(view.bounds.size.width - buttonImage.size.width - 20.0f,
                                               view.bounds.origin.y + 10.0f,
                                               buttonImage.size.width + 20.0f,
                                               26.0f)];
        [view addSubview:editClickableView];
        rightMargin += editClickableView.frame.size.width;
    }
    
    return currentY;
}

- (CGFloat)loadProductLabelInPositionY:(CGFloat)currentY
                                  name:(NSString*)name
                              quantity:(NSInteger)quantity
                                 price:(NSString*)price
{
    CGFloat startingX = 16.0f;
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                   currentY,
                                                                   self.cartView.frame.size.width - 2*startingX,
                                                                   1.0f)];
    nameLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    nameLabel.textColor = JAButtonTextOrange;
    nameLabel.text = name;
    nameLabel.numberOfLines = -1;
    [nameLabel sizeToFit];
    [self.cartView addSubview:nameLabel];
    
    currentY += nameLabel.frame.size.height;
    
    UILabel* quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                       currentY,
                                                                       self.cartView.frame.size.width - 2*startingX,
                                                                       1.0f)];
    quantityLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    quantityLabel.textColor = JAButtonTextOrange;
    quantityLabel.numberOfLines = -1;
    quantityLabel.text = [NSString stringWithFormat:@"%ld x %@", (long)quantity, price];
    [quantityLabel sizeToFit];
    [self.cartView addSubview:quantityLabel];
    
    currentY += quantityLabel.frame.size.height;
    
    return currentY;
}

- (CGFloat)loadTotalSectionInPositionY:(CGFloat)currentY
                              subtotal:(NSString*)subtotal
                            priceRules:(NSDictionary *)priceRules
                                 extra:(NSString*)extra
                           shippingFee:(NSString*)shippingFee
                               voucher:(NSString*)voucher
{
    currentY += 15.0f;
    
    CGFloat startingX = 16.0f;
    UILabel* subtotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                       currentY,
                                                                       self.cartView.frame.size.width - 2*startingX,
                                                                       1.0f)];
    subtotalLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    subtotalLabel.textColor = JAButtonTextOrange;
    subtotalLabel.text = STRING_SUBTOTAL;
    [subtotalLabel sizeToFit];
    [self.cartView addSubview:subtotalLabel];
    
    UILabel* subtotalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                            currentY,
                                                                            self.cartView.frame.size.width - 2*startingX,
                                                                            subtotalLabel.frame.size.height)];
    subtotalValueLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    subtotalValueLabel.textColor = JAButtonTextOrange;
    subtotalValueLabel.text = subtotal;
    subtotalValueLabel.textAlignment = NSTextAlignmentRight;
    [self.cartView addSubview:subtotalValueLabel];
    
    currentY += subtotalLabel.frame.size.height + 7.0f;
    
    if (VALID_NOTEMPTY(priceRules, NSDictionary)) {
        
        for (NSString *ruleKey in priceRules) {
            NSString *ruleValue = [priceRules objectForKey:ruleKey];
            
            UILabel* priceRuleLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                                currentY,
                                                                                self.cartView.frame.size.width - 2*startingX,
                                                                                1.0f)];
            priceRuleLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
            priceRuleLabel.textColor = JAButtonTextOrange;
            priceRuleLabel.text = ruleKey;
            [priceRuleLabel sizeToFit];
            [self.cartView addSubview:priceRuleLabel];
            
            UILabel* priceRuleValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                                       currentY,
                                                                                       self.cartView.frame.size.width - 2*startingX,
                                                                                       priceRuleLabel.frame.size.height)];
            priceRuleValueLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
            priceRuleValueLabel.textColor = JAButtonTextOrange;
            priceRuleValueLabel.text = ruleValue;
            priceRuleValueLabel.textAlignment = NSTextAlignmentRight;
            [self.cartView addSubview:priceRuleValueLabel];
            
            currentY += priceRuleValueLabel.frame.size.height;
        }
        currentY += 7.f;
    }
    
    if(![shippingFee isEqualToString:STRING_FREE])
    {
        UILabel* shippingFeeLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                              currentY,
                                                                              self.cartView.frame.size.width - 2*startingX,
                                                                              1.0f)];
        shippingFeeLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        shippingFeeLabel.textColor = JAButtonTextOrange;
        shippingFeeLabel.text = STRING_SHIPPING_FEE;
        [shippingFeeLabel sizeToFit];
        [self.cartView addSubview:shippingFeeLabel];
        
        UILabel* shippingFeeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                                   currentY,
                                                                                   self.cartView.frame.size.width - 2*startingX,
                                                                                   shippingFeeLabel.frame.size.height)];
        shippingFeeValueLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        shippingFeeValueLabel.textColor = JAButtonTextOrange;
        shippingFeeValueLabel.text = shippingFee;
        shippingFeeValueLabel.textAlignment = NSTextAlignmentRight;
        [self.cartView addSubview:shippingFeeValueLabel];
        
        if([shippingFee isEqualToString:STRING_FREE]){
            [shippingFeeValueLabel setHidden:YES];
            [shippingFeeLabel setHidden:YES];
            
        }
        
        currentY += shippingFeeValueLabel.frame.size.height + 7.0f;
    }
    
    if(![extra isEqualToString:STRING_FREE]){
        UILabel* extraLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                        currentY,
                                                                        self.cartView.frame.size.width - 2*startingX,
                                                                        1.0f)];
        extraLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        extraLabel.textColor = JAButtonTextOrange;
        extraLabel.text = STRING_EXTRA_COSTS;
        [extraLabel sizeToFit];
        [self.cartView addSubview:extraLabel];
        
        UILabel* extraValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                             currentY,
                                                                             self.cartView.frame.size.width - 2*startingX,
                                                                             extraLabel.frame.size.height)];
        extraValueLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        extraValueLabel.textColor = JAButtonTextOrange;
        extraValueLabel.text = extra;
        extraValueLabel.textAlignment = NSTextAlignmentRight;
        
        [self.cartView addSubview:extraValueLabel];
        
        currentY += extraLabel.frame.size.height + 7.0f;
    }
    
    
    if(![voucher isEqualToString:STRING_FREE]){
        UILabel* voucherLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                        currentY,
                                                                        self.cartView.frame.size.width - 2*startingX,
                                                                        1.0f)];
        voucherLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        voucherLabel.textColor = JACouponLabelColor;
        voucherLabel.text = STRING_VOUCHER;
        [voucherLabel sizeToFit];
        [self.cartView addSubview:voucherLabel];
        
        UILabel* voucherValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(startingX,
                                                                               currentY,
                                                                               self.cartView.frame.size.width - 2*startingX,
                                                                               voucherLabel.frame.size.height)];
        voucherValueLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        voucherValueLabel.textColor = JACouponLabelColor;
        voucherValueLabel.text = [NSString stringWithFormat:@"- %@", voucher];
        voucherValueLabel.textAlignment = NSTextAlignmentRight;
        currentY += voucherLabel.frame.size.height + 7.0f;
        
        [self.cartView addSubview:voucherValueLabel];
    }
    
    currentY += 3.f;
    
    
    return currentY;
}

- (CGFloat)loadAddressInPositionY:(CGFloat)currentY
                          address:(RIAddress*)address
                             view:(UIView*)view
{
    currentY += 10.0f;
    
    NSString *nameText = @"";
    
    if(VALID_NOTEMPTY(address.firstName, NSString) && VALID_NOTEMPTY(address.lastName, NSString))
    {
        nameText = [NSString stringWithFormat:@"%@ %@", address.firstName, address.lastName];
    }
    else if(VALID_NOTEMPTY(address.firstName, NSString))
    {
        nameText = address.firstName;
    }
    else if(VALID_NOTEMPTY(address.lastName, NSString))
    {
        nameText = address.lastName;
    }
    
    currentY += [self addLabelToView:view startX:16.0f startY:currentY text:nameText font:JAListFont color:JABlackColor] + 6.0f;
    
    NSString* addressText = @"";
    
    if(VALID_NOTEMPTY(address.address, NSString))
    {
        addressText = address.address;
    }
    
    if(VALID_NOTEMPTY(address.address2, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.address2];
        }
        else
        {
            addressText = address.address2;
        }
    }
    
    if(VALID_NOTEMPTY(address.city, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.city];
        }
        else
        {
            addressText = address.city;
        }
    }
    
    if(VALID_NOTEMPTY(address.postcode, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.postcode];
        }
        else
        {
            addressText = address.postcode;
        }
    }
    
    currentY += [self addLabelToView:view startX:16.0f startY:currentY text:addressText font:JABodyFont color:JABlack800Color] + 6.0f;
    
    NSString* phoneText = @"";
    
    if(VALID_NOTEMPTY(address.phone, NSString))
    {
        phoneText = address.phone;
    }
    
    currentY += [self addLabelToView:view startX:16.0f startY:currentY text:phoneText font:JABodyFont color:JABlack800Color] + 10.0f;
    
    return currentY;
}

- (CGFloat)addLabelToView:(UIView*)view startX:(CGFloat)startX startY:(CGFloat)startY text:(NSString*)text font:(UIFont*)font color:(UIColor*)color
{
    UILabel* addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX,
                                                                      startY,
                                                                      view.frame.size.width - 2*startX,
                                                                      0.0f)];
    addressLabel.font = font;
    addressLabel.numberOfLines = 0;
    addressLabel.textColor = color;
    addressLabel.text = text;
    [addressLabel sizeToFit];
    [view addSubview:addressLabel];
    
    return addressLabel.frame.size.height;
}

- (void)editButtonForShippingAddress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                        object:@{@"animated":[NSNumber numberWithBool:YES]}
                                                      userInfo:@{@"from_checkout":[NSNumber numberWithBool:YES]}];
}

- (void)editButtonForBillingAddress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                        object:@{@"animated":[NSNumber numberWithBool:YES]}
                                                      userInfo:@{@"from_checkout":[NSNumber numberWithBool:YES]}];
}

- (void)editButtonForShippingMethod
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutShippingScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

- (void)editButtonForPaymentMethod
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutPaymentScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

@end

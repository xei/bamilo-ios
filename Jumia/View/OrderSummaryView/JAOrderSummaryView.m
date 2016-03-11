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

#define JAOrderSummaryViewTextMargin 6.0f

@interface JAOrderSummaryView()

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UIView* cartView;
@property (nonatomic, strong)UIView* shippingAddressView;
@property (nonatomic, strong)UIView* billingAddressView;
@property (nonatomic, strong)UIView* shippingMethodView;
@property (nonatomic, strong)NSString *extraCosts;

@end

@implementation JAOrderSummaryView

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.scrollView setFrame:self.bounds];
}

- (void)loadWithCart:(RICart *)cart
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.scrollView];
    
    CGFloat topMargin = 6.0f;
    
    self.backgroundColor = JABackgroundGrey;
    
    if (VALID_NOTEMPTY(cart, RICart) && VALID_NOTEMPTY(cart.cartItems, NSArray)) {
        
        self.cartView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                                                 self.scrollView.bounds.origin.y + topMargin,
                                                                 self.scrollView.bounds.size.width,
                                                                 self.scrollView.bounds.size.height)];
        self.cartView.backgroundColor = [UIColor whiteColor];
        self.cartView.layer.cornerRadius = 5.0f;
        
        CGFloat currentY = [self headerLoad:self.cartView title:STRING_ORDER_SUMMARY selector:nil];
        
        currentY += 9.0f; // Margin between title and products
        
        UILabel* productsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.cartView.bounds.origin.x + JAOrderSummaryViewTextMargin,
                                                                                currentY,
                                                                                self.cartView.bounds.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                                26.0f)];
        productsTitleLabel.text = STRING_PRODUCTS;
        productsTitleLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        productsTitleLabel.textColor = JAButtonTextOrange;
        [self.cartView addSubview:productsTitleLabel];
        
        currentY += productsTitleLabel.frame.size.height + 10.0f;
        
        for (RICartItem* cartItem in cart.cartItems) {
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
        if (0 == [cart.shippingValue integerValue])
        {
            shippingFeeValue = STRING_FREE;
        }
        else
        {
            shippingFeeValue = cart.shippingValueFormatted;
        }
        
        NSString *extraCostsValue = nil;
        if (0 == [cart.extraCosts integerValue])
        {
            extraCostsValue = STRING_FREE;
        }
        else
        {
            extraCostsValue = cart.extraCostsFormatted;
        }
        
        NSString *voucherCostsValue = nil;
        if (0 == [cart.couponMoneyValue integerValue])
        {
            voucherCostsValue = STRING_FREE;
        }
        else
        {
            voucherCostsValue = cart.couponMoneyValueFormatted;
        }
        
        currentY = [self loadTotalSectionInPositionY:currentY
                                            subtotal:cart.cartValueFormatted
                                          priceRules:cart.priceRules
                                               extra:extraCostsValue
                                         shippingFee:shippingFeeValue
                                             voucher:voucherCostsValue];
        
        self.extraCosts = cart.extraCostsFormatted;
        
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
        
        [self loadWithShippingAddress:cart.shippingAddress billingAddress:cart.billingAddress];
        
        if (shippingMethod) {
            [self loadWithShippingMethod:cart.shippingMethod];
        }        
    }
}

- (void)loadWithShippingAddress:(RIAddress*)shippingAddress billingAddress:(RIAddress*)billingAddress
{
    CGFloat startingY =  self.scrollView.contentSize.height + 6.0f;
    CGFloat currentY = 0.0f;
    
    if(VALID_NOTEMPTY(shippingAddress, RIAddress))
    {
        self.shippingAddressView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                                                            startingY,
                                                                            self.scrollView.bounds.size.width,
                                                                            0.0f)];
        self.shippingAddressView.backgroundColor = [UIColor whiteColor];
        self.shippingAddressView.layer.cornerRadius = 5.0f;
        
        currentY = [self headerLoad:self.shippingAddressView title:STRING_SHIPPING_ADDRESSES selector:@selector(editButtonForShippingAddress)];
        currentY = [self loadAddressInPositionY:currentY address:shippingAddress view:self.shippingAddressView];
        
        [self.shippingAddressView setFrame:CGRectMake(self.shippingAddressView.frame.origin.x,
                                                      self.shippingAddressView.frame.origin.y,
                                                      self.shippingAddressView.frame.size.width,
                                                      currentY)];
        
        startingY += currentY + 6.0f;
        
        if(VALID_NOTEMPTY(billingAddress, RIAddress) && ![[shippingAddress uid] isEqualToString:[billingAddress uid]])
        {
            self.billingAddressView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                                                               startingY,
                                                                               self.scrollView.bounds.size.width,
                                                                               0.0f)];
            self.billingAddressView.backgroundColor = [UIColor whiteColor];
            self.billingAddressView.layer.cornerRadius = 5.0f;
            
            currentY = [self headerLoad:self.billingAddressView title:STRING_BILLING_ADDRESSES selector:@selector(editButtonForBillingAddress)];
            currentY = [self loadAddressInPositionY:currentY address:billingAddress view:self.billingAddressView];
            
            [self.billingAddressView setFrame:CGRectMake(self.billingAddressView.frame.origin.x,
                                                         self.billingAddressView.frame.origin.y,
                                                         self.billingAddressView.frame.size.width,
                                                         currentY)];
            startingY += currentY + 6.0f;
        }
    }
    else if(VALID_NOTEMPTY(billingAddress, RIAddress))
    {
        self.billingAddressView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                                                           startingY,
                                                                           self.scrollView.bounds.size.width,
                                                                           0.0f)];
        self.billingAddressView.backgroundColor = [UIColor whiteColor];
        self.billingAddressView.layer.cornerRadius = 5.0f;
        
        currentY = [self headerLoad:self.billingAddressView title:STRING_BILLING_ADDRESSES selector:@selector(editButtonForBillingAddress)];
        currentY = [self loadAddressInPositionY:currentY address:billingAddress view:self.billingAddressView];
        
        [self.billingAddressView setFrame:CGRectMake(self.billingAddressView.frame.origin.x,
                                                     self.billingAddressView.frame.origin.y,
                                                     self.billingAddressView.frame.size.width,
                                                     currentY)];
        startingY += currentY + 6.0f;
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
    self.shippingMethodView.layer.cornerRadius = 5.0f;
    
    CGFloat currentY = [self headerLoad:self.shippingMethodView title:STRING_SHIPPING selector:@selector(editButtonForShippingMethod)] + 15.0f;
    
    currentY += [self addLabelToView:self.shippingMethodView startY:currentY text:shippingMethod] + 10.0f;
    
    [self.shippingMethodView setFrame:CGRectMake(self.shippingMethodView.frame.origin.x,
                                                 self.shippingMethodView.frame.origin.y,
                                                 self.shippingMethodView.frame.size.width,
                                                 currentY)];
    
    startingY += currentY + 6.0f;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             startingY);
}

- (CGFloat)headerLoad:(UIView*)view
                title:(NSString*)title
             selector:(SEL)selector
{
    CGFloat currentY = 0.0f;
    
    [self.scrollView addSubview:view];
    
    CGFloat rightMargin = JAOrderSummaryViewTextMargin;
    if (selector)
    {
        UIFont *editFont = [UIFont fontWithName:kFontLightName size:10.0f];
        UIButton* editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setTitle:STRING_EDIT forState:UIControlStateNormal];
        [editButton setTitleColor:JABlue1Color forState:UIControlStateNormal];
        [editButton setTitleColor:JAOrange1Color forState:UIControlStateHighlighted];
        [editButton setTitleColor:JAOrange1Color forState:UIControlStateSelected];
        [editButton.titleLabel setFont:editFont];
        [editButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [editButton sizeToFit];
        CGRect editButtonRect = [STRING_EDIT boundingRectWithSize:CGSizeMake(view.bounds.size.width, 1000.0f)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:editFont} context:nil];
        
        [editButton setFrame:CGRectMake(view.bounds.size.width - editButtonRect.size.width - 20.0f,
                                        view.bounds.origin.y,
                                        editButtonRect.size.width + 20.0f,
                                        26.0f)];
        [view addSubview:editButton];
        rightMargin += editButton.frame.size.width;
    }
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.origin.x + JAOrderSummaryViewTextMargin,
                                                                    currentY,
                                                                    view.bounds.size.width -JAOrderSummaryViewTextMargin - rightMargin,
                                                                    26.0f)];
    titleLabel.text = title;
    titleLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
    titleLabel.textColor = JAButtonTextOrange;
    [view addSubview:titleLabel];
    
    currentY += titleLabel.frame.size.height;
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(view.bounds.origin.x,
                                                                view.bounds.origin.y + titleLabel.frame.size.height,
                                                                view.bounds.size.width,
                                                                1.0f)];
    lineView.backgroundColor = JAOrange1Color;
    [view addSubview:lineView];
    currentY += lineView.frame.size.height;
    
    
    return currentY;
}

- (CGFloat)loadProductLabelInPositionY:(CGFloat)currentY
                                  name:(NSString*)name
                              quantity:(NSInteger)quantity
                                 price:(NSString*)price
{
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                   currentY,
                                                                   self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                   1.0f)];
    nameLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    nameLabel.textColor = JAButtonTextOrange;
    nameLabel.text = name;
    nameLabel.numberOfLines = -1;
    [nameLabel sizeToFit];
    [self.cartView addSubview:nameLabel];
    
    currentY += nameLabel.frame.size.height;
    
    UILabel* quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                       currentY,
                                                                       self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
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
    
    UILabel* subtotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                       currentY,
                                                                       self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                       1.0f)];
    subtotalLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    subtotalLabel.textColor = JAButtonTextOrange;
    subtotalLabel.text = STRING_SUBTOTAL;
    [subtotalLabel sizeToFit];
    [self.cartView addSubview:subtotalLabel];
    
    UILabel* subtotalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                            currentY,
                                                                            self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
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
            
            UILabel* priceRuleLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                                  currentY,
                                                                                  self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                                  1.0f)];
            priceRuleLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
            priceRuleLabel.textColor = JAButtonTextOrange;
            priceRuleLabel.text = ruleKey;
            [priceRuleLabel sizeToFit];
            [self.cartView addSubview:priceRuleLabel];
            
            UILabel* priceRuleValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                                       currentY,
                                                                                       self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
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
        UILabel* shippingFeeLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                              currentY,
                                                                              self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                              1.0f)];
        shippingFeeLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        shippingFeeLabel.textColor = JAButtonTextOrange;
        shippingFeeLabel.text = STRING_SHIPPING_FEE;
        [shippingFeeLabel sizeToFit];
        [self.cartView addSubview:shippingFeeLabel];
        
        UILabel* shippingFeeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                                   currentY,
                                                                                   self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
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
        UILabel* extraLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                        currentY,
                                                                        self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                        1.0f)];
        extraLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        extraLabel.textColor = JAButtonTextOrange;
        extraLabel.text = STRING_EXTRA_COSTS;
        [extraLabel sizeToFit];
        [self.cartView addSubview:extraLabel];
        
        UILabel* extraValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                             currentY,
                                                                             self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                             extraLabel.frame.size.height)];
        extraValueLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        extraValueLabel.textColor = JAButtonTextOrange;
        extraValueLabel.text = extra;
        extraValueLabel.textAlignment = NSTextAlignmentRight;
        
        [self.cartView addSubview:extraValueLabel];
        
        currentY += extraLabel.frame.size.height + 7.0f;
    }
    
    
    if(![voucher isEqualToString:STRING_FREE]){
        UILabel* voucherLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                        currentY,
                                                                        self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                        1.0f)];
        voucherLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        voucherLabel.textColor = JACouponLabelColor;
        voucherLabel.text = STRING_VOUCHER;
        [voucherLabel sizeToFit];
        [self.cartView addSubview:voucherLabel];
        
        UILabel* voucherValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                             currentY,
                                                                             self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
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
    currentY += 15.0f;
    
    NSString *addressText = @"";
    
    if(VALID_NOTEMPTY(address.firstName, NSString) && VALID_NOTEMPTY(address.lastName, NSString))
    {
        addressText = [NSString stringWithFormat:@"%@ %@", address.firstName, address.lastName];
    }
    else if(VALID_NOTEMPTY(address.firstName, NSString))
    {
        addressText = address.firstName;
    }
    else if(VALID_NOTEMPTY(address.lastName, NSString))
    {
        addressText = address.lastName;
    }
    
    if(VALID_NOTEMPTY(address.address, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@\n%@",addressText, address.address];
        }
        else
        {
            addressText = address.address;
        }
    }
    
    if(VALID_NOTEMPTY(address.address2, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@\n%@",addressText, address.address2];
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
            addressText = [NSString stringWithFormat:@"%@\n%@",addressText, address.city];
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
            addressText = [NSString stringWithFormat:@"%@\n%@",addressText, address.postcode];
        }
        else
        {
            addressText = address.postcode;
        }
    }
    
    if(VALID_NOTEMPTY(address.phone, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@\n%@",addressText, address.phone];
        }
        else
        {
            addressText = address.phone;
        }
    }
    
    currentY += [self addLabelToView:view startY:currentY text:addressText] + 10.0f;
    
    return currentY;
}

- (CGFloat)addLabelToView:(UIView*)view startY:(CGFloat)startY text:(NSString*)text
{
    UILabel* addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                      startY,
                                                                      view.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                      0.0f)];
    addressLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    addressLabel.numberOfLines = 0;
    addressLabel.textColor = JAButtonTextOrange;
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

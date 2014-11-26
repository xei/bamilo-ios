//
//  JAOrderSummaryView.m
//  Jumia
//
//  Created by Telmo Pinto on 24/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAOrderSummaryView.h"
#import "RICartItem.h"

#define JAOrderSummaryViewTextMargin 6.0f

@interface JAOrderSummaryView()

@property (nonatomic, assign) CGRect initialFrame;

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UIView* cartView;
@property (nonatomic, strong)UIView* shippingAddressView;
@property (nonatomic, strong)UIView* billingAddressView;

@end

@implementation JAOrderSummaryView

- (void)loadWithCart:(RICart *)cart
{
    self.backgroundColor = JABackgroundGrey;
    
    self.initialFrame = self.bounds;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.initialFrame];
    [self addSubview:self.scrollView];
    
    if (VALID_NOTEMPTY(cart, RICart) && VALID_NOTEMPTY(cart.cartItems, NSArray)) {
        
        self.cartView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
        self.cartView.backgroundColor = [UIColor whiteColor];
        self.cartView.layer.cornerRadius = 5.0f;
        
        CGFloat currentY = [self headerLoad:self.cartView title:STRING_ORDER_SUMMARY selector:nil];
        
        currentY += 9.0f;
        
        UILabel* productsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.cartView.bounds.origin.x + JAOrderSummaryViewTextMargin,
                                                                                currentY,
                                                                                self.cartView.bounds.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                                26.0f)];
        productsTitleLabel.text = STRING_PRODUCTS;
        productsTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        productsTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
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
        
        currentY = [self loadTotalSectionInPositionY:currentY
                                                 vat:cart.vatValueFormatted
                                            subtotal:cart.cartValueFormatted
                                               extra:cart.extraCostsFormatted];
        
        [self.cartView setFrame:CGRectMake(self.cartView.frame.origin.x,
                                           self.cartView.frame.origin.y,
                                           self.cartView.frame.size.width,
                                           currentY)];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                                 currentY);
        
        CGFloat readjustedHeight = MIN(self.scrollView.contentSize.height, self.frame.size.height);
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  readjustedHeight)];
        [self.scrollView setFrame:self.bounds];
    }
}

- (void)loadWithCheckout:(RICheckout*)checkout
{
    if(VALID_NOTEMPTY(checkout, RICheckout))
    {
        [self loadWithCart:checkout.cart];
        
        if(VALID_NOTEMPTY(checkout.orderSummary, RIOrder))
        {
            RIAddress *shippingAddress = checkout.orderSummary.shippingAddress;
            RIAddress *billingAddress = checkout.orderSummary.billingAddress;
            [self loadWithShippingAddress:shippingAddress billingAddress:billingAddress];
        }
    }
}

- (void)loadWithShippingAddress:(RIAddress*)shippingAddress billingAddress:(RIAddress*)billingAddress
{
    CGFloat startingY = 0.0f;
    CGFloat currentY = 0.0f;
    if(VALID_NOTEMPTY(self.cartView, UIView) && VALID_NOTEMPTY(self.cartView.superview, UIView))
    {
        startingY = CGRectGetMaxY(self.cartView.frame) + 6.0f;
    }
    
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
    
    CGFloat readjustedHeight = MIN(self.scrollView.contentSize.height, self.initialFrame.size.height);
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              readjustedHeight)];
    
    [self.scrollView setFrame:self.bounds];
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
        UIFont *editFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f];
        UIButton* editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setTitle:STRING_EDIT forState:UIControlStateNormal];
        [editButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
        [editButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
        [editButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateSelected];
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
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    titleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    [view addSubview:titleLabel];
    
    currentY += titleLabel.frame.size.height;
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(view.bounds.origin.x,
                                                                view.bounds.origin.y + titleLabel.frame.size.height,
                                                                view.bounds.size.width,
                                                                1.0f)];
    lineView.backgroundColor = UIColorFromRGB(0xfaa41a);
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
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    nameLabel.textColor = UIColorFromRGB(0x4e4e4e);
    nameLabel.text = name;
    nameLabel.numberOfLines = -1;
    [nameLabel sizeToFit];
    [self.cartView addSubview:nameLabel];
    
    currentY += nameLabel.frame.size.height;
    
    UILabel* quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                       currentY,
                                                                       self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                       1.0f)];
    quantityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    quantityLabel.textColor = UIColorFromRGB(0x4e4e4e);
    quantityLabel.numberOfLines = -1;
    quantityLabel.text = [NSString stringWithFormat:@"%d x %@", quantity, price];
    [quantityLabel sizeToFit];
    [self.cartView addSubview:quantityLabel];
    
    currentY += quantityLabel.frame.size.height;
    
    return currentY;
}

- (CGFloat)loadTotalSectionInPositionY:(CGFloat)currentY
                                   vat:(NSString*)vat
                              subtotal:(NSString*)subtotal
                                 extra:(NSString*)extra
{
    currentY += 15.0f;
    
    UILabel* VATLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                  currentY,
                                                                  self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                  1.0f)];
    VATLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    VATLabel.textColor = UIColorFromRGB(0x4e4e4e);
    VATLabel.text = STRING_VAT;
    [VATLabel sizeToFit];
    [self.cartView addSubview:VATLabel];
    
    UILabel* VATValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                       currentY,
                                                                       self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                       VATLabel.frame.size.height)];
    VATValueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    VATValueLabel.textColor = UIColorFromRGB(0x4e4e4e);
    VATValueLabel.text = vat;
    VATValueLabel.textAlignment = NSTextAlignmentRight;
    [self.cartView addSubview:VATValueLabel];
    
    currentY += VATLabel.frame.size.height + 7.0f;
    
    
    
    UILabel* subtotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                       currentY,
                                                                       self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                       1.0f)];
    subtotalLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    subtotalLabel.textColor = UIColorFromRGB(0x4e4e4e);
    subtotalLabel.text = STRING_SUBTOTAL;
    [subtotalLabel sizeToFit];
    [self.cartView addSubview:subtotalLabel];
    
    UILabel* subtotalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                            currentY,
                                                                            self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                            subtotalLabel.frame.size.height)];
    subtotalValueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    subtotalValueLabel.textColor = UIColorFromRGB(0x4e4e4e);
    subtotalValueLabel.text = subtotal;
    subtotalValueLabel.textAlignment = NSTextAlignmentRight;
    [self.cartView addSubview:subtotalValueLabel];
    
    currentY += subtotalLabel.frame.size.height + 7.0f;
    
    
    
    UILabel* extraLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                    currentY,
                                                                    self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                    1.0f)];
    extraLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    extraLabel.textColor = UIColorFromRGB(0x4e4e4e);
    extraLabel.text = STRING_EXTRA_COSTS;
    [extraLabel sizeToFit];
    [self.cartView addSubview:extraLabel];
    
    UILabel* extraValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                         currentY,
                                                                         self.cartView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                         extraLabel.frame.size.height)];
    extraValueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    extraValueLabel.textColor = UIColorFromRGB(0x4e4e4e);
    extraValueLabel.text = extra;
    extraValueLabel.textAlignment = NSTextAlignmentRight;
    [self.cartView addSubview:extraValueLabel];
    
    currentY += extraLabel.frame.size.height + 10.0f;
    
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
    
    UILabel* addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                      currentY,
                                                                      view.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                      0.0f)];
    addressLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    addressLabel.numberOfLines = 0;
    addressLabel.textColor = UIColorFromRGB(0x4e4e4e);
    addressLabel.text = addressText;
    [addressLabel sizeToFit];
    [view addSubview:addressLabel];
    
    currentY += addressLabel.frame.size.height + 10.0f;
    
    return currentY;
}

- (void)editButtonForShippingAddress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

- (void)editButtonForBillingAddress
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

@end

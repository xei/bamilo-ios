//
//  JAOrderViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAOrderViewController.h"
#import "JAButtonWithBlur.h"
#import "RICartItem.h"
#import "UIImageView+WebCache.h"

@interface JAOrderViewController ()

@property (nonatomic, assign) NSInteger currentY;
@property (nonatomic, strong) UIScrollView* scrollView;

// Bottom view
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@end

@implementation JAOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.title = STRING_CHECKOUT;
    self.navBarLayout.showCartButton = NO;
    
    self.view.backgroundColor = JABackgroundGrey;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                     self.view.bounds.origin.y,
                                                                     self.view.bounds.size.width,
                                                                     self.view.bounds.size.height - 64.0f)];
    [self.view addSubview:self.scrollView];
    
    [self setupViews];
}

-(void)setupViews
{
    //relative to scroll
    self.currentY = self.scrollView.bounds.origin.y + 6.0f;
    [self setupOrderView];
    [self setupSubtotalView];
    NSString* shippingAddress = [self getAddressStringFromAddress:self.checkout.orderSummary.shippingAddress];
    NSString* billingAddress = [self getAddressStringFromAddress:self.checkout.orderSummary.billingAddress];
    if ([billingAddress isEqualToString:shippingAddress]) {
        billingAddress = STRING_BILLING_SAME_ADDRESSES;
    }
    [self setupGenericAddressViewWithTitle:STRING_SHIPPING_ADDRESSES address:shippingAddress];
    [self setupGenericAddressViewWithTitle:STRING_BILLING_ADDRESSES address:billingAddress];
    [self setupPaymentOptionsView];
    
    //not relative to scroll
    [self setupConfirmButton];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                               self.currentY + self.bottomView.frame.size.height)];
}

- (void)setupOrderView
{
    UIView* orderContentView = [self placeContentViewWithTitle:STRING_MY_ORDER_LABEL atYPosition:self.currentY];
    
    __block BOOL firstIteration = YES;
    [self.checkout.cart.cartItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (VALID_NOTEMPTY(obj, RICartItem)) {
            if (firstIteration) {
                firstIteration = NO;
            } else {
                [self placeGreySeparatorInContentView:orderContentView];
            }
            [self placeCartItemCell:obj inContentView:orderContentView];
        }
    }];
    
    self.currentY += orderContentView.frame.size.height + 5.0f;
}

- (void)placeCartItemCell:(RICartItem*)cartItem
            inContentView:(UIView*)contentView
{
    UIView* itemCell = [[UIView alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x,
                                                                contentView.bounds.size.height,
                                                                contentView.bounds.size.width,
                                                                89)];
    [contentView addSubview:itemCell];
    
    contentView.frame = CGRectMake(contentView.frame.origin.x,
                                   contentView.frame.origin.y,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height + itemCell.frame.size.height);
    
    
    //details inside itemCell
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemCell.bounds.origin.x + 8.0f,
                                                                           itemCell.bounds.origin.y + 2.0f,
                                                                           68.0f,
                                                                           85.0f)];

    [imageView setImageWithURL:[NSURL URLWithString:cartItem.imageUrl]
              placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    [itemCell addSubview:imageView];
    
    UILabel* nameLabel = [UILabel new];
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    nameLabel.textColor = UIColorFromRGB(0x666666);
    nameLabel.text = cartItem.name;
    [nameLabel sizeToFit];
    nameLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 8.0f,
                                 itemCell.bounds.origin.y + 15.0f,
                                 itemCell.frame.size.width - imageView.frame.size.width - 8.0f*2,
                                 nameLabel.frame.size.height);
    [itemCell addSubview:nameLabel];
    
    UILabel* quantityLabel = [UILabel new];
    quantityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    quantityLabel.textColor = UIColorFromRGB(0x666666);
    quantityLabel.text = [NSString stringWithFormat:STRING_QUANTITY, cartItem.quantity];
    [quantityLabel sizeToFit];
    quantityLabel.frame = CGRectMake(nameLabel.frame.origin.x,
                                     CGRectGetMaxY(nameLabel.frame) + 5.0f,
                                     nameLabel.frame.size.width,
                                     quantityLabel.frame.size.height);
    [itemCell addSubview:quantityLabel];
    
    UILabel* priceLabel = [UILabel new];
    priceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    priceLabel.textColor = UIColorFromRGB(0x666666);
    priceLabel.text = cartItem.priceFormatted;
    if (VALID_NOTEMPTY(cartItem.specialPriceFormatted, NSString)) {
        priceLabel.text = cartItem.specialPriceFormatted;
    }
    [priceLabel sizeToFit];
    priceLabel.frame = CGRectMake(nameLabel.frame.origin.x,
                                  CGRectGetMaxY(quantityLabel.frame),
                                  nameLabel.frame.size.width,
                                  priceLabel.frame.size.height);
    [itemCell addSubview:priceLabel];
    
    UILabel* sizeLabel = [UILabel new];
    sizeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    sizeLabel.textColor = UIColorFromRGB(0x666666);
    sizeLabel.text = cartItem.variation;
    [sizeLabel sizeToFit];
    sizeLabel.frame = CGRectMake(nameLabel.frame.origin.x,
                                 CGRectGetMaxY(priceLabel.frame),
                                 nameLabel.frame.size.width,
                                 sizeLabel.frame.size.height);
    [itemCell addSubview:sizeLabel];
}

- (void)placeGreySeparatorInContentView:(UIView*)contentView
{
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x,
                                                                 contentView.bounds.size.height,
                                                                 contentView.bounds.size.width,
                                                                 1)];
    separator.backgroundColor = JALabelGrey;
    
    [contentView addSubview:separator];
    
    contentView.frame = CGRectMake(contentView.frame.origin.x,
                                   contentView.frame.origin.y,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height + separator.frame.size.height);
}

- (void)setupSubtotalView
{
    UIView* subtotalContentView = [self placeContentViewWithTitle:STRING_SUBTOTAL atYPosition:self.currentY];
    
    UILabel* articlesLabel = [UILabel new];
    articlesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    articlesLabel.textColor = UIColorFromRGB(0x666666);
    articlesLabel.text = [NSString stringWithFormat:STRING_ARTICLES, self.checkout.cart.cartCount];
    if (1 == [self.checkout.cart.cartCount integerValue]) {
        articlesLabel.text = STRING_ARTICLE;
    }
    [articlesLabel sizeToFit];
    articlesLabel.frame = CGRectMake(subtotalContentView.bounds.origin.x + 6.0f,
                                     subtotalContentView.frame.size.height + 10.0f,
                                     (subtotalContentView.frame.size.width / 2) - 6.0f,
                                     articlesLabel.frame.size.height);
    [subtotalContentView addSubview:articlesLabel];
    
    UILabel* totalLabel = [UILabel new];
    totalLabel.textAlignment = NSTextAlignmentRight;
    totalLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    totalLabel.textColor = UIColorFromRGB(0x666666);
    totalLabel.text = self.checkout.cart.cartValueFormatted;
    [totalLabel sizeToFit];
    totalLabel.frame = CGRectMake(CGRectGetMaxX(articlesLabel.frame),
                                     articlesLabel.frame.origin.y,
                                     (subtotalContentView.frame.size.width / 2) - 6.0f,
                                     totalLabel.frame.size.height);
    [subtotalContentView addSubview:totalLabel];
    
    UILabel* vatLabel = [UILabel new];
    vatLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    vatLabel.textColor = UIColorFromRGB(0x666666);
    vatLabel.text = STRING_VAT;
    [vatLabel sizeToFit];
    vatLabel.frame = CGRectMake(articlesLabel.frame.origin.x,
                                CGRectGetMaxY(articlesLabel.frame),
                                articlesLabel.frame.size.width,
                                vatLabel.frame.size.height);
    [subtotalContentView addSubview:vatLabel];
    
    UILabel* vatValueLabel = [UILabel new];
    vatValueLabel.textAlignment = NSTextAlignmentRight;
    vatValueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    vatValueLabel.textColor = UIColorFromRGB(0x666666);
    vatValueLabel.text = self.checkout.cart.vatValueFormatted;
    [vatValueLabel sizeToFit];
    vatValueLabel.frame = CGRectMake(CGRectGetMaxX(vatLabel.frame),
                                     vatLabel.frame.origin.y,
                                     totalLabel.frame.size.width,
                                     vatValueLabel.frame.size.height);
    [subtotalContentView addSubview:vatValueLabel];
    
    UILabel* shippingLabel = [UILabel new];
    shippingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    shippingLabel.textColor = UIColorFromRGB(0x666666);
    shippingLabel.text = STRING_SHIPPING;
    [shippingLabel sizeToFit];
    shippingLabel.frame = CGRectMake(articlesLabel.frame.origin.x,
                                     CGRectGetMaxY(vatLabel.frame),
                                     articlesLabel.frame.size.width,
                                     vatLabel.frame.size.height);
    [subtotalContentView addSubview:shippingLabel];
    
    UILabel* shippingValueLabel = [UILabel new];
    shippingValueLabel.textAlignment = NSTextAlignmentRight;
    shippingValueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    shippingValueLabel.textColor = UIColorFromRGB(0x666666);
    shippingValueLabel.text = self.checkout.cart.shippingValueFormatted;
    [shippingValueLabel sizeToFit];
    shippingValueLabel.frame = CGRectMake(CGRectGetMaxX(shippingLabel.frame),
                                          shippingLabel.frame.origin.y,
                                          totalLabel.frame.size.width,
                                          shippingValueLabel.frame.size.height);
    [subtotalContentView addSubview:shippingValueLabel];
    
    UILabel* extraCostsLabel = [UILabel new];
    extraCostsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    extraCostsLabel.textColor = UIColorFromRGB(0x666666);
    extraCostsLabel.text = STRING_EXTRA_COSTS;
    [extraCostsLabel sizeToFit];
    extraCostsLabel.frame = CGRectMake(articlesLabel.frame.origin.x,
                                     CGRectGetMaxY(shippingLabel.frame),
                                     articlesLabel.frame.size.width,
                                     extraCostsLabel.frame.size.height);
    [subtotalContentView addSubview:extraCostsLabel];
    
    UILabel* extraCostsValueLabel = [UILabel new];
    extraCostsValueLabel.textAlignment = NSTextAlignmentRight;
    extraCostsValueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    extraCostsValueLabel.textColor = UIColorFromRGB(0x666666);
    extraCostsValueLabel.text = self.checkout.cart.extraCostsFormatted;
    [extraCostsValueLabel sizeToFit];
    extraCostsValueLabel.frame = CGRectMake(CGRectGetMaxX(extraCostsLabel.frame),
                                            extraCostsLabel.frame.origin.y,
                                            totalLabel.frame.size.width,
                                            extraCostsValueLabel.frame.size.height);
    [subtotalContentView addSubview:extraCostsValueLabel];
    
    subtotalContentView.frame = CGRectMake(subtotalContentView.frame.origin.x,
                                           subtotalContentView.frame.origin.y,
                                           subtotalContentView.frame.size.width,
                                           CGRectGetMaxY(extraCostsLabel.frame) + 10.0f);
    
    self.currentY += subtotalContentView.frame.size.height + 5.0f;
}

- (void)setupGenericAddressViewWithTitle:(NSString*)title
                                 address:(NSString*)address
{
    UIView* addressContentView = [self placeContentViewWithTitle:title atYPosition:self.currentY];
    
    UILabel* addressLabel = [UILabel new];
    addressLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    addressLabel.textColor = UIColorFromRGB(0x666666);
    addressLabel.text = address;
    addressLabel.numberOfLines = 0;
    [addressLabel sizeToFit];
    addressLabel.frame = CGRectMake(addressContentView.bounds.origin.x + 6.0f,
                                    addressContentView.frame.size.height + 10.0f,
                                    addressContentView.frame.size.width - 6.0f,
                                    addressLabel.frame.size.height);
    [addressContentView addSubview:addressLabel];
    
    addressContentView.frame = CGRectMake(addressContentView.frame.origin.x,
                                          addressContentView.frame.origin.y,
                                          addressContentView.frame.size.width,
                                          CGRectGetMaxY(addressLabel.frame) + 10.0f);
    
    self.currentY += addressContentView.frame.size.height + 5.0f;
}

- (NSString*)getAddressStringFromAddress:(RIAddress*)address;
{
    NSString* addressText = @"";
    
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
    
    return addressText;
}

- (void)setupPaymentOptionsView
{
    UIView* paymentContentView = [self placeContentViewWithTitle:STRING_PAYMENT_METHOD atYPosition:self.currentY];
    
    UILabel* paymentTitleLabel = [UILabel new];
    paymentTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    paymentTitleLabel.textColor = UIColorFromRGB(0x666666);
    paymentTitleLabel.text = self.checkout.orderSummary.paymentMethod;
    paymentTitleLabel.numberOfLines = 0;
    [paymentTitleLabel sizeToFit];
    paymentTitleLabel.frame = CGRectMake(paymentContentView.bounds.origin.x + 6.0f,
                                    paymentContentView.frame.size.height + 10.0f,
                                    paymentContentView.frame.size.width - 6.0f,
                                    paymentTitleLabel.frame.size.height);
    [paymentContentView addSubview:paymentTitleLabel];
    
    paymentContentView.frame = CGRectMake(paymentContentView.frame.origin.x,
                                          paymentContentView.frame.origin.y,
                                          paymentContentView.frame.size.width,
                                          CGRectGetMaxY(paymentTitleLabel.frame));
    
    if (VALID_NOTEMPTY(self.checkout.orderSummary.discountCouponCode, NSString)) {
        
        UILabel* couponTitleLabel = [UILabel new];
        couponTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        couponTitleLabel.textColor = UIColorFromRGB(0x666666);
        couponTitleLabel.text = self.checkout.orderSummary.paymentMethod;
        couponTitleLabel.numberOfLines = 0;
        [couponTitleLabel sizeToFit];
        couponTitleLabel.frame = CGRectMake(paymentContentView.bounds.origin.x + 6.0f,
                                            CGRectGetMaxY(paymentTitleLabel.frame) + 15.0f,
                                            paymentContentView.frame.size.width - 6.0f,
                                            couponTitleLabel.frame.size.height);
        [paymentContentView addSubview:couponTitleLabel];
        
        UILabel* couponCodeLabel = [UILabel new];
        couponCodeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        couponCodeLabel.textColor = UIColorFromRGB(0x666666);
        couponCodeLabel.text = self.checkout.orderSummary.paymentMethod;
        couponCodeLabel.numberOfLines = 0;
        [couponCodeLabel sizeToFit];
        couponCodeLabel.frame = CGRectMake(paymentContentView.bounds.origin.x + 6.0f,
                                           CGRectGetMaxY(couponTitleLabel.frame) + 5.0f,
                                           paymentContentView.frame.size.width - 6.0f,
                                           couponCodeLabel.frame.size.height);
        [paymentContentView addSubview:couponCodeLabel];
        
        paymentContentView.frame = CGRectMake(paymentContentView.frame.origin.x,
                                              paymentContentView.frame.origin.y,
                                              paymentContentView.frame.size.width,
                                              CGRectGetMaxY(paymentContentView.frame));
    }
    

    paymentContentView.frame = CGRectMake(paymentContentView.frame.origin.x,
                                          paymentContentView.frame.origin.y,
                                          paymentContentView.frame.size.width,
                                          paymentContentView.frame.size.height + 10.0f);
    
    self.currentY += paymentContentView.frame.size.height + 5.0f;
}

- (void)setupConfirmButton
{
    self.bottomView = [[JAButtonWithBlur alloc] init];
    [self.bottomView setFrame:CGRectMake(0.0f, self.view.frame.size.height - 64.0f - self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
    [self.bottomView addButton:STRING_NEXT target:self action:@selector(nextStepButtonPressed)];
    
    [self.view addSubview:self.bottomView];
}

#pragma mark - Content view auxiliary methods

- (UIView*)placeContentViewWithTitle:(NSString*)title
                         atYPosition:(CGFloat)yPosition;
{
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(6.0f,
                                                                   yPosition,
                                                                   self.view.frame.size.width - 2*6.0f,
                                                                   1)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 5.0f;
    [self.scrollView addSubview:contentView];
    
    [self addTitle:title toContentView:contentView];
    
    return contentView;
}

- (void)addTitle:(NSString*)title
   toContentView:(UIView*)contentView
{
    CGFloat currentContentY = contentView.bounds.origin.y;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x + 6.0f,
                                                                    currentContentY,
                                                                    contentView.bounds.size.width - 2*6.0f,
                                                                    26.0f)];
    titleLabel.text = title;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    titleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    [contentView addSubview:titleLabel];
    
    currentContentY += titleLabel.frame.size.height;
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x,
                                                                contentView.bounds.origin.y + 26.0f,
                                                                contentView.bounds.size.width,
                                                                1.0f)];
    lineView.backgroundColor = UIColorFromRGB(0xfaa41a);
    [contentView addSubview:lineView];
    
    currentContentY += lineView.frame.size.height;
    
    [contentView setFrame:CGRectMake(contentView.frame.origin.x,
                                     contentView.frame.origin.y,
                                     contentView.frame.size.width,
                                     currentContentY)];
}


#pragma mark - Button actions

-(void)nextStepButtonPressed
{
    [self showLoading];
    
    [RICheckout finishCheckoutWithSuccessBlock:^(RICheckout *checkout) {
        NSLog(@"SUCCESS Finishing checkout");
        
        if(VALID_NOTEMPTY(checkout.paymentInformation, RIPaymentInformation))
        {
            if(RIPaymentInformationCheckoutEnded == checkout.paymentInformation.type)
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[checkout.orderNr, checkout] forKeys:@[@"order_number", @"checkout"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutThanksScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
                
            }
            else
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[checkout] forKeys:@[@"checkout"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutExternalPaymentsScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
        }
        
        [self hideLoading];
    } andFailureBlock:^(NSArray *errorMessages) {
        
        NSLog(@"FAILED Finishing checkout");
        [self hideLoading];
    }];
}

@end

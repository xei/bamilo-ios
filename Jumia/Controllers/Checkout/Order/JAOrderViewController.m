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
#import "RICustomer.h"
#import "UIImageView+WebCache.h"
#import "RIAddress.h"
#import "RIPaymentInformation.h"
#import "JAUtils.h"

#define kScrollViewTag 9999

@interface JAOrderViewController ()

@property (nonatomic, strong)RICart* cart;

@property (nonatomic, assign) NSInteger scrollViewCurrentY;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIScrollView* secondScrollView;

@property (assign, nonatomic) RIApiResponse apiResponse;

// Bottom view
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@property (nonatomic, assign) BOOL alreadyLoadedConfirmButton;

@end

@implementation JAOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"OrderConfirmation";
    
    self.navBarLayout.title = STRING_CHECKOUT;
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showBackButton = YES;
    
    self.view.backgroundColor = JABackgroundGrey;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                     self.view.bounds.origin.y,
                                                                     self.view.bounds.size.width,
                                                                     self.view.bounds.size.height)];
    [self.scrollView setHidden:YES];
    [self.scrollView setShowsVerticalScrollIndicator:YES];
    [self.view addSubview:self.scrollView];
    
    self.bottomView = [[JAButtonWithBlur alloc] initWithFrame:CGRectMake(0.0f,
                                                                         self.view.frame.size.height - self.bottomView.frame.size.height,
                                                                         self.view.frame.size.width,
                                                                         self.bottomView.frame.size.height)
                                                  orientation:UIInterfaceOrientationPortrait];
    [self.bottomView setHidden:YES];
    [self.view addSubview:self.bottomView];
    
    [self loadStep];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"CheckoutMyOrder" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutOrder]
                                              data:[trackingDictionary copy]];
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
}

- (void)loadStep
{
    self.apiResponse = RIApiResponseSuccess;
    
    [self showLoading];
    
    [RICart getMultistepFinishWithSuccessBlock:^(RICart *cart) {
        self.cart = cart;
        [self setupViews];
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadStep) objects:nil];
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckOrderSummary"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    [self.scrollView setHidden:YES];
    
    if(VALID_NOTEMPTY(self.secondScrollView, UIScrollView))
    {
        [self.secondScrollView setHidden:YES];
    }
    
    [self.bottomView setHidden:YES];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupViews];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(void)setupViews
{
    if(VALID_NOTEMPTY(self.scrollView, UIScrollView))
    {
        for(UIView *view in self.scrollView.subviews)
        {
            if(kScrollViewTag == view.tag)
            {
                [view removeFromSuperview];
            }
        }
    }
    
    CGFloat horizontalMargin = 6.0f;
    CGFloat viewsWidth = self.view.frame.size.width - (2 * horizontalMargin);
    CGFloat originY = 0.0f;

    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        viewsWidth = (self.view.frame.size.width - (3 * horizontalMargin)) / 2;
        self.secondScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(horizontalMargin + viewsWidth + horizontalMargin,
                                                                               originY,
                                                                               viewsWidth,
                                                                               self.view.bounds.size.height)];
        [self.secondScrollView setShowsVerticalScrollIndicator:YES];
        [self.view addSubview:self.secondScrollView];
    }
    else
    {
        if(VALID_NOTEMPTY(self.secondScrollView, UIScrollView))
        {
            for(UIView *view in self.secondScrollView.subviews)
            {
                if(kScrollViewTag == view.tag)
                {
                    [view removeFromSuperview];
                }
            }
            [self.secondScrollView removeFromSuperview];
            self.secondScrollView = nil;
        }
    }
    
    [self.scrollView setFrame:CGRectMake(horizontalMargin,
                                         originY,
                                         viewsWidth,
                                         self.view.bounds.size.height)];
    [self.scrollView setShowsVerticalScrollIndicator:YES];
    
    //relative to scroll
    self.scrollViewCurrentY = self.scrollView.frame.origin.y + 6.0f;
    self.scrollViewCurrentY += [self setupOrderView:self.scrollView atYPostion:self.scrollViewCurrentY];
    self.scrollViewCurrentY += [self setupSubtotalView:self.scrollView atYPostion:self.scrollViewCurrentY];

    // If we have a second scroll view
    if(VALID_NOTEMPTY(self.secondScrollView, UIScrollView))
    {
        CGFloat secondScrollViewCurrentY = self.secondScrollView.frame.origin.y + 6.0f;
        secondScrollViewCurrentY += [self setupShippingAddressView:self.secondScrollView atYPostion:secondScrollViewCurrentY];
        secondScrollViewCurrentY += [self setupBillingAddressView:self.secondScrollView atYPostion:secondScrollViewCurrentY];
        secondScrollViewCurrentY += [self setupShippingMethodView:self.secondScrollView atYPostion:secondScrollViewCurrentY];
        secondScrollViewCurrentY += [self setupPaymentOptionsView:self.secondScrollView atYPostion:secondScrollViewCurrentY];
        
        [self.secondScrollView setContentSize:CGSizeMake(self.secondScrollView.frame.size.width,
                                                         secondScrollViewCurrentY + self.bottomView.frame.size.height)];
    }
    else
    {
        self.scrollViewCurrentY += [self setupShippingAddressView:self.scrollView atYPostion:self.scrollViewCurrentY];
        self.scrollViewCurrentY += [self setupBillingAddressView:self.scrollView atYPostion:self.scrollViewCurrentY];
        self.scrollViewCurrentY += [self setupShippingMethodView:self.scrollView atYPostion:self.scrollViewCurrentY];
        self.scrollViewCurrentY += [self setupPaymentOptionsView:self.scrollView atYPostion:self.scrollViewCurrentY];
    }
    
    //not relative to scroll
    [self setupConfirmButton];
    
    [self.scrollView setHidden:NO];
    
    CGFloat offset = 0.0;
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM()){
        //For some reason on iphone ios9 the view controller's view doesn't take the nav bar into account
        offset = 64.0f;
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                               self.scrollViewCurrentY + self.bottomView.frame.size.height + offset)];
    [self hideLoading];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (CGFloat)setupOrderView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    UIView* orderContentView = [self placeContentViewWithTitle:STRING_MY_ORDER_LABEL atYPosition:yPosition scrollView:scrollView];
    
    for (int i = 0; i < self.cart.cartItems.count; i++) {
        RICartItem* cartItem = [self.cart.cartItems objectAtIndex:i];
        if (0 != i) {
            [self placeGreySeparatorInContentView:orderContentView];
        }
        [self placeCartItemCell:cartItem inContentView:orderContentView];
    }
    
    return orderContentView.frame.size.height + 5.0f;
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
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    nameLabel.textColor = UIColorFromRGB(0x666666);
    nameLabel.text = cartItem.name;
    [nameLabel sizeToFit];
    nameLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 8.0f,
                                 itemCell.bounds.origin.y + 6.0f,
                                 itemCell.frame.size.width - imageView.frame.size.width - 8.0f*2,
                                 nameLabel.frame.size.height);
    [itemCell addSubview:nameLabel];
    
    UILabel* quantityLabel = [UILabel new];
    quantityLabel.textAlignment = NSTextAlignmentLeft;
    quantityLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    quantityLabel.textColor = UIColorFromRGB(0x666666);
    quantityLabel.text = [NSString stringWithFormat:STRING_QUANTITY, cartItem.quantity];
    [quantityLabel sizeToFit];
    quantityLabel.frame = CGRectMake(nameLabel.frame.origin.x,
                                     CGRectGetMaxY(nameLabel.frame) + 5.0f,
                                     nameLabel.frame.size.width,
                                     quantityLabel.frame.size.height);
    [itemCell addSubview:quantityLabel];
    
    UILabel* priceLabel = [UILabel new];
    priceLabel.textAlignment = NSTextAlignmentLeft;
    priceLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
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
    sizeLabel.textAlignment = NSTextAlignmentLeft;
    sizeLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
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

- (CGFloat)setupSubtotalView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    UIView* subtotalContentView = [self placeContentViewWithTitle:STRING_SUBTOTAL atYPosition:yPosition scrollView:scrollView];
    
    UILabel* articlesLabel = [UILabel new];
    articlesLabel.textAlignment = NSTextAlignmentLeft;
    articlesLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    articlesLabel.textColor = UIColorFromRGB(0x666666);
    articlesLabel.text = [NSString stringWithFormat:STRING_ITEMS_CART, [self.cart.cartCount integerValue]];
    if (1 == [self.cart.cartCount integerValue]) {
        articlesLabel.text = STRING_ITEM_CART;
    }
    [articlesLabel sizeToFit];
    articlesLabel.frame = CGRectMake(subtotalContentView.bounds.origin.x + 6.0f,
                                     subtotalContentView.frame.size.height + 10.0f,
                                     (subtotalContentView.frame.size.width / 2) - 6.0f,
                                     articlesLabel.frame.size.height);
    [subtotalContentView addSubview:articlesLabel];
    
    CGRect articleNumberWidth = [articlesLabel.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName:articlesLabel.font} context:nil];
    
    UILabel* totalLabel = [UILabel new];
    totalLabel.textAlignment = NSTextAlignmentRight;
    totalLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    totalLabel.textColor = UIColorFromRGB(0x666666);
    totalLabel.text = self.cart.subTotalFormatted;
    [totalLabel sizeToFit];
    totalLabel.frame = CGRectMake(CGRectGetMaxX(articlesLabel.frame),
                                  articlesLabel.frame.origin.y,
                                  (subtotalContentView.frame.size.width / 2) - 6.0f,
                                  totalLabel.frame.size.height);
    [subtotalContentView addSubview:totalLabel];
    
    NSString *priceRuleKeysString = @"";
    NSString *priceRuleValuesString = @"";
    if(VALID_NOTEMPTY(self.cart.priceRules, NSDictionary))
    {
        NSArray *priceRuleKeys = [self.cart.priceRules allKeys];
        
        for (NSString *priceRuleKey in priceRuleKeys)
        {
            if(ISEMPTY(priceRuleKeysString))
            {
                priceRuleKeysString = priceRuleKey;
                priceRuleValuesString = [self.cart.priceRules objectForKey:priceRuleKey];
            }
            else
            {
                priceRuleKeysString = [NSString stringWithFormat:@"%@\n%@", priceRuleKeysString, priceRuleKey];
                priceRuleValuesString = [NSString stringWithFormat:@"%@\n%@", priceRuleValuesString, [self.cart.priceRules objectForKey:priceRuleKey]];
            }
        }
    }
    
    UILabel* vatLabel = [UILabel new];
    vatLabel.textAlignment = NSTextAlignmentLeft;
    vatLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    vatLabel.textColor = UIColorFromRGB(0x666666);
    [vatLabel setText:self.cart.vatLabel];
    [vatLabel sizeToFit];
    vatLabel.frame = CGRectMake(articlesLabel.x,
                                CGRectGetMaxY(articlesLabel.frame),
                                articlesLabel.frame.size.width,
                                vatLabel.frame.size.height);
    
    UILabel *cartVatValue = [[UILabel alloc] initWithFrame:CGRectZero];
    cartVatValue.textAlignment = NSTextAlignmentLeft;
    [cartVatValue setFont:[UIFont fontWithName:kFontLightName size:13.0f]];
    [cartVatValue setTextColor:UIColorFromRGB(0x666666)];
    if ([[self.cart vatLabelEnabled] boolValue]) {
        [cartVatValue setText:[self.cart vatValueFormatted]];
        [subtotalContentView addSubview:cartVatValue];
    }
    [cartVatValue sizeToFit];
    [cartVatValue setBackgroundColor:[UIColor clearColor]];
    [cartVatValue setFrame:CGRectMake(CGRectGetMaxX(totalLabel.frame) - cartVatValue.frame.size.width,
                                           vatLabel.y,
                                           cartVatValue.frame.size.width,
                                           cartVatValue.frame.size.height)];
    
    CGFloat nextYPos = CGRectGetMaxY(vatLabel.frame);
    
    [subtotalContentView addSubview:vatLabel];
    
    CGFloat vatPositionY = CGRectGetMaxY(vatLabel.frame);
    if(VALID_NOTEMPTY(priceRuleKeysString, NSString) && VALID_NOTEMPTY(priceRuleValuesString, NSString))
    {
        UILabel *priceRulesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        priceRulesLabel.textAlignment = NSTextAlignmentLeft;
        [priceRulesLabel setFont:[UIFont fontWithName:kFontLightName size:13.0f]];
        [priceRulesLabel setTextColor:UIColorFromRGB(0x666666)];
        [priceRulesLabel setText:priceRuleKeysString];
        [priceRulesLabel setNumberOfLines:0];
        [priceRulesLabel setBackgroundColor:[UIColor clearColor]];
        [priceRulesLabel sizeToFit];
        [priceRulesLabel setFrame:CGRectMake(articlesLabel.frame.origin.x,
                                             CGRectGetMaxY(vatLabel.frame),
                                             articlesLabel.frame.size.width,
                                             priceRulesLabel.frame.size.height)];
        
        [subtotalContentView addSubview:priceRulesLabel];
        
        
        UILabel *priceRulesValue = [[UILabel alloc] initWithFrame:CGRectZero];
        priceRulesLabel.textAlignment = NSTextAlignmentLeft;
        [priceRulesValue setTextAlignment:NSTextAlignmentRight];
        [priceRulesValue setFont:[UIFont fontWithName:kFontLightName size:13.0f]];
        [priceRulesValue setTextColor:UIColorFromRGB(0x666666)];
        [priceRulesValue setText:priceRuleValuesString];
        [priceRulesValue setNumberOfLines:0];
        [priceRulesValue setBackgroundColor:[UIColor clearColor]];
        [priceRulesValue sizeToFit];
        [priceRulesValue setFrame:CGRectMake(CGRectGetMaxX(priceRulesLabel.frame),
                                             CGRectGetMaxY(vatLabel.frame),
                                             totalLabel.frame.size.width,
                                             priceRulesValue.frame.size.height)];
        
        [subtotalContentView addSubview:priceRulesValue];
        
        nextYPos = CGRectGetMaxY(priceRulesLabel.frame);
        vatPositionY = CGRectGetMaxY(priceRulesLabel.frame);
    }
    
    if (self.cart.shippingValue.floatValue != 0) {
        UILabel* shippingLabel = [UILabel new];
        shippingLabel.textAlignment = NSTextAlignmentLeft;
        shippingLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        shippingLabel.textColor = UIColorFromRGB(0x666666);
        shippingLabel.text = STRING_SHIPPING;
        [shippingLabel sizeToFit];
        shippingLabel.frame = CGRectMake(articlesLabel.frame.origin.x,
                                         nextYPos,
                                         articlesLabel.frame.size.width,
                                         vatLabel.frame.size.height);
        [subtotalContentView addSubview:shippingLabel];
        
        UILabel* shippingValueLabel = [UILabel new];
        shippingValueLabel.textAlignment = NSTextAlignmentRight;
        shippingValueLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        shippingValueLabel.textColor = UIColorFromRGB(0x666666);
        shippingValueLabel.text = self.cart.shippingValueFormatted;
        if (0 == [self.cart.shippingValue integerValue]) {
            shippingValueLabel.text = STRING_FREE;
        }
        [shippingValueLabel sizeToFit];
        shippingValueLabel.frame = CGRectMake(CGRectGetMaxX(shippingLabel.frame),
                                              shippingLabel.frame.origin.y,
                                              totalLabel.frame.size.width,
                                              shippingValueLabel.frame.size.height);
        [subtotalContentView addSubview:shippingValueLabel];
        nextYPos = CGRectGetMaxY(shippingLabel.frame);
    }
    
    if (self.cart.extraCosts.floatValue != 0) {
        UILabel* extraCostsLabel = [UILabel new];
        extraCostsLabel.textAlignment = NSTextAlignmentLeft;
        extraCostsLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        extraCostsLabel.textColor = UIColorFromRGB(0x666666);
        extraCostsLabel.text = STRING_EXTRA_COSTS;
        [extraCostsLabel sizeToFit];
        extraCostsLabel.frame = CGRectMake(articlesLabel.frame.origin.x,
                                           nextYPos,
                                           articlesLabel.frame.size.width,
                                           extraCostsLabel.frame.size.height);
        [subtotalContentView addSubview:extraCostsLabel];
        
        UILabel* extraCostsValueLabel = [UILabel new];
        extraCostsValueLabel.textAlignment = NSTextAlignmentRight;
        extraCostsValueLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        extraCostsValueLabel.textColor = UIColorFromRGB(0x666666);
        extraCostsValueLabel.text = self.cart.extraCostsFormatted;
        [extraCostsValueLabel sizeToFit];
        extraCostsValueLabel.frame = CGRectMake(CGRectGetMaxX(extraCostsLabel.frame),
                                                extraCostsLabel.frame.origin.y,
                                                totalLabel.frame.size.width,
                                                extraCostsValueLabel.frame.size.height);
        [subtotalContentView addSubview:extraCostsValueLabel];
        nextYPos = CGRectGetMaxY(extraCostsLabel.frame);
    }
    
    if (self.cart.couponMoneyValue != nil) {
        UILabel *couponLabel = [UILabel new];
        couponLabel.textAlignment = NSTextAlignmentLeft;
        [couponLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
        [couponLabel setTextColor:UIColorFromRGB(0x3aaa35)];
        [couponLabel setText:STRING_VOUCHER];
        [couponLabel sizeToFit];
        [couponLabel setX:articlesLabel.x];
        [couponLabel setY:nextYPos];
        [subtotalContentView addSubview:couponLabel];
        
        UILabel *couponValueLabel = [UILabel new];
        couponValueLabel.textAlignment = NSTextAlignmentLeft;
        [couponValueLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
        [couponValueLabel setTextColor:UIColorFromRGB(0x3aaa35)];
        [couponValueLabel setText:[NSString stringWithFormat:@"- %@", self.cart.couponMoneyValueFormatted]];
        [couponValueLabel sizeToFit];
        [couponValueLabel setX:CGRectGetMaxX(subtotalContentView.frame) - couponValueLabel.width - 4.f];
        [couponValueLabel setY:nextYPos];
        [subtotalContentView addSubview:couponValueLabel];
        
        nextYPos = CGRectGetMaxY(couponLabel.frame);
    }
    
    subtotalContentView.frame = CGRectMake(subtotalContentView.frame.origin.x,
                                           subtotalContentView.frame.origin.y,
                                           subtotalContentView.frame.size.width,
                                           nextYPos + 10.0f);
    
    UILabel* finalTotalLabel = [UILabel new];
    finalTotalLabel.textAlignment = NSTextAlignmentLeft;
    finalTotalLabel.font = [UIFont fontWithName:kFontBoldName size:13.0f];
    finalTotalLabel.textColor = UIColorFromRGB(0x666666);
    finalTotalLabel.text = STRING_TOTAL;
    [finalTotalLabel sizeToFit];
    finalTotalLabel.frame = CGRectMake(articlesLabel.x,
                                       nextYPos + 5.0f,
                                       articlesLabel.width,
                                       finalTotalLabel.frame.size.height);
    [subtotalContentView addSubview:finalTotalLabel];
    
    UILabel* finalTotalValueLabel = [UILabel new];
    finalTotalValueLabel.textAlignment = NSTextAlignmentRight;
    finalTotalValueLabel.font = [UIFont fontWithName:kFontBoldName size:13.0f];
    finalTotalValueLabel.textColor = UIColorFromRGB(0x666666);
    finalTotalValueLabel.text = self.cart.cartValueFormatted;
    [finalTotalValueLabel sizeToFit];
    finalTotalValueLabel.frame = CGRectMake(CGRectGetMaxX(finalTotalLabel.frame),
                                            finalTotalLabel.frame.origin.y,
                                            totalLabel.frame.size.width,
                                            finalTotalValueLabel.frame.size.height);
    [subtotalContentView addSubview:finalTotalValueLabel];
    
    subtotalContentView.frame = CGRectMake(subtotalContentView.frame.origin.x,
                                           subtotalContentView.frame.origin.y,
                                           subtotalContentView.frame.size.width,
                                           CGRectGetMaxY(finalTotalLabel.frame) + 10.0f);

    return subtotalContentView.frame.size.height + 5.0f;
}

- (CGFloat)setupShippingAddressView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    NSString* shippingAddress = [self getAddressStringFromAddress:self.cart.shippingAddress];
    return [self setupGenericAddressViewWithTitle:STRING_SHIPPING_ADDRESSES address:shippingAddress editButtonSelector:@selector(editButtonForShippingAddress) scrollView:scrollView atYPostion:yPosition];
}

- (CGFloat)setupBillingAddressView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    NSString* shippingAddress = [self getAddressStringFromAddress:self.cart.shippingAddress];
    NSString* billingAddress = [self getAddressStringFromAddress:self.cart.billingAddress];
    if ([billingAddress isEqualToString:shippingAddress]) {
        billingAddress = STRING_BILLING_SAME_ADDRESSES;
    }
    return [self setupGenericAddressViewWithTitle:STRING_BILLING_ADDRESSES address:billingAddress editButtonSelector:@selector(editButtonForBillingAddress) scrollView:scrollView atYPostion:yPosition];
}

- (CGFloat)setupGenericAddressViewWithTitle:(NSString*)title
                                    address:(NSString*)address
                         editButtonSelector:(SEL)selector
                                 scrollView:(UIScrollView*)scrollView
                                 atYPostion:(CGFloat)yPosition
{
    UIView* addressContentView = [self placeContentViewWithTitle:title atYPosition:yPosition scrollView:scrollView];
    
    [self addEditButtonToContentView:addressContentView withSelector:selector];
    
    UILabel* addressLabel = [UILabel new];
    addressLabel.textAlignment = NSTextAlignmentLeft;
    addressLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
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
    
    return addressContentView.frame.size.height + 5.0f;
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

- (CGFloat)setupShippingMethodView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    UIView* shippingContentView = [self placeContentViewWithTitle:STRING_SHIPPING atYPosition:yPosition scrollView:scrollView];
    
    [self addEditButtonToContentView:shippingContentView withSelector:@selector(editButtonForShippingMethod)];
    
    UILabel* shippingMethodLabel = [UILabel new];
    shippingMethodLabel.textAlignment = NSTextAlignmentLeft;
    shippingMethodLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
    shippingMethodLabel.textColor = UIColorFromRGB(0x666666);
    shippingMethodLabel.text = self.cart.shippingMethod;
    shippingMethodLabel.numberOfLines = 0;
    [shippingMethodLabel sizeToFit];
    shippingMethodLabel.frame = CGRectMake(shippingContentView.bounds.origin.x + 6.0f,
                                           shippingContentView.frame.size.height + 10.0f,
                                           shippingContentView.frame.size.width - 6.0f,
                                           shippingMethodLabel.frame.size.height);
    [shippingContentView addSubview:shippingMethodLabel];
    
    shippingContentView.frame = CGRectMake(shippingContentView.frame.origin.x,
                                           shippingContentView.frame.origin.y,
                                           shippingContentView.frame.size.width,
                                           CGRectGetMaxY(shippingMethodLabel.frame) + 10.0f);
    
    return shippingContentView.frame.size.height + 5.0f;
}

- (CGFloat)setupPaymentOptionsView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    UIView* paymentContentView = [self placeContentViewWithTitle:STRING_PAYMENT_METHOD atYPosition:yPosition scrollView:scrollView];
    
    [self addEditButtonToContentView:paymentContentView withSelector:@selector(editButtonForPaymentMethod)];
    
    UILabel* paymentTitleLabel = [UILabel new];
    paymentTitleLabel.textAlignment = NSTextAlignmentLeft;
    paymentTitleLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
    paymentTitleLabel.textColor = UIColorFromRGB(0x666666);
    paymentTitleLabel.text = self.cart.paymentMethod;
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
    
    if (VALID_NOTEMPTY(self.cart.couponCode, NSString)) {
        
        UILabel* couponTitleLabel = [UILabel new];
        couponTitleLabel.textAlignment = NSTextAlignmentLeft;
        couponTitleLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
        couponTitleLabel.textColor = UIColorFromRGB(0x666666);
        couponTitleLabel.text = STRING_COUPON;
        couponTitleLabel.numberOfLines = 0;
        [couponTitleLabel sizeToFit];
        couponTitleLabel.frame = CGRectMake(paymentContentView.bounds.origin.x + 6.0f,
                                            CGRectGetMaxY(paymentTitleLabel.frame) + 15.0f,
                                            paymentContentView.frame.size.width - 6.0f,
                                            couponTitleLabel.frame.size.height);
        [paymentContentView addSubview:couponTitleLabel];
        
        UILabel* couponCodeLabel = [UILabel new];
        couponCodeLabel.textAlignment = NSTextAlignmentLeft;
        couponCodeLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
        couponCodeLabel.textColor = UIColorFromRGB(0x666666);
        couponCodeLabel.text = self.cart.couponCode;
        couponCodeLabel.numberOfLines = 0;
        [couponCodeLabel sizeToFit];
        couponCodeLabel.frame = CGRectMake(paymentContentView.bounds.origin.x + 6.0f,
                                           CGRectGetMaxY(couponTitleLabel.frame),
                                           paymentContentView.frame.size.width - 6.0f,
                                           couponCodeLabel.frame.size.height);
        [paymentContentView addSubview:couponCodeLabel];
        
        paymentContentView.frame = CGRectMake(paymentContentView.frame.origin.x,
                                              paymentContentView.frame.origin.y,
                                              paymentContentView.frame.size.width,
                                              CGRectGetMaxY(couponCodeLabel.frame));
    }
    
    
    paymentContentView.frame = CGRectMake(paymentContentView.frame.origin.x,
                                          paymentContentView.frame.origin.y,
                                          paymentContentView.frame.size.width,
                                          paymentContentView.frame.size.height + 10.0f);
    
    return paymentContentView.frame.size.height + 5.0f;
}

- (void)setupConfirmButton
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    
    CGFloat offset = 0.0;
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && NO == self.alreadyLoadedConfirmButton){
        //For some reason on iphone ios9 the view controller's view doesn't take the nav bar into account
        offset = 64.0f;
        self.alreadyLoadedConfirmButton = YES;
    }
    
    [self.bottomView reloadFrame:CGRectMake((self.view.frame.size.width - newWidth) / 2,
                                            self.view.frame.size.height - self.bottomView.frame.size.height - offset,
                                            newWidth,
                                            self.bottomView.frame.size.height)];
    
    [self.bottomView addButton:STRING_CONFIRM_ORDER target:self action:@selector(nextStepButtonPressed)];
    [self.bottomView setHidden:NO];
    [self.view bringSubviewToFront:self.bottomView];
}

#pragma mark - Content view auxiliary methods

- (UIView*)placeContentViewWithTitle:(NSString*)title
                         atYPosition:(CGFloat)yPosition
                          scrollView:(UIScrollView*)scrollView
{
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                   yPosition,
                                                                   scrollView.frame.size.width,
                                                                   1)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 5.0f;
    [contentView setTag:kScrollViewTag];
    [scrollView addSubview:contentView];
    
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
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = title;
    titleLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
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

- (void)addEditButtonToContentView:(UIView*)contentView
                      withSelector:(SEL)selector
{
    if (selector) {
        UIFont *editFont = [UIFont fontWithName:kFontLightName size:10.0f];
        UIButton* editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setTitle:STRING_EDIT forState:UIControlStateNormal];
        [editButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
        [editButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
        [editButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateSelected];
        [editButton.titleLabel setFont:editFont];
        [editButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [editButton sizeToFit];
        CGRect editButtonRect = [STRING_EDIT boundingRectWithSize:CGSizeMake(contentView.bounds.size.width, 1000.0f)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:editFont} context:nil];
        
        [editButton setFrame:CGRectMake(contentView.bounds.size.width - editButtonRect.size.width - 20.0f,
                                        contentView.bounds.origin.y,
                                        editButtonRect.size.width + 20.0f,
                                        26.0f)];
        [contentView addSubview:editButton];
    }
}


#pragma mark - Button actions

-(void)nextStepButtonPressed
{
    [self continueNextStep];
}

- (void)continueNextStep
{
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }

    
    [RICart setMultistepFinishForCart:self.cart withSuccessBlock:^(RICart *cart) {
        NSLog(@"SUCCESS Finishing checkout");
        
        if(VALID_NOTEMPTY(cart.paymentInformation, RIPaymentInformation))
        {
            if(RIPaymentInformationCheckoutEnded == cart.paymentInformation.type)
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:cart forKey:@"cart"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutThanksScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
                
            }
            else
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:cart forKey:@"cart"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutExternalPaymentsScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
        }
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        self.apiResponse = apiResponse;
        
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(continueNextStep) objects:nil];
        
        [self hideLoading];
    }];
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

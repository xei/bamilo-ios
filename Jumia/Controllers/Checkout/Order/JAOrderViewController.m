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
#import "JAProductInfoHeaderLine.h"
#import "JAProductInfoPriceDescriptionLine.h"
#import "JAProductInfoPriceLine.h"
#import "JAButton.h"

#define kScrollViewTag 9999

@interface JAOrderViewController ()

@property (nonatomic, strong)RICart* cart;

@property (nonatomic, assign) NSInteger scrollViewCurrentY;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIScrollView* secondScrollView;

@property (assign, nonatomic) RIApiResponse apiResponse;

// Bottom view
@property (strong, nonatomic) JAButton *bottomButton;

@property (nonatomic, assign) BOOL alreadyLoadedConfirmButton;

@end

@implementation JAOrderViewController


-(UIScrollView *)scrollView {
    if (!VALID_NOTEMPTY(_scrollView, UIScrollView)) {
        
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                         self.view.bounds.origin.y,
                                                                         self.view.bounds.size.width,
                                                                         self.view.bounds.size.height)];
        [_scrollView setHidden:YES];
        [_scrollView setShowsVerticalScrollIndicator:YES];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

-(UIScrollView *)secondScrollView {
    if (!VALID_NOTEMPTY(_secondScrollView, UIScrollView)) {

    _secondScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [_secondScrollView setShowsVerticalScrollIndicator:YES];
    [self.view addSubview:_secondScrollView];
    }
    return _secondScrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"OrderConfirmation";
    
    self.navBarLayout.title = STRING_CHECKOUT;
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showBackButton = YES;
    
    self.view.backgroundColor = JAWhiteColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    
    [self.bottomButton setHidden:YES];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupViews];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)removeScrollViews
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
        [self.scrollView removeFromSuperview];
        self.scrollView = nil;
    }
    
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

-(void)setupViews
{
    [self removeScrollViews];
    
    
    CGFloat horizontalMargin = 0.0f;
    CGFloat viewsWidth = self.view.frame.size.width - (2 * horizontalMargin);
    CGFloat originY = 0.0f;
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        viewsWidth = (self.view.frame.size.width - (3 * horizontalMargin)) / 2;
        
        [self.secondScrollView setFrame:CGRectMake(horizontalMargin + viewsWidth + horizontalMargin,
                                                   originY,
                                                   viewsWidth,
                                                   self.view.bounds.size.height)];
        
        CGFloat secondScrollViewCurrentY = self.secondScrollView.frame.origin.y;
        secondScrollViewCurrentY += [self setupShippingAddressView:self.secondScrollView atYPostion:secondScrollViewCurrentY];
        secondScrollViewCurrentY += [self setupBillingAddressView:self.secondScrollView atYPostion:secondScrollViewCurrentY];
        secondScrollViewCurrentY += [self setupShippingMethodView:self.secondScrollView atYPostion:secondScrollViewCurrentY];
        secondScrollViewCurrentY += [self setupPaymentOptionsView:self.secondScrollView atYPostion:secondScrollViewCurrentY];
        
        [self.secondScrollView setContentSize:CGSizeMake(self.secondScrollView.frame.size.width,
                                                         secondScrollViewCurrentY + self.bottomButton.frame.size.height)];
    }
    
    [self.scrollView setFrame:CGRectMake(horizontalMargin,
                                         originY,
                                         viewsWidth,
                                         self.view.bounds.size.height)];
    
    //relative to scroll
    self.scrollViewCurrentY = self.scrollView.frame.origin.y;
    self.scrollViewCurrentY += [self setupOrderView:self.scrollView atYPostion:self.scrollViewCurrentY];
    self.scrollViewCurrentY += [self setupSubtotalView:self.scrollView atYPostion:self.scrollViewCurrentY];
    
    if(!(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)))
    {
        self.scrollViewCurrentY += [self setupShippingAddressView:self.scrollView atYPostion:self.scrollViewCurrentY];
        self.scrollViewCurrentY += [self setupBillingAddressView:self.scrollView atYPostion:self.scrollViewCurrentY];
        self.scrollViewCurrentY += [self setupShippingMethodView:self.scrollView atYPostion:self.scrollViewCurrentY];
        self.scrollViewCurrentY += [self setupPaymentOptionsView:self.scrollView atYPostion:self.scrollViewCurrentY];
    }
    
    //not relative to scroll
    [self setupConfirmButton];
    
    [self.scrollView setHidden:NO];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                               self.scrollViewCurrentY + self.bottomButton.frame.size.height)];
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
    
    return orderContentView.frame.size.height;
}

- (void)placeCartItemCell:(RICartItem*)cartItem
            inContentView:(UIView*)contentView
{
    UIView* itemCell = [[UIView alloc] init];
    [contentView addSubview:itemCell];
    
    CGSize imageSize = CGSizeMake(68.0f, 85.0f);
    
    CGFloat currentY = 10.0f;
    
    //details inside itemCell
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f,
                                                                           currentY,
                                                                           imageSize.width,
                                                                           imageSize.height)];
    
    [imageView setImageWithURL:[NSURL URLWithString:cartItem.imageUrl]
              placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    [itemCell addSubview:imageView];
    
    UILabel* brandLabel = [UILabel new];
    brandLabel.textAlignment = NSTextAlignmentLeft;
    brandLabel.font = JABodyFont;
    brandLabel.textColor = JABlack800Color;
    brandLabel.text = cartItem.brand;
    [brandLabel sizeToFit];
    brandLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 8.0f,
                                 currentY,
                                 contentView.frame.size.width - imageView.frame.size.width - 8.0f*2,
                                 brandLabel.frame.size.height);
    [itemCell addSubview:brandLabel];
    
    currentY = CGRectGetMaxY(brandLabel.frame) + 3.0f;

    
    UILabel* nameLabel = [UILabel new];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = JATitleFont;
    nameLabel.textColor = JABlackColor;
    nameLabel.text = cartItem.name;
    [nameLabel sizeToFit];
    nameLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 8.0f,
                                 currentY,
                                 contentView.frame.size.width - CGRectGetMaxX(imageView.frame) - 8.0f*2,
                                 nameLabel.frame.size.height);
    [itemCell addSubview:nameLabel];
    
    currentY = CGRectGetMaxY(nameLabel.frame) + 3.0f;
    
    if ([cartItem.shopFirst boolValue]){
        self.shopFirstOverlayText = cartItem.shopFirstOverlayText;
        UIImageView *shopFirstLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop_first_logo"]];
        [shopFirstLogo sizeToFit];
        [shopFirstLogo setX:brandLabel.frame.origin.x];
        [shopFirstLogo setY:currentY];
        [shopFirstLogo setHidden:NO];
        [shopFirstLogo setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(shopFirstLogoTapped:)];
        [shopFirstLogo addGestureRecognizer:singleTap];
        [itemCell addSubview:shopFirstLogo];
        [itemCell bringSubviewToFront:shopFirstLogo];
        
        currentY = CGRectGetMaxY(shopFirstLogo.frame) + 3.0f;
    }
    
    if (VALID_NOTEMPTY(cartItem.variation, NSString)) {
        UILabel* sizeLabel = [UILabel new];
        sizeLabel.textAlignment = NSTextAlignmentLeft;
        sizeLabel.font = JABodyFont;
        sizeLabel.textColor = JABlack800Color;
        sizeLabel.text = cartItem.variation;
        [sizeLabel sizeToFit];
        sizeLabel.frame = CGRectMake(nameLabel.frame.origin.x,
                                     currentY,
                                     nameLabel.frame.size.width,
                                     sizeLabel.frame.size.height);
        [itemCell addSubview:sizeLabel];
        
        currentY = CGRectGetMaxY(sizeLabel.frame) + 3.0f;
    }
    
    UILabel* quantityLabel = [UILabel new];
    quantityLabel.textAlignment = NSTextAlignmentLeft;
    quantityLabel.font = JABodyFont;
    quantityLabel.textColor = JABlack800Color;
    quantityLabel.text = [NSString stringWithFormat:STRING_QUANTITY, cartItem.quantity];
    [quantityLabel sizeToFit];
    [quantityLabel setX:brandLabel.frame.origin.x];
    [quantityLabel setY:currentY];
    [itemCell addSubview:quantityLabel];
    
    currentY = CGRectGetMaxY(quantityLabel.frame) + 3.0f;
    
    JAProductInfoPriceLine* priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x - 16.0f,
                                                                                                 currentY,
                                                                                                 nameLabel.frame.size.width,
                                                                                                 20.0f)];
    [priceLine setPriceSize:JAPriceSizeSmall];
    [priceLine setPrice:cartItem.priceFormatted];
    if (VALID_NOTEMPTY(cartItem.specialPriceFormatted, NSString)) {
        [priceLine setPrice:cartItem.specialPriceFormatted];
        [priceLine setOldPrice:cartItem.priceFormatted];
    }
    [itemCell addSubview:priceLine];
    
    currentY = CGRectGetMaxY(priceLine.frame) + 10.0f;
    
    //adjust having the image size in mind has a minimum
    currentY = MAX(imageSize.height + 20.0f, currentY);
    
    //center image now that the height is known
    imageView.y = (currentY - imageView.height) / 2;
    
    itemCell.frame = CGRectMake(contentView.bounds.origin.x,
                                contentView.bounds.size.height,
                                contentView.bounds.size.width,
                                currentY);
    
    contentView.frame = CGRectMake(contentView.frame.origin.x,
                                   contentView.frame.origin.y,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height + itemCell.frame.size.height);
}

- (void)placeGreySeparatorInContentView:(UIView*)contentView
{
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x,
                                                                 contentView.bounds.size.height,
                                                                 contentView.bounds.size.width,
                                                                 1)];
    separator.backgroundColor = JABlack300Color;
    
    [contentView addSubview:separator];
    
    contentView.frame = CGRectMake(contentView.frame.origin.x,
                                   contentView.frame.origin.y,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height + separator.frame.size.height);
}

- (CGFloat)setupSubtotalView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    UIView* subtotalContentView = [self placeContentViewWithTitle:STRING_SUBTOTAL atYPosition:yPosition scrollView:scrollView];
    
    JAProductInfoPriceDescriptionLine *priceDescriptionLine = [[JAProductInfoPriceDescriptionLine alloc] initWithFrame:CGRectMake(0.f,
                                                                                                                                  subtotalContentView.frame.size.height,
                                                                                                                                  scrollView.frame.size.width,
                                                                                                                                  48.0f)];
    [priceDescriptionLine setTopSeparatorVisibility:NO];
    if ([[[self cart] cartCount] integerValue] == 1) {
        [priceDescriptionLine setTitle:STRING_ITEM_CART];
    }else{
        [priceDescriptionLine setTitle:[NSString stringWithFormat:STRING_ITEMS_CART, [[[self cart] cartCount] integerValue]]];
    }
    
    [priceDescriptionLine setPrice:[[self cart] subTotalFormatted] andOldPrice:[[self cart] cartUnreducedValueFormatted]];
    [subtotalContentView addSubview:priceDescriptionLine];
    
    CGFloat startingX = 16.0f;
    CGFloat labelWidth = (subtotalContentView.frame.size.width / 2) - startingX;
    CGFloat endingX = subtotalContentView.frame.size.width - 16.0f;
    
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
    vatLabel.font = JABodyFont;
    vatLabel.textColor = JABlack800Color;
    [vatLabel setText:self.cart.vatLabel];
    [vatLabel sizeToFit];
    vatLabel.frame = CGRectMake(startingX,
                                CGRectGetMaxY(priceDescriptionLine.frame) - 16.0f,
                                labelWidth,
                                vatLabel.frame.size.height);
    
    UILabel *cartVatValue = [[UILabel alloc] initWithFrame:CGRectZero];
    cartVatValue.textAlignment = NSTextAlignmentLeft;
    [cartVatValue setFont:JABodyFont];
    [cartVatValue setTextColor:JABlack800Color];
    if ([[self.cart vatLabelEnabled] boolValue]) {
        [cartVatValue setText:[self.cart vatValueFormatted]];
        [subtotalContentView addSubview:cartVatValue];
    }
    [cartVatValue sizeToFit];
    [cartVatValue setBackgroundColor:[UIColor clearColor]];
    [cartVatValue setFrame:CGRectMake(endingX - cartVatValue.frame.size.width,
                                      vatLabel.y,
                                      cartVatValue.frame.size.width,
                                      cartVatValue.frame.size.height)];
    
    CGFloat nextYPos = CGRectGetMaxY(vatLabel.frame) + 10.0f;
    
    [subtotalContentView addSubview:vatLabel];
    
    CGFloat vatPositionY = CGRectGetMaxY(vatLabel.frame);
    if(VALID_NOTEMPTY(priceRuleKeysString, NSString) && VALID_NOTEMPTY(priceRuleValuesString, NSString))
    {
        UILabel *priceRulesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        priceRulesLabel.textAlignment = NSTextAlignmentLeft;
        [priceRulesLabel setFont:JABodyFont];
        [priceRulesLabel setTextColor:JABlack800Color];
        [priceRulesLabel setText:priceRuleKeysString];
        [priceRulesLabel setNumberOfLines:0];
        [priceRulesLabel setBackgroundColor:[UIColor clearColor]];
        [priceRulesLabel sizeToFit];
        [priceRulesLabel setFrame:CGRectMake(startingX,
                                             CGRectGetMaxY(vatLabel.frame),
                                             labelWidth,
                                             priceRulesLabel.frame.size.height)];
        
        [subtotalContentView addSubview:priceRulesLabel];
        
        
        UILabel *priceRulesValue = [[UILabel alloc] initWithFrame:CGRectZero];
        priceRulesLabel.textAlignment = NSTextAlignmentLeft;
        [priceRulesValue setTextAlignment:NSTextAlignmentRight];
        [priceRulesValue setFont:JABodyFont];
        [priceRulesValue setTextColor:JABlack800Color];
        [priceRulesValue setText:priceRuleValuesString];
        [priceRulesValue setNumberOfLines:0];
        [priceRulesValue setBackgroundColor:[UIColor clearColor]];
        [priceRulesValue sizeToFit];
        [priceRulesValue setFrame:CGRectMake(endingX - priceRulesValue.frame.size.width,
                                             CGRectGetMaxY(vatLabel.frame),
                                             priceRulesValue.frame.size.width,
                                             priceRulesValue.frame.size.height)];
        
        [subtotalContentView addSubview:priceRulesValue];
        
        nextYPos = CGRectGetMaxY(priceRulesLabel.frame) + 10.0f;
        vatPositionY = CGRectGetMaxY(priceRulesLabel.frame);
    }
    
    if (self.cart.shippingValue.floatValue != 0) {
        UILabel* shippingLabel = [UILabel new];
        shippingLabel.textAlignment = NSTextAlignmentLeft;
        shippingLabel.font = JABodyFont;
        shippingLabel.textColor = JABlackColor;
        shippingLabel.text = STRING_SHIPPING;
        [shippingLabel sizeToFit];
        shippingLabel.frame = CGRectMake(startingX,
                                         nextYPos,
                                         labelWidth,
                                         vatLabel.frame.size.height);
        [subtotalContentView addSubview:shippingLabel];
        
        UILabel* shippingValueLabel = [UILabel new];
        shippingValueLabel.textAlignment = NSTextAlignmentRight;
        shippingValueLabel.font = JABodyFont;
        shippingValueLabel.textColor = JABlackColor;
        shippingValueLabel.text = self.cart.shippingValueFormatted;
        if (0 == [self.cart.shippingValue integerValue]) {
            shippingValueLabel.text = STRING_FREE;
        }
        [shippingValueLabel sizeToFit];
        shippingValueLabel.frame = CGRectMake(endingX - shippingValueLabel.frame.size.width,
                                              shippingLabel.frame.origin.y,
                                              shippingValueLabel.frame.size.width,
                                              shippingValueLabel.frame.size.height);
        [subtotalContentView addSubview:shippingValueLabel];
        nextYPos = CGRectGetMaxY(shippingLabel.frame) + 10.0f;
    }
    
    if (self.cart.extraCosts.floatValue != 0) {
        UILabel* extraCostsLabel = [UILabel new];
        extraCostsLabel.textAlignment = NSTextAlignmentLeft;
        extraCostsLabel.font = JABodyFont;
        extraCostsLabel.textColor = JABlackColor;
        extraCostsLabel.text = STRING_EXTRA_COSTS;
        [extraCostsLabel sizeToFit];
        extraCostsLabel.frame = CGRectMake(startingX,
                                           nextYPos,
                                           labelWidth,
                                           extraCostsLabel.frame.size.height);
        [subtotalContentView addSubview:extraCostsLabel];
        
        UILabel* extraCostsValueLabel = [UILabel new];
        extraCostsValueLabel.textAlignment = NSTextAlignmentRight;
        extraCostsValueLabel.font = JABodyFont;
        extraCostsValueLabel.textColor = JABlackColor;
        extraCostsValueLabel.text = self.cart.extraCostsFormatted;
        [extraCostsValueLabel sizeToFit];
        extraCostsValueLabel.frame = CGRectMake(endingX - extraCostsValueLabel.frame.size.width,
                                                extraCostsLabel.frame.origin.y,
                                                extraCostsValueLabel.frame.size.width,
                                                extraCostsValueLabel.frame.size.height);
        [subtotalContentView addSubview:extraCostsValueLabel];
        nextYPos = CGRectGetMaxY(extraCostsLabel.frame) + 10.0f;
    }
    
    if (self.cart.couponMoneyValue != nil) {
        UILabel *couponLabel = [UILabel new];
        couponLabel.textAlignment = NSTextAlignmentLeft;
        [couponLabel setFont:JABodyFont];
        [couponLabel setTextColor:JABlackColor];
        [couponLabel setText:STRING_VOUCHER];
        [couponLabel sizeToFit];
        [couponLabel setX:startingX];
        [couponLabel setY:nextYPos];
        [subtotalContentView addSubview:couponLabel];
        
        UILabel *couponValueLabel = [UILabel new];
        couponValueLabel.textAlignment = NSTextAlignmentLeft;
        [couponValueLabel setFont:JABodyFont];
        [couponValueLabel setTextColor:JABlackColor];
        [couponValueLabel setText:[NSString stringWithFormat:@"- %@", self.cart.couponMoneyValueFormatted]];
        [couponValueLabel sizeToFit];
        [couponValueLabel setX:CGRectGetMaxX(subtotalContentView.frame) - couponValueLabel.width - 16.f];
        [couponValueLabel setY:nextYPos];
        [subtotalContentView addSubview:couponValueLabel];
        
        nextYPos = CGRectGetMaxY(couponLabel.frame) + 10.0f;
    }
    
    subtotalContentView.frame = CGRectMake(subtotalContentView.frame.origin.x,
                                           subtotalContentView.frame.origin.y,
                                           subtotalContentView.frame.size.width,
                                           nextYPos);
    
    UIView* finalTotalSeparatorView = [UIView new];
    finalTotalSeparatorView.backgroundColor = JABlack400Color;
    [subtotalContentView addSubview:finalTotalSeparatorView];
    finalTotalSeparatorView.frame = CGRectMake(16.0f,
                                               nextYPos,
                                               subtotalContentView.frame.size.width - 12.0f,
                                               1.0f);
    
    nextYPos += 10.0f;
    
    UILabel* finalTotalLabel = [UILabel new];
    finalTotalLabel.textAlignment = NSTextAlignmentLeft;
    finalTotalLabel.font = JATitleFont;
    finalTotalLabel.textColor = JABlackColor;
    finalTotalLabel.text = STRING_TOTAL;
    [finalTotalLabel sizeToFit];
    finalTotalLabel.frame = CGRectMake(startingX,
                                       nextYPos,
                                       labelWidth,
                                       finalTotalLabel.frame.size.height);
    [subtotalContentView addSubview:finalTotalLabel];
    
    UILabel* finalTotalValueLabel = [UILabel new];
    finalTotalValueLabel.textAlignment = NSTextAlignmentRight;
    finalTotalValueLabel.font = JATitleFont;
    finalTotalValueLabel.textColor = JABlackColor;
    finalTotalValueLabel.text = self.cart.cartValueFormatted;
    [finalTotalValueLabel sizeToFit];
    finalTotalValueLabel.frame = CGRectMake(endingX - finalTotalValueLabel.frame.size.width,
                                            finalTotalLabel.frame.origin.y,
                                            finalTotalValueLabel.frame.size.width,
                                            finalTotalValueLabel.frame.size.height);
    [subtotalContentView addSubview:finalTotalValueLabel];
    
    subtotalContentView.frame = CGRectMake(subtotalContentView.frame.origin.x,
                                           subtotalContentView.frame.origin.y,
                                           subtotalContentView.frame.size.width,
                                           CGRectGetMaxY(finalTotalLabel.frame) + 10.0f);

    return subtotalContentView.frame.size.height;
}

- (CGFloat)setupShippingAddressView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    NSString* shippingAddress = [self getAddressStringFromAddress:self.cart.shippingAddress];
    NSString* shippingName = [self getNameStringFromAddress:self.cart.shippingAddress];
    NSString* shippingPhone = [self getPhoneStringFromAddress:self.cart.shippingAddress];
    return [self setupGenericAddressViewWithTitle:STRING_SHIPPING_ADDRESSES address:shippingAddress name:shippingName phone:shippingPhone editButtonSelector:@selector(editButtonForShippingAddress) scrollView:scrollView atYPostion:yPosition];
}

- (CGFloat)setupBillingAddressView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    NSString* billingAddress = [self getAddressStringFromAddress:self.cart.billingAddress];
    NSString* billingName = [self getNameStringFromAddress:self.cart.billingAddress];
    NSString* billingPhone = [self getPhoneStringFromAddress:self.cart.billingAddress];
    if ([self.cart.billingAddress.uid isEqualToString:self.cart.shippingAddress.uid]) {
        billingName = STRING_BILLING_SAME_ADDRESSES;
        billingAddress = nil;
        billingPhone = nil;
    }
    return [self setupGenericAddressViewWithTitle:STRING_BILLING_ADDRESSES address:billingAddress name:billingName phone:billingPhone editButtonSelector:@selector(editButtonForBillingAddress) scrollView:scrollView atYPostion:yPosition];
}

- (CGFloat)setupGenericAddressViewWithTitle:(NSString*)title
                                    address:(NSString*)address
                                       name:(NSString*)name
                                      phone:(NSString*)phone
                         editButtonSelector:(SEL)selector
                                 scrollView:(UIScrollView*)scrollView
                                 atYPostion:(CGFloat)yPosition
{
    UIView* addressContentView = [self placeContentViewWithTitle:title atYPosition:yPosition scrollView:scrollView];
    
    [self addEditButtonToContentView:addressContentView withSelector:selector];
    
    UILabel* nameLabel = [UILabel new];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = JAListFont;
    nameLabel.textColor = JABlackColor;
    nameLabel.text = name;
    nameLabel.numberOfLines = 0;
    [nameLabel sizeToFit];
    nameLabel.frame = CGRectMake(16.0f,
                                 addressContentView.frame.size.height + 16.0f,
                                 addressContentView.frame.size.width - 16.0f * 2,
                                 nameLabel.frame.size.height);
    [addressContentView addSubview:nameLabel];
    
    UILabel* addressLabel = [UILabel new];
    addressLabel.textAlignment = NSTextAlignmentLeft;
    addressLabel.font = JABodyFont;
    addressLabel.textColor = JABlack800Color;
    addressLabel.text = address;
    addressLabel.numberOfLines = 0;
    [addressLabel sizeToFit];
    addressLabel.frame = CGRectMake(16.0f,
                                    CGRectGetMaxY(nameLabel.frame) + 3.0f,
                                    addressContentView.frame.size.width - 6.0f,
                                    addressLabel.frame.size.height);
    [addressContentView addSubview:addressLabel];

    CGFloat phoneX = 16.0f;
    
    if (VALID_NOTEMPTY(phone, NSString)) {
        UIImage* phoneImage = [UIImage imageNamed:@"phone_icon_small"];
        UIImageView* phoneImageView = [[UIImageView alloc] initWithImage:phoneImage];
        phoneImageView.frame = CGRectMake(phoneX,
                                          CGRectGetMaxY(addressLabel.frame) + 3.0f,
                                          phoneImage.size.width,
                                          phoneImage.size.height);
        [addressContentView addSubview:phoneImageView];
        
        phoneX = CGRectGetMaxX(phoneImageView.frame) + 3.0f;
    }
    
    UILabel* phoneLabel = [UILabel new];
    phoneLabel.textAlignment = NSTextAlignmentLeft;
    phoneLabel.font = JABodyFont;
    phoneLabel.textColor = JABlack800Color;
    phoneLabel.text = phone;
    phoneLabel.numberOfLines = 0;
    [phoneLabel sizeToFit];
    phoneLabel.frame = CGRectMake(phoneX,
                                  CGRectGetMaxY(addressLabel.frame) + 3.0f,
                                  addressContentView.frame.size.width - 6.0f,
                                  phoneLabel.frame.size.height);
    [addressContentView addSubview:phoneLabel];
    
    CGFloat offset = 16.0f;
    if (ISEMPTY(phone) && ISEMPTY(address)) {
        offset = 10.0f;
    }
    
    addressContentView.frame = CGRectMake(addressContentView.frame.origin.x,
                                          addressContentView.frame.origin.y,
                                          addressContentView.frame.size.width,
                                          CGRectGetMaxY(phoneLabel.frame) + offset);
    
    return addressContentView.frame.size.height;
}

- (NSString*)getNameStringFromAddress:(RIAddress*)address;
{
    NSString* nameText = @"";
    
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
    return nameText;
}

- (NSString*)getPhoneStringFromAddress:(RIAddress*)address;
{
    NSString* phoneText = @"";
    
    if(VALID_NOTEMPTY(address.phone, NSString))
    {
        phoneText = address.phone;
    }
    return phoneText;
}


- (NSString*)getAddressStringFromAddress:(RIAddress*)address;
{
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
    
    return addressText;
}

- (CGFloat)setupShippingMethodView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    UIView* shippingContentView = [self placeContentViewWithTitle:STRING_SHIPPING atYPosition:yPosition scrollView:scrollView];
    
    [self addEditButtonToContentView:shippingContentView withSelector:@selector(editButtonForShippingMethod)];
    
    UILabel* shippingMethodLabel = [UILabel new];
    shippingMethodLabel.textAlignment = NSTextAlignmentLeft;
    shippingMethodLabel.font = JAListFont;
    shippingMethodLabel.textColor = JABlackColor;
    shippingMethodLabel.text = self.cart.shippingMethod;
    shippingMethodLabel.numberOfLines = 0;
    [shippingMethodLabel sizeToFit];
    shippingMethodLabel.frame = CGRectMake(shippingContentView.bounds.origin.x + 16.0f,
                                           shippingContentView.frame.size.height + 16.0f,
                                           shippingContentView.frame.size.width - 6.0f,
                                           shippingMethodLabel.frame.size.height);
    [shippingContentView addSubview:shippingMethodLabel];
    
    shippingContentView.frame = CGRectMake(shippingContentView.frame.origin.x,
                                           shippingContentView.frame.origin.y,
                                           shippingContentView.frame.size.width,
                                           CGRectGetMaxY(shippingMethodLabel.frame) + 16.0f);
    
    return shippingContentView.frame.size.height;
}

- (CGFloat)setupPaymentOptionsView:(UIScrollView*)scrollView atYPostion:(CGFloat)yPosition
{
    UIView* paymentContentView = [self placeContentViewWithTitle:STRING_PAYMENT_METHOD atYPosition:yPosition scrollView:scrollView];
    
    [self addEditButtonToContentView:paymentContentView withSelector:@selector(editButtonForPaymentMethod)];
    
    UILabel* paymentTitleLabel = [UILabel new];
    paymentTitleLabel.textAlignment = NSTextAlignmentLeft;
    paymentTitleLabel.font = JAListFont;
    paymentTitleLabel.textColor = JABlackColor;
    paymentTitleLabel.text = self.cart.paymentMethod;
    paymentTitleLabel.numberOfLines = 0;
    [paymentTitleLabel sizeToFit];
    paymentTitleLabel.frame = CGRectMake(paymentContentView.bounds.origin.x + 16.0f,
                                         paymentContentView.frame.size.height + 16.0f,
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
        couponTitleLabel.font = JABodyFont;
        couponTitleLabel.textColor = JABlack800Color;
        couponTitleLabel.text = STRING_COUPON;
        couponTitleLabel.numberOfLines = 0;
        [couponTitleLabel sizeToFit];
        couponTitleLabel.frame = CGRectMake(paymentContentView.bounds.origin.x + 16.0f,
                                            CGRectGetMaxY(paymentTitleLabel.frame) + 10.0f,
                                            paymentContentView.frame.size.width - 6.0f,
                                            couponTitleLabel.frame.size.height);
        [paymentContentView addSubview:couponTitleLabel];
        
        UILabel* couponCodeLabel = [UILabel new];
        couponCodeLabel.textAlignment = NSTextAlignmentLeft;
        couponCodeLabel.font = JABodyFont;
        couponCodeLabel.textColor = JABlack800Color;
        couponCodeLabel.text = self.cart.couponCode;
        couponCodeLabel.numberOfLines = 0;
        [couponCodeLabel sizeToFit];
        couponCodeLabel.frame = CGRectMake(paymentContentView.bounds.origin.x + 16.0f,
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
                                          paymentContentView.frame.size.height + 16.0f);
    
    return paymentContentView.frame.size.height;
}

- (void)setupConfirmButton
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    if (!self.bottomButton) {
        self.bottomButton = [[JAButton alloc] initButtonWithTitle:STRING_CONFIRM_ORDER target:self action:@selector(nextStepButtonPressed)];
        [self.view addSubview:self.bottomButton];
    }
    [self.bottomButton setFrame:CGRectMake(0.0f,
                                           self.view.frame.size.height - 48.0f,
                                           self.view.frame.size.width,
                                           48.0f)];
    [self.bottomButton setHidden:NO];
    [self.view bringSubviewToFront:self.bottomButton];
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
    [contentView setTag:kScrollViewTag];
    [scrollView addSubview:contentView];
    
    [self addTitle:title toContentView:contentView];
    
    return contentView;
}

- (void)addTitle:(NSString*)title
   toContentView:(UIView*)contentView
{
    CGFloat currentContentY = contentView.bounds.origin.y;
    
    JAProductInfoHeaderLine* headerLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0.0f, 0.0f, contentView.frame.size.width, kProductInfoHeaderLineHeight)];
    [headerLine setTitle:title];
    [contentView addSubview:headerLine];
    
    currentContentY += headerLine.frame.size.height;
    
    [contentView setFrame:CGRectMake(contentView.frame.origin.x,
                                     contentView.frame.origin.y,
                                     contentView.frame.size.width,
                                     currentContentY)];
}

- (void)addEditButtonToContentView:(UIView*)contentView
                      withSelector:(SEL)selector
{
    if (selector) {
        
        UIImage* editImage = [UIImage imageNamed:@"editAddress"];
        JAClickableView* editClickableView = [[JAClickableView alloc] init];
        [editClickableView setImage:editImage forState:UIControlStateNormal];
        [editClickableView addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [editClickableView setFrame:CGRectMake(contentView.bounds.size.width - editImage.size.width - 16.0f,
                                               contentView.bounds.origin.y + 64.0f,
                                               editImage.size.width,
                                               editImage.size.height)];
        [contentView addSubview:editClickableView];
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

    
    [RICart setMultistepFinishForCart:self.cart withSuccessBlock:^(RICart *cart, NSString *rrTargetString) {
        
        if(VALID_NOTEMPTY(cart.paymentInformation, RIPaymentInformation))
        {
            if(RIPaymentInformationCheckoutEnded == cart.paymentInformation.type)
            {
                NSDictionary *userInfo = VALID_NOTEMPTY(rrTargetString, NSString)?@{ @"cart" : cart, @"rrTargetString" : rrTargetString }:@{ @"cart" : cart };
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

- (void)shopFirstLogoTapped:(UIGestureRecognizer *)gestureRecognizer
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:self.shopFirstOverlayText
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end

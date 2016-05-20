//
//  JACartResumeView.m
//  Jumia
//
//  Created by Jose Mota on 12/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JACartResumeView.h"
#import "JAProductInfoHeaderLine.h"
#import "JAButton.h"
#import "JAProductInfoPriceDescriptionLine.h"
#import "RICartItem.h"

#define kLateralMargin 16.f
#define kCouponTextFieldWidth 183.f

@interface JACartResumeView () <UITextFieldDelegate>
{
    CGFloat _textfieldPlaceholderWidth;
}

@property (nonatomic, strong) JAProductInfoHeaderLine *couponHeaderLine;
@property (nonatomic, strong) UIView *couponView;
@property (nonatomic, strong) UIButton *couponButton;
@property (nonatomic, strong) JAProductInfoHeaderLine *subtotalHeaderLine;
@property (nonatomic, strong) UIView *subtotalView;
@property (nonatomic, strong) UIImageView *freeShippingImageView;
@property (nonatomic, strong) UILabel *freeShippingLabel;
@property (nonatomic, strong) JAButton *proceedToCheckoutButton;
@property (nonatomic, strong) JAButton *callToOrderButton;

@end

@implementation JACartResumeView

- (JAProductInfoHeaderLine *)couponHeaderLine
{
    if (!VALID(_couponHeaderLine, JAProductInfoHeaderLine)) {
        _couponHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width, kProductInfoHeaderLineHeight)];
        [_couponHeaderLine setTitle:STRING_COUPON];
        [self addSubview:_couponHeaderLine];
    }
    return _couponHeaderLine;
}

- (UIView *)couponView
{
    if (!VALID(_couponView, UIView)) {
        _couponView = [[UIView alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(self.couponHeaderLine.frame), self.width, 48)];
        [self addSubview:_couponView];
        [_couponView addSubview:self.couponTextField];
        [_couponView addSubview:self.couponButton];
    }
    return _couponView;
}

- (JATextField *)couponTextField
{
    if (!VALID(_couponTextField, JATextField)) {
        _couponTextField = [[JATextField alloc] initWithFrame:CGRectMake(kLateralMargin, 0, kCouponTextFieldWidth, 30)];
        [_couponTextField setFont:JAListFont];
        [_couponTextField setTextColor:JABlackColor];
        [_couponTextField setPlaceholder:STRING_ENTER_COUPON];
        [_couponTextField setDelegate:self];
        [_couponTextField sizeToFit];
        _textfieldPlaceholderWidth = _couponTextField.width;
    }
    return _couponTextField;
}

- (UIButton *)couponButton
{
    if (!VALID(_couponButton, UIButton)) {
        _couponButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_couponButton.titleLabel setFont:JABUTTONFont];
        [_couponButton setTitleColor:JABlue1Color forState:UIControlStateNormal];
        [_couponButton setTitleColor:JABlue1Color forState:UIControlStateSelected];
        [_couponButton addTarget:self action:@selector(useCoupon) forControlEvents:UIControlEventTouchUpInside];
        [_couponButton setTitle:[STRING_USE uppercaseString] forState:UIControlStateNormal];
        [_couponButton setFrame:CGRectMake(CGRectGetMaxY(self.couponTextField.frame) + 16.f, 0.f, 50.f, 30.f)];
        [_couponButton sizeToFit];
    }
    return _couponButton;
}

- (JAProductInfoHeaderLine *)subtotalHeaderLine
{
    if (!VALID(_subtotalHeaderLine, JAProductInfoHeaderLine)) {
        _subtotalHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(self.couponView.frame) + 10.f, self.width, kProductInfoHeaderLineHeight)];
        [_subtotalHeaderLine setTitle:STRING_SUBTOTAL];
        [self addSubview:_subtotalHeaderLine];
    }
    return _subtotalHeaderLine;
}

- (UIView *)subtotalView
{
    if (!VALID(_subtotalView, UIView)) {
        _subtotalView = [[UIView alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(self.subtotalHeaderLine.frame), self.width, 200)];
        [self addSubview:_subtotalView];
    }
    return _subtotalView;
}

- (UIImageView *)freeShippingImageView
{
    if (!VALID(_freeShippingImageView, UIImageView)) {
        _freeShippingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"freeShipping"]];
    }
    return _freeShippingImageView;
}

- (UILabel *)freeShippingLabel
{
    if (!VALID(_freeShippingLabel, UILabel)) {
        _freeShippingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width, 30)];
        [_freeShippingLabel setFont:JACaptionItalicFont];
        [_freeShippingLabel setTextColor:JABlack800Color];
        [_freeShippingLabel setText:STRING_FREE_SHIPPING_POSSIBLE];
        [_freeShippingLabel sizeToFit];
    }
    return _freeShippingLabel;
}

- (JAButton *)proceedToCheckoutButton
{
    if (!VALID(_proceedToCheckoutButton, JAButton)) {
        _proceedToCheckoutButton = [[JAButton alloc] initButtonWithTitle:STRING_CONTINUE];
        [_proceedToCheckoutButton setFrame:CGRectMake(0.f, CGRectGetMaxY(self.subtotalView.frame), self.width, kBottomDefaultHeight)];
        [self addSubview:_proceedToCheckoutButton];
    }
    return _proceedToCheckoutButton;
}

- (JAButton *)callToOrderButton
{
    if (!VALID(_callToOrderButton, JAButton)) {
        _callToOrderButton = [[JAButton alloc] initAlternativeButtonWithTitle:STRING_CALL_TO_ORDER];
        [_callToOrderButton setFrame:CGRectMake(0.f, CGRectGetMaxY(self.proceedToCheckoutButton.frame) + 10.f, self.width, kBottomDefaultHeight)];
        [_callToOrderButton setHidden:YES];
        [self addSubview:_callToOrderButton];
    }
    return _callToOrderButton;
}

- (JAProductInfoPriceDescriptionLine *)newPriceDescriptionLineWithHeight:(CGFloat)height
{
    JAProductInfoPriceDescriptionLine *priceDescriptionLine = [[JAProductInfoPriceDescriptionLine alloc] initWithFrame:CGRectMake(0, 0, self.width, height)];
    return priceDescriptionLine;
}

- (void)setCart:(RICart *)cart
{
    _cart = cart;
    [self.subtotalView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat partialHeight = 30.f;
    
    /*
     * products total
     */
    
    JAProductInfoPriceDescriptionLine *itemsNumLine = [self newPriceDescriptionLineWithHeight:partialHeight];
    [itemsNumLine setTopSeparatorVisibility:NO];
    if ([[[self cart] cartCount] integerValue] == 1) {
        [itemsNumLine setTitle:STRING_ITEM_CART];
    }else{
        [itemsNumLine setTitle:[NSString stringWithFormat:STRING_ITEMS_CART, [[[self cart] cartCount] integerValue]]];
    }
    
    [itemsNumLine setPrice:[[self cart] subTotalFormatted] andOldPrice:[[self cart] cartUnreducedValueFormatted]];
    [self.subtotalView addSubview:itemsNumLine];
    
    /*
     * vat
     */
    
    JAProductInfoPriceDescriptionLine *vatLine = [self newPriceDescriptionLineWithHeight:partialHeight];
    [vatLine setTopSeparatorVisibility:NO];
    [vatLine setY:CGRectGetMaxY(itemsNumLine.frame)];
    [vatLine setTitle:[self.cart vatLabel]];
    if ([self.cart vatLabelEnabled].boolValue) {
        [vatLine setPrice:[self.cart vatValueFormatted] andOldPrice:nil];
    }
    [self.subtotalView addSubview:vatLine];
    
    CGFloat heigth = CGRectGetMaxY(vatLine.frame);
    
    /*
     * price rules
     */
    
    NSString *priceRuleKeysString = @"";
    NSString *priceRuleValuesString = @"";
    if(VALID_NOTEMPTY([[self cart] priceRules], NSDictionary))
    {
        NSArray *priceRuleKeys = [[[self cart] priceRules] allKeys];
        
        for (NSString *priceRuleKey in priceRuleKeys)
        {
            priceRuleKeysString = priceRuleKey;
            priceRuleValuesString = [[[self cart] priceRules] objectForKey:priceRuleKey];
            JAProductInfoPriceDescriptionLine *ruleLine = [self newPriceDescriptionLineWithHeight:partialHeight];
            [ruleLine setTopSeparatorVisibility:NO];
            [ruleLine setY:heigth];
            [ruleLine setTitle:priceRuleKeysString];
            [ruleLine setPrice:priceRuleValuesString andOldPrice:nil];
            [self.subtotalView addSubview:ruleLine];
            heigth = CGRectGetMaxY(ruleLine.frame);
        }
    }
    
    /*
     * shipping value
     */
    
    if (VALID_NOTEMPTY(self.cart.shippingValue, NSNumber) && self.cart.shippingValue.floatValue != 0.f) {
        JAProductInfoPriceDescriptionLine *shippingLine = [self newPriceDescriptionLineWithHeight:partialHeight];
        [shippingLine setTopSeparatorVisibility:NO];
        [shippingLine setY:heigth];
        [shippingLine setTitle:STRING_SHIPPING_FEE];
        [shippingLine setPrice:self.cart.shippingValueFormatted andOldPrice:nil];
        [self.subtotalView addSubview:shippingLine];
        heigth = CGRectGetMaxY(shippingLine.frame);
    }
    
    /*
     * extra costs
     */
    
    if([self.cart.extraCosts integerValue] != 0) {
        JAProductInfoPriceDescriptionLine *extraCostsLine = [self newPriceDescriptionLineWithHeight:partialHeight];
        [extraCostsLine setTopSeparatorVisibility:NO];
        [extraCostsLine setY:heigth];
        [extraCostsLine setTitle:STRING_EXTRA_COSTS];
        [extraCostsLine setPrice:[[self cart] extraCostsFormatted] andOldPrice:nil];
        [self.subtotalView addSubview:extraCostsLine];
        heigth = CGRectGetMaxY(extraCostsLine.frame);
    }
    
    /*
     * coupon value
     */
    
    if(VALID([[self cart] couponMoneyValue], NSNumber))
    {
        JAProductInfoPriceDescriptionLine *couponValueLine = [self newPriceDescriptionLineWithHeight:partialHeight];    // missing coupon text color
        [couponValueLine setTopSeparatorVisibility:NO];
        [couponValueLine setY:heigth];
        [couponValueLine setTitle:STRING_VOUCHER];
        [couponValueLine setPrice:[NSString stringWithFormat:@"- %@", [[self cart] couponMoneyValueFormatted]] andOldPrice:nil];
        [self.subtotalView addSubview:couponValueLine];
        heigth = CGRectGetMaxY(couponValueLine.frame);
        [self.couponTextField setText:[self.cart couponCode]];
        [self setCouponValid:YES];
    }else{
        [self removeVoucher];
    }
    
    /*
     * total
     */
    
    JAProductInfoPriceDescriptionLine *subtotalLine = [self newPriceDescriptionLineWithHeight:kProductInfoSubLineHeight];
    [subtotalLine setSize:JAPriceSizeTitle];
    [subtotalLine setY:heigth];
    [subtotalLine setTitle:STRING_TOTAL];
    [subtotalLine setPrice:[[self cart] cartValueFormatted] andOldPrice:nil];
    [self.subtotalView addSubview:subtotalLine];
    
    /*
     * free shipping possibility
     */
    
    heigth = CGRectGetMaxY(subtotalLine.frame);
    BOOL freeShippingPossible = NO;
    for (RICartItem* cartItem in self.cart.cartItems) {
        if (cartItem.freeShippingPossible) {
            freeShippingPossible = YES;
            break;
        }
    }
    [self.freeShippingLabel setHidden:YES];
    [self.freeShippingImageView setHidden:YES];
    if (freeShippingPossible) {
        [self.freeShippingLabel setHidden:NO];
        [self.subtotalView addSubview:self.freeShippingLabel];
        
        [self.freeShippingImageView setHidden:NO];
        [self.subtotalView addSubview:self.freeShippingImageView];
        
        [self.freeShippingImageView setY:heigth];
        [self.freeShippingLabel setY:heigth];
        [self.freeShippingLabel setHeight:self.freeShippingImageView.height];
        heigth = CGRectGetMaxY(self.freeShippingLabel.frame) + 10.f;
    }
    
    [self.subtotalView setHeight:heigth];
    [self setupLayout];
}

- (void)addProceedTarget:(id)target action:(SEL)action
{
    [self.proceedToCheckoutButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)addCallTarget:(id)target action:(SEL)action
{
    [self.callToOrderButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)addCouponTarget:(id)target action:(SEL)action
{
    [self.couponButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)useCoupon
{
    [self.couponTextField setTextColor:JABlackColor];
    [self.couponTextField resignFirstResponder];
}

- (void)removeVoucher
{
    [self.couponTextField setText:@""];
    [self.couponTextField setEnabled:YES];
    [self.couponButton setTitle:[STRING_USE uppercaseString] forState:UIControlStateNormal];
    [self.couponTextField setWidth:_textfieldPlaceholderWidth];
    [self.couponButton sizeToFit];
}

- (void)setCouponValid:(BOOL)valid
{
    if (valid) {
        [self.couponTextField setTextColor:JABlackColor];
        [self.couponTextField setEnabled:NO];
        [self.couponButton setTitle:[STRING_REMOVE uppercaseString] forState:UIControlStateNormal];
    }else{
        [self.couponTextField setTextColor:JARed1Color];
        [self.couponTextField setEnabled:YES];
        [self.couponButton setTitle:[STRING_USE uppercaseString] forState:UIControlStateNormal];
    }
    [self.couponTextField setWidth:_textfieldPlaceholderWidth];
    [self.couponButton sizeToFit];
    [self setupCouponLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (VALID(self.cart, RICart)) {
        [self setCart:self.cart];
    }
}

- (void)setupLayout
{
    [self.couponHeaderLine setFrame:CGRectMake(0.f, 0.f, self.width, self.couponHeaderLine.height)];
    [self.couponView setFrame:CGRectMake(0.f, CGRectGetMaxY(self.couponHeaderLine.frame), self.width, self.couponView.height)];
    [self.subtotalHeaderLine setFrame:CGRectMake(0.f, CGRectGetMaxY(self.couponView.frame), self.width, self.subtotalHeaderLine.height)];
    [self.subtotalView setFrame:CGRectMake(0.f, CGRectGetMaxY(self.subtotalHeaderLine.frame), self.width, self.subtotalView.height)];
    [self.proceedToCheckoutButton setFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.subtotalView.frame), self.width-2*kLateralMargin, self.proceedToCheckoutButton.height)];
    [self.callToOrderButton setFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.proceedToCheckoutButton.frame) + 10.f, self.width-2*kLateralMargin, self.callToOrderButton.height)];

    CGFloat maxWidth = self.width - 2*kLateralMargin - self.couponButton.width - kLateralMargin;
    if (_textfieldPlaceholderWidth < kCouponTextFieldWidth) {
        self.couponTextField.width = kCouponTextFieldWidth;
    }
    if (_textfieldPlaceholderWidth > maxWidth && maxWidth > 0) {
        self.couponTextField.width = maxWidth;
    }
    
    [self.couponTextField setFrame:CGRectMake(kLateralMargin, 5.f, self.couponTextField.width, 20)];
    [self.couponTextField setYCenterAligned];
    
    CGFloat buttonX = CGRectGetMaxX(self.couponTextField.frame) + kLateralMargin;
    [self.couponButton setFrame:CGRectMake(buttonX, 5.f, self.couponButton.width, 20.f)];
    [self.couponButton setYCenterAligned];
    [self.couponButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    [self.freeShippingLabel setXRightAligned:kLateralMargin];
    [self.freeShippingImageView setXLeftOf:self.freeShippingLabel at:4.f];
    
    CGFloat height = CGRectGetMaxY(self.proceedToCheckoutButton.frame);
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]) {
        [self.callToOrderButton setHidden:NO];
        height = CGRectGetMaxY(self.callToOrderButton.frame);
    }
    [self setHeight:height + 10.f];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (void)setupCouponLayout
{
    CGFloat maxWidth = self.width - 2*kLateralMargin - self.couponButton.width - kLateralMargin;
    if (_textfieldPlaceholderWidth < kCouponTextFieldWidth) {
        self.couponTextField.width = kCouponTextFieldWidth;
    }
    if (_textfieldPlaceholderWidth > maxWidth && maxWidth > 0) {
        self.couponTextField.width = maxWidth;
    }
    
    [self.couponTextField setFrame:CGRectMake(kLateralMargin, 5.f, self.couponTextField.width, 20)];
    [self.couponTextField setYCenterAligned];
    
    CGFloat buttonX = CGRectGetMaxX(self.couponTextField.frame) + kLateralMargin;
    [self.couponButton setFrame:CGRectMake(buttonX, 5.f, self.couponButton.width, 20.f)];
    [self.couponButton setYCenterAligned];
    [self.couponButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    if (RI_IS_RTL) {
        [self.couponView flipAllSubviews];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.couponTextField setTextColor:JABlackColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.couponButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    return YES;
}

@end

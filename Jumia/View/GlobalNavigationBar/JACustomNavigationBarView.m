//
//  JACustomNavigationBarView.m
//  Jumia
//
//  Created by Jose Mota on 18/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JACustomNavigationBarView.h"

@interface JACustomNavigationBarView ()
{
    CGFloat _fontSize;
}

@end

@implementation JACustomNavigationBarView

- (UIButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftButton setFrame:CGRectMake(0, 0, 40, 44)];
        [_leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [_leftButton setImage:[UIImage imageNamed:@"btn_menu"] forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:@"btn_menu_pressed"] forState:UIControlStateHighlighted];
        [_leftButton setImage:[UIImage imageNamed:@"btn_menu_pressed"] forState:UIControlStateSelected];
    }
    return _leftButton;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setFrame:CGRectMake(0, 0, 60, 44)];
        [_backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"btn_back_pressed"] forState:UIControlStateHighlighted];
        [_backButton setImage:[UIImage imageNamed:@"btn_back_pressed"] forState:UIControlStateSelected];
        [_backButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
        [_backButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
        [_backButton.titleLabel setFont:[UIFont fontWithName:kFontLightName size:_fontSize]];
    }
    return _backButton;
}

- (UIButton *)cartButton
{
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartButton setFrame:CGRectMake(275, 0, 45, 44)];
        [_cartButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [_cartButton setImage:[UIImage imageNamed:@"btn_cart"] forState:UIControlStateNormal];
        [_cartButton setImage:[UIImage imageNamed:@"btn_cart_pressed"] forState:UIControlStateHighlighted];
        [_cartButton setImage:[UIImage imageNamed:@"btn_cart_pressed"] forState:UIControlStateSelected];
    }
    return _cartButton;
}

- (UIButton *)searchButton
{
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchButton setFrame:CGRectMake(232, 0, 44, 44)];
        [_searchButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [_searchButton setImage:[UIImage imageNamed:@"btn_search"] forState:UIControlStateNormal];
        [_searchButton setImage:[UIImage imageNamed:@"btn_search_pressed"] forState:UIControlStateSelected];
        [_searchButton setImage:[UIImage imageNamed:@"btn_search_pressed"] forState:UIControlStateHighlighted];
    }
    return _searchButton;
}

- (UILabel *)cartCountLabel
{
    if (!_cartCountLabel) {
        _cartCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(288, 6, 25, 15)];
        [_cartCountLabel setTintColor:JAOrange1Color];
        [_cartCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:9]];
    }
    return _cartCountLabel;
}

- (UIImageView *)logoImageView
{
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_navbar_logo"]];
        [_logoImageView setFrame:CGRectMake(119, 12, 83, 20)];
    }
    return _logoImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 230, 44)];
        [_titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
        [_titleLabel setTintColor:JABlack800Color];
        [_titleLabel setFont:[UIFont fontWithName:kFontRegularName size:_fontSize]];
    }
    return _titleLabel;
}

- (UILabel *)topTitleLabel
{
    if (!_topTitleLabel) {
        _topTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 230, 24)];
        [_topTitleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_topTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_topTitleLabel setTintColor:JABlack800Color];
        [_topTitleLabel setFont:[UIFont fontWithName:kFontRegularName size:14.0f]];
    }
    return _topTitleLabel;
}

- (UILabel *)bottomTitleLabel
{
    if (!_bottomTitleLabel) {
        _bottomTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 24, 230, 20)];
        [_bottomTitleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_bottomTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_bottomTitleLabel setTintColor:JABlack800Color];
        [_bottomTitleLabel setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
    }
    return _bottomTitleLabel;
}

- (UIButton *)editButton
{
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setFrame:CGRectMake(0, 8, 106, 34)];
        [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [_editButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
        [_editButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
        [_editButton.titleLabel setFont:[UIFont fontWithName:kFontLightName size:_fontSize]];
    }
    return _editButton;
}

- (UIButton *)doneButton
{
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setFrame:CGRectMake(214, 8, 106, 34)];
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
        [_doneButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
        [_doneButton.titleLabel setFont:[UIFont fontWithName:kFontLightName size:_fontSize]];
    }
    return _doneButton;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

#pragma mark - Setup

- (void)initialSetup;
{
    CGFloat initialWidth = [[UIScreen mainScreen] bounds].size.width;
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIUserInterfaceIdiomPad != UI_USER_INTERFACE_IDIOM() || (orientation != UIInterfaceOrientationLandscapeLeft && orientation != UIInterfaceOrientationLandscapeRight)) {
            initialWidth = [[UIScreen mainScreen] bounds].size.width;
        }else{
            initialWidth = [[UIScreen mainScreen] bounds].size.height;
        }
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              initialWidth,
                              self.frame.size.height)];
    
    self.backgroundColor = JANavBarBackgroundGrey;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    _fontSize = 17.0f;
    if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"]) {
        _fontSize = 14.0f;
    }
    
    [self addSubview:self.leftButton];
    [self addSubview:self.backButton];
    [self addSubview:self.cartButton];
    [self addSubview:self.searchButton];
    [self addSubview:self.cartCountLabel];
    [self addSubview:self.logoImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.topTitleLabel];
    [self addSubview:self.bottomTitleLabel];
    [self addSubview:self.editButton];
    [self addSubview:self.doneButton];
    
    if (RI_IS_RTL) {
        [self.editButton flipViewAlignment];
        [self.doneButton flipViewAlignment];
        [self.backButton flipViewAlignment];
        [self.leftButton flipViewImage];
        [self.backButton flipViewImage];
        [self.cartButton flipViewImage];
    }
}

- (void)orientationChanged:(NSNotification *)notification
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationFaceUp || [[UIDevice currentDevice] orientation] == UIDeviceOrientationFaceDown || [[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        return;
    }
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIUserInterfaceIdiomPad != UI_USER_INTERFACE_IDIOM() || (orientation != UIInterfaceOrientationLandscapeLeft && orientation != UIInterfaceOrientationLandscapeRight)) {
            width = [[UIScreen mainScreen] bounds].size.width;
        }else{
            width = [[UIScreen mainScreen] bounds].size.height;
        }
    }
    if (self.width != width) {
        self.width = width;
        [self adjustTitleFrame];
    }
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupWithNavigationBarLayout:(JANavigationBarLayout*)layout
{
    //left side
    if (layout.showBackButton) {
        [self showBackButtonWithTitle:layout.backButtonTitle];
    } else if (layout.showEditButton) {
        [self showEditButton];
    } else if (layout.showMenuButton) {
        [self showMenuButton];
    } else {
        [self hideLeftItems];
    }
    
    if (layout.showTitleLabel) {
        [self showTitleLabelWithTitle:layout.title subtitle:layout.subTitle];
    } else if (layout.showLogo) {
        [self showLogo];
    } else { //default
        [self hideCenterItems];
    }
    
    if (layout.showDoneButton) {
        [self showDoneButtonWithTitle:layout.doneButtonTitle];
    } else if (layout.showCartButton) {
        [self showCartButton];
        if (layout.showSearchButton) {
            [self showSearchButton];
        }
    } else { //default
        [self hideRightItems];
    }
    
    [self adjustTitleFrame];
}


#pragma mark - Left side
- (void)showBackButtonWithTitle:(NSString*)backButtonTitle;
{
    [self.backButton setTitle:backButtonTitle forState:UIControlStateNormal];
    self.backButton.hidden = NO;
    self.leftButton.hidden = YES;
    self.editButton.hidden = YES;
    
    [self adjustTitleFrame];
}
- (void)showEditButton;
{
    [self.editButton setTitle:STRING_EDIT forState:UIControlStateNormal];
    self.backButton.hidden = YES;
    self.leftButton.hidden = YES;
    self.editButton.hidden = NO;
    
    [self adjustTitleFrame];
}

- (void)showMenuButton;
{
    self.backButton.hidden = YES;
    self.leftButton.hidden = NO;
    self.editButton.hidden = YES;
    
    [self adjustTitleFrame];
}

- (void)hideLeftItems
{
    self.backButton.hidden = YES;
    self.leftButton.hidden = YES;
    self.editButton.hidden = YES;
}

#pragma mark - Center
- (void)showLogo;
{
    self.logoImageView.hidden = NO;
    self.titleLabel.hidden = YES;
    self.topTitleLabel.hidden = YES;
    self.bottomTitleLabel.hidden = YES;
}
- (void)showTitleLabelWithTitle:(NSString*)title
                       subtitle:(NSString*)subtitle;
{
    [self.topTitleLabel setText:title];
    [self.bottomTitleLabel setText:subtitle];
    [self.titleLabel setText:title];
    
    if (VALID_NOTEMPTY(subtitle, NSString)) {
        self.titleLabel.hidden = YES;
        self.topTitleLabel.hidden = NO;
        self.bottomTitleLabel.hidden = NO;
    } else {
        self.titleLabel.hidden = NO;
        self.topTitleLabel.hidden = YES;
        self.bottomTitleLabel.hidden = YES;
        [self bringSubviewToFront:self.titleLabel];
    }
    
    [self adjustTitleFrame];
    
    self.logoImageView.hidden = YES;
}

-(void)adjustTitleFrame
{

    CGFloat width = self.width;
    
    CGFloat leftMargin = 0.0f;
    CGFloat backButtonLeftMargin = 4.0f;
    CGFloat editButtonLeftMargin = 7.0f;
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        leftMargin = 6.0f;
        backButtonLeftMargin = 16.0f;
        editButtonLeftMargin = 16.0f;
    }
    
    [self.logoImageView setFrame:CGRectMake((width - self.logoImageView.frame.size.width) / 2,
                                            self.logoImageView.frame.origin.y,
                                            self.logoImageView.frame.size.width,
                                            self.logoImageView.frame.size.height)];
    
    CGRect rightItemFrame = CGRectZero;
    if(!self.doneButton.hidden)
    {
        NSString *doneButtonText = self.doneButton.titleLabel.text;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:kFontRegularName size:17]};
        CGSize doneButtonTextSize = [doneButtonText sizeWithAttributes:attributes];
        CGFloat doneButtonWidth = 6.0f + doneButtonTextSize.width;
        
        [self.doneButton setFrame:CGRectMake(width - doneButtonWidth - editButtonLeftMargin,
                                             self.doneButton.frame.origin.y,
                                             doneButtonWidth,
                                             self.doneButton.frame.size.height)];
        rightItemFrame = self.doneButton.frame;
    }
    else if(!self.cartButton.hidden)
    {
        [self.cartButton setFrame:CGRectMake(width - self.cartButton.frame.size.width - leftMargin,
                                             self.cartButton.frame.origin.y,
                                             self.cartButton.frame.size.width,
                                             self.cartButton.frame.size.height)];
        
        CGFloat marginBetweenCartButtonAndLabel = 7.0f;
        [self.cartCountLabel setFrame:CGRectMake(width - self.cartCountLabel.frame.size.width - leftMargin - marginBetweenCartButtonAndLabel,
                                                 self.cartCountLabel.frame.origin.y,
                                                 self.cartCountLabel.frame.size.width,
                                                 self.cartCountLabel.frame.size.height)];
        
        rightItemFrame = self.cartButton.frame;
        if (!self.searchButton.hidden) {
            
            [self.searchButton setFrame:CGRectMake(self.cartButton.frame.origin.x - self.searchButton.frame.size.width,
                                                   self.searchButton.frame.origin.y,
                                                   self.searchButton.frame.size.width,
                                                   self.searchButton.frame.size.height)];
            
            rightItemFrame = CGRectMake(self.searchButton.frame.origin.x,
                                        self.searchButton.frame.origin.y,
                                        self.searchButton.frame.size.width + self.cartButton.frame.size.width,
                                        self.searchButton.frame.size.height);
        }
    }
    
    CGRect leftItemFrame = CGRectZero;
    if(!self.backButton.hidden)
    {
        NSString *backButtonText = self.backButton.titleLabel.text;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:kFontRegularName size:17]};
        CGSize backButtonTextSize = [backButtonText sizeWithAttributes:attributes];
        
        CGFloat backButtonMaxWidth = backButtonTextSize.width;
        CGFloat backButtonFinalWidth = self.backButton.frame.size.width;
        
        if(backButtonTextSize.width > 80.0f && !self.titleLabel.hidden)
        {
            backButtonMaxWidth = 80.0f;
            backButtonFinalWidth = 6.0f + backButtonMaxWidth + 11.0f + 12.0f;
        }
        else
        {
            if(!self.titleLabel.hidden || !self.topTitleLabel.hidden)
            {
                backButtonMaxWidth = backButtonTextSize.width;
                backButtonFinalWidth = 6.0f + backButtonMaxWidth + 11.0f + 12.0f;
            }
            else
            {
                backButtonMaxWidth = width - rightItemFrame.size.width - 12.0f;
                backButtonFinalWidth = 6.0f + backButtonMaxWidth + 11.0f;
            }
        }
        [self.backButton setX:backButtonLeftMargin];
        leftItemFrame = self.backButton.frame;
    }
    else if(!self.leftButton.hidden)
    {
        [self.leftButton setX:leftMargin];
        leftItemFrame = self.leftButton.frame;
    }
    else if(!self.editButton.hidden)
    {
        [self.editButton sizeToFit];
        [self.editButton setFrame:CGRectMake(editButtonLeftMargin,
                                             self.editButton.frame.origin.y,
                                             self.editButton.frame.size.width,
                                             self.editButton.frame.size.height)];
        leftItemFrame = self.editButton.frame;
    }
    
    CGFloat titleLabelWidth = 0.0f;
    CGFloat titleLabelSideMargin = 0.0f;
    if(leftItemFrame.size.width >= rightItemFrame.size.width)
    {
        titleLabelSideMargin = leftItemFrame.size.width + 3.0f;
    }
    else
    {
        titleLabelSideMargin = rightItemFrame.size.width + 3.0f;
    }
    titleLabelWidth = width - (2 * titleLabelSideMargin);
    
    NSString *titleLabelText = self.titleLabel.text;
    NSDictionary *titleLabelAttributes = @{NSFontAttributeName: [UIFont fontWithName:kFontRegularName size:17]};
    CGSize titleLabelTextSize = [titleLabelText sizeWithAttributes:titleLabelAttributes];
    if (titleLabelTextSize.width > titleLabelWidth)
    {
        titleLabelWidth = width - leftItemFrame.size.width - rightItemFrame.size.width - 24.0f;
        titleLabelSideMargin = (width - titleLabelWidth) / 2;
    }
    
    [self.titleLabel setNumberOfLines:2];
    [self.titleLabel setFrame:CGRectMake(titleLabelSideMargin,
                                         self.titleLabel.frame.origin.y,
                                         titleLabelWidth,
                                         self.titleLabel.frame.size.height)];
    [self.topTitleLabel setFrame:CGRectMake(titleLabelSideMargin,
                                            3.0f,
                                            titleLabelWidth,
                                            24.0f)];
    [self.bottomTitleLabel setFrame:CGRectMake(titleLabelSideMargin,
                                               self.frame.size.height - self.bottomTitleLabel.frame.size.height - 2.0f,
                                               titleLabelWidth,
                                               self.bottomTitleLabel.frame.size.height)];
    
    if (RI_IS_RTL) {
        [self flipSubviewPositions];
    }
}

- (void)hideCenterItems
{
    self.logoImageView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.topTitleLabel.hidden = YES;
    self.bottomTitleLabel.hidden = YES;
}

#pragma mark - Right side
- (void)showDoneButtonWithTitle:(NSString*)doneButtonTitle;
{
    [self.doneButton setTitle:doneButtonTitle forState:UIControlStateNormal];
    self.doneButton.hidden = NO;
    self.cartButton.hidden = YES;
    self.cartCountLabel.hidden = YES;
    self.searchButton.hidden = YES;
}

- (void)showCartButton;
{
    self.doneButton.hidden = YES;
    self.cartButton.hidden = NO;
    self.cartCountLabel.hidden = NO;
}

- (void)showSearchButton
{
    self.searchButton.hidden = NO;
}

- (void)hideRightItems
{
    self.doneButton.hidden = YES;
    self.cartButton.hidden = YES;
    self.cartCountLabel.hidden = YES;
    self.searchButton.hidden = YES;
}

#pragma mark - Details

- (void)updateCartProductCount:(NSNumber*)cartNumber
{
    if(0 == [cartNumber integerValue])
    {
        [self.cartCountLabel setText:@""];
    }
    else
    {
        [self.cartCountLabel setText:[cartNumber stringValue]];
    }
}

@end

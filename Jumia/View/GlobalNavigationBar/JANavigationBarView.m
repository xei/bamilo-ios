//
//  JANavigationBarView.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANavigationBarView.h"
#import "JAAppDelegate.h"

@interface JANavigationBarView ()

@end

@implementation JANavigationBarView

+ (JANavigationBarView *)getNewNavBarView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JANavigationBarView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JANavigationBarView class]]) {
            return (JANavigationBarView *)obj;
        }
    }
    
    return nil;
}

#pragma mark - Setup

- (void)initialSetup;
{
    self.translatesAutoresizingMaskIntoConstraints = YES;
    self.editButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.backButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.leftButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.topTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.bottomTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.doneButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.cartButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.cartCountLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.searchButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.titleLabel.minimumScaleFactor = 10./self.titleLabel.font.pointSize;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.topTitleLabel.minimumScaleFactor = 10./self.titleLabel.font.pointSize;
    self.topTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.bottomTitleLabel.minimumScaleFactor = 10./self.titleLabel.font.pointSize;
    self.bottomTitleLabel.adjustsFontSizeToFitWidth = YES;
    
    CGFloat initialWidth = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame.size.width;
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              initialWidth,
                              self.frame.size.height)];
    
    self.backgroundColor = JANavBarBackgroundGrey;
    [self.editButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.editButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.doneButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.doneButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    self.titleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    
    [self.backButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.backButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self.logoImageView setImage:[UIImage imageNamed:@"img_navbar_logo"]];
    
    [self.editButton.titleLabel setFont:[UIFont fontWithName:kFontLightName size:17.0f]];
    [self.backButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:17.0f]];
    [self.doneButton.titleLabel setFont:[UIFont fontWithName:kFontLightName size:17.0f]];
    [self.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:17.0f]];
    [self.topTitleLabel setFont:[UIFont fontWithName:kFontRegularName size:14.0f]];
    [self.bottomTitleLabel setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
    
    self.editButton.titleLabel.font = [UIFont fontWithName:kFontLightName size:self.editButton.titleLabel.font.pointSize];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustTitleFrame];
}

- (void)dealloc
{
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
    [self.topTitleLabel setText:@""];
    [self.topTitleLabel setText:title];
    [self.bottomTitleLabel setText:@""];
    [self.bottomTitleLabel setText:subtitle];
    [self.titleLabel setText:@""];
    [self.titleLabel setText:title];
    
    if (VALID_NOTEMPTY(subtitle, NSString)) {
        self.titleLabel.hidden = YES;
        self.topTitleLabel.hidden = NO;
        self.bottomTitleLabel.hidden = NO;
    } else {
        self.titleLabel.hidden = NO;
        self.topTitleLabel.hidden = YES;
        self.bottomTitleLabel.hidden = YES;
    }
    
    [self adjustTitleFrame];
    
    self.logoImageView.hidden = YES;
}

-(void)adjustTitleFrame
{
    CGFloat leftMargin = 0.0f;
    CGFloat backButtonLeftMargin = 4.0f;
    CGFloat editButtonLeftMargin = 7.0f;

    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat width = frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        leftMargin = 6.0f;
        backButtonLeftMargin = 12.0f;
        editButtonLeftMargin = 16.0f;
        
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(UIDeviceOrientationUnknown != deviceOrientation && UIDeviceOrientationIsPortrait(deviceOrientation))
        {
            if(frame.size.width > frame.size.height)
            {
                width = frame.size.height;
            }
        }
        else if(UIDeviceOrientationUnknown != deviceOrientation && UIDeviceOrientationIsLandscape(deviceOrientation))
        {
            if(frame.size.height > frame.size.width)
            {
                width = frame.size.height;
            }
        }
        else if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            if(frame.size.width > frame.size.height)
            {
                width = frame.size.height;
            }
        }
        else if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
        {
            if(frame.size.height > frame.size.width)
            {
                width = frame.size.height;
            }
        }
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
        
        [self.backButton setFrame:CGRectMake(backButtonLeftMargin,
                                             self.backButton.frame.origin.y,
                                             backButtonFinalWidth,
                                             self.backButton.frame.size.height)];
        leftItemFrame = self.backButton.frame;
    }
    else if(!self.leftButton.hidden)
    {
        [self.leftButton setFrame:CGRectMake(leftMargin,
                                             self.leftButton.frame.origin.y,
                                             self.leftButton.frame.size.width,
                                             self.leftButton.frame.size.height)];
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

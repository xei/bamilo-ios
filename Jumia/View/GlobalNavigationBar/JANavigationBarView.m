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
    self.doneButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.cartButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.cartCountLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.logoImageView.translatesAutoresizingMaskIntoConstraints = YES;
    
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
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustTitleFrame];
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
}
- (void)showTitleLabelWithTitle:(NSString*)title
                       subtitle:(NSString*)subtitle;
{
    NSMutableAttributedString* finalTitleString;
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"HelveticaNeue" size:17.0f], NSFontAttributeName,
                                UIColorFromRGB(0x4e4e4e), NSForegroundColorAttributeName, nil];
    if (VALID_NOTEMPTY(subtitle, NSString)) {
        NSString* subtitleBrackets = [NSString stringWithFormat:@" (%@)", subtitle];
        NSDictionary* subtitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f], NSFontAttributeName,
                                            nil];
        NSRange subtitleRange = NSMakeRange(title.length, subtitleBrackets.length);
        finalTitleString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", title, subtitleBrackets]
                                                                  attributes:attributes];
        
        [finalTitleString setAttributes:subtitleAttributes
                                  range:subtitleRange];
        
    } else {
        finalTitleString = [[NSMutableAttributedString alloc] initWithString:title attributes:attributes];
    }
    
    [self.titleLabel setAttributedText:finalTitleString];
    self.logoImageView.hidden = YES;
    self.titleLabel.hidden = NO;
    
    [self adjustTitleFrame];
}

-(void)adjustTitleFrame
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat width = frame.size.width;
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
    
    CGFloat leftMargin = 0.0f;
    CGFloat backButtonLeftMargin = 4.0f;
    CGFloat editButtonLeftMargin = 7.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        leftMargin = 6.0f;
        backButtonLeftMargin = 12.0f;
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
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
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
    }
    
    CGRect leftItemFrame = CGRectZero;
    if(!self.backButton.hidden)
    {
        NSString *backButtonText = self.backButton.titleLabel.text;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
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
            if(!self.titleLabel.hidden)
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
    CGFloat titleLabelLeftMargin = 0.0f;
    if(leftItemFrame.size.width >= rightItemFrame.size.width)
    {
        titleLabelLeftMargin = leftItemFrame.size.width + 3.0f;
    }
    else
    {
        titleLabelLeftMargin = rightItemFrame.size.width + 3.0f;
    }
    titleLabelWidth = width - (2 * titleLabelLeftMargin);
    
    NSString *titleLabelText = self.titleLabel.text;
    NSDictionary *titleLabelAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
    CGSize titleLabelTextSize = [titleLabelText sizeWithAttributes:titleLabelAttributes];
    if (titleLabelTextSize.width > titleLabelWidth)
    {
        titleLabelWidth = width - leftItemFrame.size.width - rightItemFrame.size.width - 24.0f;
        titleLabelLeftMargin = (width - titleLabelWidth) / 2 + 12.0;
    }
    
    [self.titleLabel setFrame:CGRectMake(titleLabelLeftMargin,
                                         self.titleLabel.frame.origin.y,
                                         titleLabelWidth,
                                         self.titleLabel.frame.size.height)];
}

- (void)hideCenterItems
{
    self.logoImageView.hidden = YES;
    self.titleLabel.hidden = YES;
}

#pragma mark - Right side
- (void)showDoneButtonWithTitle:(NSString*)doneButtonTitle;
{
    [self.doneButton setTitle:doneButtonTitle forState:UIControlStateNormal];
    self.doneButton.hidden = NO;
    self.cartButton.hidden = YES;
    self.cartCountLabel.hidden = YES;
}

- (void)showCartButton;
{
    self.doneButton.hidden = YES;
    self.cartButton.hidden = NO;
    self.cartCountLabel.hidden = NO;
}

- (void)hideRightItems
{
    self.doneButton.hidden = YES;
    self.cartButton.hidden = YES;
    self.cartCountLabel.hidden = YES;
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

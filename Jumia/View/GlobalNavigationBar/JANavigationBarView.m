//
//  JANavigationBarView.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANavigationBarView.h"

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
    self.backgroundColor = JANavBarBackgroundGrey;
    [self.editButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.doneButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    self.titleLabel.textColor = UIColorFromRGB(0x4e4e4e);
}

- (void)setupWithNavigationBarLayout:(JANavigationBarLayout*)layout;
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
    CGRect leftItemFrame = CGRectZero;
    if(!self.backButton.hidden)
    {
        NSString *backButtonText = self.backButton.titleLabel.text;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
        CGSize backButtonTextSize = [backButtonText sizeWithAttributes:attributes];
        CGRect frame = self.backButton.frame;
        frame.size.width = 6.0f + backButtonTextSize.width + 11.0f + 12.0f;
        self.backButton.frame = frame;
        leftItemFrame = frame;
    }
    else if(!self.leftButton.hidden)
    {
        [self.leftButton sizeToFit];
        leftItemFrame = self.leftButton.frame;
    }
    else if(!self.editButton.hidden)
    {
        [self.editButton sizeToFit];
        leftItemFrame = self.editButton.frame;
    }
    
    CGRect rightItemFrame = CGRectZero;
    if(!self.doneButton.hidden)
    {
        rightItemFrame = self.doneButton.frame;
    }
    else if(!self.cartButton.hidden)
    {
        rightItemFrame = self.cartButton.frame;
    }
    
    [self.titleLabel setFrame:CGRectMake(CGRectGetMaxX(leftItemFrame) + 3.0f,
                                         self.titleLabel.frame.origin.y,
                                         CGRectGetMinX(rightItemFrame) - 3.0f - CGRectGetMaxX(leftItemFrame),
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

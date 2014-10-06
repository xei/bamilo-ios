    //
//  JANavigationBarView.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANavigationBarView.h"

@interface JANavigationBarView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeftMargin;

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
    self.backgroundColor = JANavBarBackgroundGrey;
    [self.editButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.editButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.doneButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.doneButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    self.titleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    
    [self.backButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.backButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
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
    CGRect rightItemFrame = CGRectZero;
    if(!self.doneButton.hidden)
    {
        NSString *doneButtonText = self.doneButton.titleLabel.text;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
        CGSize doneButtonTextSize = [doneButtonText sizeWithAttributes:attributes];
        CGRect frame = self.doneButton.frame;
        frame.size.width = 6.0f + doneButtonTextSize.width;
        self.doneButton.frame = frame;
        rightItemFrame = frame;
    }
    else if(!self.cartButton.hidden)
    {
        rightItemFrame = self.cartButton.frame;
    }
    
    CGRect leftItemFrame = CGRectZero;
    if(!self.backButton.hidden)
    {
        NSString *backButtonText = self.backButton.titleLabel.text;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
        CGSize backButtonTextSize = [backButtonText sizeWithAttributes:attributes];
        CGRect frame = self.backButton.frame;
        CGFloat backButtonMaxWidth = backButtonTextSize.width;
        if(backButtonTextSize.width > 80.0f && !self.titleLabel.hidden)
        {
            backButtonMaxWidth = 80.0f;
            frame.size.width = 6.0f + backButtonMaxWidth + 11.0f + 12.0f;
        }
        else
        {
            if(!self.titleLabel.hidden)
            {
                backButtonMaxWidth = backButtonTextSize.width;
                frame.size.width = 6.0f + backButtonMaxWidth + 11.0f + 12.0f;
            }
            else
            {
                backButtonMaxWidth = self.frame.size.width - rightItemFrame.size.width - 12.0f;
                frame.size.width = 6.0f + backButtonMaxWidth + 11.0f;
            }
        }
            
        self.backButton.frame = frame;
        self.backButtonWidth.constant = frame.size.width;
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
    titleLabelWidth = self.frame.size.width - (2 * titleLabelLeftMargin);
    
    NSString *titleLabelText = self.titleLabel.text;
    NSDictionary *titleLabelAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:17]};
    CGSize titleLabelTextSize = [titleLabelText sizeWithAttributes:titleLabelAttributes];
    if (titleLabelTextSize.width > titleLabelWidth)
    {
        titleLabelWidth = self.frame.size.width - leftItemFrame.size.width - rightItemFrame.size.width - 6.0f;
        titleLabelLeftMargin = (self.frame.size.width - titleLabelWidth) / 2 + 12.0;
    }

    self.titleLabelLeftMargin.constant = titleLabelLeftMargin;
    self.titleLabelWidth.constant = titleLabelWidth;
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

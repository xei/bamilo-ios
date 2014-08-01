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

#pragma mark - Public methods

- (void)changeNavigationBarTitle:(NSString *)newTitle
{
    self.backButton.hidden = YES;
    self.backImageView.hidden = YES;
    self.applyButton.hidden = YES;
    self.cartButton.hidden = NO;
    
    self.logoImageView.hidden = YES;
    self.titleLabel.text = newTitle;
    self.titleLabel.hidden = NO;
}

- (void)changedToHomeViewController
{
    self.backButton.hidden = YES;
    self.backImageView.hidden = YES;
    self.applyButton.hidden = YES;
    self.cartButton.hidden = NO;
    
    self.logoImageView.hidden = NO;
    self.titleLabel.hidden = YES;
}

- (void)enteredInFirstLevelWithTitle:(NSString *)title
                     andProductCount:(NSString *)productCount
{
    self.backButton.hidden = YES;
    self.backImageView.hidden = YES;
    self.applyButton.hidden = YES;
    self.cartButton.hidden = NO;
    
    title = [title stringByAppendingString:@" "];
    productCount = [NSString stringWithFormat:@"(%@)", productCount];
    
    NSMutableAttributedString *stringTitle = [[NSMutableAttributedString alloc] initWithString:title];
    
    NSInteger _stringLength = title.length;
    
    UIColor *titleColor = [UIColor colorWithRed:78.0/255.0 green:78.0/255.0 blue:78.0/255.0 alpha:1.0f];
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue"
                                   size:17.0];
    
    [stringTitle addAttribute:NSFontAttributeName
                        value:font
                        range:NSMakeRange(0, _stringLength)];
    
    [stringTitle addAttribute:NSStrokeColorAttributeName
                        value:titleColor
                        range:NSMakeRange(0, _stringLength)];
    
    NSMutableAttributedString *stringProductCount = [[NSMutableAttributedString alloc] initWithString:productCount];
    
    NSInteger secondStringLength = productCount.length;
    
    UIFont *countFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                        size:10.0];
    
    [stringProductCount addAttribute:NSFontAttributeName
                               value:countFont
                               range:NSMakeRange(0, secondStringLength)];
    
    [stringProductCount addAttribute:NSStrokeColorAttributeName
                               value:titleColor
                               range:NSMakeRange(0, secondStringLength)];
    
    NSMutableAttributedString *resultString = [stringTitle mutableCopy];
    [resultString appendAttributedString:stringProductCount];
    
    self.logoImageView.hidden = YES;
    self.titleLabel.attributedText = resultString;
    self.titleLabel.hidden = NO;
}

- (void)enteredSecondOrThirdLevelWithBackTitle:(NSString *)backTitle
{
    self.logoImageView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.leftButton.hidden = YES;
    self.applyButton.hidden = YES;
    self.cartButton.hidden = NO;
    
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue"
                                   size:17.0];
    
    self.backButton.titleLabel.font = font;
    
    [self.backButton setTitle:backTitle
                     forState:UIControlStateNormal];
    
    self.backButton.hidden = NO;
    self.backImageView.hidden = NO;
}

- (void)updateCartProductCount:(NSNumber*)cartNumber
{
    [self.cartCountLabel setText:[cartNumber stringValue]];
}

#pragma mark - Choose country

- (void)changeToChooseCountry
{
    self.logoImageView.hidden = NO;
    self.titleLabel.hidden = YES;
    self.leftButton.hidden = NO;
    self.applyButton.hidden = NO;
    self.cartButton.hidden = YES;
    
    self.applyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

@end

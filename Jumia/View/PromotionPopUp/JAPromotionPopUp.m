//
//  JAPromotionPopUp.m
//  Jumia
//
//  Created by Telmo Pinto on 02/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPromotionPopUp.h"

@interface JAPromotionPopUp()

@property (nonatomic, strong)UIView* containerView;
@property (nonatomic, strong)UILabel* titleLabel;
@property (nonatomic, strong)UILabel* descriptionLabel;
@property (nonatomic, strong)UIButton* couponButton;
@property (nonatomic, strong)UILabel* couponCodeLabel;
@property (nonatomic, strong)UILabel* couponEndDateLabel;
@property (nonatomic, strong)UIButton* shopNowButton;
@property (nonatomic, strong)UILabel* termsAndConditionsLabel;

@end

@implementation JAPromotionPopUp

- (void)loadWithPromotion:(RIPromotion*)promotion
{
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    
    CGFloat contentWidth = 270.0f;
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - contentWidth) / 2,
                                                                  100.0f,
                                                                  contentWidth,
                                                                  10.0f)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 5.0f;
    [self addSubview:self.containerView];
    
    CGFloat currentY = 15.0f;
    CGRect genericRect = CGRectMake(10.0f,
                                    currentY,
                                    contentWidth - 10.0f * 2,
                                    20.0f);
    
    self.titleLabel = [[UILabel alloc] initWithFrame:genericRect];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = -1;
    [self formatStringInLabel:self.titleLabel
                         text:promotion.title
                     fontName:kFontRegularName
                     fontSize:12.0f];
    [self.titleLabel sizeToFit];
    [self.titleLabel setFrame:CGRectMake(genericRect.origin.x,
                                         currentY,
                                         genericRect.size.width,
                                         self.titleLabel.frame.size.height)];
    [self.containerView addSubview:self.titleLabel];
    
    currentY = CGRectGetMaxY(self.titleLabel.frame) + 20.0f;
    self.descriptionLabel = [[UILabel alloc] initWithFrame:genericRect];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.numberOfLines = -1;
    [self formatStringInLabel:self.descriptionLabel
                         text:promotion.descriptionMessage
                     fontName:kFontMediumName
                     fontSize:17.0f];
    [self.descriptionLabel setFrame:CGRectMake(genericRect.origin.x,
                                               currentY,
                                               genericRect.size.width,
                                               self.descriptionLabel.frame.size.height)];
    [self.containerView addSubview:self.descriptionLabel];
    
    currentY = CGRectGetMaxY(self.descriptionLabel.frame) + 20.0f;
    UIImage* buttonImage = [UIImage imageNamed:@"trackNumberBox"];
    self.couponButton = [[UIButton alloc] initWithFrame:CGRectMake((self.containerView.frame.size.width - buttonImage.size.width) / 2,
                                                                   currentY,
                                                                   buttonImage.size.width,
                                                                   buttonImage.size.height)];
    [self.couponButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.couponButton addTarget:self action:@selector(copyOrderNumber) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.couponButton];
    
    self.couponCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.couponButton.frame.origin.x,
                                                                     self.couponButton.frame.origin.y,
                                                                     self.couponButton.frame.size.width,
                                                                     self.couponButton.frame.size.height)];
    self.couponCodeLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.couponCodeLabel.font = [UIFont fontWithName:kFontBoldName size:13.0f];
    self.couponCodeLabel.textAlignment = NSTextAlignmentCenter;
    self.couponCodeLabel.text = promotion.couponCode;
    [self.containerView addSubview:self.couponCodeLabel];
    
    currentY = CGRectGetMaxY(self.couponButton.frame) + 15.0f;
    self.couponEndDateLabel = [[UILabel alloc] initWithFrame:genericRect];
    self.couponEndDateLabel.textAlignment = NSTextAlignmentCenter;
    self.couponEndDateLabel.numberOfLines = -1;
    self.couponEndDateLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
    self.couponEndDateLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.couponEndDateLabel.text = [NSString stringWithFormat:@"%@. %@ %@",STRING_PROMOTION_TIP_TAP, STRING_CAMPAIGN_TIMER_END, promotion.endDate];
    [self.couponEndDateLabel sizeToFit];
    [self.couponEndDateLabel setFrame:CGRectMake(genericRect.origin.x,
                                                 currentY,
                                                 genericRect.size.width,
                                                 self.couponEndDateLabel.frame.size.height)];
    [self.containerView addSubview:self.couponEndDateLabel];
    
    currentY = CGRectGetMaxY(self.couponEndDateLabel.frame) + 20.0f;
    UIImage* shopButtonImage = [UIImage imageNamed:@"promoContinueShopping"];
    UIImage* shopButtonImageHighlighted = [UIImage imageNamed:@"promoContinueShopping_highlighted"];
    self.shopNowButton = [[UIButton alloc] initWithFrame:CGRectMake((self.containerView.frame.size.width - shopButtonImage.size.width) / 2,
                                                                    currentY,
                                                                    shopButtonImage.size.width,
                                                                    shopButtonImage.size.height)];
    [self.shopNowButton setBackgroundImage:shopButtonImage forState:UIControlStateNormal];
    [self.shopNowButton setBackgroundImage:shopButtonImageHighlighted forState:UIControlStateHighlighted];
    [self.shopNowButton setTitle:STRING_GO_SHOP forState:UIControlStateNormal];
    [self.shopNowButton.titleLabel setFont:[UIFont fontWithName:kFontLightName size:11.0f]];
    [self.shopNowButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.shopNowButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.shopNowButton];
    
    currentY = CGRectGetMaxY(self.shopNowButton.frame) + 15.0f;
    self.termsAndConditionsLabel = [[UILabel alloc] initWithFrame:genericRect];
    self.termsAndConditionsLabel.textAlignment = NSTextAlignmentCenter;
    self.termsAndConditionsLabel.numberOfLines = -1;
    [self formatStringInLabel:self.termsAndConditionsLabel
                         text:promotion.termsAndConditions
                     fontName:kFontLightName
                     fontSize:9.0f];
    [self.termsAndConditionsLabel sizeToFit];
    [self.termsAndConditionsLabel setFrame:CGRectMake(genericRect.origin.x,
                                                      currentY,
                                                      genericRect.size.width,
                                                      self.termsAndConditionsLabel.frame.size.height)];
    [self.containerView addSubview:self.termsAndConditionsLabel];
    
    currentY = CGRectGetMaxY(self.termsAndConditionsLabel.frame) + 15.0f;
    
    [self.containerView setFrame:CGRectMake(self.containerView.frame.origin.x,
                                            (self.bounds.size.height - currentY) / 2,
                                            self.containerView.frame.size.width,
                                            currentY)];
}

- (void)formatStringInLabel:(UILabel*)label
                       text:(NSString*)text
                   fontName:(NSString*)fontName
                   fontSize:(CGFloat)fontSize
{
    NSRange tagStartRange = [text rangeOfString:@"[bold]"];
    NSRange tagEndRange = [text rangeOfString:@"[/bold]"];
    NSRange boldTextRange = NSMakeRange(tagStartRange.location + tagStartRange.length, tagEndRange.location - (tagStartRange.location + tagStartRange.length));
    NSRange beforeBoldRange = NSMakeRange(0, tagStartRange.location);
    NSRange afterBoldRange = NSMakeRange(tagEndRange.location + tagEndRange.length, text.length - (tagEndRange.location + tagEndRange.length));
    
    NSMutableAttributedString* finalString;
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                                UIColorFromRGB(0x4e4e4e), NSForegroundColorAttributeName, nil];
    
    if (NSNotFound != boldTextRange.location) {
        NSString* boldText = [text substringWithRange:boldTextRange];
        NSString* beforeText = [text substringWithRange:beforeBoldRange];
        NSString* afterText = [text substringWithRange:afterBoldRange];
        
        NSDictionary* boldAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:kFontBoldName size:fontSize], NSFontAttributeName,
                                        nil];
        finalString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@", beforeText, boldText, afterText]
                                                             attributes:attributes];
        NSRange boldTextRangeMinusTheTag = NSMakeRange(boldTextRange.location - tagStartRange.length, boldTextRange.length);
        [finalString setAttributes:boldAttributes
                             range:boldTextRangeMinusTheTag];
    } else {
        finalString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    }
    
    [label setAttributedText:finalString];
    [label sizeToFit];
}

- (void)copyOrderNumber
{
    [[UIPasteboard generalPasteboard] setString:[self.couponCodeLabel text]];
}

- (void)dismissView
{
    [self removeFromSuperview];
}

@end

//
//  JAMaintenancePage.m
//  Jumia
//
//  Created by plopes on 13/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMaintenancePage.h"
#import "UIImageView+WebCache.h"

@implementation JAMaintenancePage

void(^retryBock)(BOOL dismiss);

+ (JAMaintenancePage *)getNewJAMaintenancePage
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAMaintenancePage"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib)
    {
        if ([obj isKindOfClass:[JAMaintenancePage class]])
        {
            return (JAMaintenancePage *)obj;
        }
    }
    
    return nil;
}

- (void)setupMaintenancePage:(CGRect)frame
{
    [self setFrame:frame];
    
    RIApi *apiInformation = [RIApi getApiInformation];
    NSString *countryName = @"";
    if(VALID_NOTEMPTY(apiInformation, RIApi) && VALID_NOTEMPTY(apiInformation.countryName, NSString))
    {
        countryName = apiInformation.countryName;
    }
    
    UILabel *maintenanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [maintenanceLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0f]];
    [maintenanceLabel setTextColor:UIColorFromRGB(0xffffff)];
    [maintenanceLabel setText:STRING_MAINTENANCE];
    [maintenanceLabel sizeToFit];
    [maintenanceLabel setFrame:CGRectMake((frame.size.width - maintenanceLabel.frame.size.width) / 2,
                                          27.0f,
                                          maintenanceLabel.frame.size.width,
                                          maintenanceLabel.frame.size.height)];
    [self addSubview:maintenanceLabel];
    
    UIView *maintenanceLabelSeparator = [[UIView alloc] initWithFrame:CGRectMake(maintenanceLabel.frame.origin.x,
                                                                                 CGRectGetMaxY(maintenanceLabel.frame) + 10.0f,
                                                                                 maintenanceLabel.frame.size.width,
                                                                                 1.0f)];
    [maintenanceLabelSeparator setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self addSubview:maintenanceLabelSeparator];
    
    CGFloat logoViewWidth = 0.0f;
    CGFloat logoViewHeight = 0.0f;
    
    UIView *logoView = [[UIView alloc] initWithFrame:CGRectZero];
    UIImage *logoImage = [UIImage imageNamed:@"maintenanceLogo"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    
    [logoView addSubview:logoImageView];
    logoViewWidth = logoImage.size.width;
    logoViewHeight = logoImage.size.height;
    
    UIFont *countryNameLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:24.0f];
    UILabel *countryNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [countryNameLabel setFont:countryNameLabelFont];
    [countryNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [countryNameLabel setNumberOfLines:0];
    [countryNameLabel setTextColor:UIColorFromRGB(0x000000)];
    [countryNameLabel setText:countryName];
    [countryNameLabel sizeToFit];
    
    
    CGRect countryNameLabelRect = [countryName boundingRectWithSize:CGSizeMake(self.frame.size.width - logoViewWidth - 20.0f, self.frame.size.height)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:countryNameLabelFont} context:nil];
    CGFloat countryNameLabelHeight = countryNameLabelRect.size.height;// + 2.0f;
    
    [logoView addSubview:countryNameLabel];
    logoViewWidth += (countryNameLabelRect.size.width + 10.0f);
    
    CGFloat logoImageViewTopPadding = 10.0f;
    CGFloat countryNameLabelTopPadding = 10.0f;
    if(countryNameLabelHeight > logoImage.size.height)
    {
        logoViewHeight = countryNameLabelHeight;
        countryNameLabelTopPadding = 0.0f;
        logoImageViewTopPadding = (countryNameLabelHeight - logoImage.size.height) / 2;
    }
    
    [logoImageView setFrame:CGRectMake(0.0f,
                                       logoImageViewTopPadding,
                                       logoImage.size.width,
                                       logoImage.size.height)];
    
    [countryNameLabel setFrame:CGRectMake(CGRectGetMaxX(logoImageView.frame) + 10.0f,
                                          countryNameLabelTopPadding,
                                          countryNameLabelRect.size.width,
                                          countryNameLabelHeight)];
    
    [logoView setFrame:CGRectMake((self.frame.size.width - logoViewWidth) / 2,
                                  CGRectGetMaxY(maintenanceLabelSeparator.frame),
                                  logoImage.size.width,
                                  logoViewHeight)];
    [self addSubview:logoView];
    
    NSString *bestShoppingExperienceString = @"";
    if(VALID_NOTEMPTY(countryName, NSString))
    {
        bestShoppingExperienceString = [NSString stringWithFormat:@"%@'s %@", countryName, STRING_BEST_SHOPPING_EXPERIENCE];
    }
    else
    {
        bestShoppingExperienceString = [STRING_BEST_SHOPPING_EXPERIENCE capitalizedString];
    }
    
    UIFont *bestShoppingExperienceFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    CGRect bestShoppingExperienceLabelRect = [bestShoppingExperienceString boundingRectWithSize:CGSizeMake(self.frame.size.width - 20.0f, self.frame.size.height)
                                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                                     attributes:@{NSFontAttributeName:bestShoppingExperienceFont} context:nil];
    
    UILabel *bestShoppingExperienceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [bestShoppingExperienceLabel setFont:bestShoppingExperienceFont];
    [bestShoppingExperienceLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [bestShoppingExperienceLabel setNumberOfLines:0];
    [bestShoppingExperienceLabel setTextColor:UIColorFromRGB(0x000000)];
    [bestShoppingExperienceLabel setText:bestShoppingExperienceString];
    [bestShoppingExperienceLabel sizeToFit];
    [bestShoppingExperienceLabel setFrame:CGRectMake((self.frame.size.width - bestShoppingExperienceLabelRect.size.width) / 2,
                                                     CGRectGetMaxY(logoView.frame) + 10.0f,
                                                     bestShoppingExperienceLabelRect.size.width,
                                                     bestShoppingExperienceLabelRect.size.height + 2.0f)];
    [self addSubview:bestShoppingExperienceLabel];
    
    NSString *widestChoicedString = [NSString stringWithFormat:@"%@ %@", STRING_WIDEST_CHOICE, STRING_AT_YOUR_DOORSTEP];
    
    NSMutableAttributedString *widestChoiceAttributedString = [[NSMutableAttributedString alloc] initWithString:widestChoicedString];
    
    UIFont *doorStepTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f];
    UIColor *doorStepTextColor = UIColorFromRGB(0x000000);
    
    [widestChoiceAttributedString addAttribute:NSFontAttributeName
                                         value:doorStepTextFont
                                         range:NSMakeRange([STRING_WIDEST_CHOICE length], [widestChoicedString length] - [STRING_WIDEST_CHOICE length])];
    [widestChoiceAttributedString addAttribute:NSForegroundColorAttributeName
                                         value:doorStepTextColor
                                         range:NSMakeRange([STRING_WIDEST_CHOICE length], [widestChoicedString length] - [STRING_WIDEST_CHOICE length])];
    
    UIFont *widestChoiceAttributedFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10.0f];
    CGRect widestChoiceLabelRect = [widestChoicedString boundingRectWithSize:CGSizeMake(self.frame.size.width - 20.0f, self.frame.size.height)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:widestChoiceAttributedFont} context:nil];
    
    UILabel *widestChoiceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [widestChoiceLabel setFont:widestChoiceAttributedFont];
    [widestChoiceLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [widestChoiceLabel setNumberOfLines:0];
    [widestChoiceLabel setTextColor:UIColorFromRGB(0xffffff)];
    [widestChoiceLabel setAttributedText:widestChoiceAttributedString];
    [widestChoiceLabel sizeToFit];
    [widestChoiceLabel setFrame:CGRectMake((self.frame.size.width - widestChoiceLabelRect.size.width) / 2,
                                           CGRectGetMaxY(bestShoppingExperienceLabel.frame),
                                           widestChoiceLabelRect.size.width,
                                           widestChoiceLabelRect.size.height + 2.0f)];
    [self addSubview:widestChoiceLabel];
    
    UIButton *changeCountryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeCountryButton setFrame:CGRectMake(6.0f, self.frame.size.height - 44.0f - 15.0f, 308.0f, 44.0f)];
    [changeCountryButton setBackgroundImage:[UIImage imageNamed:@"greyBig_normal"] forState:UIControlStateNormal];
    [changeCountryButton setBackgroundImage:[UIImage imageNamed:@"greyBig_highlighted"] forState:UIControlStateHighlighted];
    [changeCountryButton setBackgroundImage:[UIImage imageNamed:@"greyBig_highlighted"] forState:UIControlStateSelected];
    [changeCountryButton setBackgroundImage:[UIImage imageNamed:@"greyBig_disabled"] forState:UIControlStateDisabled];
    [changeCountryButton setTitle:STRING_CHOOSE_COUNTRY forState:UIControlStateNormal];
    [changeCountryButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [changeCountryButton addTarget:self action:@selector(changeCountryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [changeCountryButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self addSubview:changeCountryButton];
    
    UIButton *retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [retryButton setFrame:CGRectMake(6.0f, CGRectGetMinY(changeCountryButton.frame) - 44.0f - 6.0f, 308.0f, 44.0f)];
    [retryButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [retryButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [retryButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [retryButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [retryButton setTitle:STRING_TRY_AGAIN forState:UIControlStateNormal];
    [retryButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [retryButton addTarget:self action:@selector(retryConnectionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [retryButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self addSubview:retryButton];
    
    UIFont *tryToBeBriefLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    CGRect tryToBeBriefLabelRect = [STRING_TRY_TO_BE_BRIEF boundingRectWithSize:CGSizeMake(self.frame.size.width - 80.0f, self.frame.size.height)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                     attributes:@{NSFontAttributeName:tryToBeBriefLabelFont} context:nil];
    
    UILabel *tryToBeBriefLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [tryToBeBriefLabel setFont:tryToBeBriefLabelFont];
    [tryToBeBriefLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [tryToBeBriefLabel setTextAlignment:NSTextAlignmentCenter];
    [tryToBeBriefLabel setNumberOfLines:0];
    [tryToBeBriefLabel setTextColor:UIColorFromRGB(0x000000)];
    [tryToBeBriefLabel setText:STRING_TRY_TO_BE_BRIEF];
    [tryToBeBriefLabel sizeToFit];
    [tryToBeBriefLabel setFrame:CGRectMake((self.frame.size.width - tryToBeBriefLabelRect.size.width) / 2,
                                           CGRectGetMinY(retryButton.frame) - tryToBeBriefLabelRect.size.height - 20.0f,
                                           tryToBeBriefLabelRect.size.width,
                                           tryToBeBriefLabelRect.size.height + 2.0f)];
    [self addSubview:tryToBeBriefLabel];
    
     NSString *jumiaString = @"";
    if(VALID_NOTEMPTY(countryName, NSString))
    {
        jumiaString = [NSString stringWithFormat:@"%@ %@", STRING_JUMIA, countryName];
    }
    else
    {
        jumiaString = STRING_JUMIA;
    }
    
    NSString *currentlyMaintenanceString = [NSString stringWithFormat:@"%@ %@", jumiaString, STRING_CURRENTLY_IN_MAINTENANCE];
    
    NSMutableAttributedString *currentlyMaintenanceAttributedString = [[NSMutableAttributedString alloc] initWithString:currentlyMaintenanceString];
    
    UIFont *currentlyInCurrentlyMaintenanceTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    [currentlyMaintenanceAttributedString addAttribute:NSFontAttributeName
                                                 value:currentlyInCurrentlyMaintenanceTextFont
                                                 range:NSMakeRange([jumiaString length], [currentlyMaintenanceString length] -[jumiaString length])];
    UIFont *currentlyMaintenanceAttributedFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
    CGRect currentlyMaintenanceLabelRect = [currentlyMaintenanceString boundingRectWithSize:CGSizeMake(self.frame.size.width - 20.0f, self.frame.size.height)
                                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                                 attributes:@{NSFontAttributeName:currentlyMaintenanceAttributedFont} context:nil];
    
    UILabel *currentlyMaintenanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [currentlyMaintenanceLabel setFont:currentlyMaintenanceAttributedFont];
    [currentlyMaintenanceLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [currentlyMaintenanceLabel setTextAlignment:NSTextAlignmentCenter];
    [currentlyMaintenanceLabel setNumberOfLines:0];
    [currentlyMaintenanceLabel setTextColor:UIColorFromRGB(0x000000)];
    [currentlyMaintenanceLabel setAttributedText:currentlyMaintenanceAttributedString];
    [currentlyMaintenanceLabel sizeToFit];
    [currentlyMaintenanceLabel setFrame:CGRectMake((self.frame.size.width - currentlyMaintenanceLabel.frame.size.width) / 2,
                                                   CGRectGetMinY(tryToBeBriefLabel.frame) - currentlyMaintenanceLabelRect.size.height,
                                                   currentlyMaintenanceLabelRect.size.width,
                                                   currentlyMaintenanceLabelRect.size.height + 2.0f)];
    [self addSubview:currentlyMaintenanceLabel];
    
    UIImage *mapImage = [UIImage imageNamed:@"jumiaMap"];
    UIImageView *mapImageview = [[UIImageView alloc] initWithImage:mapImage];
    
    CGFloat mapImageviewTopPadding = CGRectGetMaxY(widestChoiceLabel.frame) + (((CGRectGetMinY(currentlyMaintenanceLabel.frame) - CGRectGetMaxY(widestChoiceLabel.frame)) / 2));
    [mapImageview setCenter:CGPointMake((self.frame.size.width  / 2),
                                        mapImageviewTopPadding)];
    [self addSubview:mapImageview];
}

- (void)retryConnectionButtonTapped:(id)sender
{
    if (retryBock)
    {
        retryBock(YES);
    }
    
    [self removeFromSuperview];
}

- (void)setRetryBlock:(void(^)(BOOL dismiss))completion
{
    retryBock = completion;
}


- (void)changeCountryButtonTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowChooseCountryScreenNotification
                                                        object:nil];
    
    [self removeFromSuperview];
}

@end

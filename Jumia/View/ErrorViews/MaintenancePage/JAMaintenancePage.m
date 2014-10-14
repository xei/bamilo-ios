//
//  JAMaintenancePage.m
//  Jumia
//
//  Created by plopes on 13/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMaintenancePage.h"


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

#define STRING_CURRENTLY_IN_MAINTENANCE RILocalizedString(@"fallback_maintenance_text", nil)
#define STRING_TRY_TO_BE_BRIEF RILocalizedString(@"fallback_maintenance_text_bottom", nil)
#define STRING_BEST_SHOPPING_EXPERIENCE RILocalizedString(@"fallback_best", nil)
#define STRING_WIDEST_CHOICE RILocalizedString(@"fallback_choice", nil)
#define STRING_AT_YOUR_DOORSTEP RILocalizedString(@"fallback_doorstep", nil)

- (void)setupMaintenancePage:(CGRect)frame
{
    [self setFrame:frame];
   
    NSString *countryName = [RIApi getCountryName];
countryName = @"asçfhasdf Nigeria";
    UILabel *maintenanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [maintenanceLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0f]];
    [maintenanceLabel setTextColor:UIColorFromRGB(0xffffff)];
    [maintenanceLabel setText:STRING_MAINTENANCE];
    [maintenanceLabel sizeToFit];
    [maintenanceLabel setFrame:CGRectMake((frame.size.width - maintenanceLabel.frame.size.width) / 2,
                                          20.0f,
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
    [logoImageView setFrame:CGRectMake(0.0f,
                                       10.0f,
                                       logoImage.size.width,
                                       logoImage.size.height)];
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
    CGFloat countryNameLabelHeight = countryNameLabelRect.size.height + 2.0f;
    
    [logoView addSubview:countryNameLabel];
    logoViewWidth += (countryNameLabelRect.size.width + 10.0f);
    if(countryNameLabelHeight > logoViewHeight)
    {
        logoViewHeight = countryNameLabelHeight;
    }

    [countryNameLabel setFrame:CGRectMake(CGRectGetMaxX(logoImageView.frame) + 10.0f,
                                          10.0f,
                                          countryNameLabelRect.size.width,
                                          countryNameLabelHeight)];

    [logoView setFrame:CGRectMake((self.frame.size.width - logoViewWidth) / 2,
                                  CGRectGetMaxY(maintenanceLabelSeparator.frame),
                                  logoImage.size.width,
                                  logoViewHeight)];
    [self addSubview:logoView];
}

- (IBAction)retryConnectionButtonTapped:(id)sender
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


- (IBAction)changeCountryButtonTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowChooseCountryScreenNotification
                                                        object:nil];
    
    [self removeFromSuperview];
}

@end

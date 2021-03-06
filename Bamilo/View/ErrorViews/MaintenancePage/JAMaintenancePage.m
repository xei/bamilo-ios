//
//  JAMaintenancePage.m
//  Jumia
//
//  Created by plopes on 13/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMaintenancePage.h"
#import "UIImageView+WebCache.h"

@interface JAMaintenancePage()

@property (weak, nonatomic) IBOutlet UIImageView *imageBackground;
@property (strong, nonatomic) UILabel *maintenanceLabel;
@property (strong, nonatomic) UIView *maintenanceLabelSeparator;
@property (strong, nonatomic) UIView *logoView;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UILabel *countryNameLabel;
@property (strong, nonatomic) UILabel *bestShoppingExperienceLabel;
@property (strong, nonatomic) UILabel *widestChoiceLabel;
@property (strong, nonatomic) UIButton *changeCountryButton;
@property (strong, nonatomic) UIButton *retryButton;
@property (strong, nonatomic) UILabel *tryToBeBriefLabel;
@property (strong, nonatomic) UILabel *currentlyMaintenanceLabel;
@property (strong, nonatomic) UIImageView *mapImageView;
@property (strong, nonatomic) UIImage *logoImage;
@property (strong, nonatomic) NSString *backgroundImageName;

@end
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

- (void)setupMaintenancePage:(CGRect)frame orientation:(UIInterfaceOrientation)myOrientation
{
    self.imageBackground.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self removeViews];
    
    CGFloat screenWidth = frame.size.width;
    CGFloat screenHeight = frame.size.height;
    
    if(UIInterfaceOrientationIsPortrait(myOrientation))
    {
        if(screenWidth > screenHeight)
        {
            frame  = CGRectMake(0, 0, screenHeight, screenWidth);
        }
        else
        {
            frame  = CGRectMake(0, 0, screenWidth, screenHeight);
        }
    }
    else
    {
        if(screenWidth > screenHeight)
        {
            frame  = CGRectMake(0, 0, screenWidth, screenHeight);
        }
        else
        {
            frame  = CGRectMake(0, 0, screenHeight, screenWidth);
        }
    }
    
    [self setFrame:frame];
    
    self.backgroundImageName = @"maintenancePageBackground";
    CGFloat startingY = 27.0f;
    CGFloat leftPadding = 6.0f;
    NSString *orangeButtonName = @"maintGreyBig_%@";
    NSString *greyButtonName = @"greyBig_%@";
    
    NSString *mapName = @"map";
    CGFloat buttonsWidth = 12.0f;
    CGFloat marginBottom = 15.0f;
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        orangeButtonName = @"maintGreyFull_%@";
        greyButtonName = @"greyFullPortrait_%@";
        mapName = @"mapiPad";
        
        if(UIInterfaceOrientationIsLandscape(myOrientation)){
            startingY = 50.0f;
            leftPadding = 134.0f;
            buttonsWidth = 268.0f;
            marginBottom = 50.0f;
            self.backgroundImageName = @"maintenancePageBackground_iPad_land";
            mapName = @"mapiPad";
            
        }else{
            self.backgroundImageName = @"maintenancePageBackground_iPad_port";
        }
    }
    
    //RIApi *apiInformation = [RIApi getApiInformation];
    NSString *countryName = @"";
    
    UIImage *backgroundImage = [UIImage imageNamed:self.backgroundImageName];
    [self.imageBackground setFrame:CGRectMake(0.0f, 0.0f, backgroundImage.size.width, backgroundImage.size.height)];
    [self.imageBackground setImage:backgroundImage];
    
    self.maintenanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.maintenanceLabel setFont:[UIFont fontWithName:kFontRegularName size:18.0f]];
    [self.maintenanceLabel setTextColor:JAWhiteColor];
    [self.maintenanceLabel setText:STRING_MAINTENANCE];
    [self.maintenanceLabel sizeToFit];
    [self.maintenanceLabel setFrame:CGRectMake((frame.size.width - self.maintenanceLabel.frame.size.width) / 2,
                                               startingY,
                                               self.maintenanceLabel.frame.size.width,
                                               self.maintenanceLabel.frame.size.height)];
    [self addSubview:self.maintenanceLabel];
    
    self.maintenanceLabelSeparator = [[UIView alloc] initWithFrame:CGRectMake(self.maintenanceLabel.frame.origin.x,
                                                                              CGRectGetMaxY(self.maintenanceLabel.frame) + 10.0f,
                                                                              self.maintenanceLabel.frame.size.width,
                                                                              1.0f)];
    [self.maintenanceLabelSeparator setBackgroundColor:JAWhiteColor];
    [self addSubview:self.maintenanceLabelSeparator];
    
    CGFloat logoViewWidth = 0.0f;
    CGFloat logoViewHeight = 0.0f;
    
    self.logoView = [[UIView alloc] initWithFrame:CGRectZero];
    self.logoImage = [UIImage imageNamed:@"maintenanceLogo"];
    self.logoImageView = [[UIImageView alloc] initWithImage:self.logoImage];
    
    [self.logoView addSubview:self.logoImageView];
    logoViewWidth = self.logoImage.size.width;
    logoViewHeight = self.logoImage.size.height;
    
    UIFont *countryNameLabelFont = [UIFont fontWithName:kFontRegularName size:24.0f];
    self.countryNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.countryNameLabel setFont:countryNameLabelFont];
    [self.countryNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.countryNameLabel setNumberOfLines:0];
    [self.countryNameLabel setTextColor:JABlackColor];
    [self.countryNameLabel setText:countryName];
    [self.countryNameLabel sizeToFit];
    
    
    CGRect countryNameLabelRect = [countryName boundingRectWithSize:CGSizeMake(self.frame.size.width - logoViewWidth - 20.0f, self.frame.size.height)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:countryNameLabelFont} context:nil];
    CGFloat countryNameLabelHeight = countryNameLabelRect.size.height;// + 2.0f;
    
    [self.logoView addSubview:self.countryNameLabel];
    logoViewWidth += (countryNameLabelRect.size.width + 10.0f);
    
    CGFloat logoImageViewTopPadding = 10.0f;
    CGFloat countryNameLabelTopPadding = 10.0f;
    
    [self.logoImageView setFrame:CGRectMake(0.0f,
                                            logoImageViewTopPadding,
                                            self.logoImage.size.width,
                                            self.logoImage.size.height)];
    
    [self.countryNameLabel setFrame:CGRectMake(CGRectGetMaxX(self.logoImageView.frame) + 10.0f,
                                               countryNameLabelTopPadding,
                                               countryNameLabelRect.size.width,
                                               countryNameLabelHeight)];
    
    [self.logoView setFrame:CGRectMake((self.frame.size.width - logoViewWidth) / 2,
                                       CGRectGetMaxY(self.maintenanceLabelSeparator.frame),
                                       self.logoImage.size.width,
                                       logoViewHeight)];
    [self addSubview:self.logoView];
    
    NSString *bestShoppingExperienceString = @"";
    
    UIFont *bestShoppingExperienceFont = JAListFont;
    CGRect bestShoppingExperienceLabelRect = [bestShoppingExperienceString boundingRectWithSize:CGSizeMake(self.frame.size.width - 20.0f, self.frame.size.height)
                                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                                     attributes:@{NSFontAttributeName:bestShoppingExperienceFont} context:nil];
    
    self.bestShoppingExperienceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.bestShoppingExperienceLabel setFont:bestShoppingExperienceFont];
    [self.bestShoppingExperienceLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.bestShoppingExperienceLabel setNumberOfLines:0];
    [self.bestShoppingExperienceLabel setTextColor:JABlackColor];
    [self.bestShoppingExperienceLabel setText:bestShoppingExperienceString];
    [self.bestShoppingExperienceLabel sizeToFit];
    [self.bestShoppingExperienceLabel setFrame:CGRectMake((self.frame.size.width - bestShoppingExperienceLabelRect.size.width) / 2,
                                                          CGRectGetMaxY(self.logoView.frame) + 10.0f,
                                                          bestShoppingExperienceLabelRect.size.width,
                                                          bestShoppingExperienceLabelRect.size.height + 2.0f)];
    [self addSubview:self.bestShoppingExperienceLabel];
    
    
    CGFloat nextButtonPosition = self.frame.size.height - 44.0f - marginBottom;
    
    self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.retryButton setFrame:CGRectMake(leftPadding, nextButtonPosition, self.frame.size.width - buttonsWidth, 44.0f)];
    [self.retryButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"normal"]]forState:UIControlStateNormal];
    [self.retryButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]]forState:UIControlStateHighlighted];
    [self.retryButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]]forState:UIControlStateSelected];
    [self.retryButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"disabled"]]forState:UIControlStateDisabled];
    [self.retryButton setTitle:STRING_TRY_AGAIN forState:UIControlStateNormal];
    [self.retryButton setTitleColor:JAButtonTextOrange forState:UIControlStateNormal];
    [self.retryButton addTarget:self action:@selector(retryConnectionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.retryButton.titleLabel setFont:JADisplay3Font];
    [self addSubview:self.retryButton];
    
        
    NSString *jumiaString = @"";
    if(VALID_NOTEMPTY(countryName, NSString))
    {
        jumiaString = [NSString stringWithFormat:@"%@ %@", APP_NAME, countryName];
    }
    else
    {
        jumiaString = APP_NAME;
    }
    
    NSString *currentlyMaintenanceString = [NSString stringWithFormat:@"%@ %@", jumiaString, STRING_CURRENTLY_IN_MAINTENANCE];
    
    NSMutableAttributedString *currentlyMaintenanceAttributedString = [[NSMutableAttributedString alloc] initWithString:currentlyMaintenanceString];
    
    UIFont *currentlyInCurrentlyMaintenanceTextFont = [UIFont fontWithName:kFontLightName size:12.0f];
    [currentlyMaintenanceAttributedString addAttribute:NSFontAttributeName
                                                 value:currentlyInCurrentlyMaintenanceTextFont
                                                 range:NSMakeRange([jumiaString length], [currentlyMaintenanceString length] -[jumiaString length])];
    UIFont *currentlyMaintenanceAttributedFont = [UIFont fontWithName:kFontMediumName size:12.0f];
    CGRect currentlyMaintenanceLabelRect = [currentlyMaintenanceString boundingRectWithSize:CGSizeMake(self.frame.size.width - 20.0f, self.frame.size.height)
                                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                                 attributes:@{NSFontAttributeName:currentlyMaintenanceAttributedFont} context:nil];
    
    self.currentlyMaintenanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.currentlyMaintenanceLabel setFont:currentlyMaintenanceAttributedFont];
    [self.currentlyMaintenanceLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.currentlyMaintenanceLabel setTextAlignment:NSTextAlignmentCenter];
    [self.currentlyMaintenanceLabel setNumberOfLines:0];
    [self.currentlyMaintenanceLabel setTextColor:JABlackColor];
    [self.currentlyMaintenanceLabel setTextColor:JAWhiteColor];
    [self.currentlyMaintenanceLabel setAttributedText:currentlyMaintenanceAttributedString];
    [self.currentlyMaintenanceLabel sizeToFit];
    [self.currentlyMaintenanceLabel setFrame:CGRectMake((self.frame.size.width - self.currentlyMaintenanceLabel.frame.size.width) / 2,
                                                        CGRectGetMinY(self.tryToBeBriefLabel.frame) - currentlyMaintenanceLabelRect.size.height,
                                                        currentlyMaintenanceLabelRect.size.width,
                                                        currentlyMaintenanceLabelRect.size.height + 2.0f)];
    [self addSubview:self.currentlyMaintenanceLabel];
    
    UIImage *mapImage = [UIImage imageNamed:mapName];
    self.mapImageView = [[UIImageView alloc] initWithImage:mapImage];
    
    CGFloat mapImageviewTopPadding = self.frame.size.height / 2;
   
    [self.mapImageView setCenter:CGPointMake((self.frame.size.width  / 2),
                                             mapImageviewTopPadding)];
    [self addSubview:self.mapImageView];
    
    //after all this we still have to change the button and label order for bamilo
    //doing it here to avoid muddying the code above even more

    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        [self.retryButton setFrame:CGRectMake(self.retryButton.frame.origin.x,
                                              self.frame.size.height - self.retryButton.frame.size.height - 50.0f,
                                              self.retryButton.frame.size.width,
                                              self.retryButton.frame.size.height)];
        [self.currentlyMaintenanceLabel setFrame:CGRectMake(self.currentlyMaintenanceLabel.frame.origin.x,
                                                            self.retryButton.frame.origin.y - self.currentlyMaintenanceLabel.frame.size.height - 18.0f,
                                                            self.currentlyMaintenanceLabel.frame.size.width,
                                                            self.currentlyMaintenanceLabel.frame.size.height)];

    } else {
        [self.currentlyMaintenanceLabel setFrame:CGRectMake(self.currentlyMaintenanceLabel.frame.origin.x,
                                                            self.frame.size.height - self.currentlyMaintenanceLabel.frame.size.height - marginBottom - 40.0f,
                                                            self.currentlyMaintenanceLabel.frame.size.width,
                                                            self.currentlyMaintenanceLabel.frame.size.height)];
        [self.retryButton setFrame:CGRectMake(self.retryButton.frame.origin.x,
                                              self.currentlyMaintenanceLabel.frame.origin.y - self.retryButton.frame.size.height - 12.0f,
                                              self.retryButton.frame.size.width,
                                              self.retryButton.frame.size.height)];
    }
    
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

-(void) removeViews
{
    [self.maintenanceLabel removeFromSuperview];
    [self.maintenanceLabelSeparator removeFromSuperview];
    [self.logoView removeFromSuperview];
    [self.logoImageView removeFromSuperview];
    [self.countryNameLabel removeFromSuperview];
    [self.bestShoppingExperienceLabel removeFromSuperview];
    [self.widestChoiceLabel removeFromSuperview];
    [self.changeCountryButton removeFromSuperview];
    [self.retryButton removeFromSuperview];
    [self.tryToBeBriefLabel removeFromSuperview];
    [self.currentlyMaintenanceLabel removeFromSuperview];
    [self.mapImageView removeFromSuperview];
}
@end

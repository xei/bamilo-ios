//
//  JAFallbackView.m
//  Jumia
//
//  Created by Telmo Pinto on 17/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAFallbackView.h"
#import "RIApi.h"

@interface JAFallbackView()

@property (nonatomic, strong)UIImageView* backgroundImageView;

//from top
@property (nonatomic, strong)UILabel* welcomeLabel;
@property (nonatomic, strong)UIView* separator;
@property (nonatomic, strong)UIImageView* logoImageView;
@property (nonatomic, strong)UILabel* countryLabel;
@property (nonatomic, strong)UILabel* firstSloganLabel;
@property (nonatomic, strong)UILabel* secondSloganLabel1;
@property (nonatomic, strong)UILabel* secondSloganLabel2;
@property (nonatomic, strong)UIImageView* mapImageView;

//from bottom
@property (nonatomic, strong)UILabel* moreLabelTop;
@property (nonatomic, strong)UILabel* moreLabelBottom;
@property (nonatomic, strong)UIView* leftColumn;
@property (nonatomic, strong)UIView* rightColumn;
@property (nonatomic, strong)UIImageView* arrowImageView;

@end

@implementation JAFallbackView

+ (JAFallbackView *)getNewJAFallbackView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAFallbackView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib)
    {
        if ([obj isKindOfClass:[JAFallbackView class]])
        {
            return (JAFallbackView *)obj;
        }
    }
    
    return nil;
}

- (void)setupFallbackView:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    [self setFrame:frame];
    
    NSString *fallbackBackgroundImageName = @"fallbackPageBackground";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        fallbackBackgroundImageName = @"fallbackPageBackgroundIpadPortrait";
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            fallbackBackgroundImageName = @"fallbackPageBackgroundIpadLandscape";
        }
    }
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fallbackBackgroundImageName]];
    [self.backgroundImageView setFrame:frame];
    [self addSubview:self.backgroundImageView];
    
    self.welcomeLabel = [[UILabel alloc] init];
    self.welcomeLabel.textColor = [UIColor whiteColor];
    self.welcomeLabel.font = [UIFont fontWithName:kFontRegularName size:18.0f];
    self.welcomeLabel.text = STRING_FALLBACK_WELCOME;
    [self.welcomeLabel sizeToFit];
    [self.welcomeLabel setFrame:CGRectMake((self.bounds.size.width - self.welcomeLabel.frame.size.width) / 2,
                                           10.0f,
                                           self.welcomeLabel.frame.size.width,
                                           self.welcomeLabel.frame.size.height)];
    [self addSubview:self.welcomeLabel];
    
    self.separator = [[UIView alloc] initWithFrame:CGRectMake(self.welcomeLabel.frame.origin.x,
                                                              CGRectGetMaxY(self.welcomeLabel.frame) + 10.0f,
                                                              self.welcomeLabel.frame.size.width,
                                                              1)];
    self.separator.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.separator];
    
    UIImage *logoImage = [UIImage imageNamed:@"maintenanceLogo"];
    self.logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    
    self.countryLabel = [[UILabel alloc] init];
    self.countryLabel.textColor = [UIColor blackColor];
    self.countryLabel.font = [UIFont fontWithName:kFontRegularName size:24.0f];
    self.countryLabel.text = [RIApi getCountryNameInUse];
    [self.countryLabel sizeToFit];
    
    CGFloat countryLabelWidth = self.countryLabel.frame.size.width;
    CGFloat totalWidth = logoImage.size.width + 10.0f + countryLabelWidth;
    
    if (totalWidth > self.frame.size.width) {
        totalWidth = self.frame.size.width;
        countryLabelWidth = self.frame.size.width - (logoImage.size.width + 10.0f);
    }
    
    CGFloat startingX = (self.frame.size.width - totalWidth) / 2;
    
    [self.logoImageView setFrame:CGRectMake(startingX,
                                            CGRectGetMaxY(self.separator.frame) + 10.0f,
                                            logoImage.size.width,
                                            logoImage.size.height)];
    [self addSubview:self.logoImageView];
    
    [self.countryLabel setFrame:CGRectMake(CGRectGetMaxX(self.logoImageView.frame) + 10.0f,
                                           self.logoImageView.frame.origin.y + 2.0f,
                                           self.countryLabel.frame.size.width,
                                           self.countryLabel.frame.size.height)];
    [self addSubview:self.countryLabel];
    
    self.firstSloganLabel = [[UILabel alloc] init];
    self.firstSloganLabel.numberOfLines = -1;
    self.firstSloganLabel.textAlignment = NSTextAlignmentCenter;
    self.firstSloganLabel.textColor = [UIColor blackColor];
    self.firstSloganLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
    self.firstSloganLabel.text = [NSString stringWithFormat:@"%@ %@", [RIApi getCountryNameInUse], STRING_BEST_SHOPPING_EXPERIENCE];
    [self.firstSloganLabel sizeToFit];
    [self.firstSloganLabel setFrame:CGRectMake(10.0f,
                                               CGRectGetMaxY(self.logoImageView.frame) + 4.0f,
                                               self.bounds.size.width - 10.0f*2,
                                               self.firstSloganLabel.frame.size.height)];
    [self addSubview:self.firstSloganLabel];
    
    self.secondSloganLabel1 = [[UILabel alloc] init];
    self.secondSloganLabel1.textColor = [UIColor whiteColor];
    self.secondSloganLabel1.font = [UIFont fontWithName:kFontRegularName size:10.0f];
    self.secondSloganLabel1.text = STRING_WIDEST_CHOICE;
    [self.secondSloganLabel1 sizeToFit];
    
    self.secondSloganLabel2 = [[UILabel alloc] init];
    self.secondSloganLabel2.textColor = [UIColor blackColor];
    self.secondSloganLabel2.font = [UIFont fontWithName:kFontRegularName size:10.0f];
    self.secondSloganLabel2.text = [NSString stringWithFormat:@" %@", STRING_AT_YOUR_DOORSTEP];
    [self.secondSloganLabel2 sizeToFit];
    
    CGFloat totalSecondSloganWidth = self.secondSloganLabel1.frame.size.width + self.secondSloganLabel2.frame.size.width;
    CGFloat startingSecondSloganX = (self.bounds.size.width - totalSecondSloganWidth) / 2;
    
    [self.secondSloganLabel1 setFrame:CGRectMake(startingSecondSloganX,
                                                 CGRectGetMaxY(self.firstSloganLabel.frame) + 4.0f,
                                                 self.secondSloganLabel1.frame.size.width,
                                                 self.secondSloganLabel1.frame.size.height)];
    [self addSubview:self.secondSloganLabel1];
    [self.secondSloganLabel2 setFrame:CGRectMake(CGRectGetMaxX(self.secondSloganLabel1.frame),
                                                 self.secondSloganLabel1.frame.origin.y,
                                                 self.secondSloganLabel2.frame.size.width,
                                                 self.secondSloganLabel2.frame.size.height)];
    [self addSubview:self.secondSloganLabel2];
    
    
    CGFloat moreLabelBottomPadding = 10.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        moreLabelBottomPadding = 40.0f;
    }
    
    self.moreLabelBottom = [[UILabel alloc] init];
    self.moreLabelBottom.textColor = [UIColor whiteColor];
    self.moreLabelBottom.font = [UIFont fontWithName:kFontBoldName size:12.0f];
    self.moreLabelBottom.text = STRING_FALLBACK_BOTTOM_1;
    [self.moreLabelBottom sizeToFit];
    [self.moreLabelBottom setFrame:CGRectMake((self.bounds.size.width - self.moreLabelBottom.frame.size.width) / 2,
                                              self.bounds.size.height - self.moreLabelBottom.frame.size.height - moreLabelBottomPadding,
                                              self.moreLabelBottom.frame.size.width,
                                              self.moreLabelBottom.frame.size.height)];
    [self addSubview:self.moreLabelBottom];
    
    self.moreLabelTop = [[UILabel alloc] init];
    self.moreLabelTop.textColor = [UIColor whiteColor];
    self.moreLabelTop.font = [UIFont fontWithName:kFontMediumName size:12.0f];
    self.moreLabelTop.text = STRING_FALLBACK_BOTTOM_2;
    [self.moreLabelTop sizeToFit];
    [self.moreLabelTop setFrame:CGRectMake((self.bounds.size.width - self.moreLabelTop.frame.size.width) / 2,
                                           self.moreLabelBottom.frame.origin.y - self.moreLabelBottom.frame.size.height,
                                           self.moreLabelTop.frame.size.width,
                                           self.moreLabelTop.frame.size.height)];
    [self addSubview:self.moreLabelTop];
    
    CGFloat currentY = self.moreLabelTop.frame.origin.y;

    // The padding between the more label and category list
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        currentY -= 10.0f;
    }
    
    CGFloat columnsWidth = 160.0f;
    CGFloat leftCheckboxX = 30.0f;
    CGFloat rightCheckboxX = 15.0f;
    
    UIImage* checkboxImage = [UIImage imageNamed:@"whiteCheck"];
    CGFloat marginBetweenCheckboxAndLabel = 6.0f;
    CGFloat labelWidth = columnsWidth - leftCheckboxX - checkboxImage.size.width - marginBetweenCheckboxAndLabel;
    
    self.leftColumn = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray* leftColumnCategoriesArray = [NSArray arrayWithObjects:STRING_FALLBACK_FASHION, STRING_FALLBACK_MOBILE, STRING_FALLBACK_HOME_OFFICE, nil];
    CGFloat leftColumnY = 0.0f;
    CGFloat leftColumnLeftMargin = 0.0f;
    CGFloat rightColumnLeftMargin = 0.0f;
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        rightColumnLeftMargin = 40.0f - rightCheckboxX;
        leftColumnLeftMargin = 219.0f - leftCheckboxX;
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            leftColumnLeftMargin = 353.0f - leftCheckboxX;
        }
    }
    
    for (int i = 0; i < leftColumnCategoriesArray.count; i++)
    {
        UIImageView* checkboxImageView = [[UIImageView alloc] initWithImage:checkboxImage];
        [checkboxImageView setFrame:CGRectMake(leftCheckboxX,
                                               leftColumnY,
                                               checkboxImage.size.width,
                                               checkboxImage.size.height)];
        [self.leftColumn addSubview:checkboxImageView];
        
        UILabel* categoryLabel = [[UILabel alloc] init];
        categoryLabel.textColor = [UIColor blackColor];
        categoryLabel.font = [UIFont fontWithName:kFontRegularName size:12.0f];
        categoryLabel.text = [leftColumnCategoriesArray objectAtIndex:i];
        [categoryLabel sizeToFit];
        [categoryLabel setFrame:CGRectMake(CGRectGetMaxX(checkboxImageView.frame) + 6.0f,
                                           checkboxImageView.frame.origin.y,
                                           labelWidth,
                                           categoryLabel.frame.size.height)];
        [self.leftColumn addSubview:categoryLabel];
        leftColumnY += checkboxImage.size.height + 15.0f;
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        [self.leftColumn setFrame:CGRectMake(leftColumnLeftMargin,
                                             currentY - leftColumnY,
                                             columnsWidth + leftCheckboxX,
                                             leftColumnY)];
    }
    else
    {
        [self.leftColumn setFrame:CGRectMake(leftColumnLeftMargin,
                                             currentY - leftColumnY,
                                             columnsWidth,
                                             leftColumnY)];
    }
    
    [self addSubview:self.leftColumn];
    
    NSArray* rightColumnCategoriesArray = [NSArray arrayWithObjects:STRING_FALLBACK_HEALTH, STRING_FALLBACK_AUDIO,STRING_FALLBACK_BOOKS, nil];
    self.rightColumn = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat rightColumnY = 0.0f;
    
    for (int i = 0; i < rightColumnCategoriesArray.count; i++)
    {
        UIImageView* checkboxImageView = [[UIImageView alloc] initWithImage:checkboxImage];
        [checkboxImageView setFrame:CGRectMake(rightCheckboxX,
                                               rightColumnY,
                                               checkboxImage.size.width,
                                               checkboxImage.size.height)];
        [self.rightColumn addSubview:checkboxImageView];
        
        UILabel* categoryLabel = [[UILabel alloc] init];
        categoryLabel.textColor = [UIColor blackColor];
        categoryLabel.font = [UIFont fontWithName:kFontRegularName size:12.0f];
        categoryLabel.text = [rightColumnCategoriesArray objectAtIndex:i];
        [categoryLabel sizeToFit];
        [categoryLabel setFrame:CGRectMake(CGRectGetMaxX(checkboxImageView.frame) + 6.0f,
                                           checkboxImageView.frame.origin.y,
                                           labelWidth,
                                           categoryLabel.frame.size.height)];
        [self.rightColumn addSubview:categoryLabel];
        rightColumnY += checkboxImage.size.height + 15.0f;
    }
    
    // We need to do this for iPad because we're removing rightCheckboxX from the rightColumnLeftMargin
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        [self.rightColumn setFrame:CGRectMake(CGRectGetMaxX(self.leftColumn.frame) + rightColumnLeftMargin,
                                              currentY - rightColumnY,
                                              columnsWidth + rightCheckboxX,
                                              rightColumnY)];
    }
    else
    {
        [self.rightColumn setFrame:CGRectMake(CGRectGetMaxX(self.leftColumn.frame),
                                              currentY - rightColumnY,
                                              columnsWidth,
                                              rightColumnY)];
    }
    
    [self addSubview:self.rightColumn];
    
    CGFloat availableHeight = CGRectGetMinY(self.leftColumn.frame) - CGRectGetMaxY(self.secondSloganLabel1.frame);
    UIImage* mapImage = [UIImage imageNamed:@"jumiaMap"];
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        mapImage = [UIImage imageNamed:@"jumiaMapiPad"];
    }
    self.mapImageView = [[UIImageView alloc] initWithImage:mapImage];
    [self.mapImageView setFrame:CGRectMake((self.frame.size.width - mapImage.size.width) / 2,
                                           CGRectGetMaxY(self.secondSloganLabel1.frame) + ((availableHeight - mapImage.size.height) / 2),
                                           mapImage.size.width,
                                           mapImage.size.height)];
    [self addSubview:self.mapImageView];

    currentY -= rightColumnY;
    
    currentY -= 20.0f; // padding from text to arrow
    
    UIImage* arrowImage = [UIImage imageNamed:@"whiteArrow"];
    CGFloat arrowLeftMargin = 15.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        arrowImage = [UIImage imageNamed:@"whiteArrowIpad"];
        arrowLeftMargin = 116.0f;
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            arrowLeftMargin = 250.0f;
        }
    }
    
    self.arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
    [self.arrowImageView setFrame:CGRectMake(arrowLeftMargin,
                                             currentY - arrowImage.size.height,
                                             arrowImage.size.width,
                                             arrowImage.size.height)];
    [self addSubview:self.arrowImageView];
}

- (void)reloadFallbackView:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    [self setFrame:frame];
    
    NSString *fallbackBackgroundImageName = @"fallbackPageBackground";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        fallbackBackgroundImageName = @"fallbackPageBackgroundIpadPortrait";
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            fallbackBackgroundImageName = @"fallbackPageBackgroundIpadLandscape";
        }
    }
    
    [self.backgroundImageView setImage:[UIImage imageNamed:fallbackBackgroundImageName]];
    [self.backgroundImageView setFrame:frame];
    
    [self.welcomeLabel sizeToFit];
    [self.welcomeLabel setFrame:CGRectMake((self.bounds.size.width - self.welcomeLabel.frame.size.width) / 2,
                                           10.0f,
                                           self.welcomeLabel.frame.size.width,
                                           self.welcomeLabel.frame.size.height)];
    
    [self.separator setFrame:CGRectMake(self.welcomeLabel.frame.origin.x,
                                        CGRectGetMaxY(self.welcomeLabel.frame) + 10.0f,
                                        self.welcomeLabel.frame.size.width,
                                        1)];
    
    [self.countryLabel sizeToFit];
    
    CGFloat countryLabelWidth = self.countryLabel.frame.size.width;
    CGFloat totalWidth = self.logoImageView.frame.size.width + 10.0f + countryLabelWidth;
    
    if (totalWidth > self.frame.size.width)
    {
        totalWidth = self.frame.size.width;
        countryLabelWidth = self.frame.size.width - (self.logoImageView.frame.size.width + 10.0f);
    }
    
    CGFloat startingX = (self.frame.size.width - totalWidth) / 2;
    
    [self.logoImageView setFrame:CGRectMake(startingX,
                                            CGRectGetMaxY(self.separator.frame) + 10.0f,
                                            self.logoImageView.frame.size.width,
                                            self.logoImageView.frame.size.height)];
    
    [self.countryLabel setFrame:CGRectMake(CGRectGetMaxX(self.logoImageView.frame) + 10.0f,
                                           self.logoImageView.frame.origin.y + 2.0f,
                                           self.countryLabel.frame.size.width,
                                           self.countryLabel.frame.size.height)];
    [self.firstSloganLabel sizeToFit];
    [self.firstSloganLabel setFrame:CGRectMake(10.0f,
                                               CGRectGetMaxY(self.logoImageView.frame) + 4.0f,
                                               self.bounds.size.width - 10.0f*2,
                                               self.firstSloganLabel.frame.size.height)];
    [self.secondSloganLabel1 sizeToFit];
    [self.secondSloganLabel2 sizeToFit];
    
    CGFloat totalSecondSloganWidth = self.secondSloganLabel1.frame.size.width + self.secondSloganLabel2.frame.size.width;
    CGFloat startingSecondSloganX = (self.bounds.size.width - totalSecondSloganWidth) / 2;
    
    [self.secondSloganLabel1 setFrame:CGRectMake(startingSecondSloganX,
                                                 CGRectGetMaxY(self.firstSloganLabel.frame) + 4.0f,
                                                 self.secondSloganLabel1.frame.size.width,
                                                 self.secondSloganLabel1.frame.size.height)];
    
    [self.secondSloganLabel2 setFrame:CGRectMake(CGRectGetMaxX(self.secondSloganLabel1.frame),
                                                 self.secondSloganLabel1.frame.origin.y,
                                                 self.secondSloganLabel2.frame.size.width,
                                                 self.secondSloganLabel2.frame.size.height)];
    
    CGFloat moreLabelBottomPadding = 10.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        moreLabelBottomPadding = 40.0f;
    }

    [self.moreLabelBottom sizeToFit];
    [self.moreLabelBottom setFrame:CGRectMake((self.bounds.size.width - self.moreLabelBottom.frame.size.width) / 2,
                                              self.bounds.size.height - self.moreLabelBottom.frame.size.height - moreLabelBottomPadding,
                                              self.moreLabelBottom.frame.size.width,
                                              self.moreLabelBottom.frame.size.height)];
    
    [self.moreLabelTop sizeToFit];
    [self.moreLabelTop setFrame:CGRectMake((self.bounds.size.width - self.moreLabelTop.frame.size.width) / 2,
                                           
                                           self.moreLabelBottom.frame.origin.y - self.moreLabelBottom.frame.size.height,
                                           self.moreLabelTop.frame.size.width,
                                           self.moreLabelTop.frame.size.height)];
    
    CGFloat currentY = self.moreLabelTop.frame.origin.y;
    // The padding between the more label and category list
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        currentY -= 10.0f;
    }
    
    CGFloat leftColumnLeftMargin = 0.0f;
    CGFloat rightColumnLeftMargin = 0.0f;
    CGFloat leftCheckboxX = 30.0f;
    CGFloat rightCheckboxX = 15.0f;
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        rightColumnLeftMargin = 40.0f - rightCheckboxX;
        leftColumnLeftMargin = 219.0f - leftCheckboxX;
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            leftColumnLeftMargin = 353.0f - leftCheckboxX;
        }
    }
    
    [self.leftColumn setFrame:CGRectMake(leftColumnLeftMargin,
                                         currentY - self.leftColumn.frame.size.height,
                                         self.leftColumn.frame.size.width,
                                         self.leftColumn.frame.size.height)];
    
    [self.rightColumn setFrame:CGRectMake(CGRectGetMaxX(self.leftColumn.frame) + rightColumnLeftMargin,
                                          currentY - self.rightColumn.frame.size.height,
                                          self.rightColumn.frame.size.width,
                                          self.rightColumn.frame.size.height)];
    
    currentY = self.rightColumn.frame.origin.y;
    
    currentY -= 20.0f; // padding from text to arrow
    
    UIImage* arrowImage = [UIImage imageNamed:@"whiteArrow"];
    
    CGFloat arrowLeftMargin = 15.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        arrowImage = [UIImage imageNamed:@"whiteArrowIpad"];
        arrowLeftMargin = 116.0f;
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            arrowLeftMargin = 250.0f;
        }
    }

    CGFloat availableHeight = CGRectGetMinY(self.leftColumn.frame) - CGRectGetMaxY(self.secondSloganLabel1.frame);
    UIImage* mapImage = [UIImage imageNamed:@"jumiaMap"];
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        mapImage = [UIImage imageNamed:@"jumiaMapiPad"];
    }
    [self.mapImageView setImage:mapImage];
    [self.mapImageView setFrame:CGRectMake((self.frame.size.width - mapImage.size.width) / 2,
                                          CGRectGetMaxY(self.secondSloganLabel1.frame) + ((availableHeight - mapImage.size.height) / 2),
                                           mapImage.size.width,
                                           mapImage.size.height)];
    
    [self.arrowImageView setImage:arrowImage];
    [self.arrowImageView setFrame:CGRectMake(arrowLeftMargin,
                                             currentY - arrowImage.size.height,
                                             arrowImage.size.width,
                                             arrowImage.size.height)];
}

@end

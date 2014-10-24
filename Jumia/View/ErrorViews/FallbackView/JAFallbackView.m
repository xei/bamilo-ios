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
@property (nonatomic, strong)NSMutableArray* checkboxImageViewsArray;
@property (nonatomic, strong)NSMutableArray* categoryLabelsArray;
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

- (void)setupFallbackView:(CGRect)frame
{
    [self setFrame:frame];
    
    self.welcomeLabel = [[UILabel alloc] init];
    self.welcomeLabel.textColor = [UIColor whiteColor];
    self.welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
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
    self.countryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:24.0f];
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
    self.firstSloganLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    self.firstSloganLabel.text = [NSString stringWithFormat:@"%@ %@", [RIApi getCountryNameInUse], STRING_BEST_SHOPPING_EXPERIENCE];
    [self.firstSloganLabel sizeToFit];
    [self.firstSloganLabel setFrame:CGRectMake(10.0f,
                                               CGRectGetMaxY(self.logoImageView.frame) + 4.0f,
                                               self.bounds.size.width - 10.0f*2,
                                               self.firstSloganLabel.frame.size.height)];
    [self addSubview:self.firstSloganLabel];
    
    self.secondSloganLabel1 = [[UILabel alloc] init];
    self.secondSloganLabel1.textColor = [UIColor whiteColor];
    self.secondSloganLabel1.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0f];
    self.secondSloganLabel1.text = STRING_WIDEST_CHOICE;
    [self.secondSloganLabel1 sizeToFit];

    self.secondSloganLabel2 = [[UILabel alloc] init];
    self.secondSloganLabel2.textColor = [UIColor blackColor];
    self.secondSloganLabel2.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0f];
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
    
    UIImage* mapImage = [UIImage imageNamed:@"jumiaMap"];
    self.mapImageView = [[UIImageView alloc] initWithImage:mapImage];
    self.mapImageView.center = self.center;
    [self addSubview:self.mapImageView];
    
    
    self.moreLabelBottom = [[UILabel alloc] init];
    self.moreLabelBottom.textColor = [UIColor whiteColor];
    self.moreLabelBottom.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
    self.moreLabelBottom.text = STRING_FALLBACK_BOTTOM_1;
    [self.moreLabelBottom sizeToFit];
    [self.moreLabelBottom setFrame:CGRectMake((self.bounds.size.width - self.moreLabelBottom.frame.size.width) / 2,
                                              self.bounds.size.height - self.moreLabelBottom.frame.size.height - 10.0f,
                                              self.moreLabelBottom.frame.size.width,
                                              self.moreLabelBottom.frame.size.height)];
    [self addSubview:self.moreLabelBottom];
    
    self.moreLabelTop = [[UILabel alloc] init];
    self.moreLabelTop.textColor = [UIColor whiteColor];
    self.moreLabelTop.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
    self.moreLabelTop.text = STRING_FALLBACK_BOTTOM_2;
    [self.moreLabelTop sizeToFit];
    [self.moreLabelTop setFrame:CGRectMake((self.bounds.size.width - self.moreLabelTop.frame.size.width) / 2,
                                           self.moreLabelBottom.frame.origin.y - self.moreLabelBottom.frame.size.height,
                                           self.moreLabelTop.frame.size.width,
                                           self.moreLabelTop.frame.size.height)];
    [self addSubview:self.moreLabelTop];

    
    CGFloat marginBetweenCheckboxAndLabel = 6.0f;
    CGFloat leftCheckboxX = 30.0f;
    CGFloat rightCheckboxX = (self.frame.size.width / 2) + 15.0f;
    
    UIImage* checkboxImage = [UIImage imageNamed:@"whiteCheck"];
    CGFloat labelWidth = (self.frame.size.width / 2) - leftCheckboxX - checkboxImage.size.width - marginBetweenCheckboxAndLabel;
    
    NSArray* categoriesArray = [NSArray arrayWithObjects:STRING_FALLBACK_BOOKS, STRING_FALLBACK_HOME_OFFICE, STRING_FALLBACK_AUDIO, STRING_FALLBACK_MOBILE, STRING_FALLBACK_HEALTH, STRING_FALLBACK_FASHION, nil];
    
    CGFloat currentY = self.moreLabelTop.frame.origin.y - 20.0f;
    for (int i = 0; i < categoriesArray.count; i++) {
        
        CGFloat startingX = leftCheckboxX;
        if (0 == i % 2) { //even
            startingX = rightCheckboxX;
        }
        
        UIImageView* checkboxImageView = [[UIImageView alloc] initWithImage:checkboxImage];
        [checkboxImageView setFrame:CGRectMake(startingX,
                                               currentY,
                                               checkboxImage.size.width,
                                               checkboxImage.size.height)];
        [self.checkboxImageViewsArray addObject:checkboxImageView];
        [self addSubview:checkboxImageView];
        
        UILabel* categoryLabel = [[UILabel alloc] init];
        categoryLabel.textColor = [UIColor blackColor];
        categoryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        categoryLabel.text = [categoriesArray objectAtIndex:i];
        [categoryLabel sizeToFit];
        [categoryLabel setFrame:CGRectMake(CGRectGetMaxX(checkboxImageView.frame) + 6.0f,
                                           checkboxImageView.frame.origin.y,
                                           labelWidth,
                                           categoryLabel.frame.size.height)];
        [self.categoryLabelsArray addObject:categoryLabel];
        [self addSubview:categoryLabel];
        
        if (0 != i % 2) { //odd
            currentY -= checkboxImage.size.height + 15.0f;
        }
    }
    
    UIImage* arrowImage = [UIImage imageNamed:@"whiteArrow"];
    self.arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
    [self.arrowImageView setFrame:CGRectMake(15.0f,
                                             currentY - arrowImage.size.height,
                                             arrowImage.size.width,
                                             arrowImage.size.height)];
    [self addSubview:self.arrowImageView];
}

@end

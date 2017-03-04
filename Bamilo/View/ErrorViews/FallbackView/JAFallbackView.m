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

    [self.welcomeLabel removeFromSuperview];
    [self.separator removeFromSuperview];
    [self.logoImageView removeFromSuperview];
    [self.countryLabel removeFromSuperview];
    [self.firstSloganLabel removeFromSuperview];
    [self.secondSloganLabel1 removeFromSuperview];
    [self.secondSloganLabel2 removeFromSuperview];
    [self.mapImageView removeFromSuperview];
    [self.moreLabelTop removeFromSuperview];
    [self.moreLabelBottom removeFromSuperview];
    [self.leftColumn removeFromSuperview];
    [self.rightColumn removeFromSuperview];
    [self.arrowImageView removeFromSuperview];
    
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
    [self.backgroundImageView setFrame:self.bounds];
    [self addSubview:self.backgroundImageView];
    

    self.welcomeLabel = [[UILabel alloc] init];
    self.welcomeLabel.textColor = [UIColor whiteColor];
    self.welcomeLabel.font = [UIFont fontWithName:kFontRegularName size:18.0f];
    
    self.welcomeLabel.text = @" ";
    
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
    
    
    self.separator.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.separator];
    
    UIImage *logoImage = [UIImage imageNamed:@"maintenanceLogo"];
    self.logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    
    self.countryLabel = [[UILabel alloc] init];
    self.countryLabel.textColor = [UIColor blackColor];
    self.countryLabel.font = [UIFont fontWithName:kFontRegularName size:24.0f];
    
    
    self.countryLabel.text = @"";

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
    
    CGFloat availableHeight = self.frame.size.height;
    
    
    UIImage* mapImage = [UIImage imageNamed:@"map"];
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        mapImage = [UIImage imageNamed:@"mapiPad"];
    }
    self.mapImageView = [[UIImageView alloc] initWithImage:mapImage];
    [self.mapImageView setFrame:CGRectMake((self.frame.size.width - mapImage.size.width) / 2,
                                           CGRectGetMaxY(self.secondSloganLabel1.frame) + ((availableHeight - mapImage.size.height) / 2),
                                           mapImage.size.width,
                                           mapImage.size.height)];
    [self addSubview:self.mapImageView];
}

@end

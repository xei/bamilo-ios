//
//  JAPDVWizardView.m
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVWizardView.h"

@implementation JAPDVWizardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat currentX = 0.0f;
        
        UIView* wizardPage1 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                       self.scrollView.bounds.origin.y,
                                                                       self.scrollView.bounds.size.width,
                                                                       self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:wizardPage1];
        
        UIImage* image1 = [UIImage imageNamed:@"wizard_swipe"];
        UIImageView* imageView1 = [[UIImageView alloc] initWithImage:image1];
        [imageView1 setFrame:CGRectMake((wizardPage1.bounds.size.width - image1.size.width) / 2,
                                        kJAWizardViewImageGenericTopMargin,
                                        imageView1.frame.size.width,
                                        imageView1.frame.size.height)];
        [wizardPage1 addSubview:imageView1];
        
        UILabel* wizardLabel1 = [[UILabel alloc] init];
        wizardLabel1.textAlignment = NSTextAlignmentCenter;
        wizardLabel1.numberOfLines = -1;
        wizardLabel1.font = kJAWizardFont;
        wizardLabel1.textColor = kJAWizardFontColor;
        wizardLabel1.text = STRING_WIZARD_PDV_SWIPE;
        
        CGRect wizardLabe1Rect = [STRING_WIZARD_PDV_SWIPE boundingRectWithSize:CGSizeMake(wizardPage1.bounds.size.width - kJAWizardPDV1TextHorizontalMargin*2, 1000.0f)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [wizardLabel1 setFrame:CGRectMake(wizardPage1.bounds.origin.x + kJAWizardPDV1TextHorizontalMargin,
                                          CGRectGetMaxY(imageView1.frame) + kJAWizardPDV1ViewTextVerticalMargin,
                                          wizardPage1.bounds.size.width - kJAWizardPDV1TextHorizontalMargin*2,
                                          wizardLabe1Rect.size.height)];
        [wizardPage1 addSubview:wizardLabel1];
        
        currentX += wizardPage1.frame.size.width;
        
        
        
        UIView* wizardPage2 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                       self.scrollView.bounds.origin.y,
                                                                       self.scrollView.bounds.size.width,
                                                                       self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:wizardPage2];
        
        UIImage* image2 = [UIImage imageNamed:@"wizard_tap"];
        UIImageView* imageView2 = [[UIImageView alloc] initWithImage:image2];
        [imageView2 setFrame:CGRectMake((wizardPage2.bounds.size.width - image2.size.width) / 2 + 30.0f,
                                        kJAWizardViewImageGenericTopMargin,
                                        imageView2.frame.size.width,
                                        imageView2.frame.size.height)];
        [wizardPage2 addSubview:imageView2];
        
        UILabel* wizardLabel2 = [[UILabel alloc] init];
        wizardLabel2.textAlignment = NSTextAlignmentCenter;
        wizardLabel2.numberOfLines = -1;
        wizardLabel2.font = kJAWizardFont;
        wizardLabel2.textColor = kJAWizardFontColor;
        wizardLabel2.text = STRING_WIZARD_PDV_TAP;
        
        CGRect wizardLabe2Rect = [STRING_WIZARD_PDV_TAP boundingRectWithSize:CGSizeMake(wizardPage1.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2, 1000.0f)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        
        
        [wizardLabel2 setFrame:CGRectMake(wizardPage2.bounds.origin.x + kJAWizardPDV2TextHorizontalMargin,
                                          CGRectGetMaxY(imageView2.frame) + kJAWizardPDV2ViewTextVerticalMargin,
                                          wizardPage2.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2,
                                          wizardLabe2Rect.size.height)];
        [wizardPage2 addSubview:wizardLabel2];
        
        currentX += wizardPage2.frame.size.width;
        
        
        
        UIView* wizardPage3 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                       self.scrollView.bounds.origin.y,
                                                                       self.scrollView.bounds.size.width,
                                                                       self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:wizardPage3];
        
        UIImage* image3 = [UIImage imageNamed:@"wizard_fav"];
        UIImageView* imageView3 = [[UIImageView alloc] initWithImage:image3];
        [imageView3 setFrame:CGRectMake(wizardPage3.bounds.size.width - image3.size.width - 15.0f,
                                        kJAWizardViewImageGenericSmallTopMargin,
                                        imageView3.frame.size.width,
                                        imageView3.frame.size.height)];
        [wizardPage3 addSubview:imageView3];
        
        UILabel* wizardLabel3 = [[UILabel alloc] init];
        wizardLabel3.textAlignment = NSTextAlignmentCenter;
        wizardLabel3.numberOfLines = -1;
        wizardLabel3.font = kJAWizardFont;
        wizardLabel3.textColor = kJAWizardFontColor;
        wizardLabel3.text = STRING_WIZARD_CATALOG_FAVORITE;
        
        CGRect wizardLabe3Rect = [STRING_WIZARD_CATALOG_FAVORITE boundingRectWithSize:CGSizeMake(wizardPage1.bounds.size.width - kJAWizardPDV3TextHorizontalMargin*2, 1000.0f)
                                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                                           attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [wizardLabel3 setFrame:CGRectMake(wizardPage3.bounds.origin.x + kJAWizardPDV3TextHorizontalMargin,
                                          CGRectGetMaxY(imageView3.frame) + kJAWizardPDV3ViewTextVerticalMargin,
                                          wizardPage3.bounds.size.width - kJAWizardPDV3TextHorizontalMargin*2,
                                          wizardLabe3Rect.size.height)];
        [wizardPage3 addSubview:wizardLabel3];
        
        currentX += wizardPage3.frame.size.width;
        
        
        UIView* wizardPage4 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                       self.scrollView.bounds.origin.y,
                                                                       self.scrollView.bounds.size.width,
                                                                       self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:wizardPage4];
        
        UIImage* image4 = [UIImage imageNamed:@"wizard_tap"];
        UIImageView* imageView4 = [[UIImageView alloc] initWithImage:image4];
        [imageView4 setFrame:CGRectMake(kJAWizardPDV4TextHorizontalMargin,
                                        kJAWizardViewImageGenericSmallTopMargin,
                                        imageView4.frame.size.width,
                                        imageView4.frame.size.height)];
        [wizardPage4 addSubview:imageView4];
        
        UILabel* wizardLabel4 = [[UILabel alloc] init];
        wizardLabel4.textAlignment = NSTextAlignmentCenter;
        wizardLabel4.numberOfLines = -1;
        wizardLabel4.font = kJAWizardFont;
        wizardLabel4.textColor = kJAWizardFontColor;
        wizardLabel4.text = STRING_WIZARD_PDV_SHARE;
        
        CGRect wizardLabe4Rect = [STRING_WIZARD_PDV_SHARE boundingRectWithSize:CGSizeMake(wizardPage1.bounds.size.width - kJAWizardPDV4TextHorizontalMargin*2, 1000.0f)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [wizardLabel4 setFrame:CGRectMake(wizardPage4.bounds.origin.x + kJAWizardPDV4TextHorizontalMargin,
                                          CGRectGetMaxY(imageView4.frame) + kJAWizardPDV4ViewTextVerticalMargin,
                                          wizardPage4.bounds.size.width - kJAWizardPDV4TextHorizontalMargin*2,
                                          wizardLabe4Rect.size.height)];
        [wizardPage4 addSubview:wizardLabel4];
        
        currentX += wizardPage4.frame.size.width;
        
        [self.scrollView setContentSize:CGSizeMake(currentX,
                                                   self.scrollView.frame.size.height)];
        
        self.pageControl.numberOfPages = 4;
    }
    return self;
}


@end

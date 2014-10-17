//
//  JACatalogWizardView.m
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogWizardView.h"

@implementation JACatalogWizardView

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
        wizardLabel1.text = STRING_WIZARD_CATALOG_SWIPE;
        [wizardLabel1 setFrame:CGRectMake(wizardPage1.bounds.origin.x + kJAWizardViewTextMargin,
                                          CGRectGetMaxY(imageView1.frame) + kJAWizardViewTextMargin,
                                          wizardPage1.bounds.size.width - kJAWizardViewTextMargin*2,
                                          100.0f)];
        [wizardPage1 addSubview:wizardLabel1];
        
        currentX += wizardPage1.frame.size.width;
        
        UIView* wizardPage2 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                       self.scrollView.bounds.origin.y,
                                                                       self.scrollView.bounds.size.width,
                                                                       self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:wizardPage2];
        
        UIImage* image2 = [UIImage imageNamed:@"wizard_fav"];
        UIImageView* imageView2 = [[UIImageView alloc] initWithImage:image2];
        [imageView2 setFrame:CGRectMake(wizardPage2.bounds.size.width - image2.size.width - 15.0f,
                                        kJAWizardViewImageGenericTopMargin,
                                        imageView2.frame.size.width,
                                        imageView2.frame.size.height)];
        [wizardPage2 addSubview:imageView2];
        
        UILabel* wizardLabel2 = [[UILabel alloc] init];
        wizardLabel2.textAlignment = NSTextAlignmentCenter;
        wizardLabel2.numberOfLines = -1;
        wizardLabel2.font = kJAWizardFont;
        wizardLabel2.textColor = kJAWizardFontColor;
        wizardLabel2.text = STRING_WIZARD_CATALOG_FAVORITE;
        [wizardLabel2 setFrame:CGRectMake(wizardPage2.bounds.origin.x + kJAWizardViewTextMargin,
                                          CGRectGetMaxY(imageView2.frame) + kJAWizardViewTextMargin,
                                          wizardPage2.bounds.size.width - kJAWizardViewTextMargin*2,
                                          100.0f)];
        [wizardPage2 addSubview:wizardLabel2];
        
        currentX += wizardPage2.frame.size.width;
        
        [self.scrollView setContentSize:CGSizeMake(currentX,
                                                   self.scrollView.frame.size.height)];
        
        self.pageControl.numberOfPages = 2;
    }
    return self;
}

@end

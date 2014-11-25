//
//  JACatalogWizardView.m
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogWizardView.h"

@interface JACatalogWizardView ()

@property (nonatomic, strong) UIView* wizardPage1;
@property (nonatomic, strong) UIImageView* wizardPage1ImageView;
@property (nonatomic, strong) UILabel* wizardPage1Label;
@property (nonatomic, strong) UIView* wizardPage2;
@property (nonatomic, strong) UIImageView* wizardPage2ImageView;
@property (nonatomic, strong) UILabel* wizardPage2Label;

@end

@implementation JACatalogWizardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat currentX = 0.0f;
        
        self.wizardPage1 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                    self.scrollView.bounds.origin.y,
                                                                    self.scrollView.bounds.size.width,
                                                                    self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:self.wizardPage1];
        
        UIImage* image1 = [UIImage imageNamed:@"wizard_swipe"];
        self.wizardPage1ImageView = [[UIImageView alloc] initWithImage:image1];
        [self.wizardPage1ImageView setFrame:CGRectMake((self.wizardPage1.bounds.size.width - image1.size.width) / 2,
                                                       kJAWizardViewImageGenericTopMargin,
                                                       image1.size.width,
                                                       image1.size.height)];
        [self.wizardPage1 addSubview:self.wizardPage1ImageView];
        
        self.wizardPage1Label = [[UILabel alloc] init];
        self.wizardPage1Label.textAlignment = NSTextAlignmentCenter;
        self.wizardPage1Label.numberOfLines = -1;
        self.wizardPage1Label.font = kJAWizardFont;
        self.wizardPage1Label.textColor = kJAWizardFontColor;
        self.wizardPage1Label.text = STRING_WIZARD_CATALOG_SWIPE;
        
        CGRect wizardLabe1Rect = [STRING_WIZARD_CATALOG_SWIPE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardCatalog1TextHorizontalMargin*2, 1000.0f)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [self.wizardPage1Label setFrame:CGRectMake(self.wizardPage1.bounds.origin.x + kJAWizardCatalog1TextHorizontalMargin,
                                                   CGRectGetMaxY(self.wizardPage1ImageView.frame) + kJAWizardCatalog1ViewTextVerticalMargin,
                                                   self.wizardPage1.bounds.size.width - kJAWizardCatalog1TextHorizontalMargin*2,
                                                   wizardLabe1Rect.size.height)];
        [self.wizardPage1 addSubview:self.wizardPage1Label];
        
        currentX += self.wizardPage1.frame.size.width;
        
        self.wizardPage2 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                    self.scrollView.bounds.origin.y,
                                                                    self.scrollView.bounds.size.width,
                                                                    self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:self.wizardPage2];
        
        UIImage* image2 = [UIImage imageNamed:@"wizard_fav"];
        self.wizardPage2ImageView = [[UIImageView alloc] initWithImage:image2];
        [self.wizardPage2ImageView setFrame:CGRectMake(self.wizardPage2.bounds.size.width - image2.size.width - 15.0f,
                                                       kJAWizardViewImageGenericSmallTopMargin,
                                                       image2.size.width,
                                                       image2.size.height)];
        [self.wizardPage2 addSubview:self.wizardPage2ImageView];
        
        self.wizardPage2Label = [[UILabel alloc] init];
        self.wizardPage2Label.textAlignment = NSTextAlignmentCenter;
        self.wizardPage2Label.numberOfLines = -1;
        self.wizardPage2Label.font = kJAWizardFont;
        self.wizardPage2Label.textColor = kJAWizardFontColor;
        self.wizardPage2Label.text = STRING_WIZARD_CATALOG_FAVORITE;
        
        CGRect wizardLabe2ect = [STRING_WIZARD_CATALOG_FAVORITE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardCatalog2TextHorizontalMargin*2, 1000.0f)
                                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                                          attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [self.wizardPage2Label setFrame:CGRectMake(self.wizardPage2.bounds.origin.x + kJAWizardCatalog2TextHorizontalMargin,
                                                   CGRectGetMaxY(self.wizardPage2ImageView.frame) + kJAWizardCatalog2ViewTextVerticalMargin,
                                                   self.wizardPage2.bounds.size.width - kJAWizardCatalog2TextHorizontalMargin*2,
                                                   wizardLabe2ect.size.height)];
        [self.wizardPage2 addSubview:self.wizardPage2Label];
        
        currentX += self.wizardPage2.frame.size.width;
        
        [self.scrollView setContentSize:CGSizeMake(currentX,
                                                   self.scrollView.frame.size.height)];
        
        self.pageControl.numberOfPages = 2;
    }
    return self;
}

- (void)reloadForFrame:(CGRect)frame
{
    [super reloadForFrame:frame];
    
    CGFloat currentX = 0.0f;
    
    [self.wizardPage1 setFrame:CGRectMake(currentX,
                                          self.scrollView.bounds.origin.y,
                                          self.scrollView.bounds.size.width,
                                          self.scrollView.bounds.size.height)];
    
    [self.wizardPage1ImageView setFrame:CGRectMake((self.wizardPage1.bounds.size.width -  self.wizardPage1ImageView.frame.size.width) / 2,
                                                   kJAWizardViewImageGenericTopMargin,
                                                   self.wizardPage1ImageView.frame.size.width,
                                                   self.wizardPage1ImageView.frame.size.height)];
    
    CGRect wizardLabe1Rect = [STRING_WIZARD_CATALOG_SWIPE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardCatalog1TextHorizontalMargin*2, 1000.0f)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    [self.wizardPage1Label setFrame:CGRectMake(self.wizardPage1.bounds.origin.x + kJAWizardCatalog1TextHorizontalMargin,
                                               CGRectGetMaxY(self.wizardPage1ImageView.frame) + kJAWizardCatalog1ViewTextVerticalMargin,
                                               self.wizardPage1.bounds.size.width - kJAWizardCatalog1TextHorizontalMargin*2,
                                               wizardLabe1Rect.size.height)];
    currentX += self.wizardPage1.frame.size.width;
    
    [self.wizardPage2 setFrame:CGRectMake(currentX,
                                          self.scrollView.bounds.origin.y,
                                          self.scrollView.bounds.size.width,
                                          self.scrollView.bounds.size.height)];
    
    [self.wizardPage2ImageView setFrame:CGRectMake(self.wizardPage2.bounds.size.width - self.wizardPage2ImageView.frame.size.width - 15.0f,
                                                   kJAWizardViewImageGenericSmallTopMargin,
                                                   self.wizardPage2ImageView.frame.size.width,
                                                   self.wizardPage2ImageView.frame.size.height)];
    
    CGRect wizardLabe2ect = [STRING_WIZARD_CATALOG_FAVORITE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardCatalog2TextHorizontalMargin*2, 1000.0f)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                      attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    [self.wizardPage2Label setFrame:CGRectMake(self.wizardPage2.bounds.origin.x + kJAWizardCatalog2TextHorizontalMargin,
                                               CGRectGetMaxY(self.wizardPage2ImageView.frame) + kJAWizardCatalog2ViewTextVerticalMargin,
                                               self.wizardPage2.bounds.size.width - kJAWizardCatalog2TextHorizontalMargin*2,
                                               wizardLabe2ect.size.height)];
    
    currentX += self.wizardPage2.frame.size.width;
    
    [self.scrollView setContentSize:CGSizeMake(currentX,
                                               self.scrollView.frame.size.height)];
    
    self.pageControl.numberOfPages = 2;
}

@end

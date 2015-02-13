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
        
        UIImage* image2 = [UIImage imageNamed:@"wizard_fav"];
        self.wizardPage1ImageView = [[UIImageView alloc] initWithImage:image2];
        [self.wizardPage1ImageView setFrame:CGRectMake(self.wizardPage1.bounds.size.width - self.wizardPage1ImageView.frame.size.width - 15.0f,
                                                       kJAWizardViewImageGenericSmallTopMargin,
                                                       image2.size.width,
                                                       image2.size.height)];
        [self.wizardPage1 addSubview:self.wizardPage1ImageView];
        
        self.wizardPage1Label = [[UILabel alloc] init];
        self.wizardPage1Label.textAlignment = NSTextAlignmentCenter;
        self.wizardPage1Label.numberOfLines = -1;
        self.wizardPage1Label.font = kJAWizardFont;
        self.wizardPage1Label.textColor = kJAWizardFontColor;
        self.wizardPage1Label.text = STRING_WIZARD_CATALOG_FAVORITE;
        
        CGRect wizardLabe2ect = [STRING_WIZARD_CATALOG_FAVORITE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardCatalog2TextHorizontalMargin*2, 1000.0f)
                                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                                          attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        CGFloat labelTopMargin = kJAWizardCatalog2ViewTextVerticalMargin;
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
            labelTopMargin = kJAWizardCatalog2ViewTextVerticalMargin_ipad;
        }
        [self.wizardPage1Label setFrame:CGRectMake(self.wizardPage1.bounds.origin.x + kJAWizardCatalog2TextHorizontalMargin,
                                                   CGRectGetMaxY(self.wizardPage1ImageView.frame) + labelTopMargin,
                                                   self.wizardPage1.bounds.size.width - kJAWizardCatalog2TextHorizontalMargin*2,
                                                   wizardLabe2ect.size.height)];
        [self.wizardPage1 addSubview:self.wizardPage1Label];
        
        currentX += self.wizardPage1.frame.size.width;
        
        [self.scrollView setContentSize:CGSizeMake(currentX,
                                                   self.scrollView.frame.size.height)];
        
        [self reloadForFrame:frame];
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
    
    [self.wizardPage1ImageView setFrame:CGRectMake(self.wizardPage1.bounds.size.width - self.wizardPage1ImageView.frame.size.width - 15.0f,
                                                   kJAWizardViewImageGenericSmallTopMargin,
                                                   self.wizardPage1ImageView.frame.size.width,
                                                   self.wizardPage1ImageView.frame.size.height)];
    
    CGRect wizardLabe2ect = [STRING_WIZARD_CATALOG_FAVORITE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardCatalog2TextHorizontalMargin*2, 1000.0f)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                      attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    CGFloat labelTopMargin = kJAWizardCatalog2ViewTextVerticalMargin;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        labelTopMargin = kJAWizardCatalog2ViewTextVerticalMargin_ipad;
    }
    [self.wizardPage1Label setFrame:CGRectMake(self.wizardPage1.bounds.origin.x + kJAWizardCatalog2TextHorizontalMargin,
                                               CGRectGetMaxY(self.wizardPage1ImageView.frame) + labelTopMargin,
                                               self.wizardPage1.bounds.size.width - kJAWizardCatalog2TextHorizontalMargin*2,
                                               wizardLabe2ect.size.height)];
    
    currentX += self.wizardPage1.frame.size.width;
    
    [self.scrollView setContentSize:CGSizeMake(currentX,
                                               self.scrollView.frame.size.height)];
    
    [self.scrollView scrollRectToVisible:CGRectMake(0.0f, 0.0f, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:NO];
}

@end

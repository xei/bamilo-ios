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
                                                                    self.y,
                                                                    self.width,
                                                                    self.height)];
        
        UIImage* image2 = [UIImage imageNamed:@"wizard_fav"];
        self.wizardPage1ImageView = [[UIImageView alloc] initWithImage:image2];
        [self.wizardPage1ImageView setFrame:CGRectMake(self.wizardPage1.bounds.size.width - self.wizardPage1ImageView.frame.size.width - 15.0f,
                                                       kJAWizardViewImageGenericSmallTopMargin,
                                                       image2.size.width,
                                                       image2.size.height)];
        
        if(RI_IS_RTL){
            
            [self.wizardPage1ImageView setImage:[image2 flipImageWithOrientation:UIImageOrientationUpMirrored]];
        
        }
        [self.wizardPage1 addSubview:self.wizardPage1ImageView];
        
        self.wizardPage1Label = [[UILabel alloc] init];
        self.wizardPage1Label.textAlignment = NSTextAlignmentCenter;
        self.wizardPage1Label.numberOfLines = -1;
        self.wizardPage1Label.font = kJAWizardFont;
        self.wizardPage1Label.textColor = JABlack700Color;
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
        
/*  Wizard Page 2 - Scroll Back to Top */
        
        CGFloat topMargin = 60.0f;
        CGFloat marginBetweenImageAndLabel = 40.0f;
        
        self.wizardPage2 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                   self.y,
                                                                   self.width,
                                                                    self.height)];
        
        
        UIImage* imageForWizardPage2 = [UIImage imageNamed:@"backtop_wizard"];
        self.wizardPage2ImageView = [[UIImageView alloc] initWithImage:imageForWizardPage2];
        [self.wizardPage2ImageView setFrame:CGRectMake((self.wizardPage2.bounds.size.width - imageForWizardPage2.size.width)/2,
                                                      topMargin,
                                                      imageForWizardPage2.size.width,
                                                       imageForWizardPage2.size.height)];
        [self.wizardPage2 addSubview:self.wizardPage2ImageView];
        
        self.wizardPage2Label = [[UILabel alloc] init];
        self.wizardPage2Label.textAlignment = NSTextAlignmentCenter;
        self.wizardPage2Label.numberOfLines = -1;
        self.wizardPage2Label.font = kJAWizardFont;
        self.wizardPage2Label.textColor = JABlack700Color;
        self.wizardPage2Label.text = STRING_WIZARD_BACK_TOP;
        
        CGRect wizardLabe2Rect = [STRING_WIZARD_BACK_TOP boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2, 1000.0f)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];

        
        [self.wizardPage2Label setFrame:CGRectMake(self.wizardPage2.bounds.origin.x + kJAWizardPDV2TextHorizontalMargin,
                                                   CGRectGetMaxY(self.wizardPage2ImageView.frame) + marginBetweenImageAndLabel,
                                                   self.wizardPage2.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2,
                                                   wizardLabe2Rect.size.height)];
        [self.wizardPage2 addSubview:self.wizardPage2Label];
        
        [self.pagedView setViews:[NSArray arrayWithObjects:_wizardPage1, _wizardPage2, nil]];
        
        [self reloadForFrame:frame];
    }
    return self;
}

- (void)reloadForFrame:(CGRect)frame
{
    [super reloadForFrame:frame];
    
    CGFloat currentX = 0.0f;
    
    CGFloat topMargin = 60.0f;
    BOOL isLandscape = frame.size.width>frame.size.height?YES:NO;
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        topMargin = 150.0f;
    }
    
    [self.wizardPage1 setFrame:CGRectMake(currentX,
                                          self.y,
                                          self.width,
                                          self.height)];
    
    [self.wizardPage1ImageView setFrame:CGRectMake(self.wizardPage1.bounds.size.width - self.wizardPage1ImageView.frame.size.width - 25.0f,
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
    
    CGFloat leftMargin2 = (self.bounds.size.width - self.wizardPage2ImageView.frame.size.width) / 2;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && isLandscape) {
        leftMargin2 = 397.0f;
    }
    
    [self.wizardPage2 setFrame:CGRectMake(currentX,
                                          self.y,
                                          self.width,
                                          self.height)];
    
    [self.wizardPage2ImageView setFrame:CGRectMake(leftMargin2,
                                                   topMargin,
                                                   self.wizardPage2ImageView.frame.size.width,
                                                   self.wizardPage2ImageView.frame.size.height)];
    
    CGRect wizardLabe2Rect = [STRING_WIZARD_BACK_TOP boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2, 1000.0f)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    
    
    [self.wizardPage2Label setFrame:CGRectMake(self.wizardPage2.bounds.origin.x + kJAWizardPDV2TextHorizontalMargin,
                                               CGRectGetMaxY(self.wizardPage2ImageView.frame) + kJAWizardPDV2ViewTextVerticalMargin,
                                               self.wizardPage2.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2,
                                               wizardLabe2Rect.size.height)];
    
    if (RI_IS_RTL) {
        [_wizardPage1 flipAllSubviews];
        [_wizardPage2 flipAllSubviews];
    }
}

@end

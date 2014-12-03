//
//  JAPDVWizardView.m
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVWizardView.h"

@interface JAPDVWizardView ()

@property (nonatomic, strong) UIView *wizardPage1;
@property (nonatomic, strong) UIImageView *wizardPage1ImageView;
@property (nonatomic, strong) UILabel *wizardPage1Label;
@property (nonatomic, strong) UIView *wizardPage2;
@property (nonatomic, strong) UIImageView *wizardPage2ImageView;
@property (nonatomic, strong) UILabel *wizardPage2Label;
@property (nonatomic, strong) UIView *wizardPage3;
@property (nonatomic, strong) UIImageView *wizardPage3ImageView;
@property (nonatomic, strong) UILabel *wizardPage3Label;
@property (nonatomic, strong) UIView *wizardPage4;
@property (nonatomic, strong) UIImageView *wizardPage4ImageView;
@property (nonatomic, strong) UILabel *wizardPage4Label;

@end

@implementation JAPDVWizardView

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
        NSString* label1Text = STRING_WIZARD_PDV_SWIPE;
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
            label1Text = [label1Text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        }
        self.wizardPage1Label.text = label1Text;
        
        CGRect wizardLabe1Rect = [STRING_WIZARD_PDV_SWIPE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardPDV1TextHorizontalMargin*2, 1000.0f)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [self.wizardPage1Label setFrame:CGRectMake(self.wizardPage1.bounds.origin.x + kJAWizardPDV1TextHorizontalMargin,
                                                   CGRectGetMaxY(self.wizardPage1ImageView.frame) + kJAWizardPDV1ViewTextVerticalMargin,
                                                   self.wizardPage1.bounds.size.width - kJAWizardPDV1TextHorizontalMargin*2,
                                                   wizardLabe1Rect.size.height)];
        [self.wizardPage1 addSubview:self.wizardPage1Label];
        
        currentX += self.wizardPage1.frame.size.width;
        
        
        
        self.wizardPage2 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                    self.scrollView.bounds.origin.y,
                                                                    self.scrollView.bounds.size.width,
                                                                    self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:self.wizardPage2];
        
        UIImage* image2 = [UIImage imageNamed:@"wizard_tap"];
        self.wizardPage2ImageView = [[UIImageView alloc] initWithImage:image2];
        [self.wizardPage2ImageView setFrame:CGRectMake((self.wizardPage2.bounds.size.width - image2.size.width) / 2 + 30.0f,
                                                       kJAWizardViewImageGenericTopMargin,
                                                       image2.size.width,
                                                       image2.size.height)];
        [self.wizardPage2 addSubview:self.wizardPage2ImageView];
        
        self.wizardPage2Label = [[UILabel alloc] init];
        self.wizardPage2Label.textAlignment = NSTextAlignmentCenter;
        self.wizardPage2Label.numberOfLines = -1;
        self.wizardPage2Label.font = kJAWizardFont;
        self.wizardPage2Label.textColor = kJAWizardFontColor;
        self.wizardPage2Label.text = STRING_WIZARD_PDV_TAP;
        
        CGRect wizardLabe2Rect = [STRING_WIZARD_PDV_TAP boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2, 1000.0f)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        
        
        [self.wizardPage2Label setFrame:CGRectMake(self.wizardPage2.bounds.origin.x + kJAWizardPDV2TextHorizontalMargin,
                                                   CGRectGetMaxY(self.wizardPage2ImageView.frame) + kJAWizardPDV2ViewTextVerticalMargin,
                                                   self.wizardPage2.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2,
                                                   wizardLabe2Rect.size.height)];
        [self.wizardPage2 addSubview:self.wizardPage2Label];
        
        currentX += self.wizardPage2.frame.size.width;
        
        
        
        self.wizardPage3 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                    self.scrollView.bounds.origin.y,
                                                                    self.scrollView.bounds.size.width,
                                                                    self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:self.wizardPage3];
        
        UIImage* image3 = [UIImage imageNamed:@"wizard_fav"];
        self.wizardPage3ImageView = [[UIImageView alloc] initWithImage:image3];
        [self.wizardPage3ImageView setFrame:CGRectMake(self.wizardPage3.bounds.size.width - image3.size.width - 15.0f,
                                                       kJAWizardViewImageGenericSmallTopMargin,
                                                       image3.size.width,
                                                       image3.size.height)];
        [self.wizardPage3 addSubview:self.wizardPage3ImageView];
        
        self.wizardPage3Label = [[UILabel alloc] init];
        self.wizardPage3Label.textAlignment = NSTextAlignmentCenter;
        self.wizardPage3Label.numberOfLines = -1;
        self.wizardPage3Label.font = kJAWizardFont;
        self.wizardPage3Label.textColor = kJAWizardFontColor;
        self.wizardPage3Label.text = STRING_WIZARD_CATALOG_FAVORITE;
        
        CGRect wizardLabe3Rect = [STRING_WIZARD_CATALOG_FAVORITE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardPDV3TextHorizontalMargin*2, 1000.0f)
                                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                                           attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [self.wizardPage3Label setFrame:CGRectMake(self.wizardPage3.bounds.origin.x + kJAWizardPDV3TextHorizontalMargin,
                                                   CGRectGetMaxY(self.wizardPage3ImageView.frame) + kJAWizardPDV3ViewTextVerticalMargin,
                                                   self.wizardPage3.bounds.size.width - kJAWizardPDV3TextHorizontalMargin*2,
                                                   wizardLabe3Rect.size.height)];
        [self.wizardPage3 addSubview:self.wizardPage3Label];
        
        currentX += self.wizardPage3.frame.size.width;
        
        
        self.wizardPage4 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                    self.scrollView.bounds.origin.y,
                                                                    self.scrollView.bounds.size.width,
                                                                    self.scrollView.bounds.size.height)];
        [self.scrollView addSubview:self.wizardPage4];
        
        UIImage* image4 = [UIImage imageNamed:@"wizard_tap"];
        self.wizardPage4ImageView = [[UIImageView alloc] initWithImage:image4];
        [self.wizardPage4ImageView setFrame:CGRectMake(kJAWizardPDV4TextHorizontalMargin,
                                                       kJAWizardViewImageGenericSmallTopMargin,
                                                       image4.size.width,
                                                       image4.size.height)];
        [self.wizardPage4 addSubview:self.wizardPage4ImageView];
        
        self.wizardPage4Label = [[UILabel alloc] init];
        self.wizardPage4Label.textAlignment = NSTextAlignmentCenter;
        self.wizardPage4Label.numberOfLines = -1;
        self.wizardPage4Label.font = kJAWizardFont;
        self.wizardPage4Label.textColor = kJAWizardFontColor;
        self.wizardPage4Label.text = STRING_WIZARD_PDV_SHARE;
        
        CGRect wizardLabe4Rect = [STRING_WIZARD_PDV_SHARE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardPDV4TextHorizontalMargin*2, 1000.0f)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [self.wizardPage4Label setFrame:CGRectMake(self.wizardPage4.bounds.origin.x + kJAWizardPDV4TextHorizontalMargin,
                                                   CGRectGetMaxY(self.wizardPage4ImageView.frame) + kJAWizardPDV4ViewTextVerticalMargin,
                                                   self.wizardPage4.bounds.size.width - kJAWizardPDV4TextHorizontalMargin*2,
                                                   wizardLabe4Rect.size.height)];
        [self.wizardPage4 addSubview:self.wizardPage4Label];
        
        currentX += self.wizardPage4.frame.size.width;
        
        [self.scrollView setContentSize:CGSizeMake(currentX,
                                                   self.scrollView.frame.size.height)];
        
        self.pageControl.numberOfPages = 4;
        
        [self reloadForFrame:frame];
    }
    return self;
}

- (void)reloadForFrame:(CGRect)frame
{
    [super reloadForFrame:frame];
    
    CGFloat currentX = 0.0f;
    
    BOOL isLandscape = frame.size.width>frame.size.height?YES:NO;
    
    CGFloat topMargin = kJAWizardViewImageGenericTopMargin;
    CGFloat leftMargin1 = (self.wizardPage1.bounds.size.width - self.wizardPage1ImageView.frame.size.width) / 2;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        topMargin = kJAWizardViewImageGenericTopMargin_ipad;
        if (isLandscape) {
            leftMargin1 = kJAWizardViewFirstImageLeftMargin;
        }
    }
    
    [self.wizardPage1 setFrame:CGRectMake(currentX,
                                          self.scrollView.bounds.origin.y,
                                          self.scrollView.bounds.size.width,
                                          self.scrollView.bounds.size.height)];
    
    [self.wizardPage1ImageView setFrame:CGRectMake(leftMargin1,
                                                   topMargin,
                                                   self.wizardPage1ImageView.frame.size.width,
                                                   self.wizardPage1ImageView.frame.size.height)];
    
    CGRect wizardLabe1Rect = [STRING_WIZARD_PDV_SWIPE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardPDV1TextHorizontalMargin*2, 1000.0f)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    [self.wizardPage1Label setFrame:CGRectMake(self.wizardPage1.bounds.origin.x + kJAWizardPDV1TextHorizontalMargin,
                                               CGRectGetMaxY(self.wizardPage1ImageView.frame) + kJAWizardPDV1ViewTextVerticalMargin,
                                               self.wizardPage1.bounds.size.width - kJAWizardPDV1TextHorizontalMargin*2,
                                               wizardLabe1Rect.size.height)];
    
    currentX += self.wizardPage1.frame.size.width;
    
    
    
    CGFloat leftMargin2 = (self.wizardPage2.bounds.size.width - self.wizardPage2ImageView.frame.size.width) / 2 + 30.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && isLandscape) {
        leftMargin2 = kJAWizardViewFirstImageLeftMargin + 60.0f;
    }
    
    [self.wizardPage2 setFrame:CGRectMake(currentX,
                                          self.scrollView.bounds.origin.y,
                                          self.scrollView.bounds.size.width,
                                          self.scrollView.bounds.size.height)];
    
    [self.wizardPage2ImageView setFrame:CGRectMake(leftMargin2,
                                                   topMargin,
                                                   self.wizardPage2ImageView.frame.size.width,
                                                   self.wizardPage2ImageView.frame.size.height)];
    
    CGRect wizardLabe2Rect = [STRING_WIZARD_PDV_TAP boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2, 1000.0f)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    
    
    [self.wizardPage2Label setFrame:CGRectMake(self.wizardPage2.bounds.origin.x + kJAWizardPDV2TextHorizontalMargin,
                                               CGRectGetMaxY(self.wizardPage2ImageView.frame) + kJAWizardPDV2ViewTextVerticalMargin,
                                               self.wizardPage2.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2,
                                               wizardLabe2Rect.size.height)];
    currentX += self.wizardPage2.frame.size.width;
    
    
    CGFloat topMargin3 = kJAWizardViewThirdImageTopMargin;
    CGFloat leftMargin3 = self.wizardPage3.bounds.size.width - self.wizardPage3ImageView.frame.size.width - 15.0f;
    CGFloat labelTopMargin3 = kJAWizardPDV3ViewTextVerticalMargin;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && isLandscape) {
        labelTopMargin3 = kJAWizardPDV3ViewTextVerticalMargin_ipad;
        leftMargin3 = (self.wizardPage3.bounds.size.width / 2) - self.wizardPage3ImageView.frame.size.width - 15.0f ;
        topMargin3 = kJAWizardViewThirdImageTopMargin_landscape;
    }
    [self.wizardPage3 setFrame:CGRectMake(currentX,
                                          self.scrollView.bounds.origin.y,
                                          self.scrollView.bounds.size.width,
                                          self.scrollView.bounds.size.height)];
    [self.wizardPage3ImageView setFrame:CGRectMake(leftMargin3,
                                                   topMargin3,
                                                   self.wizardPage3ImageView.frame.size.width,
                                                   self.wizardPage3ImageView.frame.size.height)];
    
    CGRect wizardLabe3Rect = [STRING_WIZARD_CATALOG_FAVORITE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardPDV3TextHorizontalMargin*2, 1000.0f)
                                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    [self.wizardPage3Label setFrame:CGRectMake(self.wizardPage3.bounds.origin.x + kJAWizardPDV3TextHorizontalMargin,
                                               CGRectGetMaxY(self.wizardPage3ImageView.frame) + labelTopMargin3,
                                               self.wizardPage3.bounds.size.width - kJAWizardPDV3TextHorizontalMargin*2,
                                               wizardLabe3Rect.size.height)];
    currentX += self.wizardPage3.frame.size.width;
    
    
    CGFloat topMargin4 = kJAWizardViewThirdImageTopMargin;
    CGFloat labelTopMargin4 = kJAWizardPDV3ViewTextVerticalMargin;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && isLandscape) {
        labelTopMargin4 = kJAWizardPDV3ViewTextVerticalMargin_ipad;
        topMargin4 = kJAWizardViewThirdImageTopMargin_landscape;
    }
    [self.wizardPage4 setFrame:CGRectMake(currentX,
                                          self.scrollView.bounds.origin.y,
                                          self.scrollView.bounds.size.width,
                                          self.scrollView.bounds.size.height)];
    
    [self.wizardPage4ImageView setFrame:CGRectMake(kJAWizardPDV4TextHorizontalMargin,
                                                   topMargin4,
                                                   self.wizardPage4ImageView.frame.size.width,
                                                   self.wizardPage4ImageView.frame.size.height)];
    
    CGRect wizardLabe4Rect = [STRING_WIZARD_PDV_SHARE boundingRectWithSize:CGSizeMake(self.wizardPage1.bounds.size.width - kJAWizardPDV4TextHorizontalMargin*2, 1000.0f)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    [self.wizardPage4Label setFrame:CGRectMake(self.wizardPage4.bounds.origin.x + kJAWizardPDV4TextHorizontalMargin,
                                               CGRectGetMaxY(self.wizardPage4ImageView.frame) + labelTopMargin4,
                                               self.wizardPage4.bounds.size.width - kJAWizardPDV4TextHorizontalMargin*2,
                                               wizardLabe4Rect.size.height)];
    currentX += self.wizardPage4.frame.size.width;
    
    [self.scrollView setContentSize:CGSizeMake(currentX,
                                               self.scrollView.frame.size.height)];
    
    self.pageControl.numberOfPages = 4;
    
    [self.scrollView scrollRectToVisible:CGRectMake(0.0f, 0.0f, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:NO];
}

@end

//
//  JAPDVWizardView.m
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVWizardView.h"

#define kSellerOffset 70

@interface JAPDVWizardView ()
{
    UIView *_wizardPage1;
    UIImageView *_wizardPage1ImageView;
    UILabel *_wizardPage1Label;
    UIView *_wizardPage2;
    UIImageView *_wizardPage2ImageView;
    UILabel *_wizardPage2Label;
    UIView *_wizardPage3;
    UIImageView *_wizardPage3ImageView;
    UILabel *_wizardPage3Label;
    UIView *_wizardPage4;
    UIImageView *_wizardPage4ImageView;
    UILabel *_wizardPage4Label;
}

@end

@implementation JAPDVWizardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat currentX = 0.0f;
        
        _wizardPage1 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                self.y,
                                                                self.width,
                                                                self.height)];
        
        UIImage* image1 = [UIImage imageNamed:@"wizard_swipe"];
        _wizardPage1ImageView = [[UIImageView alloc] initWithImage:image1];
        [_wizardPage1ImageView setFrame:CGRectMake((_wizardPage1.bounds.size.width - image1.size.width) / 2,
                                                   kJAWizardViewImageGenericTopMargin,
                                                   image1.size.width,
                                                   image1.size.height)];
        [_wizardPage1 addSubview:_wizardPage1ImageView];
        
        _wizardPage1Label = [[UILabel alloc] init];
        _wizardPage1Label.textAlignment = NSTextAlignmentCenter;
        _wizardPage1Label.numberOfLines = -1;
        _wizardPage1Label.font = kJAWizardFont;
        _wizardPage1Label.textColor = kJAWizardFontColor;
        NSString* label1Text = STRING_WIZARD_PDV_SWIPE;
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
            label1Text = [label1Text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        }
        _wizardPage1Label.text = label1Text;
        
        CGRect wizardLabe1Rect = [STRING_WIZARD_PDV_SWIPE boundingRectWithSize:CGSizeMake(_wizardPage1.bounds.size.width - kJAWizardPDV1TextHorizontalMargin*2, 1000.0f)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [_wizardPage1Label setFrame:CGRectMake(_wizardPage1.bounds.origin.x + kJAWizardPDV1TextHorizontalMargin,
                                               CGRectGetMaxY(_wizardPage1ImageView.frame) + kJAWizardPDV1ViewTextVerticalMargin,
                                               _wizardPage1.bounds.size.width - kJAWizardPDV1TextHorizontalMargin*2,
                                               wizardLabe1Rect.size.height)];
        [_wizardPage1 addSubview:_wizardPage1Label];
        
        
        _wizardPage2 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                self.y,
                                                                self.width,
                                                                self.height)];
        
        UIImage* image2 = [UIImage imageNamed:@"wizard_tap"];
        _wizardPage2ImageView = [[UIImageView alloc] initWithImage:image2];
        [_wizardPage2ImageView setFrame:CGRectMake((_wizardPage2.bounds.size.width - image2.size.width) / 2 + 30.0f,
                                                   kJAWizardViewImageGenericTopMargin,
                                                   image2.size.width,
                                                   image2.size.height)];
        [_wizardPage2 addSubview:_wizardPage2ImageView];
        
        _wizardPage2Label = [[UILabel alloc] init];
        _wizardPage2Label.textAlignment = NSTextAlignmentCenter;
        _wizardPage2Label.numberOfLines = -1;
        _wizardPage2Label.font = kJAWizardFont;
        _wizardPage2Label.textColor = kJAWizardFontColor;
        _wizardPage2Label.text = STRING_WIZARD_PDV_TAP;
        
        CGRect wizardLabe2Rect = [STRING_WIZARD_PDV_TAP boundingRectWithSize:CGSizeMake(_wizardPage1.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2, 1000.0f)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        
        
        [_wizardPage2Label setFrame:CGRectMake(_wizardPage2.bounds.origin.x + kJAWizardPDV2TextHorizontalMargin,
                                               CGRectGetMaxY(_wizardPage2ImageView.frame) + kJAWizardPDV2ViewTextVerticalMargin,
                                               _wizardPage2.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2,
                                               wizardLabe2Rect.size.height)];
        [_wizardPage2 addSubview:_wizardPage2Label];
        
        _wizardPage3 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                self.y,
                                                                self.width,
                                                                self.height)];
        
        UIImage* image3 = [UIImage imageNamed:@"wizard_fav"];
        
        _wizardPage3ImageView = [[UIImageView alloc] initWithImage:image3];
        
        [_wizardPage3ImageView setFrame:CGRectMake(_wizardPage3.bounds.size.width - image3.size.width - 15.0f,
                                                   kJAWizardViewImageGenericSmallTopMargin,
                                                   image3.size.width,
                                                   image3.size.height)];
        [_wizardPage3 addSubview:_wizardPage3ImageView];
        
        _wizardPage3Label = [[UILabel alloc] init];
        _wizardPage3Label.textAlignment = NSTextAlignmentCenter;
        _wizardPage3Label.numberOfLines = -1;
        _wizardPage3Label.font = kJAWizardFont;
        _wizardPage3Label.textColor = kJAWizardFontColor;
        _wizardPage3Label.text = STRING_WIZARD_CATALOG_FAVORITE;
        
        CGRect wizardLabe3Rect = [STRING_WIZARD_CATALOG_FAVORITE boundingRectWithSize:CGSizeMake(_wizardPage1.bounds.size.width - kJAWizardPDV3TextHorizontalMargin*2, 1000.0f)
                                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                                           attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [_wizardPage3Label setFrame:CGRectMake(_wizardPage3.bounds.origin.x + kJAWizardPDV3TextHorizontalMargin,
                                               CGRectGetMaxY(_wizardPage3ImageView.frame) + kJAWizardPDV3ViewTextVerticalMargin,
                                               _wizardPage3.bounds.size.width - kJAWizardPDV3TextHorizontalMargin*2,
                                               wizardLabe3Rect.size.height)];
        [_wizardPage3 addSubview:_wizardPage3Label];
        
        
        _wizardPage4 = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                self.y,
                                                                self.width,
                                                                self.height)];
        
        UIImage* image4 = [UIImage imageNamed:@"wizard_tap"];
        _wizardPage4ImageView = [[UIImageView alloc] initWithImage:image4];
        [_wizardPage4ImageView setFrame:CGRectMake(15.0f,
                                                   kJAWizardViewImageGenericSmallTopMargin,
                                                   image4.size.width,
                                                   image4.size.height)];
        [_wizardPage4 addSubview:_wizardPage4ImageView];
        
        _wizardPage4Label = [[UILabel alloc] init];
        _wizardPage4Label.textAlignment = NSTextAlignmentCenter;
        _wizardPage4Label.numberOfLines = -1;
        _wizardPage4Label.font = kJAWizardFont;
        _wizardPage4Label.textColor = kJAWizardFontColor;
        _wizardPage4Label.text = STRING_WIZARD_PDV_SHARE;
        
        CGRect wizardLabe4Rect = [STRING_WIZARD_PDV_SHARE boundingRectWithSize:CGSizeMake(_wizardPage1.bounds.size.width - kJAWizardPDV4TextHorizontalMargin*2, 1000.0f)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [_wizardPage4Label setFrame:CGRectMake(_wizardPage4.bounds.origin.x + kJAWizardPDV4TextHorizontalMargin,
                                               CGRectGetMaxY(_wizardPage4ImageView.frame) + kJAWizardPDV4ViewTextVerticalMargin,
                                               _wizardPage4.bounds.size.width - kJAWizardPDV4TextHorizontalMargin*2,
                                               wizardLabe4Rect.size.height)];
        [_wizardPage4 addSubview:_wizardPage4Label];
        
        [self.pagedView setViews:[NSArray arrayWithObjects:_wizardPage1, _wizardPage2, _wizardPage3, _wizardPage4, nil]];
        
        [self reloadForFrame:self.frame];
    }
    return self;
}

- (void)setHasNoSeller:(BOOL)hasNoSeller
{
    _hasNoSeller = hasNoSeller;
    [self reloadForFrame:self.frame];
}

- (void)reloadForFrame:(CGRect)frame
{
    [super reloadForFrame:frame];
    
    CGFloat currentX = 0.0f;
    
    BOOL isLandscape = frame.size.width>frame.size.height?YES:NO;
    
    CGFloat topMargin = kJAWizardViewImageGenericTopMargin;
    CGFloat leftMargin1 = (self.bounds.size.width - _wizardPage1ImageView.frame.size.width) / 2;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        topMargin = kJAWizardViewImageGenericTopMargin_ipad - 5.0f;
        if (isLandscape) {
            topMargin = kJAWizardViewImageGenericTopMargin_landscape + 5.0f;
            leftMargin1 = kJAWizardViewFirstImageLeftMargin;
            if (_hasNoSeller) {
                topMargin -= kSellerOffset;
            }
        }
    }
    
    
    [_wizardPage1 setFrame:CGRectMake(currentX,
                                          self.y,
                                          self.width,
                                          self.height)];
    
    [_wizardPage1ImageView setFrame:CGRectMake(leftMargin1,
                                                   topMargin,
                                                   _wizardPage1ImageView.frame.size.width,
                                                   _wizardPage1ImageView.frame.size.height)];
    
    CGRect wizardLabe1Rect = [STRING_WIZARD_PDV_SWIPE boundingRectWithSize:CGSizeMake(_wizardPage1.bounds.size.width - kJAWizardPDV1TextHorizontalMargin*2, 1000.0f)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    [_wizardPage1Label setFrame:CGRectMake(_wizardPage1.bounds.origin.x + kJAWizardPDV1TextHorizontalMargin,
                                               CGRectGetMaxY(_wizardPage1ImageView.frame) + kJAWizardPDV1ViewTextVerticalMargin,
                                               _wizardPage1.bounds.size.width - kJAWizardPDV1TextHorizontalMargin*2,
                                               wizardLabe1Rect.size.height)];
    
    CGFloat leftMargin2 = (self.bounds.size.width - _wizardPage2ImageView.frame.size.width) / 2 + 30.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && isLandscape) {
        leftMargin2 = kJAWizardViewFirstImageLeftMargin + 60.0f;
    }
    
    [_wizardPage2 setFrame:CGRectMake(currentX,
                                          self.y,
                                          self.width,
                                          self.height)];
    
    [_wizardPage2ImageView setFrame:CGRectMake(leftMargin2,
                                                   topMargin,
                                                   _wizardPage2ImageView.frame.size.width,
                                                   _wizardPage2ImageView.frame.size.height)];
    
    CGRect wizardLabe2Rect = [STRING_WIZARD_PDV_TAP boundingRectWithSize:CGSizeMake(_wizardPage1.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2, 1000.0f)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    
    
    [_wizardPage2Label setFrame:CGRectMake(_wizardPage2.bounds.origin.x + kJAWizardPDV2TextHorizontalMargin,
                                               CGRectGetMaxY(_wizardPage2ImageView.frame) + kJAWizardPDV2ViewTextVerticalMargin,
                                               _wizardPage2.bounds.size.width - kJAWizardPDV2TextHorizontalMargin*2,
                                               wizardLabe2Rect.size.height)];
    
    CGFloat topMargin3 = kJAWizardViewThirdImageTopMargin;
    CGFloat leftMargin3 = self.bounds.size.width - _wizardPage3ImageView.frame.size.width - 15.0f;
    CGFloat labelTopMargin3 = kJAWizardPDV3ViewTextVerticalMargin;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && isLandscape) {
        labelTopMargin3 = kJAWizardPDV3ViewTextVerticalMargin_ipad;
        leftMargin3 = (self.bounds.size.width / 2) - _wizardPage3ImageView.frame.size.width - 15.0f ;
        topMargin3 = kJAWizardViewThirdImageTopMargin_landscape;
        if (_hasNoSeller) {
            topMargin3 -= kSellerOffset;
        }
    }
    
    [_wizardPage3 setFrame:CGRectMake(currentX,
                                          self.y,
                                          self.width,
                                          self.height)];
    [_wizardPage3ImageView setFrame:CGRectMake(leftMargin3,
                                                   topMargin3,
                                                   _wizardPage3ImageView.frame.size.width,
                                                   _wizardPage3ImageView.frame.size.height)];
    
    CGRect wizardLabe3Rect = [STRING_WIZARD_CATALOG_FAVORITE boundingRectWithSize:CGSizeMake(_wizardPage1.bounds.size.width - kJAWizardPDV3TextHorizontalMargin*2, 1000.0f)
                                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    [_wizardPage3Label setFrame:CGRectMake(_wizardPage3.bounds.origin.x + kJAWizardPDV3TextHorizontalMargin,
                                               CGRectGetMaxY(_wizardPage3ImageView.frame) + labelTopMargin3,
                                               _wizardPage3.bounds.size.width - kJAWizardPDV3TextHorizontalMargin*2,
                                               wizardLabe3Rect.size.height)];
    
    CGFloat topMargin4 = kJAWizardViewThirdImageTopMargin;
    CGFloat labelTopMargin4 = kJAWizardPDV3ViewTextVerticalMargin;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && isLandscape) {
        labelTopMargin4 = kJAWizardPDV3ViewTextVerticalMargin_ipad;
        topMargin4 = kJAWizardViewThirdImageTopMargin_landscape;
        if (_hasNoSeller) {
            topMargin4 -= kSellerOffset;
        }
    }
    
    [_wizardPage4 setFrame:CGRectMake(currentX,
                                          self.y,
                                          self.width,
                                          self.height)];
    
    [_wizardPage4ImageView setFrame:CGRectMake(kJAWizardPDV4TextHorizontalMargin,
                                                   topMargin4,
                                                   _wizardPage4ImageView.frame.size.width,
                                                   _wizardPage4ImageView.frame.size.height)];
    
    CGRect wizardLabe4Rect = [STRING_WIZARD_PDV_SHARE boundingRectWithSize:CGSizeMake(_wizardPage1.bounds.size.width - kJAWizardPDV4TextHorizontalMargin*2, 1000.0f)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    [_wizardPage4Label setFrame:CGRectMake(_wizardPage4.bounds.origin.x + kJAWizardPDV4TextHorizontalMargin,
                                               CGRectGetMaxY(_wizardPage4ImageView.frame) + labelTopMargin4,
                                               _wizardPage4.bounds.size.width - kJAWizardPDV4TextHorizontalMargin*2,
                                               wizardLabe4Rect.size.height)];
    
    if (RI_IS_RTL) {
        [_wizardPage1 flipAllSubviews];
        [_wizardPage1ImageView flipViewImage];
        [_wizardPage2 flipAllSubviews];
        [_wizardPage2ImageView flipViewImage];
        [_wizardPage3 flipAllSubviews];
        [_wizardPage3ImageView flipViewImage];
        [_wizardPage4 flipAllSubviews];
        [_wizardPage4ImageView flipViewImage];
    }
}

@end

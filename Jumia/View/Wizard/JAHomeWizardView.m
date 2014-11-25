//
//  JAHomeWizardView.m
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAHomeWizardView.h"

@interface JAHomeWizardView ()

@property (nonatomic, strong) UIView *wizardPage;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel *wizardLabel;

@end

@implementation JAHomeWizardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.wizardPage = [[UIView alloc] initWithFrame:self.scrollView.bounds];
        [self.scrollView addSubview:self.wizardPage];
        
        UIImage* image = [UIImage imageNamed:@"wizard_swipe"];
        self.imageView = [[UIImageView alloc] initWithImage:image];
        [self.imageView setFrame:CGRectMake((self.wizardPage.bounds.size.width - image.size.width) / 2,
                                            kJAWizardViewImageGenericTopMargin,
                                            image.size.width,
                                            image.size.height)];
        [self.wizardPage addSubview:self.imageView];
        
        self.wizardLabel = [[UILabel alloc] init];
        self.wizardLabel.textAlignment = NSTextAlignmentCenter;
        self.wizardLabel.numberOfLines = 0;
        self.wizardLabel.font = kJAWizardFont;
        self.wizardLabel.textColor = kJAWizardFontColor;
        self.wizardLabel.text = STRING_WIZARD_HOME;
        [self.wizardLabel sizeToFit];
        
        CGRect wizardLabelRect = [STRING_WIZARD_HOME boundingRectWithSize:CGSizeMake(self.wizardPage.bounds.size.width - kJAWizardHomeTextHorizontalMargin*2, 1000.0f)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [self.wizardLabel setFrame:CGRectMake(self.wizardPage.bounds.origin.x + kJAWizardHomeTextHorizontalMargin,
                                              CGRectGetMaxY(self.imageView.frame) + kJAWizardHomeViewTextVerticalMargin,
                                              self.wizardPage.bounds.size.width - kJAWizardHomeTextHorizontalMargin*2,
                                              wizardLabelRect.size.height)];
        
        [self.wizardPage addSubview:self.wizardLabel];
    }
    return self;
}

- (void)reloadForFrame:(CGRect)frame
{
    [super reloadForFrame:frame];
    
    [self.wizardPage setFrame:self.scrollView.bounds];
    
    [self.imageView setFrame:CGRectMake((self.wizardPage.bounds.size.width - self.imageView.frame.size.width) / 2,
                                        kJAWizardViewImageGenericTopMargin,
                                        self.imageView.frame.size.width,
                                        self.imageView.frame.size.height)];
    
    CGRect wizardLabelRect = [STRING_WIZARD_HOME boundingRectWithSize:CGSizeMake(self.wizardPage.bounds.size.width - kJAWizardHomeTextHorizontalMargin*2, 1000.0f)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
    
    [self.wizardLabel setFrame:CGRectMake(self.wizardPage.bounds.origin.x + kJAWizardHomeTextHorizontalMargin,
                                          CGRectGetMaxY(self.imageView.frame) + kJAWizardHomeViewTextVerticalMargin,
                                          self.wizardPage.bounds.size.width - kJAWizardHomeTextHorizontalMargin*2,
                                          wizardLabelRect.size.height)];
}

@end

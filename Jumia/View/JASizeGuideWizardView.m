//
//  JASizeGuideWizardView.m
//  Jumia
//
//  Created by jcarreira on 16/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASizeGuideWizardView.h"


@interface JASizeGuideWizardView()

@property (nonatomic, strong) UIView *wizardView;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel *label;

@end



@implementation JASizeGuideWizardView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        self.wizardView = [[UIView alloc] initWithFrame:self.bounds];
        
        CGFloat topMargin = kJAWizardViewImageGenericTopMargin;
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
        {
            topMargin = kJAWizardViewImageGenericTopMargin_ipad;
        }
        
        UIImage *image = [UIImage imageNamed: @"wizard_pinch"];
        self.imageView = [[UIImageView alloc] initWithImage:image];
        [self.imageView setFrame:CGRectMake((self.wizardView.bounds.size.width - image.size.width) / 2,
                                            topMargin,
                                            image.size.width,
                                            image.size.height)];
        [self.wizardView addSubview:self.imageView];
        
        
        self.label = [[UILabel alloc] init];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        self.label.font = kJAWizardFont;
        self.label.textColor = kJAWizardFontColor;
        self.label.text = STRING_WIZARD_SIZE_GUIDE_PINCH;
        [self.label sizeToFit];
        
        CGRect wizardLabelRect = [STRING_WIZARD_SIZE_GUIDE_PINCH boundingRectWithSize:CGSizeMake(self.wizardView.bounds.size.width - kJAWizardSizeGuideViewTextHorizontalMargin * 2, 1000.0f)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName:kJAWizardFont}
                                                                  context:nil];
        
        [self.wizardView setFrame:CGRectMake(self.wizardView.bounds.origin.x + kJAWizardSizeGuideViewTextHorizontalMargin,
                                              CGRectGetMaxY(self.imageView.frame) + kJAWizardHomeViewTextVerticalMargin,
                                              self.wizardView.bounds.size.width - kJAWizardSizeGuideViewTextHorizontalMargin * 2,
                                              wizardLabelRect.size.height)];
        
        [self.wizardView addSubview:self.label];
        
        [self.pagedView setViews:[NSArray arrayWithObject:self.wizardView]];
        
        [self reloadForFrame:frame];
    }
    
    return self;
}


-(void)reloadForFrame:(CGRect)frame
{
    [super reloadForFrame:frame];
    
    [self.wizardView setFrame:self.bounds];
    
    CGFloat topMargin = kJAWizardViewImageGenericTopMargin;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        topMargin = kJAWizardViewImageGenericTopMargin_ipad;
    }
    
    [self.imageView setFrame:CGRectMake((self.wizardView.bounds.size.width - self.imageView.frame.size.width) / 2,
                                        topMargin,
                                        self.imageView.frame.size.width,
                                        self.imageView.frame.size.height)];
    
    CGRect wizardLabelRect = [STRING_WIZARD_HOME boundingRectWithSize:CGSizeMake(self.wizardView.bounds.size.width - kJAWizardHomeTextHorizontalMargin * 2, 1000.0f)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName:kJAWizardFont}
                                                              context:nil];
    
    [self.label setFrame:CGRectMake(self.wizardView.bounds.origin.x + kJAWizardHomeTextHorizontalMargin,
                                          CGRectGetMaxY(self.imageView.frame) + kJAWizardHomeViewTextVerticalMargin,
                                          self.wizardView.bounds.size.width - kJAWizardHomeTextHorizontalMargin * 2,
                                          wizardLabelRect.size.height)];
    
    if (RI_IS_RTL) {
        [self.wizardView flipAllSubviews];
    }
}



@end

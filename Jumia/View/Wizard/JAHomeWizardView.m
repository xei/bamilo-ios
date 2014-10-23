//
//  JAHomeWizardView.m
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAHomeWizardView.h"

@implementation JAHomeWizardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView* wizardPage = [[UIView alloc] initWithFrame:self.scrollView.bounds];
        [self.scrollView addSubview:wizardPage];
        
        UIImage* image = [UIImage imageNamed:@"wizard_swipe"];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setFrame:CGRectMake((wizardPage.bounds.size.width - image.size.width) / 2,
                                       kJAWizardViewImageGenericTopMargin,
                                       imageView.frame.size.width,
                                       imageView.frame.size.height)];
        [wizardPage addSubview:imageView];
        
        UILabel* wizardLabel = [[UILabel alloc] init];
        wizardLabel.textAlignment = NSTextAlignmentCenter;
        wizardLabel.numberOfLines = 0;
        wizardLabel.font = kJAWizardFont;
        wizardLabel.textColor = kJAWizardFontColor;
        wizardLabel.text = STRING_WIZARD_HOME;
        [wizardLabel sizeToFit];
        
        CGRect wizardLabelRect = [STRING_WIZARD_HOME boundingRectWithSize:CGSizeMake( wizardPage.bounds.size.width - kJAWizardHomeTextHorizontalMargin*2, 1000.0f)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName:kJAWizardFont} context:nil];
        
        [wizardLabel setFrame:CGRectMake(wizardPage.bounds.origin.x + kJAWizardHomeTextHorizontalMargin,
                                         CGRectGetMaxY(imageView.frame) + kJAWizardHomeViewTextVerticalMargin,
                                         wizardPage.bounds.size.width - kJAWizardHomeTextHorizontalMargin*2,
                                         wizardLabelRect.size.height)];
        
        [wizardPage addSubview:wizardLabel];
    }
    return self;
}

@end

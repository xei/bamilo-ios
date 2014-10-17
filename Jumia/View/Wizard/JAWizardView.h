//
//  JAWizardView.h
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJAWizardViewImageGenericTopMargin 60.0f
#define kJAWizardViewTextMargin 30.0f
#define kJAWizardFont [UIFont fontWithName:@"HelveticaNeue" size:18.0f]
#define kJAWizardFontColor UIColorFromRGB(0xc3c3c3)

@interface JAWizardView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, retain)UIPageControl* pageControl;

@end

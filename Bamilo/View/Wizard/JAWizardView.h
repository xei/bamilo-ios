//
//  JAWizardView.h
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAPagedView.h"

#define kJAWizardViewImageGenericTopMargin 80.0f
#define kJAWizardViewImageGenericTopMargin_ipad 160.0f
#define kJAWizardViewImageGenericTopMargin_landscape 250.0f
#define kJAWizardViewImageGenericSmallTopMargin 50.0f

#define kJAWizardHomeTextHorizontalMargin 35.0f
#define kJAWizardHomeViewTextVerticalMargin 32.0f
#define kJAWizardCatalog1TextHorizontalMargin 35.0f
#define kJAWizardCatalog1ViewTextVerticalMargin 32.0f
#define kJAWizardCatalog2TextHorizontalMargin 25.0f
#define kJAWizardCatalog2ViewTextVerticalMargin 72.0f
#define kJAWizardCatalog2ViewTextVerticalMargin_ipad 125.0f
#define kJAWizardSizeGuideViewTextHorizontalMargin 40.0f
#define kJAWizardSizeGuideViewTextVerticalMargin 32.0f

#define kJAWizardPDV1TextHorizontalMargin 35.0f
#define kJAWizardPDV1ViewTextVerticalMargin 32.0f
#define kJAWizardPDV2TextHorizontalMargin 25.0f
#define kJAWizardPDV2ViewTextVerticalMargin 32.0f
#define kJAWizardPDV3TextHorizontalMargin 25.0f
#define kJAWizardPDV3ViewTextVerticalMargin 72.0f
#define kJAWizardPDV3ViewTextVerticalMargin_ipad 110.0f
#define kJAWizardPDV4TextHorizontalMargin 25.0f
#define kJAWizardPDV4ViewTextVerticalMargin 72.0f

#define kJAWizardFont [UIFont fontWithName:kFontRegularName size:18.0f]

#define kJAWizardButtonBottomMargin 10.0f
#define kJAWizardButtonBottomMargin_ipad_portrait 100.0f
#define kJAWizardButtonBottomMargin_ipad_landscape 50.0f

@interface JAWizardView : UIView
//<UIScrollViewDelegate>

//@property (nonatomic, strong)UIScrollView* scrollView;
//@property (nonatomic, retain)UIPageControl* pageControl;
//@property (nonatomic, strong)UIButton* dismissButton;
@property (nonatomic, strong) JAPagedView *pagedView;

- (void)reloadForFrame:(CGRect)frame;

@end

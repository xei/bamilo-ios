//
//  JAWizardView.m
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAWizardView.h"

@interface JAWizardView()

@property (nonatomic, strong)UIButton* dismissButton;

@end

@implementation JAWizardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.85f];
        
        CGFloat bottomMargin;
        UIImage* buttonImageNormal;
        UIImage* buttonImageHightlight;
        UIImage* buttonImageDisabled;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (frame.size.height > frame.size.width) {
                bottomMargin = kJAWizardButtonBottomMargin_ipad_portrait;
            } else {
                bottomMargin = kJAWizardButtonBottomMargin_ipad_landscape;
            }
            buttonImageNormal = [UIImage imageNamed:@"orangeQuarterLandscape_normal"];
            buttonImageHightlight = [UIImage imageNamed:@"orangeQuarterLandscape_highlighted"];
            buttonImageDisabled = [UIImage imageNamed:@"orangeQuarterLandscape_disabled"];
        } else {
            bottomMargin = kJAWizardButtonBottomMargin;
            buttonImageNormal = [UIImage imageNamed:@"orangeHalf_normal"];
            buttonImageHightlight = [UIImage imageNamed:@"orangeHalf_highlighted"];
            buttonImageDisabled = [UIImage imageNamed:@"orangeHalf_disabled"];
        }
        self.dismissButton = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - buttonImageNormal.size.width) / 2,
                                                                        self.frame.size.height - bottomMargin - buttonImageNormal.size.height,
                                                                        buttonImageNormal.size.width,
                                                                        buttonImageNormal.size.height)];
        [self.dismissButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        [self.dismissButton setBackgroundImage:buttonImageHightlight forState:UIControlStateHighlighted];
        [self.dismissButton setBackgroundImage:buttonImageDisabled forState:UIControlStateDisabled];
        [self.dismissButton setTitle:STRING_GOT_IT forState:UIControlStateNormal];
        self.dismissButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        [self.dismissButton setTitleColor:JAButtonTextOrange forState:UIControlStateNormal];
        [self.dismissButton addTarget:self action:@selector(dismissButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.dismissButton];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                           self.dismissButton.frame.origin.y - 10.0f - 10.0f,
                                                                           self.bounds.size.width,
                                                                           10.0f)];
        [self addSubview:self.pageControl];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                         self.bounds.origin.y,
                                                                         self.bounds.size.width,
                                                                         self.pageControl.frame.origin.y)];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
    }
    return self;
}

- (void)dismissButtonPressed
{
    [self removeFromSuperview];
}

- (void)reloadForFrame:(CGRect)frame
{
    [self setFrame:frame];
    
    CGFloat bottomMargin;
    UIImage* buttonImageNormal;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (frame.size.height > frame.size.width) {
            bottomMargin = kJAWizardButtonBottomMargin_ipad_portrait;
        } else {
            bottomMargin = kJAWizardButtonBottomMargin_ipad_landscape;
        }
        buttonImageNormal = [UIImage imageNamed:@"orangeQuarterLandscape_normal"];
    } else {
        bottomMargin = kJAWizardButtonBottomMargin;
        buttonImageNormal = [UIImage imageNamed:@"orangeHalf_normal"];
    }
    [self.dismissButton setFrame:CGRectMake((self.frame.size.width - buttonImageNormal.size.width) / 2,
                                            self.frame.size.height - bottomMargin - buttonImageNormal.size.height,
                                            buttonImageNormal.size.width,
                                            buttonImageNormal.size.height)];
    
    [self.pageControl setFrame:CGRectMake(self.bounds.origin.x,
                                         self.dismissButton.frame.origin.y - 10.0f - 10.0f,
                                         self.bounds.size.width,
                                          10.0f)];
    
    [self.scrollView setFrame:CGRectMake(self.bounds.origin.x,
                                         self.bounds.origin.y,
                                         self.bounds.size.width,
                                         self.pageControl.frame.origin.y)];

}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //add 0.5 to make sure we scroll the indicators with the middle of the page
    self.pageControl.currentPage = (scrollView.contentOffset.x / self.scrollView.frame.size.width) + 0.5;
}

@end

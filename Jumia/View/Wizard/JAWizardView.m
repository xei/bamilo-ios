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
        
        UIImage* buttonImageNormal = [UIImage imageNamed:@"orangeHalf_normal"];
        UIImage* buttonImageHightlight = [UIImage imageNamed:@"orangeHalf_highlight"];
        UIImage* buttonImageDisabled = [UIImage imageNamed:@"orangeHalf_disabled"];
        self.dismissButton = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - buttonImageNormal.size.width) / 2,
                                                                        self.frame.size.height - 10.0f - buttonImageNormal.size.height,
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

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //add 0.5 to make sure we scroll the indicators with the middle of the page
    self.pageControl.currentPage = (scrollView.contentOffset.x / self.scrollView.frame.size.width) + 0.5;
}

@end

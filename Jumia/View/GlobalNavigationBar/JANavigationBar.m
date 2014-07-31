//
//  JANavigationBar.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANavigationBar.h"

@interface JANavigationBar ()

@end

@implementation JANavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.navigationBarView = [JANavigationBarView getNewNavBarView];
        [self.viewForBaselineLayout addSubview:self.navigationBarView];
        
        [self.navigationBarView.leftButton addTarget:self
                                              action:@selector(openMenu)
                                    forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)openMenu
{
    [self.customDelegate customNavigationBarOpenMenu];
}

- (void)changeNavigationBarTitle:(NSString *)newTitle
{
    self.navigationBarView.logoImageView.hidden = YES;
    self.navigationBarView.titleLabel.text = newTitle;
    self.navigationBarView.titleLabel.hidden = NO;
}

- (void)changedToHomeViewController
{
    self.navigationBarView.logoImageView.hidden = NO;
    self.navigationBarView.titleLabel.hidden = YES;
}

@end

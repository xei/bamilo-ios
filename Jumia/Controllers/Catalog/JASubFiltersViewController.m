//
//  JASubFiltersViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 13/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASubFiltersViewController.h"

@interface JASubFiltersViewController ()

@end

@implementation JASubFiltersViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffMenuSwipePanelNotification
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneButtonPressed)
                                                 name:kDidPressDoneNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonPressed)
                                                 name:kDidPressBackNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)doneButtonPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(isClosing:)]) {
        [self.delegate isClosing:self];
    }
}

- (void)backButtonPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(isClosing:)]) {
        [self.delegate isClosing:self];
    }
}

@end

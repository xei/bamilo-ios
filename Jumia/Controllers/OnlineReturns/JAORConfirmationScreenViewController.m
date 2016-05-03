//
//  JAORConfirmationScreenViewController.m
//  Jumia
//
//  Created by Jose Mota on 03/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORConfirmationScreenViewController.h"
#import "JACenterNavigationController.h"
#import "JAButton.h"

@interface JAORConfirmationScreenViewController ()

@property (nonatomic, strong) JAButton *submitButton;

@end

@implementation JAORConfirmationScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = NO;
    
    self.submitButton = [[JAButton alloc] initButtonWithTitle:@"SUBMIT"];
    [self.submitButton addTarget:self action:@selector(goToNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
    [self.submitButton setFrame:CGRectMake(0, 0, self.view.width, kBottomDefaultHeight)];
    [self.submitButton setYBottomAligned:0.f];
}

- (void)goToNext
{
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.submitButton setWidth:self.view.width];
    [self.submitButton setYBottomAligned:0.f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.submitButton setWidth:self.view.width];
    [self.submitButton setYBottomAligned:0.f];
}

@end

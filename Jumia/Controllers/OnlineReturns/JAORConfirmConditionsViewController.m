//
//  JAORConfirmConditionsViewController.m
//  Jumia
//
//  Created by Jose Mota on 03/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORConfirmConditionsViewController.h"
#import "JACenterNavigationController.h"
#import "JAButton.h"

@interface JAORConfirmConditionsViewController ()

@property (nonatomic, strong) JAButton *submitButton;

@end

@implementation JAORConfirmConditionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = NO;
    
    self.submitButton = [[JAButton alloc] initButtonWithTitle:@"OK, GOT IT!"];
    [self.submitButton addTarget:self action:@selector(goToNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
    [self.submitButton setFrame:CGRectMake(0, 0, self.view.width, kBottomDefaultHeight)];
    [self.submitButton setYBottomAligned:0.f];
}

- (void)goToNext
{
    [[JACenterNavigationController sharedInstance] goToOnlineReturnsConfirmScreen];
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

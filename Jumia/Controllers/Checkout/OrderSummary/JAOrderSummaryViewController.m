//
//  JAOrderSummaryViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAOrderSummaryViewController.h"
#import "JAButtonWithBlur.h"
#import "RICheckout.h"
@interface JAOrderSummaryViewController ()

// Bottom view
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@end

@implementation JAOrderSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.title = @"Checkout";
    
    [self setupViews];
}

-(void)setupViews
{
    self.bottomView = [[JAButtonWithBlur alloc] init];
    [self.bottomView setFrame:CGRectMake(0.0f, self.view.frame.size.height - 64.0f - self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
    [self.bottomView addButton:@"Next" target:self action:@selector(nextStepButtonPressed)];
    
    [self.view addSubview:self.bottomView];
}

-(void)nextStepButtonPressed
{
    [self showLoading];
    
    [RICheckout finishCheckoutWithSuccessBlock:^(RICheckout *checkout) {
        NSLog(@"SUCCESS Finishing checkout");
        
        NSLog(@"%@ - %d - %@", checkout.nextStep, checkout.paymentInformation.type, checkout.paymentInformation.method);
        
        [self hideLoading];
    } andFailureBlock:^(NSArray *errorMessages) {
        
        NSLog(@"FAILED Finishing checkout");
        [self hideLoading];
    }];
}

@end

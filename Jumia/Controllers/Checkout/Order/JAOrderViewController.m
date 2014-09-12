//
//  JAOrderViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAOrderViewController.h"
#import "JAButtonWithBlur.h"
#import "RICheckout.h"
@interface JAOrderViewController ()

// Bottom view
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@end

@implementation JAOrderViewController

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
        
        if(VALID_NOTEMPTY(checkout.paymentInformation, RIPaymentInformation))
        {
            if(RIPaymentInformationCheckoutEnded == checkout.paymentInformation.type)
            {
                NSLog(@"DOES NOT NEED EXTERNAL WEBVIEW");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutThanksScreenNotification
                                                                    object:nil
                                                                  userInfo:nil];
                
            }
            else
            {
                NSLog(@"NEEDS EXTERNAL WEBVIEW %d - %@", checkout.paymentInformation.type, checkout.paymentInformation.method);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutExternalPaymentsScreenNotification
                                                                    object:nil
                                                                  userInfo:nil];
            }
        }
        
        [self hideLoading];
    } andFailureBlock:^(NSArray *errorMessages) {
        
        NSLog(@"FAILED Finishing checkout");
        [self hideLoading];
    }];
}

@end

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
    
    self.navBarLayout.title = STRING_CHECKOUT;
    
    self.navBarLayout.showCartButton = NO;
    
    [self setupViews];
}

-(void)setupViews
{
    self.bottomView = [[JAButtonWithBlur alloc] init];
    [self.bottomView setFrame:CGRectMake(0.0f, self.view.frame.size.height - 64.0f - self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
    [self.bottomView addButton:STRING_NEXT target:self action:@selector(nextStepButtonPressed)];
    
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
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[checkout.orderNr, checkout] forKeys:@[@"order_number", @"checkout"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutThanksScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
                
            }
            else
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[checkout] forKeys:@[@"checkout"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutExternalPaymentsScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
        }
        
        [self hideLoading];
    } andFailureBlock:^(NSArray *errorMessages) {
        
        NSLog(@"FAILED Finishing checkout");
        [self hideLoading];
    }];
}

@end

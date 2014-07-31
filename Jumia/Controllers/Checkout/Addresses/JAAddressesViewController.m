//
//  JAAddressesViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAddressesViewController.h"
#import "RICheckout.h"
#import "RIAddress.h"
#import "RIForm.h"
#import "RIField.h"
#import "JAUtils.h"

@interface JAAddressesViewController ()

@property (nonatomic, strong) NSString *billingAddressId;
@property (nonatomic, strong) NSString *shippingAddressId;

@end

@implementation JAAddressesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.chooseBillingAndShippingAddressesAndGoToNextStep setTitle:@"Login and go to addresses" forState:UIControlStateNormal];
    [self.chooseBillingAndShippingAddressesAndGoToNextStep sizeToFit];
    
    [self.chooseBillingAndShippingAddressesAndGoToNextStep addTarget:self action:@selector(chooseBillingAndShippingAddressesAndGoToNextStepAction) forControlEvents:UIControlEventTouchUpInside];
    [self.chooseBillingAndShippingAddressesAndGoToNextStep setEnabled:NO];
    
    [self showLoading];
    [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
        NSLog(@"Get customer addresses with success");
        NSDictionary *addressDictionary = adressList;
        if(VALID_NOTEMPTY(addressDictionary, NSDictionary))
        {
            RIAddress *billingAddress = [addressDictionary objectForKey:@"billing"];
            if(VALID_NOTEMPTY(billingAddress, RIAddress))
            {
                self.billingAddressId = [billingAddress uid];
            }
            
            RIAddress *shippingAddress = [addressDictionary objectForKey:@"shipping"];
            if(VALID_NOTEMPTY(shippingAddress, RIAddress))
            {
                self.shippingAddressId = [shippingAddress uid];
            }
        }
        
        [self.chooseBillingAndShippingAddressesAndGoToNextStep setEnabled:YES];
        [self hideLoading];
    } andFailureBlock:^(NSArray *errorMessages) {
        NSLog(@"Failed to get customer addresses");
        [self hideLoading];
    }];
}

- (void) chooseBillingAndShippingAddressesAndGoToNextStepAction
{
    [self showLoading];
    
    [RICheckout getBillingAddressFormWithSuccessBlock:^(RICheckout *checkout) {
        NSLog(@"Get billing address form with success");
        RIForm *billingForm = checkout.billingAddressForm;
        
        for (RIField *field in [billingForm fields])
        {
            if([@"billingForm[billingAddressId]" isEqualToString:[field name]])
            {
                field.value = self.billingAddressId;
            }
            else if([@"billingForm[shippingAddressId]" isEqualToString:[field name]])
            {
                field.value = self.shippingAddressId;
            }
            else if([@"billingForm[shippingAddressDifferent" isEqualToString:[field name]])
            {
                field.value = [self.billingAddressId isEqualToString:self.shippingAddressId] ? @"0" : @":1";
            }
        }
        
        [RICheckout setBillingAddress:billingForm successBlock:^(RICheckout *checkout) {
            NSLog(@"Set billing address form with success");
            
            UIViewController *controller = [JAUtils getCheckoutNextStepViewController:checkout.nextStep inStoryboard:self.storyboard];
            [self.navigationController pushViewController:controller
                                                 animated:YES];
            [self hideLoading];
        } andFailureBlock:^(NSArray *errorMessages) {
            NSLog(@"Failed to set billing address form");
            [self hideLoading];
        }];
    } andFailureBlock:^(NSArray *errorMessages) {
        NSLog(@"Failed to get billing address form");
        [self hideLoading];
    }];
}

@end

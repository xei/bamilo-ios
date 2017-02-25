//
//  CheckoutAddressViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"
#import "CheckoutAddressViewController.h"
#import "CheckoutProgressViewButtonModel.h"
#import "ViewControllerManager.h"
#import "AddressTableViewController.h"
#import "AddressList.h"

@interface CheckoutAddressViewController() <AddressTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *addressListContainerView;
@end

@implementation CheckoutAddressViewController {
@private
    AddressTableViewController *_addressTableViewController;
    NSMutableArray *_addresses;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _addressTableViewController = (AddressTableViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"AddressTableViewController"];
    _addressTableViewController.titleHeaderText = STRING_PLEASE_CHOOSE_YOUR_ADDRESS;
    _addressTableViewController.options = (ADDRESS_CELL_EDIT | ADDRESS_CELL_SELECT);
    _addressTableViewController.delegate = self;
    [_addressTableViewController addInto:self ofView:self.addressListContainerView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DataManager sharedInstance] getMultistepAddressList:self completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            [self publishScreenLoadTime];
        }
    }];
}

#pragma mark - Overrides
-(NSString *)getTitleForContinueButton {
    return STRING_CONTINUE_SHOPPING;
}

-(NSString *)getNextStepViewControllerSegueIdentifier:(NSString *)serviceIdentifier {
    return @"pushAddressToConfirmation";
}

-(void)updateNavBar {
    [super updateNavBar];

    self.navBarLayout.title = STRING_CHOOSE_ADDRESS;
}

-(void)performPreDepartureAction:(CheckoutActionCompletion)completion {
    if(_addresses.count == 0) {
        completion(nil, NO);
    } else {
        Address *selectedAddress = [_addresses objectAtIndex:0];
        Address *billingAddress = selectedAddress;
        
        [[DataManager sharedInstance] setMultistepAddress:self forShipping:selectedAddress.uid billing:billingAddress.uid completion:^(id data, NSError *error) {
            if(error == nil && completion != nil) {
                MultistepEntity *multistepEntity = (MultistepEntity *)data;
                completion(multistepEntity.nextStep, YES);
            } else {
                [self showNotificationBar:error isSuccess:NO];
                completion(nil, NO);
            }
        }];
    }
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING]
    ];
}

#pragma mark - AddressTableViewControllerDelegate
-(void)addressEditButtonTapped:(id)sender {
    [[ViewControllerManager centerViewController] requestNavigateToNib:@"AddressEditViewController" ofStoryboard:@"Main" useCache:NO args:@{ kAddress: (Address *)sender }];
}

-(BOOL)addressSelected:(Address *)address {
    [[DataManager sharedInstance] setDefaultAddress:self address:address isBilling:NO completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:1];
            [_addressTableViewController scrollToTop];
        }
    }];
    
    return YES;
}

- (void)addAddressTapped {
    [[ViewControllerManager centerViewController] requestNavigateToNib:@"AddressEditViewController" ofStoryboard:@"Main" useCache:NO args:nil];
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        //GET ADDRESS LIST
        case 0: {
            self.cart = (RICart *)data;
            _addresses = [AddressTableViewController bindAddresses:self.cart.customerEntity.addressList];
            [_addressTableViewController updateWithModel:_addresses];
        }
        break;
        
        //UPDATED DEFAULT ADDRESS
        case 1: {
            AddressList *_addressList = (AddressList *)data;
            _addresses = [AddressTableViewController bindAddresses:_addressList];
            [_addressTableViewController updateWithModel:_addresses];
        }
        break;
    }
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    return @"CheckoutAddresses";
}

@end

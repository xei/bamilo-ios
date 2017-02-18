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
    NSMutableArray *_addresses;
    AddressTableViewController *_addressTableViewController;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _addressTableViewController = (AddressTableViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"AddressTableViewController"];
    _addressTableViewController.titleHeaderText = STRING_PLEASE_CHOOSE_YOUR_ADDRESS;
    _addressTableViewController.options = (ADDRESS_CELL_EDIT | ADDRESS_CELL_SELECT);
    _addressTableViewController.delegate = self;
    [_addressTableViewController addInto:self ofView:self.addressListContainerView];
    
    _addresses = [NSMutableArray new];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self asyncGetMultistepAddressList];
}

#pragma mark - Overrides
-(NSString *)getNextStepViewControllerSegueIdentifier:(NSString *)serviceIdentifier {
    return @"pushAddressToConfirmation";
}

-(void)updateNavBar {
    [super updateNavBar];

    self.navBarLayout.title = STRING_CHOOSE_ADDRESS;
}

-(void)performPreDepartureAction:(CheckoutActionCompletion)completion {
    Address *selectedAddress = [_addresses objectAtIndex:0];
    Address *billingAddress = selectedAddress;
    
    [[DataManager sharedInstance] setMultistepAddress:self forShipping:selectedAddress.uid billing:billingAddress.uid completion:^(id data, NSError *error) {
        if(error == nil && completion != nil) {
            MultistepEntity *multistepEntity = (MultistepEntity *)data;
            completion(multistepEntity.nextStep);
        }
    }];
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
-(BOOL)addressSelected:(Address *)address {
    [[DataManager sharedInstance] setDefaultAddress:self address:address isBilling:NO completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:1];
        }
    }];
    
    return YES;
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        //GET ADDRESS LIST
        case 0: {
            self.cart = (RICart *)data;
            
            [self bindAddresses:self.cart.customerEntity.addressList];
        }
        break;
            
        //CHANGED DEFAULT ADDRESS
        case 1: {
            [self asyncGetMultistepAddressList];
        }
        break;
    }
}

#pragma mark - Helpers
-(void) asyncGetMultistepAddressList {
    [[DataManager sharedInstance] getMultistepAddressList:self completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
        }
    }];
}

-(void) bindAddresses:(AddressList *)addressList {
    [_addresses removeAllObjects];
    
    if(addressList) {
        if(addressList.shipping) {
            [_addresses addObject:addressList.shipping];
        }
        
        for(Address *otherAddress in addressList.other) {
            [_addresses addObject:otherAddress];
        }
        
        [_addressTableViewController updateWithModel:_addresses];
    }
}

@end

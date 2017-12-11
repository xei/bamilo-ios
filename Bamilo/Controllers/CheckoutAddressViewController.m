//
//  CheckoutAddressViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutAddressViewController.h"
#import "CheckoutProgressViewButtonModel.h"
#import "Bamilo-Swift.h"
#import "AddressTableViewController.h"
#import "AddressList.h"
#import "Bamilo-Swift.h"
#import "AddressEditViewController.h"

@interface CheckoutAddressViewController() <AddressTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *addressListContainerView;
@end

@implementation CheckoutAddressViewController {
@private
    AddressTableViewController *_addressTableViewController;
    NSMutableArray *_addresses;
    BOOL isEmptyList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _addressTableViewController = (AddressTableViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"AddressTableViewController"];
    _addressTableViewController.titleHeaderText = STRING_PLEASE_CHOOSE_YOUR_ADDRESS;
    _addressTableViewController.options = (ADDRESS_CELL_EDIT | ADDRESS_CELL_SELECT);
    _addressTableViewController.delegate = self;
    [_addressTableViewController addInto:self ofView:self.addressListContainerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.viewIsDisappearing) {
        [self getContent:nil];
    }
}

- (void)getContent:(void(^)(BOOL))callBack {
    [DataAggregator getMultistepAddressList:self completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            [self setIsStepValid:_addresses.count];
            if(self.cart.cartEntity.shippingAddress) {
                Address *_addressToSelect = [self getAddressById:self.cart.cartEntity.shippingAddress.uid];
                [self updateSelectedAddress:_addressToSelect];
            }
            [_addressTableViewController updateWithModel:_addresses];
            [self publishScreenLoadTime];
            [TrackerManager postEventWithSelector:[EventSelectors checkoutStartSelector] attributes:[EventAttributes checkoutStartWithCart:data]];
            if (callBack) callBack(YES);
        } else {
            if (callBack) callBack(NO);
            [self errorHandler:error forRequestID:0];
        }
    }];
}
#pragma mark - Overrides
- (NSString *)getTitleForContinueButton {
    return STRING_CONTINUE_SHOPPING;
}

- (NSString *)getNextStepViewControllerSegueIdentifier:(NSString *)serviceIdentifier {
    return @"pushAddressToConfirmation";
}

- (void)performPreDepartureAction:(CheckoutActionCompletion)completion {
    if(_addresses.count == 0) {
        completion(nil, NO);
    } else {
        Address *_selectedAddress = [self getSelectedAddress];
        if (_selectedAddress) {
            [DataAggregator setDefaultAddress:self address:_selectedAddress isBilling:NO type:RequestExecutionTypeContainer completion:^(id _Nullable data , NSError * _Nullable error) {
                if(error == nil) {
                    [DataAggregator setMultistepAddress:self shipping:_selectedAddress.uid billing:_selectedAddress.uid completion:^(id data, NSError *error) {
                        if(error == nil && completion != nil) {
                            MultistepEntity *multistepEntity = (MultistepEntity *)data;
                            completion(multistepEntity.nextStep, YES);
                        } else {
                            if (![Utility handleErrorMessagesWithError:error viewController:self]) {
                                [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
                            }
                            completion(nil, NO);
                        }
                    }];
                } else {
                    if (![Utility handleErrorMessagesWithError:error viewController:self]) {
                        [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
                    }
                }
            }];
        } else {
            //show something to user to select from avaiable addresses
        }
    }
}

#pragma mark - CheckoutProgressViewDelegate
- (NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING]
    ];
}

#pragma mark - AddressTableViewControllerDelegate
- (void)addressEditButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"showCreateEditAddress" sender:sender];
}

- (BOOL)addressSelected:(Address *)address {
    NSArray<NSIndexPath *> *_indexPathsToRefresh = [self updateSelectedAddress:address];
    if(_indexPathsToRefresh) {
        [self updateSelectedAddressAppearance:_indexPathsToRefresh];
    }
    return YES;
}

- (void)addAddressTapped {
    [self showAddNewAddressWithAnimation:NO];
}

- (void)showAddNewAddressWithAnimation:(BOOL)fromEmptyList {
    isEmptyList = fromEmptyList;
    [self performSegueWithIdentifier:@"showCreateEditAddress" sender:nil];
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        //GET ADDRESS LIST
        case 0: {
            self.cart = (RICart *)data;
            _addresses = [AddressTableViewController bindAddresses:self.cart.customerEntity.addressList];
            if (!_addresses.count) {
                [self showAddNewAddressWithAnimation:YES];
            }
        }
        break;
    }
}

- (void)retryAction:(RetryHandler)callBack forRequestId:(int)rid {
    [self getContent:^(BOOL success) {
        callBack(success);
    }];
}

- (void)errorHandler:(NSError *)error forRequestID:(int)rid {
    if (![Utility handleErrorMessagesWithError:error viewController:self]) {
        [self handleGenericErrorCodesWithErrorControlView:(int)error.code forRequestID:rid];
    }
}

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"CheckoutAddresses";
}

#pragma mark - Helpers
-(Address *)getSelectedAddress {
    NSArray *_filteredAddress = [_addresses filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.isDefaultShipping == YES"]];
    if(_filteredAddress && _filteredAddress.count == 1) {
        return [_filteredAddress lastObject];
    }
    return nil;
}

- (NSArray *)updateSelectedAddress:(Address *)selectedAddress {
    Address *prevSelectedAddress = [self getSelectedAddress];
    NSUInteger indexOfPrevSelectedAddress = [_addresses indexOfObject:prevSelectedAddress];
    [prevSelectedAddress setIsDefaultShipping:0];
    [prevSelectedAddress setIsDefaultBilling:0];
    
    if (selectedAddress) {
        NSUInteger indexOfAddressToSelect = [_addresses indexOfObject:selectedAddress];
        Address *selectedAddressObj = (Address *)[_addresses objectAtIndex:indexOfAddressToSelect];
        [selectedAddressObj setIsDefaultBilling:1];
        [selectedAddressObj setIsDefaultShipping:1];
        return @[ [NSIndexPath indexPathForRow:indexOfPrevSelectedAddress inSection:0], [NSIndexPath indexPathForRow:indexOfAddressToSelect inSection:0] ];
    }
    return nil;
}

- (void)updateSelectedAddressAppearance:(NSArray *)indexPathsToRefresh {
    [_addressTableViewController updateAppearanceForCellAtIndexPath:indexPathsToRefresh];
}

- (Address *)getAddressById:(NSString *)uid {
    if(uid && uid.length) {
        NSArray *_filteredAddress = [_addresses filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.uid == %@", uid]];
        if(_filteredAddress && _filteredAddress.count == 1) {
            return [_filteredAddress lastObject];
        }
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showCreateEditAddress"]) {
        UINavigationController *navigationViewController = (UINavigationController *)segue.destinationViewController;
        AddressEditViewController *addressEditViewController = (AddressEditViewController *)navigationViewController.viewControllers.firstObject;
        if(sender) {
            addressEditViewController.address = sender;
        }
        addressEditViewController.comesFromEmptyList = isEmptyList;
    }
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_CHOOSE_ADDRESS;
}

@end

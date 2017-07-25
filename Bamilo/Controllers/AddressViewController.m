//
//  AddressTableViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AddressViewController.h"
#import "AddressList.h"
#import "AddressTableViewController.h"
#import "ViewControllerManager.h"
#import "AlertManager.h"
#import "AddressEditViewController.h"
#import "Bamilo-Swift.h"

@interface AddressViewController() <AddressTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *addressListContainerView;
@end

@implementation AddressViewController {
@private
    AddressTableViewController *_addressTableViewController;
    Address *_currentAddress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _addressTableViewController = (AddressTableViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"AddressTableViewController"];
    _addressTableViewController.titleHeaderText = nil;
    _addressTableViewController.options = (ADDRESS_CELL_EDIT | ADDRESS_CELL_DELETE /*| ADDRESS_CELL_SELECT*/);
    _addressTableViewController.delegate = self;
    [_addressTableViewController addInto:self ofView:self.addressListContainerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchAddressList];
}

#pragma mark - AddressTableViewControllerDelegate
- (BOOL)addressSelected:(Address *)address {
    
    //TODO: this action has been ignored for now, because of endpoint issues (sed default address endpoint)
    return NO;
    if(_currentAddress.uid == address.uid) {
        return NO;
    }
    _currentAddress = address;
    [[AlertManager sharedInstance] confirmAlert:@"تغییر آدرس" text:@"از تغییر آدرس پیش فرض خود اطمینان دارید؟" confirm:@"بله" cancel:@"خیر" completion:^(BOOL OK) {
        if(OK) {
            [DataAggregator setDefaultAddress:self address:address isBilling:NO completion:^(id _Nullable data , NSError * _Nullable error) {
                if(error == nil) {
                    [self bind:data[kDataContent] forRequestId:1];
                    [_addressTableViewController scrollToTop];
                }
            }];
        }
    }];
    
    return YES;
}

-(void)addressEditButtonTapped:(id)sender {
    _currentAddress = (Address *)sender;
    [self performSegueWithIdentifier:@"pushAddressListToAddressEdit" sender:nil];
}

-(void)addressDeleteButtonTapped:(id)sender {
    _currentAddress = (Address *)sender;
    
    [[AlertManager sharedInstance] confirmAlert:@"حذف آدرس" text:@"از حذف آدرس خود اطمینان دارید؟" confirm:@"بله" cancel:@"خیر" completion:^(BOOL OK) {
        if(OK) {
            [DataAggregator deleteAddressWithTarget:self address:_currentAddress completion:^(id data, NSError *error) {
                if(error == nil) {
                    [self fetchAddressList];
                } else {
                    if(![self showNotificationBar:error isSuccess:NO]) {
                        //do not what else should we do here
                    }
                }
            }];
        }
    }];
}

- (void)addAddressTapped {
    _currentAddress = nil;
    
    [self performSegueWithIdentifier:@"pushAddressListToAddressEdit" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"pushAddressListToAddressEdit"]) {
        AddressEditViewController *addressEditViewController = (AddressEditViewController *)segue.destinationViewController;
        if(_currentAddress) {
            addressEditViewController.address = _currentAddress;
        }
    }
}

#pragma mark - Helpers
-(void) fetchAddressList {
    [DataAggregator getUserAddressList:self completion:^(id _Nullable data, NSError * _Nullable error) {
        if(error == nil && [data isKindOfClass:AddressList.class]) {
            [self bind:data forRequestId:0];
            [self publishScreenLoadTime];
        } else if ([data isKindOfClass:ApiResponseData.class]) {
            //TODO: we can show error messages
        }
    }];
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        case 0:
        case 1: {
            AddressList *addressList = (AddressList *)data;
            [_addressTableViewController updateWithModel:[AddressTableViewController bindAddresses:addressList]];
        }
        break;
    }
}

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"MyAddresses";
}

-(NSString *)getPerformanceTrackerLabel {
    return [RICustomer getCustomerId];
}


#pragma mark - NavigationBarProtocol
- (NSString *)navbarTitleString {
    return STRING_MY_ADDRESSES;
}

@end

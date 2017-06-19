//
//  AddressTableViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AddressViewController.h"
#import "AddressList.h"
#import "AddressDataManager.h"
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

#pragma mark - Overrides
- (void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.title = STRING_MY_ADDRESSES;
    self.navBarLayout.showBackButton = YES;
}

#pragma mark - AddressTableViewControllerDelegate
- (BOOL)addressSelected:(Address *)address {
    //TEMPORARILY DISABLED ADDRESS SELECTION
    return NO;
    
    if(_currentAddress.uid == address.uid) {
        return NO;
    }
    
    _currentAddress = address;
    
    [[AlertManager sharedInstance] confirmAlert:@"تغییر آدرس" text:@"از تغییر آدرس پیش فرض خود اطمینان دارید؟" confirm:@"بله" cancel:@"خیر" completion:^(BOOL OK) {
        if(OK) {
            [DataAggregator setDefaultAddress:self address:address isBilling:NO completion:^(id _Nullable data , NSError * _Nullable error) {
                if(error == nil) {
                    [self bind:data forRequestId:1];
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
            [DataAggregator deleteAddress:self address:_currentAddress completion:^(id _Nullable data, NSError * _Nullable error) {
                if(error == nil) {
                    [self fetchAddressList];
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

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    return @"MyAddresses";
}

-(NSString *)getPerformanceTrackerLabel {
    return [RICustomer getCustomerId];
}

@end

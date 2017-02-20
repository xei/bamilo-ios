//
//  AddressTableViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AddressViewController.h"
#import "AddressList.h"
#import "DataManager.h"
#import "AddressTableViewController.h"
#import "ViewControllerManager.h"
#import "AlertManager.h"
#import "AddressEditViewController.h"

@interface AddressViewController() <AddressTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *addressListContainerView;
@end

@implementation AddressViewController {
@private
    NSMutableArray *_addresses;
    AddressTableViewController *_addressTableViewController;
    Address *_workingAddress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _addressTableViewController = (AddressTableViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"AddressTableViewController"];
    _addressTableViewController.titleHeaderText = nil;
    _addressTableViewController.options = (ADDRESS_CELL_EDIT | ADDRESS_CELL_DELETE | ADDRESS_CELL_SELECT);
    _addressTableViewController.delegate = self;
    [_addressTableViewController addInto:self ofView:self.addressListContainerView];

    _addresses = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DataManager sharedInstance] getUserAddressList:self completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            
            [self publishScreenLoadTime];
        }
    }];
}

#pragma mark - Overrides
- (void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.title = STRING_MY_ADDRESSES;
    self.navBarLayout.showBackButton = YES;
}

#pragma mark - AddressTableViewControllerDelegate
- (BOOL)addressSelected:(Address *)address {
    _workingAddress = address;
    
    [[AlertManager sharedInstance] confirmAlert:@"تغییر آدرس" text:@"از تغییر آدرس پیش فرض خود اطمینان دارید؟" confirm:@"بله" cancel:@"خیر" completion:^(BOOL OK) {
        if(OK) {
            [[DataManager sharedInstance] setDefaultAddress:self address:address isBilling:NO completion:^(id data, NSError *error) {
                if(error == nil) {
                    [self bind:data forRequestId:1];
                }
            }];
        }
    }];
    
    return YES;
}

-(void)addressEditButtonTapped:(id)sender {
    _workingAddress = (Address *)sender;
    
    [self performSegueWithIdentifier:@"pushAddressListToAddressEdit" sender:nil];
}

-(void)addressDeleteButtonTapped:(id)sender {
    _workingAddress = (Address *)sender;
    
    [[AlertManager sharedInstance] confirmAlert:@"حذف آدرس" text:@"از حذف آدرس خود اطمینان دارید؟" confirm:@"بله" cancel:@"خیر" completion:^(BOOL OK) {
        if(OK) {
        }
    }];
}

- (void)addAddressTapped {
    _workingAddress = nil;
    
    [self performSegueWithIdentifier:@"pushAddressListToAddressEdit" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"pushAddressListToAddressEdit"]) {
        AddressEditViewController *addressEditViewController = (AddressEditViewController *)segue.destinationViewController;
        if(_workingAddress) {
            addressEditViewController.addressUID = _workingAddress.uid;
        }
    }
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        case 0:
        case 1: {
            [_addresses removeAllObjects];
            AddressList *addressList = (AddressList *)data;
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

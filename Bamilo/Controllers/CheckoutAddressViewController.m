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
    
    if(self.isCompleteFetch == NO) {
        [[DataManager sharedInstance] getMultistepAddressList:self completion:^(id data, NSError *error) {
            if(error == nil) {
                [self bind:data forRequestId:0];
                [self publishScreenLoadTime];
                
                self.isCompleteFetch = YES;
            }
        }];
    }
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
        Address *_selectedAddress = [self getSelectedAddress];
        [[DataManager sharedInstance] setMultistepAddress:self forShipping:_selectedAddress.uid billing:_selectedAddress.uid completion:^(id data, NSError *error) {
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
    [self updateSelectedAddress:address];
    
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
    }
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
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

-(void)updateSelectedAddress:(Address *)selectedAddress {
    Address *prevSelectedAddress = [self getSelectedAddress];
    NSUInteger indexOfPrevSelectedAddress = [_addresses indexOfObject:prevSelectedAddress];
    [prevSelectedAddress setIsDefaultShipping:0];
    [prevSelectedAddress setIsDefaultBilling:0];

    NSUInteger indexOfAddressToSelect = [_addresses indexOfObject:selectedAddress];
    Address *selectedAddressObj = (Address *)[_addresses objectAtIndex:indexOfAddressToSelect];
    [selectedAddressObj setIsDefaultBilling:1];
    [selectedAddressObj setIsDefaultShipping:1];
    
    [_addressTableViewController updateAppearanceForCellAtIndexPath:@[
        [NSIndexPath indexPathForRow:indexOfPrevSelectedAddress inSection:0],
        [NSIndexPath indexPathForRow:indexOfAddressToSelect inSection:0]
    ]];
}

@end

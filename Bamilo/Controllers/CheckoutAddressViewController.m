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
#import "AddressTableViewHeaderCell.h"
#import "AddressTableViewCell.h"
#import "AddressList.h"

@interface CheckoutAddressViewController()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CheckoutAddressViewController {
@private
    NSMutableArray *_addresses;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:[AddressTableViewHeaderCell nibName] bundle:nil] forHeaderFooterViewReuseIdentifier:[AddressTableViewHeaderCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[AddressTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[AddressTableViewCell nibName]];
    
    _addresses = [NSMutableArray array];
    
    [[DataManager sharedInstance] getUserAddressList:self completion:^(id data, NSError *error) {
        if(error == nil) {
            [self parse:data forRequestId:0];
        }
    }];
}

#pragma mark - Overrides
-(NSString *)getNextStepViewControllerSegueIdentifier {
    return @"pushAddressToReview";
}

-(void)updateNavBar {
    [super updateNavBar];

    self.navBarLayout.title = STRING_CHOOSE_ADDRESS;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AddressTableViewHeaderCell *addressTableViewHeaderCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[AddressTableViewHeaderCell nibName]];
    addressTableViewHeaderCell.title = STRING_PLEASE_CHOOSE_YOUR_ADDRESS;
    return addressTableViewHeaderCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSIndexPath *selectedAddressIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    //Trying to reselect the selected address. Ignore.
    if(indexPath.row == selectedAddressIndexPath.row) {
        return;
    }
    
    /*[tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[ selectedAddressIndexPath ] withRowAnimation:UITableViewRowAnimationLeft];
    [tableView insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationLeft];
    [tableView endUpdates];*/
    
    [[DataManager sharedInstance] setDefaultAddress:self address:[_addresses objectAtIndex:indexPath.row] isBilling:NO completion:^(id data, NSError *error) {
        if(error == nil) {
            [self parse:data forRequestId:1];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_addresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressTableViewCell *addressTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:[AddressTableViewCell nibName] forIndexPath:indexPath];
    
    [addressTableViewCell updateWithModel:[_addresses objectAtIndex:indexPath.row]];
    
    return addressTableViewCell;
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING]
    ];
}

#pragma mark - Helpers
-(void)parse:(id)data forRequestId:(int)rid {
    [_addresses removeAllObjects];
    
    AddressList *addressList = (AddressList *)data;
    
    if(addressList) {
        if(addressList.shipping) {
            [_addresses addObject:addressList.shipping];
        }
        
        for(Address *otherAddress in addressList.other) {
            [_addresses addObject:otherAddress];
        }
        
        [self.tableView reloadData];
    }
}

@end

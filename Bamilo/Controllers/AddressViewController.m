//
//  AddressTableViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AddressViewController.h"
#import "AddressTableViewHeaderCell.h"
#import "AddressTableViewCell.h"
#import "AddressList.h"
#import "DataManager.h"

@interface AddressViewController()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AddressViewController {
@private
    NSMutableArray *_addresses;
}

#pragma mark - AddressViewControllerDelegate
-(NSString *)getAddressHeaderViewTitle {
    return STRING_PLEASE_CHOOSE_YOUR_ADDRESS;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:[AddressTableViewHeaderCell nibName] bundle:nil] forHeaderFooterViewReuseIdentifier:[AddressTableViewHeaderCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[AddressTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[AddressTableViewCell nibName]];
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    _addresses = [NSMutableArray array];
    
    [[DataManager sharedInstance] getUserAddressList:self completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
        }
    }];
}

#pragma mark - Overrides
-(void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.title = STRING_MY_ADDRESSES;
    self.navBarLayout.showBackButton = YES;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AddressTableViewHeaderCell *addressTableViewHeaderCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[AddressTableViewHeaderCell nibName]];
    addressTableViewHeaderCell.title = self.titleHeaderText;
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
            [self bind:data forRequestId:1];
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

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
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

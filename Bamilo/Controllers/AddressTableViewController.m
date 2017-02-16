//
//  AddressTableViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AddressTableViewController.h"
#import "AddressTableViewHeaderCell.h"

@interface AddressTableViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation AddressTableViewController {
@private
    NSArray *_addresses;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.options = ADDRESS_CELL_NONE;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:[AddressTableViewHeaderCell nibName] bundle:nil] forHeaderFooterViewReuseIdentifier:[AddressTableViewHeaderCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[AddressTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[AddressTableViewCell nibName]];
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

-(void)updateWithModel:(NSArray *)addresses {
    _addresses = addresses;
    [self.tableView reloadData];
}

-(void)addInto:(UIViewController *)viewController ofView:(UIView *)containerView {
    [viewController addChildViewController:self];
    [self.view setFrame:CGRectMake(0, 0, containerView.width, containerView.height)];
    [containerView addSubview:self.view];
    [self didMoveToParentViewController:viewController];
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
    
    if([self.delegate respondsToSelector:@selector(addressSelected:)]) {
        [self.delegate addressSelected:[_addresses objectAtIndex:selectedAddressIndexPath.row]];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_addresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressTableViewCell *addressTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:[AddressTableViewCell nibName] forIndexPath:indexPath];
    
    [addressTableViewCell updateWithModel:[_addresses objectAtIndex:indexPath.row]];
    addressTableViewCell.options = self.options;
    
    return addressTableViewCell;
}

@end

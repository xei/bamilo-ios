//
//  CheckoutAddressViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutAddressViewController.h"
#import "AddressTableViewHeaderCell.h"
#import "AddressTableViewCell.h"

@interface CheckoutAddressViewController()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CheckoutAddressViewController {
@private
    NSArray *_addresses;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:[AddressTableViewHeaderCell nibName] bundle:nil] forHeaderFooterViewReuseIdentifier:[AddressTableViewHeaderCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[AddressTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[AddressTableViewCell nibName]];
    
    _addresses = [NSArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overrides
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;//[_addresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressTableViewCell *addressTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:[AddressTableViewCell nibName] forIndexPath:indexPath];
    
    return addressTableViewCell;
}

@end

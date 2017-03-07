//
//  OrderDetailViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderTableHeaderCell.h"
#import "DataManager.h"
#import "OrderProductListTableViewCell.h"
#import "ProgressViewControl.h"

@interface OrderDetailViewController ()
@property (weak, nonatomic) IBOutlet ProgressViewControl *progressViewControl;
@property (nonatomic, weak) IBOutlet UITableView *tableview;
@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    [self.tableview registerNib:[UINib nibWithNibName:[OrderTableHeaderCell nibName] bundle:nil] forCellReuseIdentifier: [OrderTableHeaderCell nibName]];
    [self.tableview registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil] forCellReuseIdentifier: [PlainTableViewHeaderCell nibName]];
    [self.tableview registerNib:[UINib nibWithNibName:[OrderProductListTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [OrderProductListTableViewCell nibName]];
    
    //PROGRESS VIEW
    ProgressItemViewModel *progressItemOrderRegistered = [ProgressItemViewModel itemWithIcons:[ProgressItemImageSet setWith:@"order-registered-pending" active:@"order-registered-active" done:@"order-registered-done"] title:@"ثبت سفارش" type:PROGRESS_ITEM_DONE];
    ProgressItemViewModel *progressItemOrderInProgress = [ProgressItemViewModel itemWithIcons:[ProgressItemImageSet setWith:@"order-inprogress-pending" active:@"order-inprogress-active" done:@"order-inprogress-done"] title:@"در حال تامین" type:PROGRESS_ITEM_ACTIVE];
    ProgressItemViewModel *progressItemOrderDelivered = [ProgressItemViewModel itemWithIcons:[ProgressItemImageSet setWith:@"order-delivered-pending" active:@"order-delivered-active" done:@"order-delivered-done"] title:@"ارسال شد" type:PROGRESS_ITEM_PENDING];
    
    [self.progressViewControl updateWithModel:@[ progressItemOrderDelivered, progressItemOrderInProgress, progressItemOrderRegistered ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DataManager sharedInstance] getOrder:self forOrderId:self.order.orderId completion:^(id data, NSError *error) {
        if (error == nil) {
            [self bind:data forRequestId:0];
        } else {
            if(![self showNotificationBar:error isSuccess:NO]) {
                //Donno what else should we do here
            }
        }
    }];
}

- (void)updateNavBar {
    [super updateNavBar];
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_ORDER_STATUS;
    self.navBarLayout.showBackButton = YES;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        OrderTableHeaderCell *headerCell = [self.tableview dequeueReusableCellWithIdentifier:[OrderTableHeaderCell nibName]];
        [headerCell updateWithModel: self.order];
        return headerCell;
    } else {
        PlainTableViewHeaderCell *headerCell = [self.tableview dequeueReusableCellWithIdentifier:[PlainTableViewHeaderCell nibName]];
        headerCell.titleString = [[NSString stringWithFormat:@"%@: %lu", STRING_ORDER_QUANTITY, (unsigned long)self.order.products.count] numbersToPersian];
        return headerCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [OrderTableHeaderCell cellHeight];
    } else {
        return [PlainTableViewHeaderCell cellHeight] - 10;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [UITableViewCell new];
    } else {
        OrderProductListTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:[OrderProductListTableViewCell nibName] forIndexPath:indexPath];
        [cell updateWithModel:self.order.products[indexPath.row]];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.order.products.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - bind data to view

- (void)bind:(id)data forRequestId:(int)rid {
    self.order = data;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}

@end

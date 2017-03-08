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

@implementation OrderDetailViewController {
@private
    ProgressItemImageSet *_orderRegisteredImageSet, *_orderInProgressImageSet, *_orderDeliveredImageSet;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    [self.tableview registerNib:[UINib nibWithNibName:[OrderTableHeaderCell nibName] bundle:nil] forCellReuseIdentifier: [OrderTableHeaderCell nibName]];
    [self.tableview registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil] forCellReuseIdentifier: [PlainTableViewHeaderCell nibName]];
    [self.tableview registerNib:[UINib nibWithNibName:[OrderProductListTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [OrderProductListTableViewCell nibName]];
    
    _orderRegisteredImageSet = [ProgressItemImageSet setWith:@"order-registered-pending" active:@"order-registered-active" done:@"order-registered-done"];
    _orderInProgressImageSet = [ProgressItemImageSet setWith:@"order-inprogress-pending" active:@"order-inprogress-active" done:@"order-inprogress-done"];
    _orderDeliveredImageSet = [ProgressItemImageSet setWith:@"order-delivered-pending" active:@"order-delivered-active" done:@"order-delivered-done"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DataManager sharedInstance] getOrder:self forOrderId:self.order.orderId completion:^(id data, NSError *error) {
        if (error == nil) {
            [self bind:data forRequestId:0];
            NSArray *progressViewContent = [self getProgressViewControlContentForOrder:self.order];
            if(RI_IS_RTL) {
                [self.progressViewControl updateWithModel:[[progressViewContent reverseObjectEnumerator] allObjects]];
            }
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

#pragma mark - Helpers
-(NSArray *) getProgressViewControlContentForOrder:(Order *)order {
    NSArray *progressViewControlContent = @[
       [ProgressItemViewModel itemWithIcons:_orderRegisteredImageSet title:STRING_REGISTER_ORDER type:PROGRESS_ITEM_PENDING isIndicator:YES],
       [ProgressItemViewModel itemWithIcons:_orderInProgressImageSet title:STRING_IN_PROGRESS type:PROGRESS_ITEM_PENDING isIndicator:YES],
       [ProgressItemViewModel itemWithIcons:_orderDeliveredImageSet title:STRING_SENT type:PROGRESS_ITEM_PENDING isIndicator:YES]
    ];
    
    switch (order.status) {
        case 0: {
            ((ProgressItemViewModel *)progressViewControlContent[0]).type = PROGRESS_ITEM_ACTIVE;
        }
        break;
    
        case 1: {
            ((ProgressItemViewModel *)progressViewControlContent[0]).type = PROGRESS_ITEM_DONE;
            ((ProgressItemViewModel *)progressViewControlContent[1]).type = PROGRESS_ITEM_ACTIVE;
        }
        break;
            
        case 2: {
            ((ProgressItemViewModel *)progressViewControlContent[0]).type = PROGRESS_ITEM_DONE;
            ((ProgressItemViewModel *)progressViewControlContent[1]).type = PROGRESS_ITEM_DONE;
            ((ProgressItemViewModel *)progressViewControlContent[2]).type = PROGRESS_ITEM_ACTIVE;
        }
        break;
            
        case 3: {
            ((ProgressItemViewModel *)progressViewControlContent[0]).type = PROGRESS_ITEM_DONE;
            ((ProgressItemViewModel *)progressViewControlContent[1]).type = PROGRESS_ITEM_DONE;
            ((ProgressItemViewModel *)progressViewControlContent[2]).type = PROGRESS_ITEM_DONE;
        }
        break;
            
        default:
            break;
    }
    
    return progressViewControlContent;
}

@end

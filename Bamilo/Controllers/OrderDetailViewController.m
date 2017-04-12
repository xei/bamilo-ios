//
//  OrderDetailViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "PlainTableViewHeaderCell.h"
#import "DataManager.h"
#import "OrderProductListTableViewCell.h"
#import "OrderDetailInformationTableViewCell.h"
#import "NSDate+Extensions.h"
#import "RIProduct.h"
#import "LoadingManager.h"
#import "ProgressViewControl.h"

@interface OrderDetailViewController () <OrderProductListTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet ProgressViewControl *progressViewControl;
@property (nonatomic, weak) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray *orderDetailInoArray;
@end

@implementation OrderDetailViewController {
@private
    ProgressItemImageSet *_orderRegisteredImageSet, *_orderInProgressImageSet, *_orderDeliveredImageSet;
}

- (NSArray *)orderDetailInoArray {
    if (!_orderDetailInoArray) {
        _orderDetailInoArray = [[NSArray alloc] init];
    }
    return _orderDetailInoArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;

    [self.tableview registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil] forCellReuseIdentifier: [PlainTableViewHeaderCell nibName]];
    [self.tableview registerNib:[UINib nibWithNibName:[OrderProductListTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [OrderProductListTableViewCell nibName]];

    [self.tableview registerNib:[UINib nibWithNibName:[OrderDetailInformationTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [OrderDetailInformationTableViewCell nibName]];

    _orderRegisteredImageSet = [ProgressItemImageSet setWith:@"order-registered-pending" active:@"order-registered-active" done:@"order-registered-done" error:nil];
    _orderInProgressImageSet = [ProgressItemImageSet setWith:@"order-inprogress-pending" active:@"order-inprogress-active" done:@"order-inprogress-done" error:nil];
    _orderDeliveredImageSet = [ProgressItemImageSet setWith:@"order-delivered-pending" active:@"order-delivered-active" done:@"order-delivered-done" error:@"order-delivered-error"];

    [self.tableview setHidden:YES];
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

    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)updateNavBar {
    [super updateNavBar];

    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_ORDER_STATUS;
    self.navBarLayout.showBackButton = YES;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *headerTitle = section == 0 ? STRING_ORDER_DETAILS : STRING_ORDER_PRODUCT_DETAIL;
    PlainTableViewHeaderCell *headerCell = [self.tableview dequeueReusableCellWithIdentifier:[PlainTableViewHeaderCell nibName]];
    headerCell.titleString = headerTitle;
    return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [PlainTableViewHeaderCell cellHeight] - 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        OrderDetailInformationTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:[OrderDetailInformationTableViewCell nibName] forIndexPath:indexPath];
        cell.title = ((NSDictionary *)self.orderDetailInoArray[indexPath.row]).allKeys[0];
        cell.value = [((NSDictionary *)self.orderDetailInoArray[indexPath.row]).allValues[0] numbersToPersian];
        return cell;
    } else {
        OrderProductListTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:[OrderProductListTableViewCell nibName] forIndexPath:indexPath];
        [cell updateWithModel:self.order.products[indexPath.row]];
        cell.delegate = self;
        return cell;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.orderDetailInoArray.count;
    } else {
        return self.order.products.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.orderDetailInoArray.count || self.order.products.count) {
        return 2;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *userInfo = @{@"sku": ((OrderProduct *)self.order.products[indexPath.row]).sku};
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication object:nil userInfo:userInfo];
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

#pragma mark - bind data to view
- (void)bind:(id)data forRequestId:(int)rid {
    self.order = data;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });

    self.orderDetailInoArray = @[
         @{STRING_ORDER_ID: self.order.orderId ?: @""},
         @{STRING_ORDER_DATE_INFO: [[self.order.creationDate convertToJalali] numbersToPersian] ?: @""},
         @{STRING_TOTAL_COST_INFO: self.order.formattedPrice ?: @""},
         @{STRING_ORDER_PRODUCT_QUANTITY: [NSString stringWithFormat:@"%lu %@", (unsigned long)self.order.products.count, STRING_PRODUCT_QUANTITY_POSTFIX] ?: @""},
         @{STRING_PAYMENT_METHOD: self.order.paymentMethod ?: @""}
    ];

    [self.tableview setHidden:NO];
}

#pragma mark - OrderProductListTableViewCellDelegate

- (void)needsToShowProductReviewForProduct:(OrderProduct *)product {
    [[LoadingManager sharedInstance] showLoading];
    [RIProduct getCompleteProductWithSku:product.sku successBlock:^(id product) {
        [[LoadingManager sharedInstance] hideLoading];
        NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
        if(VALID_NOTEMPTY(product, RIProduct)) {
            [userInfo setObject:product forKey:@"product"];
        }
        [userInfo setObject:@"reviews" forKey:@"product.screen"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowProductSpecificationScreenNotification object:nil userInfo:userInfo];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        [[LoadingManager sharedInstance] hideLoading];
        if (error.count && ![self showNotificationBarMessage:error[0] isSuccess:NO]) {

        }
    }];

}

#pragma mark - Helpers
-(NSArray *) getProgressViewControlContentForOrder:(Order *)order {
    NSArray *progressViewControlContent = @[
       [ProgressItemViewModel itemWithIcons:_orderRegisteredImageSet title:STRING_REGISTER_ORDER errorTitle:nil isIndicator:YES],
       [ProgressItemViewModel itemWithIcons:_orderInProgressImageSet title:STRING_IN_PROGRESS errorTitle:nil isIndicator:YES],
       [ProgressItemViewModel itemWithIcons:_orderDeliveredImageSet title:STRING_SENT errorTitle:STRING_CANCELLED isIndicator:YES]
    ];

    switch (order.status) {
        case ORDER_STATUS_NEW_ORDER: {
            ((ProgressItemViewModel *)progressViewControlContent[0]).type = PROGRESS_ITEM_ACTIVE;
        }
        break;

        case ORDER_STATUS_REGISTERED: {
            ((ProgressItemViewModel *)progressViewControlContent[0]).type = PROGRESS_ITEM_DONE;
            ((ProgressItemViewModel *)progressViewControlContent[1]).type = PROGRESS_ITEM_ACTIVE;
        }
        break;

        case ORDER_STATUS_IN_PROGRESS: {
            ((ProgressItemViewModel *)progressViewControlContent[0]).type = PROGRESS_ITEM_DONE;
            ((ProgressItemViewModel *)progressViewControlContent[1]).type = PROGRESS_ITEM_DONE;
            ((ProgressItemViewModel *)progressViewControlContent[2]).type = PROGRESS_ITEM_ACTIVE;
        }
        break;

        case ORDER_STATUS_DELIVERED: {
            ((ProgressItemViewModel *)progressViewControlContent[0]).type = PROGRESS_ITEM_DONE;
            ((ProgressItemViewModel *)progressViewControlContent[1]).type = PROGRESS_ITEM_DONE;
            ((ProgressItemViewModel *)progressViewControlContent[2]).type = PROGRESS_ITEM_DONE;
        }
        break;

        case ORDER_STATUS_CANCELLED: {
            ((ProgressItemViewModel *)progressViewControlContent[0]).type = PROGRESS_ITEM_PENDING;
            ((ProgressItemViewModel *)progressViewControlContent[1]).type = PROGRESS_ITEM_PENDING;
            ((ProgressItemViewModel *)progressViewControlContent[2]).type = PROGRESS_ITEM_ERROR;
        }
        break;

        default:
            break;
    }

    return progressViewControlContent;
}

@end

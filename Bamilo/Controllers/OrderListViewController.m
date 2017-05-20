//
//  OrderListViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderListViewController.h"
#import "OrderListTableViewCell.h"
#import "DataManager.h"
#import "OrderDetailViewController.h"
#import "OrderList.h"

#define kTopSeparatorHight 1.f
#define kOrdersPerPage 25

@interface OrderListViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableview;
@property (nonatomic, strong) OrderList *list;

@property (assign, nonatomic) int currentOrdersPage;
@property (assign, nonatomic) int ordersTotal;
@property (assign, nonatomic) BOOL isLoadingOrders;
// Empty order history
@property (strong, nonatomic) UIView *emptyOrderHistoryView;
@property (strong, nonatomic) UIImageView *emptyOrderHistoryImageView;
@property (strong, nonatomic) UILabel *emptyOrderHistoryLabel;
@property (strong, nonatomic) UILabel *emptyOrderHistoryTitleLabel;
@end

@implementation OrderListViewController


// --- Legacy views -----

- (UIView *)emptyOrderHistoryView {
    if (!VALID_NOTEMPTY(_emptyOrderHistoryView, UIView)) {
        _emptyOrderHistoryView = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                         self.view.bounds.origin.y + kTopSeparatorHight,
                                                                         self.view.bounds.size.width,
                                                                         self.view.bounds.size.height - kTopSeparatorHight)];
        [_emptyOrderHistoryView setBackgroundColor:[UIColor whiteColor]];
        [_emptyOrderHistoryView setHidden:NO];
        [self.view addSubview:_emptyOrderHistoryView];
    }
    return _emptyOrderHistoryView;
}

- (UILabel *)emptyOrderHistoryTitleLabel {
    if (!VALID_NOTEMPTY(_emptyOrderHistoryTitleLabel, UILabel)) {
        _emptyOrderHistoryTitleLabel = [UILabel new];
        [_emptyOrderHistoryTitleLabel setFont:JADisplay2Font];
        [_emptyOrderHistoryTitleLabel setTextColor:JABlackColor];
        [_emptyOrderHistoryTitleLabel setText:STRING_NO_ORDERS_TITLE];
        [_emptyOrderHistoryTitleLabel sizeToFit];
        [self.emptyOrderHistoryView addSubview:_emptyOrderHistoryTitleLabel];
    }
    return _emptyOrderHistoryTitleLabel;
}

- (UILabel *)emptyOrderHistoryLabel {
    if (!VALID_NOTEMPTY(_emptyOrderHistoryLabel, UILabel)) {
        _emptyOrderHistoryLabel = [UILabel new];
        [_emptyOrderHistoryLabel setFont:JABodyFont];
        [_emptyOrderHistoryLabel setTextColor:JABlack800Color];
        [_emptyOrderHistoryLabel setText:STRING_NO_ORDERS];
        [_emptyOrderHistoryLabel sizeToFit];
        [self.emptyOrderHistoryView addSubview:_emptyOrderHistoryLabel];
    }
    return _emptyOrderHistoryLabel;
}

- (UIImageView *)emptyOrderHistoryImageView {
    if (!VALID_NOTEMPTY(_emptyOrderHistoryImageView, UIImageView)) {
        _emptyOrderHistoryImageView = [UIImageView new];
        UIImage *img = [UIImage imageNamed:@"noOrdersImage"];
        [_emptyOrderHistoryImageView setImage:img];
        [_emptyOrderHistoryImageView setWidth:img.size.width];
        [_emptyOrderHistoryImageView setHeight:img.size.height];
        [self.emptyOrderHistoryView addSubview:_emptyOrderHistoryImageView];
    }
    return _emptyOrderHistoryImageView;
}

// --- endof Legacy views
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.tableview registerNib:[UINib nibWithNibName:[OrderListTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [OrderListTableViewCell nibName]];
    
    
    // This will remove extra separators from tableview
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_MY_ORDERS;
    self.navBarLayout.showBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[DataManager sharedInstance] getOrders:self forPageNumber:self.currentOrdersPage perPageCount:kOrdersPerPage completion:^(id data, NSError *error) {
        if (error == nil) {
            [self bind:data forRequestId:0];
        } else {
            if(![self showNotificationBar:error isSuccess:NO]) {
                //Donno what else should we do here
            }
        }
    }];
}


#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderListTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:[OrderListTableViewCell nibName] forIndexPath:indexPath];
    [cell updateWithModel:self.list.orders[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.orders.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:NSStringFromClass([OrderDetailViewController class]) sender:self.list.orders[indexPath.row]];
}

#pragma mark - bind to UI

- (void)bind:(id)data forRequestId:(int)rid {
    self.list = data;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:NSStringFromClass([OrderDetailViewController class])]) {
        OrderDetailViewController *orderDetailViewCtrl = (OrderDetailViewController *)segue.destinationViewController;
        orderDetailViewCtrl.order = ((Order *)sender);
    }
}


@end
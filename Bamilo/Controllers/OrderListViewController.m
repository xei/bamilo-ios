//
//  OrderListViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderListViewController.h"
#import "OrderListTableViewCell.h"
#import "Bamilo-Swift.h"
#import "ThreadManager.h"
#import "OrderList.h"

#define kTopSeparatorHight 1.f
#define kOrdersPerPage 25
#define bottomListThreshold 40.f //point

@interface OrderListViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *emptyListMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *emptyListMessageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewBottomConstraint;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) OrderList *list;
@property (assign, nonatomic) BOOL isLoadingOrders;
// Empty order history
@property (strong, nonatomic) UIView *emptyOrderHistoryView;
@property (strong, nonatomic) UIImageView *emptyOrderHistoryImageView;
@property (strong, nonatomic) UILabel *emptyOrderHistoryLabel;
@property (strong, nonatomic) UILabel *emptyOrderHistoryTitleLabel;

@end

@implementation OrderListViewController

// --- Legacy views ----
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
- (OrderList *)list {
    if (!_list) {
        _list = [[OrderList alloc] init];
        _list.orders = [[NSMutableArray<Order> alloc] init];
        return _list;
    }
    return _list;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.tableview registerNib:[UINib nibWithNibName:[OrderListTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [OrderListTableViewCell nibName]];
    
    
    // This will remove extra separators from tableview
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.emptyListMessageLabel applyStyle:[Theme font:kFontVariationRegular size:15] color:[UIColor blackColor]];
    self.emptyListMessageLabel.text = STRING_NO_ORDERS_TITLE;
    
    //it's possible that previous view controllers hides bottom bar so content edges will be disturbed
    //by this trick this view always shows proper boundary
    self.tableviewBottomConstraint.constant = [MainTabBarViewController sharedInstance].tabBar.height;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(resetContentAndRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableview addSubview:self.refreshControl];
    
    //Get data for this list
    [self getPage:1 callBack:nil];
    [self.tableview sizeToFit];
}

- (void) showLoading {
    LoadingView *footerView = [LoadingView nibInstance];
    footerView.backgroundColor = [UIColor clearColor];
    [footerView setSize:CGSizeMake(self.tableview.frame.size.width, 100)];
    self.tableview.tableFooterView = footerView;
    [footerView.loadingIndicator startAnimating];
}

- (void)getPage:(NSInteger)pageNumber callBack:(void(^)(void))handler {
    if (self.isLoadingOrders) return;
    self.isLoadingOrders = YES;
    [self showLoading];
    [DataAggregator getOrders:self page:pageNumber perPageCount:kOrdersPerPage completion:^(id data, NSError *error) {
        if (handler) handler();
        self.isLoadingOrders = NO;
        if (error == nil) {
            [self bind:data forRequestId:0];
        } else {
            [Utility handleErrorWithError:error viewController:self];
        }
    }];
}

- (void)resetContentAndRefresh {
    self.list.currentPage = 1;
    [self getPage:self.list.currentPage callBack:^(void) {
        [self.list.orders removeAllObjects];
        [self.refreshControl endRefreshing];
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
    [self performSegueWithIdentifier:@"OrderDetailViewController" sender:self.list.orders[indexPath.row]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height - bottomListThreshold) {
        // we are approaching at the end of scrollview
        if (self.list.currentPage < self.list.totalPages) {
            [self getPage:self.list.currentPage + 1 callBack:nil];
        }
    }
}


#pragma mark - bind to UI
- (void)bind:(id)data forRequestId:(int)rid {
    if ([data isKindOfClass:[OrderList class]]) {
        [self.list.orders addObjectsFromArray:((OrderList *)data).orders];
        self.list.currentPage = ((OrderList *)data).currentPage;
        self.list.totalPages = ((OrderList *)data).totalPages;
        
        [ThreadManager executeOnMainThread:^{
            if (self.list.orders.count == 0) {
                self.emptyListMessageView.hidden = NO;
            }
            [self.tableview reloadData];
            
            // This will remove extra separators from tableview
            self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString: @"OrderDetailViewController"]) {
        self.hidesBottomBarWhenPushed = YES;
        OrderDetailViewController *orderDetailViewCtrl = (OrderDetailViewController *)segue.destinationViewController;
        self.hidesBottomBarWhenPushed = NO;
        orderDetailViewCtrl.orderId = ((Order *)sender).orderId;
    }
}
    
#pragma mark - hide tabbar in this view controller
- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}


#pragma mark - DataTrackerProtocol
- (NSString *)getScreenName {
    return @"OrderListView";
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_MY_ORDERS;
}

@end

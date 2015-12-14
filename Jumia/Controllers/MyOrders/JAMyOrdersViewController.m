//
//  JAMyOrdersViewController.m
//  Jumia
//
//  Created by Miguel Rossi Seabra on 09/12/2015.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyOrdersViewController.h"
#import "JAMyOrderDetailView.h"
#import "JAMyOrderCell.h"
#import "JACollectionHeaderView.h"
#import "RIOrder.h"
#import "RICustomer.h"

#define kOrdersPerPage 25
#define KEmptyTitleLabelDist 48.f
#define KEmptyImageViewDist 28.f
#define KEmptyLabelDist 28.f
#define kCollectionViewHeaderHeight 58.f
#define kTopSeparatorHight 1.f

//typedef NS_ENUM(NSUInteger, RITrackOrderRequestState) {
//    RITrackOrderRequestNotDone = 0,
//    RITrackOrderRequestDone = 1
//};

@interface JAMyOrdersViewController ()
<
UITextFieldDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>


@property (strong, nonatomic) NSMutableArray *orders;
@property (assign, nonatomic) NSInteger currentOrdersPage;
@property (assign, nonatomic) NSInteger ordersTotal;
@property (assign, nonatomic) BOOL isLoadingOrders;

// Empty order history
@property (strong, nonatomic) UIView *emptyOrderHistoryView;
@property (strong, nonatomic) UIImageView *emptyOrderHistoryImageView;
@property (strong, nonatomic) UILabel *emptyOrderHistoryLabel;
@property (strong, nonatomic) UILabel *emptyOrderHistoryTitleLabel;


// Order history
@property (strong, nonatomic) UICollectionView *ordersCollectionView;

// Detail should only show on IPad landscape
@property (strong, nonatomic) UIScrollView *orderDetailsScrollView;
@property (strong, nonatomic) JAMyOrderDetailView *orderDetailsView;
@property (strong, nonatomic) NSIndexPath *selectedOrderIndexPath;
@property (strong, nonatomic) RITrackOrder *trackingOrder;

@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JAMyOrdersViewController

#pragma mark init

-(UIView *)emptyOrderHistoryView {
    if (!VALID_NOTEMPTY(_emptyOrderHistoryView, UIView)) {
        _emptyOrderHistoryView = [[UIView alloc]initWithFrame:CGRectMake(self.viewBounds.origin.x,
                                                                        self.viewBounds.origin.y+kTopSeparatorHight,
                                                                        self.viewBounds.size.width,
                                                                        self.viewBounds.size.height-kTopSeparatorHight)];
        [_emptyOrderHistoryView setBackgroundColor:[UIColor whiteColor]];
        [_emptyOrderHistoryView setHidden:NO];
        [self.view addSubview:_emptyOrderHistoryView];
    }
    return _emptyOrderHistoryView;
}

-(UILabel *)emptyOrderHistoryTitleLabel {
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

-(UILabel *)emptyOrderHistoryLabel {
    if (!VALID_NOTEMPTY(_emptyOrderHistoryLabel, UILabel)) {
        _emptyOrderHistoryLabel = [UILabel new];
        [_emptyOrderHistoryLabel setFont:JABody3Font];
        [_emptyOrderHistoryLabel setTextColor:JABlack800Color];
        [_emptyOrderHistoryLabel setText:STRING_NO_ORDERS];
        [_emptyOrderHistoryLabel sizeToFit];
        [self.emptyOrderHistoryView addSubview:_emptyOrderHistoryLabel];
    }
    return _emptyOrderHistoryLabel;
}

-(UIImageView *)emptyOrderHistoryImageView {
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

-(UICollectionView *)ordersCollectionView {
    if (!VALID_NOTEMPTY(_ordersCollectionView, UICollectionView)) {
        UICollectionViewFlowLayout* ordersCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        [ordersCollectionViewFlowLayout setMinimumLineSpacing:0.0f];
        [ordersCollectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
        [ordersCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [ordersCollectionViewFlowLayout setItemSize:CGSizeZero];
        [ordersCollectionViewFlowLayout setHeaderReferenceSize:CGSizeMake(self.viewBounds.size.width, kCollectionViewHeaderHeight)];
        
        _ordersCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.viewBounds.origin.x,
                                                                                   self.viewBounds.origin.y + kTopSeparatorHight,
                                                                                   self.viewBounds.size.width,
                                                                                   self.viewBounds.size.height - kTopSeparatorHight)
                                                   collectionViewLayout: ordersCollectionViewFlowLayout];
        [_ordersCollectionView setBackgroundColor:UIColorFromRGB(0xffffff)];
        

        [_ordersCollectionView setDataSource:self];
        [_ordersCollectionView setDelegate:self];
        [_ordersCollectionView setHidden:YES];
        
        [self.view addSubview: _ordersCollectionView];
    }
    return _ordersCollectionView;
}

-(UIScrollView *)orderDetailsScrollView {
    if (!VALID_NOTEMPTY(_orderDetailsScrollView, UIScrollView)) {
        _orderDetailsScrollView = [UIScrollView new];
        [_orderDetailsScrollView setHidden:YES];
        [_orderDetailsScrollView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:_orderDetailsScrollView];
    }
    return _orderDetailsScrollView;
}

-(JAMyOrderDetailView *)orderDetailsView {
    if (!VALID_NOTEMPTY(_orderDetailsView,JAMyOrderDetailView)) {
        _orderDetailsView = [JAMyOrderDetailView new];
        [_orderDetailsView setHidden:YES];
        [self.orderDetailsScrollView addSubview:_orderDetailsView];
    }
    return _orderDetailsView;
}

#pragma mark ViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    self.apiResponse = RIApiResponseSuccess;
    self.currentOrdersPage = 0;
    self.orders = [[NSMutableArray alloc] init];
    self.ordersTotal = 0;
    
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_MY_ORDERS;
    self.navBarLayout.showBackButton = YES;
    
    self.screenName = @"MyOrders";
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:self.screenName];
    
    [self.ordersCollectionView registerClass:[JACollectionHeaderView class]
                 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                        withReuseIdentifier:@"orderHeader"];
    
    [self.ordersCollectionView registerClass:[JAMyOrderCell class] forCellWithReuseIdentifier:@"myOrderCell"];
    
    [self loadOrders];
}

-(void)viewWillLayoutSubviews {
    [self setupViews];
}


- (void) loadOrders
{
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    self.isLoadingOrders = YES;
    
    [RIOrder getOrdersPage:[NSNumber numberWithInteger:self.currentOrdersPage+1]
                  maxItems:[NSNumber numberWithInteger:kOrdersPerPage]
          withSuccessBlock:^(NSArray *orders, NSInteger ordersTotal) {
              [self.orders addObjectsFromArray:orders];
              
              NSInteger previousOrdersTotal = self.ordersTotal;
              self.ordersTotal = ordersTotal;
              
              self.isLoadingOrders = NO;
              [self removeErrorView];
              
              if (previousOrdersTotal <= 0) {
                  [self setupViews];
                  if ((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) && (ordersTotal > 0)) {
                      self.selectedOrderIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                      [self loadOrderDetails];
                  } else
                      [self hideLoading];
              } else {
                  [self hideLoading];
              }
              [self.ordersCollectionView reloadData];
          }
           andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
               self.apiResponse = apiResponse;
               self.isLoadingOrders = NO;
               [self hideLoading];
               if(RIApiResponseMaintenancePage == apiResponse)
               {
                   [self showMaintenancePage:@selector(loadOrders) objects:nil];
               }
               else if(RIApiResponseKickoutView == apiResponse)
               {
                   [self showKickoutView:@selector(loadOrders) objects:nil];
               }
               else
               {
                   BOOL noConnection = NO;
                   if (RIApiResponseNoInternetConnection == apiResponse)
                   {
                       noConnection = YES;
                   }
                   [self showErrorView:noConnection startingY:self.viewBounds.origin.y+kTopSeparatorHight selector:@selector(loadOrders) objects:nil];
               }
           }];
}

- (void)loadOrderDetails
{
    if(!self.firstLoading &&
       (self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess) )
    {
        [self showLoading];
    }
    
    RITrackOrder *  order = [self.orders objectAtIndex:[self.selectedOrderIndexPath row]];
    
    
    [RIOrder trackOrderWithOrderNumber:order.orderId
                      WithSuccessBlock:^(RITrackOrder *trackingOrder) {
                          
                          self.trackingOrder = trackingOrder;
                          
                          [self setupViews];
                          
                          if(self.firstLoading)
                          {
                              NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                              [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                              self.firstLoading = NO;
                          }
                          [self removeErrorView];
                          [self hideLoading];
                          
                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                          self.apiResponse = apiResponse;
                          self.trackingOrder = nil;
                          
                          if(self.firstLoading)
                          {
                              NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                              [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                              self.firstLoading = NO;
                          }
                          
                          if(RIApiResponseMaintenancePage == apiResponse)
                          {
                              [self showMaintenancePage:@selector(loadOrderDetails) objects:nil];
                          }
                          else if(RIApiResponseKickoutView == apiResponse)
                          {
                              [self showKickoutView:@selector(loadOrderDetails) objects:nil];
                          }
                          else if (RIApiResponseNoInternetConnection == apiResponse)
                          {

                                  [self showErrorView:YES startingY:0.0f selector:@selector(loadOrderDetails) objects:nil];
                              
                          }
                          [self hideLoading];
                      }];
}



-(void) setupViews {
    if (VALID_NOTEMPTY(self.orders, NSMutableArray) ) {
        
        [self.ordersCollectionView setHidden:NO];
        [self.emptyOrderHistoryView setHidden:YES];
        [self setupMyOrderHistoyViews];
        // will only be drawn if we are in IPad and in landscape;
        [self setupMyOrderDetailsView];
    } else{
        
        [self.orderDetailsScrollView setHidden:YES];
        [self.ordersCollectionView setHidden:YES];
        [self.emptyOrderHistoryView setHidden:NO];
        [self setupEmptyViews];
    }
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

-(void) setupEmptyViews {
    
    [self.emptyOrderHistoryView setFrame:CGRectMake(self.viewBounds.origin.x,
                                                    self.viewBounds.origin.y+kTopSeparatorHight,
                                                    self.viewBounds.size.width,
                                                    self.viewBounds.size.height-kTopSeparatorHight)];
    
    [self.emptyOrderHistoryTitleLabel setFrame:CGRectMake((self.viewBounds.size.width - self.emptyOrderHistoryTitleLabel.width)/2,
                                                          KEmptyTitleLabelDist,
                                                          self.emptyOrderHistoryTitleLabel.width,
                                                          self.emptyOrderHistoryTitleLabel.height)];
    
    [self.emptyOrderHistoryImageView setFrame:CGRectMake((self.viewBounds.size.width - self.emptyOrderHistoryImageView.width)/2,
                                                         CGRectGetMaxY(self.emptyOrderHistoryTitleLabel.frame) + KEmptyImageViewDist,
                                                         self.emptyOrderHistoryTitleLabel.width,
                                                         self.emptyOrderHistoryTitleLabel.height)];
    
    [self.emptyOrderHistoryLabel setFrame:CGRectMake((self.viewBounds.size.width - self.emptyOrderHistoryLabel.width)/2,
                                                     CGRectGetMaxY(self.emptyOrderHistoryImageView.frame) + KEmptyLabelDist,
                                                     self.emptyOrderHistoryLabel.width,
                                                     self.emptyOrderHistoryLabel.height)];

}

-(void) setupMyOrderHistoyViews {
    
    CGFloat width = self.viewBounds.size.width;
    
    if ((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        width = width/2 - 1.f;
    }
    [self.ordersCollectionView setFrame:CGRectMake(self.viewBounds.origin.x,
                                                   self.viewBounds.origin.y+kTopSeparatorHight,
                                                   width, 
                                                   self.viewBounds.size.height-kTopSeparatorHight)];
    [self.ordersCollectionView reloadData];
}

-(void) setupMyOrderDetailsView {
    
    if ((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        if (VALID_NOTEMPTY(self.selectedOrderIndexPath,NSIndexPath)) {
            
            [self.orderDetailsScrollView setHidden: NO];
            [self.orderDetailsScrollView setFrame:CGRectMake(self.viewBounds.size.width/2, self.viewBounds.origin.y+kTopSeparatorHight,
                                                            self.viewBounds.size.width/2, self.viewBounds.size.height-kTopSeparatorHight)];
            if (VALID_NOTEMPTY(self.trackingOrder,RITrackOrder)) {
                
                [self.orderDetailsView setupWithOrder:self.trackingOrder maxWidth:self.viewBounds.size.width/2 allowsFlip:NO];
                [self.orderDetailsView setHidden:NO];
            }
        }
    } else {
        [self.orderDetailsScrollView setHidden:YES];
    }
}



#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize referenceSizeForHeaderInSection = CGSizeZero;
    if(collectionView == self.ordersCollectionView)
    {
        referenceSizeForHeaderInSection = CGSizeMake(self.ordersCollectionView.frame.size.width, kCollectionViewHeaderHeight);
    }
    
    return referenceSizeForHeaderInSection;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize sizeForItemAtIndexPath = CGSizeZero;
    if(collectionView == self.ordersCollectionView)
    {
        sizeForItemAtIndexPath = CGSizeMake(self.ordersCollectionView.frame.size.width, [JAMyOrderCell getCellHeight]);
    }
    return sizeForItemAtIndexPath;
}

#pragma mark UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    if (kind == UICollectionElementKindSectionHeader) {
        JACollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"orderHeader" forIndexPath:indexPath];
        
        if(collectionView == self.ordersCollectionView)
        {
            [headerView loadHeaderWithText:STRING_MY_ORDER_HISTORY width:self.ordersCollectionView.frame.size.width height:kCollectionViewHeaderHeight];
        }
        
        reusableview = headerView;
    }
    
    return reusableview;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = 0;
    if(VALID_NOTEMPTY(self.orders, NSArray))
    {
        numberOfItemsInSection = [self.orders count];

    }
    return numberOfItemsInSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if(collectionView == self.ordersCollectionView)
    {
        if (!self.isLoadingOrders && [self.orders count] < self.ordersTotal && [self.orders count] - 5 <= indexPath.row)
        {
            self.currentOrdersPage++;
            [self loadOrders];
        }
        
        if(VALID_NOTEMPTY(self.orders, NSArray) && indexPath.row < [self.orders count])
        {
            RITrackOrder *order = [self.orders objectAtIndex:indexPath.row];
            JAMyOrderCell *myOrderCell = (JAMyOrderCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"myOrderCell" forIndexPath:indexPath];
            [myOrderCell setupWithOrder:order];
            
            [myOrderCell.clickableView setTag:indexPath.row];
            [myOrderCell.clickableView addTarget:self action:@selector(selectedOrder:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = myOrderCell;
        }
    }
    return cell;
}

#pragma mark Actions

- (void)selectedOrder:(id)sender
{
    JAClickableView *clickableView = sender;
    NSInteger tag = clickableView.tag;
    self.selectedOrderIndexPath = [NSIndexPath indexPathForRow:tag inSection:0];

    if ((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        [self loadOrderDetails];
        
    } else {
        
        
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];

        [userInfo setObject:[self.orders objectAtIndex:tag] forKey:@"order"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMyOrderDetailScreenNotification object:nil userInfo:userInfo];
    }
}





@end

//
//  JAMyOrderDetailViewController.m
//  Jumia
//
//  Created by miguelseabra on 14/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMyOrderDetailViewController.h"
#import "JAMyOrderDetailView.h"
#import "JAMyOrdersViewController.h"

@interface JAMyOrderDetailViewController ()
//
@property (strong, nonatomic) UIScrollView *orderDetailsScrollView;
@property (strong, nonatomic) JAMyOrderDetailView *orderDetailsView;

@property (assign, nonatomic) RIApiResponse apiResponse;


@end

@implementation JAMyOrderDetailViewController

-(UIScrollView *)orderDetailsScrollView {
    if (!VALID_NOTEMPTY(_orderDetailsScrollView, UIScrollView)) {
        _orderDetailsScrollView = [UIScrollView new];
        [_orderDetailsScrollView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:_orderDetailsScrollView];
    }
    
    [_orderDetailsScrollView setFrame:CGRectMake(self.viewBounds.origin.x, self.viewBounds.origin.y,
                                           self.viewBounds.size.width, self.viewBounds.size.height)];
    return _orderDetailsScrollView;
}

-(JAMyOrderDetailView *)orderDetailsView {
    if (!VALID_NOTEMPTY(_orderDetailsView,JAMyOrderDetailView)) {
        _orderDetailsView = [JAMyOrderDetailView new];
        [_orderDetailsView setParent:self];
        [_orderDetailsView setHidden:YES];
        [_orderDetailsView setFrame:CGRectMake(0.f, 0.f,
                                               _orderDetailsView.frame.size.width,
                                               _orderDetailsView.frame.size.height)];
        [self.orderDetailsScrollView addSubview:_orderDetailsView];
    }
    return _orderDetailsView;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_ORDER_STATUS;
    self.navBarLayout.showBackButton = YES;
    
    self.apiResponse = RIApiResponseSuccess;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (VALID(self.trackingOrder, RITrackOrder)) {
        [self loadOrderDetails:self.trackingOrder.orderId];
    }else{
        [self loadOrderDetails:self.orderNumber];
    }
}

- (void)loadOrderDetails:(NSString *)orderNumber
{
    self.orderNumber = orderNumber;
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess) {
        [self showLoading];
    }
    
    [RIOrder trackOrderWithOrderNumber:orderNumber
                      WithSuccessBlock:^(RITrackOrder *trackingOrder) {
                          
                          self.trackingOrder = trackingOrder;
                          
                          [self setupViews];
                          
                          if(self.firstLoading)
                          {
                              NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                              [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                              self.firstLoading = NO;
                          }
                          [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                          [self hideLoading];
                          
                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                          self.apiResponse = apiResponse;
                          
                          if(self.firstLoading)
                          {
                              NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                              [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                              self.firstLoading = NO;
                          }
                          
                          [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadOrderDetails:) objects:@[orderNumber]];
                          [self hideLoading];
                      }];
}

-(void)setupViews {
    [self.orderDetailsView setupWithOrder:self.trackingOrder frame:self.viewBounds];
    [self.orderDetailsView setHidden:NO];
    
    [self.orderDetailsScrollView setContentSize:CGSizeMake(self.orderDetailsView.frame.size.width, self.orderDetailsView.frame.size.height)];
}

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    if ((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        UIViewController *viewController = [[[self.navigationController.viewControllers reverseObjectEnumerator] allObjects] objectAtIndex:1];
        [self.navigationController popViewControllerAnimated:NO];
        if (![viewController isKindOfClass:[JAMyOrdersViewController class]])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowMyOrdersScreenNotification object:self.orderNumber];
        }
    }
}

@end

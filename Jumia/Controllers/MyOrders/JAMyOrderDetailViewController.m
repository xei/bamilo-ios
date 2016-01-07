//
//  JAMyOrderDetailViewController.m
//  Jumia
//
//  Created by miguelseabra on 14/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMyOrderDetailViewController.h"
#import "JAMyOrderDetailView.h"

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
    
    [_orderDetailsScrollView setFrame:CGRectMake(self.viewBounds.origin.x, self.viewBounds.origin.y + 1.f,
                                           self.viewBounds.size.width, self.viewBounds.size.height - 1.f)];
    return _orderDetailsScrollView;
}

-(JAMyOrderDetailView *)orderDetailsView {
    if (!VALID_NOTEMPTY(_orderDetailsView,JAMyOrderDetailView)) {
        _orderDetailsView = [JAMyOrderDetailView new];
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
    self.navBarLayout.title = STRING_MY_ORDERS;
    self.navBarLayout.showBackButton = YES;
    
    self.apiResponse = RIApiResponseSuccess;

    [self loadOrderDetails];
}


- (void)loadOrderDetails
{
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess) {
        [self showLoading];
    }
    
    [RIOrder trackOrderWithOrderNumber:self.trackingOrder.orderId
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
                          self.trackingOrder = nil;
                          
                          if(self.firstLoading)
                          {
                              NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                              [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                              self.firstLoading = NO;
                          }
                          
                          [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadOrderDetails) objects:nil];
                          [self hideLoading];
                      }];
}

-(void)setupViews {
    [self.orderDetailsView setupWithOrder:self.trackingOrder maxWidth:self.viewBounds.size.width allowsFlip:NO];
    [self.orderDetailsView setHidden:NO];
}

@end

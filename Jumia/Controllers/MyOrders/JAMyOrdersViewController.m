//
//  JAMyOrdersViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyOrdersViewController.h"
#import "JAPickerScrollView.h"
#import "JATextFieldComponent.h"
#import "JACartListHeaderView.h"
#import "JAMyOrderCell.h"
#import "JAMyOrderDetailCell.h"
#import "JAMyOrderDetailView.h"
#import "RIOrder.h"
#import "RICustomer.h"

#define kMyOrderViewTag 999
#define kOrdersPerPage 25

typedef NS_ENUM(NSUInteger, RITrackOrderRequestState) {
    RITrackOrderRequestNotDone = 0,
    RITrackOrderRequestDone = 1
};

@interface JAMyOrdersViewController ()
<
UITextFieldDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
JAPickerScrollViewDelegate
>
{
    NSInteger _pickerScrollIndex;
}

@property (weak, nonatomic) IBOutlet JAPickerScrollView *myOrdersPickerScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (strong, nonatomic) NSArray* sortList;

@property (strong, nonatomic) UIScrollView *firstScrollView;
@property (strong, nonatomic) UIScrollView *secondScrollView;

@property (strong, nonatomic) NSMutableArray *orders;
@property (assign, nonatomic) NSInteger currentOrdersPage;
@property (assign, nonatomic) NSInteger ordersTotal;
@property (assign, nonatomic) BOOL isLoadingOrders;

@property (assign, nonatomic) BOOL animatedScroll;

// Track Order
@property (strong, nonatomic) UIView *trackOrderView;
@property (strong, nonatomic) UILabel *trackOrderLabel;
@property (strong, nonatomic) UIView *trackOrderSeparator;
@property (strong, nonatomic) JATextFieldComponent *trackOrderTextField;
@property (strong, nonatomic) UIButton *trackOrderButton;
@property (strong, nonatomic) UIView *myOrderView;
@property (strong, nonatomic) UILabel *myOrderViewLabel;
@property (strong, nonatomic) UIView *myOrderViewSeparator;
@property (strong, nonatomic) UILabel *myOrderHintLabel;
@property (assign, nonatomic) RITrackOrderRequestState trackOrderRequestState;
@property (strong, nonatomic) RITrackOrder *trackingOrder;

// Empty order history
@property (strong, nonatomic) UIView *emptyOrderHistoryView;
@property (strong, nonatomic) UIImageView *emptyOrderHistoryImageView;
@property (strong, nonatomic) UILabel *emptyOrderHistoryLabel;

// Order history
@property (strong, nonatomic) UICollectionView *ordersCollectionView;
@property (strong, nonatomic) UIScrollView *orderDetailsScrollView;
@property (strong, nonatomic) UIView *orderDetailsContainer;
@property (strong, nonatomic) UILabel *orderDetailsLabel;
@property (strong, nonatomic) UIView *orderDetailsSeparator;
@property (strong, nonatomic) JAMyOrderDetailView *orderDetailsView;
@property (strong, nonatomic) NSIndexPath *selectedOrderIndexPath;

@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JAMyOrdersViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.apiResponse = RIApiResponseSuccess;
    self.currentOrdersPage = 0;
    self.orders = [[NSMutableArray alloc] init];
    self.ordersTotal = 0;
    
    self.trackingOrder = nil;
    self.trackOrderRequestState = RITrackOrderRequestNotDone;
    
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_MY_ORDERS;
    
    self.sortList = [NSArray arrayWithObjects:STRING_ORDER_TRACKING, STRING_MY_ORDER_HISTORY, nil];
    if (RI_IS_RTL) {
        self.sortList = [NSArray arrayWithObjects:STRING_MY_ORDER_HISTORY, STRING_ORDER_TRACKING, nil];
    }
    
    [self.contentScrollView setPagingEnabled:YES];
    [self.contentScrollView setScrollEnabled:NO];
    
    self.firstScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.contentScrollView addSubview:self.firstScrollView];
    
    self.trackOrderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.trackOrderView.layer.cornerRadius = 5.0f;
    [self.trackOrderView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    self.trackOrderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.trackOrderLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.trackOrderLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.trackOrderLabel setText:STRING_TRACK_YOUR_ORDER];
    [self.trackOrderLabel setBackgroundColor:[UIColor clearColor]];
    [self.trackOrderView addSubview:self.trackOrderLabel];
    
    self.trackOrderSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    [self.trackOrderSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.trackOrderView addSubview:self.trackOrderSeparator];
    
    self.trackOrderTextField = [JATextFieldComponent getNewJATextFieldComponent];
    self.trackOrderTextField.frame = CGRectMake(-100.0f, -100.0f, self.trackOrderTextField.frame.size.width, self.trackOrderTextField.frame.size.height);
    [self.trackOrderTextField setupWithLabel:STRING_ORDER_ID value:self.startingTrackOrderNumber mandatory:YES];
    [self.trackOrderView addSubview:self.trackOrderTextField];
    
    self.trackOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.trackOrderButton setTitle:STRING_TRACK_YOUR_ORDER forState:UIControlStateNormal];
    [self.trackOrderButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.trackOrderButton addTarget:self action:@selector(trackOrder:) forControlEvents:UIControlEventTouchUpInside];
    [self.trackOrderButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
    [self.trackOrderView addSubview:self.trackOrderButton];
    
    [self.firstScrollView addSubview:self.trackOrderView];
    
    self.myOrderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.myOrderView.layer.cornerRadius = 5.0f;
    [self.myOrderView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    self.myOrderViewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.myOrderViewLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.myOrderViewLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.myOrderViewLabel setText:STRING_TRACK_YOUR_ORDER];
    [self.myOrderViewLabel setBackgroundColor:[UIColor clearColor]];
    [self.myOrderView addSubview:self.myOrderViewLabel];
    
    self.myOrderViewSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    [self.myOrderViewSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.myOrderView addSubview:self.myOrderViewSeparator];
    
    self.myOrderHintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.myOrderHintLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.myOrderHintLabel setTextColor:UIColorFromRGB(0xcccccc)];
    [self.myOrderHintLabel setText:STRING_TRACK_YOUR_ORDER_TIP];
    [self.myOrderHintLabel setBackgroundColor:[UIColor clearColor]];
    [self.myOrderView addSubview:self.myOrderHintLabel];
    
    UINib *myOrderHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    UINib *myOrderListCellNib = [UINib nibWithNibName:@"JAMyOrderCell" bundle:nil];
    UINib *myOrderDetailListCellNib = [UINib nibWithNibName:@"JAMyOrderDetailCell" bundle:nil];
    
    UICollectionViewFlowLayout* ordersCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [ordersCollectionViewFlowLayout setMinimumLineSpacing:0.0f];
    [ordersCollectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
    [ordersCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [ordersCollectionViewFlowLayout setItemSize:CGSizeZero];
    [ordersCollectionViewFlowLayout setHeaderReferenceSize:CGSizeZero];
    
    self.ordersCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:ordersCollectionViewFlowLayout];
    [self.ordersCollectionView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.ordersCollectionView.layer.cornerRadius = 5.0f;
    
    [self.ordersCollectionView registerNib:myOrderHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader"];
    [self.ordersCollectionView registerNib:myOrderListCellNib forCellWithReuseIdentifier:@"myOrderListCell"];;
    [self.ordersCollectionView registerNib:myOrderDetailListCellNib forCellWithReuseIdentifier:@"myOrderDetailListCell"];;
    [self.ordersCollectionView setDataSource:self];
    [self.ordersCollectionView setDelegate:self];
    [self.ordersCollectionView setHidden:YES];
    
    [self.contentScrollView addSubview:self.ordersCollectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateFromInterfaceOrientation:) name:kAppWillEnterForeground object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffMenuSwipePanelNotification
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboard)
                                                 name:kOpenMenuNotification
                                               object:nil];
    
    [self.firstScrollView setFrame:self.contentScrollView.frame];
    
    self.myOrdersPickerScrollView.delegate = self;
    self.myOrdersPickerScrollView.startingIndex = self.selectedIndex;
    
    //this will trigger load methods
    [self.myOrdersPickerScrollView setOptions:self.sortList];
    
    if([RICustomer checkIfUserIsLogged])
    {
        [self loadOrders];
    } else {
        [self setupViews];
    }
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
              self.ordersTotal = ordersTotal;
              
              self.isLoadingOrders = NO;
              [self hideLoading];
              [self removeErrorView];
              
              [self setupViews];
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
                   [self showErrorView:noConnection startingY:CGRectGetMaxY(self.myOrdersPickerScrollView.frame) selector:@selector(loadOrders) objects:nil];
               }
           }];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupMyOrdersViews:self.view.frame.size.width height:self.view.frame.size.height interfaceOrientation:self.interfaceOrientation];
    
    [self setupViews];
    
    [self selectedIndex:_pickerScrollIndex];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)setupViews
{
    self.animatedScroll = NO;
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [self.sortList count], self.view.frame.size.height - self.myOrdersPickerScrollView.frame.size.height);
    
    [self setupMyOrdersViews:self.view.frame.size.width height:self.view.frame.size.height - self.myOrdersPickerScrollView.frame.size.height interfaceOrientation:self.interfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Swipe Actions
- (IBAction)swipeRight:(id)sender
{
    //    [self removeNotifications];
    [self.myOrdersPickerScrollView scrollRightAnimated:YES];
}

- (IBAction)swipeLeft:(id)sender
{
    //    [self removeNotifications];
    [self.myOrdersPickerScrollView scrollLeftAnimated:YES];
}

- (void) hideKeyboard
{
    [self.trackOrderTextField.textField resignFirstResponder];
}

#pragma mark JAPickerScrollView
- (void)selectedIndex:(NSInteger)index
{
    _pickerScrollIndex = index;
    if (RI_IS_RTL) {
        if (0==_pickerScrollIndex) {
            _pickerScrollIndex = 1;
        } else if (1==_pickerScrollIndex) {
            _pickerScrollIndex = 0;
        }
    }
    
    // Track Order
    if(0 == _pickerScrollIndex)
    {
        self.screenName = @"OrdingTracker";
        [[RITrackingWrapper sharedInstance] trackScreenWithName:self.screenName];
        
        //the actual position in scroll is correct, so use index instead of pickerScrollIndex
        [self.contentScrollView scrollRectToVisible:CGRectMake(index * self.contentScrollView.frame.size.width,
                                                               0.0f,
                                                               self.contentScrollView.frame.size.width,
                                                               self.contentScrollView.frame.size.height) animated:self.animatedScroll];
    }
    // Order history
    else if(1 == _pickerScrollIndex)
    {
        self.screenName = @"MyOrders";
        if([RICustomer checkIfUserIsLogged])
        {
            [[RITrackingWrapper sharedInstance] trackScreenWithName:self.screenName];
            
            //the actual position in scroll is correct, so use index instead of pickerScrollIndex
            [self.contentScrollView scrollRectToVisible:CGRectMake(index * self.contentScrollView.frame.size.width,
                                                                   0.0f,
                                                                   self.contentScrollView.frame.size.width,
                                                                   self.contentScrollView.frame.size.height) animated:self.animatedScroll];
        }
        else
        {
            if (YES == self.animatedScroll) {
                //if the scroll is animated, it means the user is the one scrolling and not the menu redraw
                NSNotification *nextNotification = [NSNotification notificationWithName:kShowMyOrdersScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:index] forKey:@"selected_index"]];
                
                NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:nextNotification forKey:@"notification"];
                [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"from_side_menu"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
        }
    }
    self.animatedScroll = YES;
    [self hideKeyboard];
}

#pragma mark - Actions
- (IBAction)trackOrder:(id)sender
{
    [self.view endEditing:YES];
    
    if (VALID_NOTEMPTY(self.trackOrderTextField.textField.text, NSString))
    {
        [self loadOrderDetails];
    }
    else
    {
        [self showMessage:STRING_ENTER_ORDER_ID success:NO];
    }
}

- (void)loadOrderDetails
{
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    self.trackOrderRequestState = RITrackOrderRequestDone;
    
    [RIOrder trackOrderWithOrderNumber:self.trackOrderTextField.textField.text
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
                              if (VALID_NOTEMPTY(self.trackOrderTextField.textField.text, NSString))
                              {
                                  [self showMessage:STRING_NO_CONNECTION success:NO];
                                  
                              }else{
                                  
                                  [self showErrorView:YES startingY:0.0f selector:@selector(loadOrderDetails) objects:nil];
                              }
                          }
                          else
                          {
                              [self builContentForNoResult];
                          }
                          
                          [self hideLoading];
                      }];
}

#pragma mark - Textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self trackOrder:nil];
    
    return YES;
}

#pragma mark - Build variable content

- (void)buildContentForOrder:(RITrackOrder *)order
{
    // Clean the variable view if the user track another order
    for (UIView *view in self.myOrderView.subviews) {
        if (kMyOrderViewTag == view.tag)
        {
            [view removeFromSuperview];
        }
    }
    
    [self.myOrderView setHidden:NO];
    
    
    CGFloat startingY = self.myOrderViewSeparator.frame.origin.y + 10.0f;
    
    [self.myOrderViewLabel setText:[NSString stringWithFormat:@"# %@", order.orderId]];
    
    // Creation date
    UILabel *creationDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f,
                                                                           startingY,
                                                                           150.0f,
                                                                           20.0f)];
    creationDateLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
    creationDateLabel.textColor = UIColorFromRGB(0x4e4e4e);
    creationDateLabel.text = STRING_CREATION_DATE;
    creationDateLabel.tag = kMyOrderViewTag;
    [creationDateLabel sizeToFit];
    [self.myOrderView addSubview:creationDateLabel];
    
    UILabel *creationDateLabelDetail = [[UILabel alloc] initWithFrame:CGRectMake(creationDateLabel.frame.size.width + 12.0f,
                                                                                 startingY,
                                                                                 200.0f,
                                                                                 20.0f)];
    creationDateLabelDetail.font = [UIFont fontWithName:kFontLightName size:13.0f];
    creationDateLabelDetail.textColor = UIColorFromRGB(0x666666);
    creationDateLabelDetail.text = order.creationDate;
    [creationDateLabelDetail sizeToFit];
    creationDateLabelDetail.tag = kMyOrderViewTag;
    [self.myOrderView addSubview:creationDateLabelDetail];
    
    startingY += creationDateLabel.frame.size.height + 10.0f;
    
    // Payment method
    UILabel *paymentMethodLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 150, 20)];
    paymentMethodLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
    paymentMethodLabel.textColor = UIColorFromRGB(0x4e4e4e);
    paymentMethodLabel.text = STRING_PAYMENT_METHOD;
    paymentMethodLabel.tag = kMyOrderViewTag;
    [paymentMethodLabel sizeToFit];
    [self.myOrderView addSubview:paymentMethodLabel];
    
    UILabel *paymentMethodLabelDetail = [[UILabel alloc] initWithFrame:CGRectMake(paymentMethodLabel.frame.size.width + 12, startingY, 200, 20)];
    paymentMethodLabelDetail.font = [UIFont fontWithName:kFontLightName size:13.0f];
    paymentMethodLabelDetail.textColor = UIColorFromRGB(0x666666);
    paymentMethodLabelDetail.text = order.paymentMethod;
    [paymentMethodLabelDetail sizeToFit];
    paymentMethodLabelDetail.tag = kMyOrderViewTag;
    [self.myOrderView addSubview:paymentMethodLabelDetail];
    
    startingY += paymentMethodLabelDetail.frame.size.height + 20;
    
    // Products label
    UILabel *productsLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 20)];
    productsLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
    productsLabel.textColor = UIColorFromRGB(0x4e4e4e);
    productsLabel.text = STRING_PRODUCTS;
    [productsLabel sizeToFit];
    productsLabel.tag = kMyOrderViewTag;
    [self.myOrderView addSubview:productsLabel];
    
    startingY += productsLabel.frame.size.height + 20.0f;
    
    for (RIItemCollection *item in order.itemCollection)
    {
        UILabel *labelProductName = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 40)];
        labelProductName.numberOfLines = 0;
        labelProductName.font = [UIFont fontWithName:kFontLightName size:13.0f];
        labelProductName.textColor = UIColorFromRGB(0x4e4e4e);
        labelProductName.text = item.name;
        [labelProductName sizeToFit];
        labelProductName.tag = kMyOrderViewTag;
        [self.myOrderView addSubview:labelProductName];
        
        startingY += labelProductName.frame.size.height + 6;
        
        UILabel *labelQuantity = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 40)];
        labelQuantity.font = [UIFont fontWithName:kFontRegularName size:13.0f];
        labelQuantity.textColor = UIColorFromRGB(0x666666);
        labelQuantity.text = [NSString stringWithFormat:STRING_QUANTITY, [item.quantity stringValue]];
        [labelQuantity sizeToFit];
        labelQuantity.tag = kMyOrderViewTag;
        [self.myOrderView addSubview:labelQuantity];
        
        startingY += labelQuantity.frame.size.height + 6;
        
        RIStatus *status = [item.status firstObject];
        
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 20)];
        statusLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
        statusLabel.textColor = UIColorFromRGB(0x666666);
        statusLabel.text = status.itemStatus;
        [statusLabel sizeToFit];
        statusLabel.tag = kMyOrderViewTag;
        [self.myOrderView addSubview:statusLabel];
        
        startingY += statusLabel.frame.size.height + 20;
    }
    
    self.myOrderView.frame = CGRectMake(self.myOrderView.frame.origin.x,
                                        self.myOrderView.frame.origin.y,
                                        self.myOrderView.frame.size.width,
                                        startingY);
    
    if(VALID_NOTEMPTY(self.secondScrollView, UIScrollView))
    {
        self.secondScrollView.contentSize = CGSizeMake(self.secondScrollView.frame.size.width,
                                                       CGRectGetMaxY(self.myOrderView.frame) + 6.0f);
    }
    else
    {
        self.firstScrollView.contentSize = CGSizeMake(self.firstScrollView.frame.size.width,
                                                      CGRectGetMaxY(self.myOrderView.frame) + 6.0f);
    }
}

- (void)builContentForNoResult
{
    // Clean the variable view if the user track another order
    for (UIView *view in self.myOrderView.subviews) {
        if (kMyOrderViewTag == view.tag)
        {
            [view removeFromSuperview];
        }
    }
    
    [self.myOrderView setHidden:NO];
    
    [self.myOrderViewLabel setText:[NSString stringWithFormat:@"# %@", self.trackOrderTextField.textField.text]];
    
    UILabel *noResultsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noResultsLabel.textAlignment = NSTextAlignmentCenter;
    noResultsLabel.numberOfLines = 0;
    noResultsLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    noResultsLabel.textColor = UIColorFromRGB(0x666666);
    noResultsLabel.text = STRING_ERROR_NO_RESULTS_FOR_TRACKING_ID;
    noResultsLabel.tag = kMyOrderViewTag;
    [self.myOrderView addSubview:noResultsLabel];
    
    CGFloat noResultsHorizontalMargin = 10.0f;
    CGFloat noResultsVerticalMargin = 10.0f;
    CGFloat noResultsWidth = self.myOrderView.frame.size.width - (2 * noResultsHorizontalMargin);
    
    CGRect noResultsLabelRect = [noResultsLabel.text boundingRectWithSize:CGSizeMake(noResultsWidth, 1000.0f)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName:noResultsLabel.font} context:nil];
    
    if(noResultsLabelRect.size.height + (2 * noResultsVerticalMargin) > self.trackOrderView.frame.size.height)
    {
        [noResultsLabel setFrame:CGRectMake((self.myOrderView.frame.size.width - noResultsLabelRect.size.width) / 2,
                                            CGRectGetMaxY(self.myOrderViewSeparator.frame) + noResultsVerticalMargin,
                                            noResultsLabelRect.size.width,
                                            ceilf(noResultsLabelRect.size.height))];
        
        [self.myOrderView setFrame:CGRectMake(self.myOrderView.frame.origin.x,
                                              self.myOrderView.frame.origin.y,
                                              self.myOrderView.frame.size.width,
                                              CGRectGetMaxY(noResultsLabel.frame) + noResultsVerticalMargin)];
    }
    else
    {
        CGFloat noResultsMaxHeight = self.trackOrderView.frame.size.height - CGRectGetMaxY(self.myOrderViewSeparator.frame);
        [noResultsLabel setFrame:CGRectMake((self.myOrderView.frame.size.width - noResultsLabelRect.size.width) / 2,
                                            CGRectGetMaxY(self.myOrderViewSeparator.frame) + ((noResultsMaxHeight - ceilf(noResultsLabelRect.size.height)) / 2),
                                            noResultsLabelRect.size.width,
                                            ceilf(noResultsLabelRect.size.height))];
        
        
        [self.myOrderView setFrame:CGRectMake(self.myOrderView.frame.origin.x,
                                              self.myOrderView.frame.origin.y,
                                              self.myOrderView.frame.size.width,
                                              self.trackOrderView.frame.size.height)];
    }
    
    if(VALID_NOTEMPTY(self.secondScrollView, UIScrollView))
    {
        self.secondScrollView.contentSize = CGSizeMake(self.secondScrollView.frame.size.width,
                                                       CGRectGetMaxY(self.myOrderView.frame) + 6.0f);
    }
    else
    {
        self.firstScrollView.contentSize = CGSizeMake(self.firstScrollView.frame.size.width,
                                                      CGRectGetMaxY(self.myOrderView.frame) + 6.0f);
    }
}

#pragma mark - Init elements

- (void)setupMyOrdersViews:(CGFloat)width height:(CGFloat)height interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat horizontalMargin = 6.0f;
    CGFloat verticalMargin = 6.0f;
    
    CGFloat viewsWidth = width - (2 * horizontalMargin);
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        viewsWidth = (width - (3 * horizontalMargin)) / 2;
        self.secondScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(horizontalMargin + viewsWidth + horizontalMargin,
                                                                               0.0f,
                                                                               viewsWidth,
                                                                               height)];
        [self.contentScrollView addSubview:self.secondScrollView];
    }
    else if(VALID_NOTEMPTY(self.secondScrollView, UIScrollView))
    {
        [self.myOrderView removeFromSuperview];
        [self.myOrderHintLabel removeFromSuperview];
        
        [self.secondScrollView removeFromSuperview];
        self.secondScrollView = nil;
    }
    
    
    [self.firstScrollView setFrame:CGRectMake(horizontalMargin,
                                              0.0f,
                                              viewsWidth,
                                              height)];
    
    CGFloat trackOrderViewWidth = viewsWidth;
    
    self.trackOrderLabel.textAlignment = NSTextAlignmentLeft;
    [self.trackOrderLabel setFrame:CGRectMake(horizontalMargin,
                                              0.0f,
                                              trackOrderViewWidth - (2 * horizontalMargin),
                                              26.0f)];
    
    [self.trackOrderSeparator setFrame:CGRectMake(0.0f,
                                                  CGRectGetMaxY(self.trackOrderLabel.frame),
                                                  trackOrderViewWidth,
                                                  1.0f)];
    
    [self.trackOrderTextField setFrame:CGRectMake(0.0f,
                                                  CGRectGetMaxY(self.trackOrderSeparator.frame) + 11.0f,
                                                  trackOrderViewWidth,
                                                  self.trackOrderTextField.frame.size.height)];
    
    NSString *orangeButtonName = @"orangeMedium_%@";
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
        {
            orangeButtonName = @"orangeHalfMedium_%@";
        }
        else
        {
            orangeButtonName = @"orangeMediumPortrait_%@";
        }
    }
    
    UIImage *orangeButtonImage = [UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"normal"]];
    [self.trackOrderButton setBackgroundImage:orangeButtonImage forState:UIControlStateNormal];
    [self.trackOrderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]]forState:UIControlStateHighlighted];
    [self.trackOrderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]]forState:UIControlStateSelected];
    [self.trackOrderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"disabled"]]forState:UIControlStateDisabled];
    
    [self.trackOrderButton setFrame:CGRectMake((trackOrderViewWidth - orangeButtonImage.size.width) / 2.0f,
                                               CGRectGetMaxY(self.trackOrderTextField.frame) + 15.0f,
                                               orangeButtonImage.size.width,
                                               orangeButtonImage.size.height)];
    
    [self.trackOrderView setFrame:CGRectMake(0.0f,
                                             verticalMargin,
                                             trackOrderViewWidth,
                                             CGRectGetMaxY(self.trackOrderButton.frame) + 6.0f)];
    
    self.firstScrollView.contentSize = CGSizeMake(self.firstScrollView.frame.size.width,
                                                  CGRectGetMaxY(self.trackOrderView.frame) + 6.0f);
    
    self.myOrderViewLabel.textAlignment = NSTextAlignmentLeft;
    [self.myOrderViewLabel setFrame:CGRectMake(horizontalMargin,
                                               0.0f,
                                               trackOrderViewWidth - (2 * horizontalMargin),
                                               26.0f)];
    
    [self.myOrderViewSeparator setFrame:CGRectMake(0.0f,
                                                   CGRectGetMaxY(self.myOrderViewLabel.frame),
                                                   trackOrderViewWidth,
                                                   1.0f)];
    
    if(VALID_NOTEMPTY(self.secondScrollView, UIScrollView))
    {
        [self.myOrderHintLabel setTag:kMyOrderViewTag];
        CGFloat myOrderViewHeight = CGRectGetMaxY(self.trackOrderButton.frame) + 6.0f;
        self.myOrderHintLabel.numberOfLines = 2;
        [self.myOrderHintLabel setFrame:CGRectMake(0,
                                                   0,
                                                   trackOrderViewWidth,
                                                   1)];
        [self.myOrderHintLabel sizeToFit];
        [self.myOrderHintLabel setFrame:CGRectMake((trackOrderViewWidth - self.myOrderHintLabel.frame.size.width) / 2,
                                                   CGRectGetMaxY(self.myOrderViewSeparator.frame) + ((myOrderViewHeight - CGRectGetMaxY(self.myOrderViewSeparator.frame)) - self.myOrderHintLabel.frame.size.height) / 2,
                                                   self.myOrderHintLabel.frame.size.width,
                                                   self.myOrderHintLabel.frame.size.height)];

        [self.myOrderView addSubview:self.myOrderHintLabel];
        [self.myOrderView setFrame:CGRectMake(0.0f,
                                              verticalMargin,
                                              trackOrderViewWidth,
                                              myOrderViewHeight)];
        [self.myOrderView setHidden:NO];
        [self.secondScrollView addSubview:self.myOrderView];
    }
    else
    {
        [self.myOrderView setHidden:YES];
        [self.myOrderView setFrame:CGRectMake(0.0f,
                                              CGRectGetMaxY(self.trackOrderView.frame) + 6.0f,
                                              trackOrderViewWidth,
                                              27.0f)];
        [self.firstScrollView addSubview:self.myOrderView];
    }
    
    if(RITrackOrderRequestDone == self.trackOrderRequestState)
    {
        if(VALID_NOTEMPTY(self.trackingOrder, RITrackOrder))
        {
            [self buildContentForOrder:self.trackingOrder];
        }
        else
        {
            [self builContentForNoResult];
        }
    }
    
    CGFloat orderHistoryViewHorizontalMargin = 6.0f;
    CGFloat orderHistoryViewVerticalMargin = 6.0f;
    
    // This layout should start on the second page of the scrollview
    CGFloat startingX = width;
    
    CGFloat collectionHeight = 0.0f;
    if(VALID_NOTEMPTY(self.orders, NSArray))
    {
        [self.emptyOrderHistoryView setHidden:YES];
        [self.ordersCollectionView setHidden:NO];
        [self.ordersCollectionView reloadData];
        
        // 27.0f is the height of the header
        collectionHeight = 27.0f + [JAMyOrderCell getCellHeight] * [self.orders count];
        if(!(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)))
        {
            if(VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath) && self.selectedOrderIndexPath.row < [self.orders count])
            {
                // Add selected row
                RITrackOrder *order = [self.orders objectAtIndex:self.selectedOrderIndexPath.row];
                collectionHeight += [JAMyOrderDetailView getOrderDetailViewHeight:order maxWidth:self.ordersCollectionView.frame.size.width];
            }
        }
        
        if(collectionHeight > self.contentScrollView.contentSize.height - 12.0f)
        {
            collectionHeight = self.contentScrollView.contentSize.height - 12.0f;
        }
        
        [self.ordersCollectionView setFrame:CGRectMake(startingX + orderHistoryViewHorizontalMargin,
                                                       orderHistoryViewVerticalMargin,
                                                       viewsWidth,
                                                       collectionHeight)];
        
        if(!VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath) && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            self.selectedOrderIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        }
        
        [self setupOrderDetailView:viewsWidth interfaceOrientation:interfaceOrientation redrawingFromScratch:YES];
        
        [self.contentScrollView bringSubviewToFront:self.ordersCollectionView];
    }
    else
    {
        [self setupEmptyOrderHistoryViews:width height:height interfaceOrientation:interfaceOrientation];
    }
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
        [self.emptyOrderHistoryImageView flipViewImage];
    }
}

- (void)setupOrderDetailView:(CGFloat)width interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation redrawingFromScratch:(BOOL)redrawingFromScratch
{
    CGFloat scrollViewX = self.orderDetailsScrollView.frame.origin.x;
    if (YES==redrawingFromScratch) {
        scrollViewX = CGRectGetMaxX(self.ordersCollectionView.frame) + 6.0f;
    }
    
    if(VALID_NOTEMPTY(self.orderDetailsView, UIView))
    {
        [self.orderDetailsView removeFromSuperview];
        self.orderDetailsView = nil;
    }
    if(VALID_NOTEMPTY(self.orderDetailsSeparator, UIView))
    {
        [self.orderDetailsSeparator removeFromSuperview];
        self.orderDetailsSeparator = nil;
    }
    if(VALID_NOTEMPTY(self.orderDetailsLabel, UILabel))
    {
        [self.orderDetailsLabel removeFromSuperview];
        self.orderDetailsLabel = nil;
    }
    if(VALID_NOTEMPTY(self.orderDetailsContainer, UIView))
    {
        [self.orderDetailsContainer removeFromSuperview];
        self.orderDetailsContainer = nil;
    }
    if(VALID_NOTEMPTY(self.orderDetailsScrollView, UIScrollView))
    {
        [self.orderDetailsScrollView removeFromSuperview];
        self.orderDetailsScrollView = nil;
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        if(VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath))
        {
            self.orderDetailsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(scrollViewX,
                                                                                         0.0f,
                                                                                         width,
                                                                                         self.contentScrollView.frame.size.height)];
            
            self.orderDetailsContainer = [[UIView alloc] initWithFrame:CGRectZero];
            [self.orderDetailsContainer setBackgroundColor:UIColorFromRGB(0xffffff)];
            self.orderDetailsContainer.layer.cornerRadius = 5.0f;
            
            self.orderDetailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 0.0f, width-12.0f, 26.0f)];
            [self.orderDetailsLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
            [self.orderDetailsLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
            [self.orderDetailsLabel setText:STRING_ORDER_DETAILS];
            [self.orderDetailsLabel setBackgroundColor:[UIColor clearColor]];
            self.orderDetailsLabel.textAlignment = NSTextAlignmentLeft;
            [self.orderDetailsContainer addSubview:self.orderDetailsLabel];
            
            self.orderDetailsSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.orderDetailsLabel.frame), width, 1.0f)];
            [self.orderDetailsSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
            [self.orderDetailsContainer addSubview:self.orderDetailsSeparator];
            
            RITrackOrder *order = [self.orders objectAtIndex:self.selectedOrderIndexPath.row];
            CGFloat myOrderDetailsViewHeight = [JAMyOrderDetailView getOrderDetailViewHeight:order maxWidth:width];
            self.orderDetailsView = [[JAMyOrderDetailView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                          CGRectGetMaxY(self.orderDetailsSeparator.frame),
                                                                                          width,
                                                                                          myOrderDetailsViewHeight)];
            BOOL allowsFlip = !redrawingFromScratch;
            [self.orderDetailsView setupWithOrder:order maxWidth:width allowsFlip:allowsFlip];
            if (RI_IS_RTL && allowsFlip) {
                [self.orderDetailsLabel flipViewAlignment];
            }
            
            [self.orderDetailsContainer addSubview:self.orderDetailsView];
            [self.orderDetailsContainer setFrame:CGRectMake(0.0f,
                                                            6.0f,
                                                            width,
                                                            CGRectGetMaxY(self.orderDetailsView.frame))];
            [self.orderDetailsScrollView addSubview:self.orderDetailsContainer];
            [self.contentScrollView addSubview:self.orderDetailsScrollView];
            [self.orderDetailsScrollView setContentSize:CGSizeMake(self.orderDetailsScrollView.frame.size.width,
                                                                   CGRectGetMaxY(self.orderDetailsContainer.frame) + 6.0f)];
        }
    }
}

- (void)setupEmptyOrderHistoryViews:(CGFloat)width height:(CGFloat)height interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat emptyOrderHistoryViewHorizontalMargin = 6.0f;
    CGFloat emptyOrderHistoryViewVerticalMargin = 6.0f;
    CGFloat emptyOrderHistoryViewMinHeight = 200.0f;
    CGFloat emptyOrderHistoryViewInnerHorizontaMargin = 6.0f;
    CGFloat emptyOrderHistoryViewInnerVerticalMargin = 20.0f;
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        emptyOrderHistoryViewMinHeight = 300.0f;
        if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
        {
            emptyOrderHistoryViewInnerHorizontaMargin = 60.0f;
        }
    }
    
    if(VALID_NOTEMPTY(self.emptyOrderHistoryView, UIView))
    {
        [self.emptyOrderHistoryView removeFromSuperview];
    }
    
    self.emptyOrderHistoryView = [[UIView alloc] initWithFrame:CGRectZero];
    self.emptyOrderHistoryView.layer.cornerRadius = 5.0f;
    [self.emptyOrderHistoryView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.contentScrollView addSubview:self.emptyOrderHistoryView];
    
    // This layout should start on the second page of the scrollview
    CGFloat startingX = width;
    [self.emptyOrderHistoryView setFrame:CGRectMake(startingX + emptyOrderHistoryViewHorizontalMargin,
                                                    emptyOrderHistoryViewVerticalMargin,
                                                    width - (2 * emptyOrderHistoryViewHorizontalMargin),
                                                    0.0f)];
    
    CGFloat emptyOrderViewActualSize = 0.0f;
    
    
    if(VALID_NOTEMPTY(self.emptyOrderHistoryImageView, UIImageView))
    {
        [self.emptyOrderHistoryImageView removeFromSuperview];
    }
    UIImage *emptyOrderImage = [UIImage imageNamed:@"noOrdersImage"];
    self.emptyOrderHistoryImageView = [[UIImageView alloc] initWithImage:emptyOrderImage];
    [self.emptyOrderHistoryImageView setFrame:CGRectZero];
    [self.emptyOrderHistoryView addSubview:self.emptyOrderHistoryImageView];
    emptyOrderViewActualSize += emptyOrderImage.size.height;
    
    if(VALID_NOTEMPTY(self.emptyOrderHistoryLabel, UILabel))
    {
        [self.emptyOrderHistoryLabel removeFromSuperview];
    }
    self.emptyOrderHistoryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.emptyOrderHistoryLabel setNumberOfLines:0];
    [self.emptyOrderHistoryLabel setFont:[UIFont fontWithName:kFontRegularName size:15.0f]];
    [self.emptyOrderHistoryLabel setTextColor:UIColorFromRGB(0xcccccc)];
    [self.emptyOrderHistoryLabel setText:STRING_NO_ORDERS];
    [self.emptyOrderHistoryLabel setTextAlignment:NSTextAlignmentCenter];
    [self.emptyOrderHistoryLabel setBackgroundColor:[UIColor clearColor]];
    [self.emptyOrderHistoryView addSubview:self.emptyOrderHistoryLabel];
    
    CGRect emptyOrderHistoryLabelRect = [self.emptyOrderHistoryLabel.text boundingRectWithSize:CGSizeMake(self.emptyOrderHistoryView.frame.size.width - (2 * emptyOrderHistoryViewInnerHorizontaMargin), 1000.0f)
                                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                                    attributes:@{NSFontAttributeName:self.emptyOrderHistoryLabel.font} context:nil];
    emptyOrderViewActualSize += ceilf(emptyOrderHistoryLabelRect.size.height) + 10.0f;
    
    
    CGFloat emptyOrderHistoryViewStartY = emptyOrderHistoryViewInnerVerticalMargin;
    if(emptyOrderViewActualSize + (2 * emptyOrderHistoryViewInnerVerticalMargin) < emptyOrderHistoryViewMinHeight)
    {
        emptyOrderHistoryViewStartY = (emptyOrderHistoryViewMinHeight - emptyOrderViewActualSize) / 2;
        emptyOrderViewActualSize = emptyOrderHistoryViewMinHeight;
    }
    else
    {
        emptyOrderViewActualSize += (2 * emptyOrderHistoryViewInnerVerticalMargin);
    }
    
    [self.emptyOrderHistoryView setFrame:CGRectMake(startingX +emptyOrderHistoryViewHorizontalMargin,
                                                    emptyOrderHistoryViewVerticalMargin,
                                                    width - (2 * emptyOrderHistoryViewHorizontalMargin),
                                                    emptyOrderViewActualSize)];
    
    [self.emptyOrderHistoryImageView setFrame:CGRectMake((self.emptyOrderHistoryView.frame.size.width - emptyOrderImage.size.width) / 2,
                                                         emptyOrderHistoryViewStartY,
                                                         emptyOrderImage.size.width,
                                                         emptyOrderImage.size.height)];
    
    [self.emptyOrderHistoryLabel setFrame:CGRectMake(emptyOrderHistoryViewInnerHorizontaMargin,
                                                     CGRectGetMaxY(self.emptyOrderHistoryImageView.frame) + 10.0f,
                                                     self.emptyOrderHistoryView.frame.size.width - (2 * emptyOrderHistoryViewInnerHorizontaMargin),
                                                     ceilf(emptyOrderHistoryLabelRect.size.height))];
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize referenceSizeForHeaderInSection = CGSizeZero;
    if(collectionView == self.ordersCollectionView)
    {
        referenceSizeForHeaderInSection = CGSizeMake(self.ordersCollectionView.frame.size.width, 27.0f);
    }
    
    return referenceSizeForHeaderInSection;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize sizeForItemAtIndexPath = CGSizeZero;
    
    if(collectionView == self.ordersCollectionView)
    {
        sizeForItemAtIndexPath = CGSizeMake(self.ordersCollectionView.frame.size.width, [JAMyOrderCell getCellHeight]);
        
        // If it is iPad in landscape then the order detail view appears out of the collection view
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath) && ((self.selectedOrderIndexPath.row + 1) == indexPath.row))
        {
            // order detail row
            if(VALID_NOTEMPTY(self.orders, NSArray) && self.selectedOrderIndexPath.row < [self.orders count])
            {
                RITrackOrder *order = [self.orders objectAtIndex:self.selectedOrderIndexPath.row];
                sizeForItemAtIndexPath = CGSizeMake(self.ordersCollectionView.frame.size.width, [JAMyOrderDetailView getOrderDetailViewHeight:order maxWidth:self.ordersCollectionView.frame.size.width]);
            }
        }
    }
    
    return sizeForItemAtIndexPath;
}

#pragma mark UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    
    if (kind == UICollectionElementKindSectionHeader) {
        JACartListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader" forIndexPath:indexPath];
        
        if(collectionView == self.ordersCollectionView)
        {
            [headerView loadHeaderWithText:STRING_MY_ORDERS width:self.ordersCollectionView.frame.size.width];
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
        if(VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath) && UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        {
            numberOfItemsInSection++;
        }
    }
    return numberOfItemsInSection++;
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
        
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            if(VALID_NOTEMPTY(self.orders, NSArray) && indexPath.row < [self.orders count])
            {
                RITrackOrder *order = [self.orders objectAtIndex:indexPath.row];
                JAMyOrderCell *myOrderCell = (JAMyOrderCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"myOrderListCell" forIndexPath:indexPath];
                [myOrderCell setupWithOrder:order isInLandscape:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)];
                
                [myOrderCell.clickableView setTag:indexPath.row];
                [myOrderCell.clickableView addTarget:self action:@selector(selectedOrder:) forControlEvents:UIControlEventTouchUpInside];
                
                [myOrderCell.clickableView setSelected:NO];
                if(VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath) && (self.selectedOrderIndexPath.row) == indexPath.row)
                {
                    [myOrderCell.clickableView setSelected:YES];
                }
                
                cell = myOrderCell;
            }
        }
        else
        {
            if(VALID_NOTEMPTY(self.orders, NSArray) && indexPath.row < [self.orders count] + 1)
            {
                if(VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath) && (self.selectedOrderIndexPath.row + 1) == indexPath.row)
                {
                    RITrackOrder *order = [self.orders objectAtIndex:self.selectedOrderIndexPath.row];
                    
                    // Order detail row
                    JAMyOrderDetailCell *myOrderDetailCell = (JAMyOrderDetailCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"myOrderDetailListCell" forIndexPath:indexPath];
                    [myOrderDetailCell setupWithOrder:order];
                    cell = myOrderDetailCell;
                }
                else
                {
                    NSInteger orderIndex = indexPath.row;
                    if(VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath) && self.selectedOrderIndexPath.row < indexPath.row)
                    {
                        orderIndex--;
                    }
                    
                    if(orderIndex < [self.orders count])
                    {
                        RITrackOrder *order = [self.orders objectAtIndex:orderIndex];
                        JAMyOrderCell *myOrderCell = (JAMyOrderCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"myOrderListCell" forIndexPath:indexPath];
                        [myOrderCell setupWithOrder:order isInLandscape:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)];
                        [myOrderCell.clickableView setTag:orderIndex];
                        [myOrderCell.clickableView addTarget:self action:@selector(selectedOrder:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [myOrderCell.clickableView setSelected:NO];
                        [myOrderCell.portraitArrowImageView setImage:[UIImage imageNamed:@"arrowGreyClose"]];
                        if(VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath) && (self.selectedOrderIndexPath.row) == orderIndex)
                        {
                            [myOrderCell.clickableView setSelected:YES];
                            [myOrderCell.portraitArrowImageView setImage:[UIImage imageNamed:@"arrowGreyOpen"]];
                        }

                        cell = myOrderCell;
                    }
                }
            }
        }
    }
    
    return cell;
}

- (void)selectedOrder:(id)sender
{
    JAClickableView *clickableView = sender;
    NSInteger tag = clickableView.tag;
    
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath) && self.selectedOrderIndexPath.row == tag)
    {
        self.selectedOrderIndexPath = nil;
    }
    else
    {
        self.selectedOrderIndexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    }
    
    // 27.0f is the height of the header
    CGFloat collectionHeight =  27.0f + [JAMyOrderCell getCellHeight] * [self.orders count];
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        if(VALID_NOTEMPTY(self.selectedOrderIndexPath, NSIndexPath) && self.selectedOrderIndexPath.row < [self.orders count])
        {
            // Add order detail row
            RITrackOrder *order = [self.orders objectAtIndex:self.selectedOrderIndexPath.row];
            collectionHeight += [JAMyOrderDetailView getOrderDetailViewHeight:order maxWidth:self.ordersCollectionView.frame.size.width];
        }
    }
    
    if(collectionHeight > self.contentScrollView.contentSize.height - 12.0f)
    {
        collectionHeight = self.contentScrollView.contentSize.height - 12.0f;
    }
    
    [self.ordersCollectionView setFrame:CGRectMake(self.ordersCollectionView.frame.origin.x,
                                                   self.ordersCollectionView.frame.origin.y,
                                                   self.ordersCollectionView.frame.size.width,
                                                   collectionHeight)];
    
    [self.ordersCollectionView reloadData];
    
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        [self setupOrderDetailView:self.ordersCollectionView.frame.size.width interfaceOrientation:self.interfaceOrientation redrawingFromScratch:NO];
    }
}

@end

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
#import "RIOrder.h"
#import "RICustomer.h"

#define kMyOrderViewTag 999

typedef NS_ENUM(NSUInteger, RITrackOrderRequestState) {
    RITrackOrderRequestNotDone = 0,
    RITrackOrderRequestDone = 1
};

@interface JAMyOrdersViewController ()
<
UITextFieldDelegate,
JAPickerScrollViewDelegate
>

@property (weak, nonatomic) IBOutlet JAPickerScrollView *myOrdersPickerScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (strong, nonatomic) NSArray* sortList;

@property (strong, nonatomic) UIScrollView *firstScrollView;
@property (strong, nonatomic) UIScrollView *secondScrollView;

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


@end

@implementation JAMyOrdersViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.animatedScroll = YES;
    
    self.screenName = @"TrackOrder";
    
    self.trackingOrder = nil;
    self.trackOrderRequestState = RITrackOrderRequestNotDone;
    
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_MY_ORDERS;
    
    [self.contentScrollView setPagingEnabled:YES];
    [self.contentScrollView setScrollEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboard)
                                                 name:kOpenMenuNotification
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];
    
    self.firstScrollView = [[UIScrollView alloc] initWithFrame:self.contentScrollView.frame];
    [self.contentScrollView addSubview:self.firstScrollView];
    
    self.sortList = [NSArray arrayWithObjects:STRING_ORDER_TRACKING, STRING_MY_ORDER_HISTORY, nil];
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [self.sortList count], self.view.frame.size.height - self.myOrdersPickerScrollView.frame.size.height);
    
    self.trackOrderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.trackOrderView.layer.cornerRadius = 5.0f;
    [self.trackOrderView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    self.trackOrderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.trackOrderLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.trackOrderLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.trackOrderLabel setText:STRING_TRACK_YOUR_ORDER];
    [self.trackOrderLabel setBackgroundColor:[UIColor clearColor]];
    [self.trackOrderView addSubview:self.trackOrderLabel];
    
    self.trackOrderSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    [self.trackOrderSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.trackOrderView addSubview:self.trackOrderSeparator];
    
    self.trackOrderTextField = [JATextFieldComponent getNewJATextFieldComponent];
    [self.trackOrderTextField setupWithLabel:STRING_ORDER_ID value:self.startingTrackOrderNumber mandatory:YES];
    [self.trackOrderView addSubview:self.trackOrderTextField];
    
    self.trackOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.trackOrderButton setTitle:STRING_TRACK_YOUR_ORDER forState:UIControlStateNormal];
    [self.trackOrderButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.trackOrderButton addTarget:self action:@selector(trackOrder:) forControlEvents:UIControlEventTouchUpInside];
    [self.trackOrderButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.trackOrderView addSubview:self.trackOrderButton];
    
    [self.firstScrollView addSubview:self.trackOrderView];
    
    self.myOrderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.myOrderView.layer.cornerRadius = 5.0f;
    [self.myOrderView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    self.myOrderViewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.myOrderViewLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.myOrderViewLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.myOrderViewLabel setText:STRING_TRACK_YOUR_ORDER];
    [self.myOrderViewLabel setBackgroundColor:[UIColor clearColor]];
    [self.myOrderView addSubview:self.myOrderViewLabel];
    
    self.myOrderViewSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    [self.myOrderViewSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.myOrderView addSubview:self.myOrderViewSeparator];
    
    self.myOrderHintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.myOrderHintLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.myOrderHintLabel setTextColor:UIColorFromRGB(0xcccccc)];
    [self.myOrderHintLabel setText:STRING_TRACK_YOUR_ORDER_TIP];
    [self.myOrderHintLabel setBackgroundColor:[UIColor clearColor]];
    [self.myOrderView addSubview:self.myOrderHintLabel];
    
    self.emptyOrderHistoryView = [[UIView alloc] initWithFrame:CGRectZero];
    self.emptyOrderHistoryView.layer.cornerRadius = 5.0f;
    [self.emptyOrderHistoryView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.contentScrollView addSubview:self.emptyOrderHistoryView];
    
    UIImage *emptyOrderImage = [UIImage imageNamed:@"noOrdersImage"];
    self.emptyOrderHistoryImageView = [[UIImageView alloc] initWithImage:emptyOrderImage];
    [self.emptyOrderHistoryImageView setFrame:CGRectZero];
    [self.emptyOrderHistoryView addSubview:self.emptyOrderHistoryImageView];
    
    self.emptyOrderHistoryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.emptyOrderHistoryLabel setNumberOfLines:0];
    [self.emptyOrderHistoryLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
    [self.emptyOrderHistoryLabel setTextColor:UIColorFromRGB(0xcccccc)];
    [self.emptyOrderHistoryLabel setText:STRING_NO_ORDERS];
    [self.emptyOrderHistoryLabel setTextAlignment:NSTextAlignmentCenter];
    [self.emptyOrderHistoryLabel setBackgroundColor:[UIColor clearColor]];
    [self.emptyOrderHistoryView addSubview:self.emptyOrderHistoryLabel];

    [self setupOrderTrackingViews:self.view.frame.size.width height:self.view.frame.size.height - self.myOrdersPickerScrollView.frame.size.height interfaceOrientation:self.interfaceOrientation];
    
    self.myOrdersPickerScrollView.delegate = self;
    self.myOrdersPickerScrollView.startingIndex = self.selectedIndex;
    
    //this will trigger load methods
    [self.myOrdersPickerScrollView setOptions:self.sortList];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.contentScrollView setHidden:YES];
    
    self.selectedIndex = self.myOrdersPickerScrollView.selectedIndex;
    
    [self showLoading];
    
    self.myOrdersPickerScrollView.startingIndex = self.selectedIndex;
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    CGFloat newHeight = self.view.frame.size.width - self.view.frame.origin.y;
    [self setupOrderTrackingViews:newWidth height:newHeight interfaceOrientation:toInterfaceOrientation];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width * [self.sortList count], self.view.frame.size.height - self.myOrdersPickerScrollView.frame.size.height);
    
    [self setupOrderTrackingViews:self.view.frame.size.width height:self.view.frame.size.height interfaceOrientation:self.interfaceOrientation];
    
    self.animatedScroll = NO;
    
    [self selectedIndex:self.selectedIndex];
    
    [self.myOrdersPickerScrollView setNeedsLayout];
    
    [self hideLoading];
    
    [self.contentScrollView setHidden:NO];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
    // Track Order
    if(0 == index)
    {
        [self.contentScrollView scrollRectToVisible:CGRectMake(index * self.contentScrollView.frame.size.width,
                                                               0.0f,
                                                               self.contentScrollView.frame.size.width,
                                                               self.contentScrollView.frame.size.height) animated:self.animatedScroll];
    }
    // Order history
    else if(1 == index)
    {
        if([RICustomer checkIfUserIsLogged])
        {
            [self.contentScrollView scrollRectToVisible:CGRectMake(index * self.contentScrollView.frame.size.width,
                                                                   0.0f,
                                                                   self.contentScrollView.frame.size.width,
                                                                   self.contentScrollView.frame.size.height) animated:self.animatedScroll];
        }
        else
        {
            NSNotification *nextNotification = [NSNotification notificationWithName:kShowMyOrdersScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:@"selected_index"]];
            
            NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setObject:nextNotification forKey:@"notification"];
            [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"from_side_menu"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification
                                                                object:nil
                                                              userInfo:userInfo];
        }
    }
    self.animatedScroll = YES;
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
    [self showLoading];
    
    self.trackOrderRequestState = RITrackOrderRequestDone;
    
    [RIOrder trackOrderWithOrderNumber:self.trackOrderTextField.textField.text
                      WithSuccessBlock:^(RITrackOrder *trackingOrder) {
                          
                          self.trackingOrder = trackingOrder;
                          
                          [self buildContentForOrder:trackingOrder];
                          
                          if(self.firstLoading)
                          {
                              NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                              [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                              self.firstLoading = NO;
                          }
                          
                          [self hideLoading];
                          
                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                          
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
                          else if (RIApiResponseNoInternetConnection == apiResponse)
                          {
                              [self showErrorView:YES startingY:0.0f selector:@selector(loadOrderDetails) objects:nil];
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
    creationDateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    creationDateLabel.textColor = UIColorFromRGB(0x4e4e4e);
    creationDateLabel.text = STRING_CREATION_DATE;
    creationDateLabel.tag = kMyOrderViewTag;
    [creationDateLabel sizeToFit];
    [self.myOrderView addSubview:creationDateLabel];
    
    UILabel *creationDateLabelDetail = [[UILabel alloc] initWithFrame:CGRectMake(creationDateLabel.frame.size.width + 12.0f,
                                                                                 startingY,
                                                                                 200.0f,
                                                                                 20.0f)];
    creationDateLabelDetail.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    creationDateLabelDetail.textColor = UIColorFromRGB(0x666666);
    creationDateLabelDetail.text = order.creationDate;
    [creationDateLabelDetail sizeToFit];
    creationDateLabelDetail.tag = kMyOrderViewTag;
    [self.myOrderView addSubview:creationDateLabelDetail];
    
    startingY += creationDateLabel.frame.size.height + 10.0f;
    
    // Payment method
    UILabel *paymentMethodLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 150, 20)];
    paymentMethodLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    paymentMethodLabel.textColor = UIColorFromRGB(0x4e4e4e);
    paymentMethodLabel.text = STRING_PAYMENT_METHOD;
    paymentMethodLabel.tag = kMyOrderViewTag;
    [paymentMethodLabel sizeToFit];
    [self.myOrderView addSubview:paymentMethodLabel];
    
    UILabel *paymentMethodLabelDetail = [[UILabel alloc] initWithFrame:CGRectMake(paymentMethodLabel.frame.size.width + 12, startingY, 200, 20)];
    paymentMethodLabelDetail.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    paymentMethodLabelDetail.textColor = UIColorFromRGB(0x666666);
    paymentMethodLabelDetail.text = order.paymentMethod;
    [paymentMethodLabelDetail sizeToFit];
    paymentMethodLabelDetail.tag = kMyOrderViewTag;
    [self.myOrderView addSubview:paymentMethodLabelDetail];
    
    startingY += paymentMethodLabelDetail.frame.size.height + 20;
    
    // Products label
    UILabel *productsLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 20)];
    productsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
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
        labelProductName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        labelProductName.textColor = UIColorFromRGB(0x4e4e4e);
        labelProductName.text = item.name;
        [labelProductName sizeToFit];
        labelProductName.tag = kMyOrderViewTag;
        [self.myOrderView addSubview:labelProductName];
        
        startingY += labelProductName.frame.size.height + 6;
        
        UILabel *labelQuantity = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 40)];
        labelQuantity.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        labelQuantity.textColor = UIColorFromRGB(0x666666);
        labelQuantity.text = [NSString stringWithFormat:STRING_QUANTITY, [item.quantity stringValue]];
        [labelQuantity sizeToFit];
        labelQuantity.tag = kMyOrderViewTag;
        [self.myOrderView addSubview:labelQuantity];
        
        startingY += labelQuantity.frame.size.height + 6;
        
        RIStatus *status = [item.status firstObject];
        
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 20)];
        statusLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
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
    noResultsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
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

- (void)setupOrderTrackingViews:(CGFloat)width height:(CGFloat)height interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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
    else
    {
        if(VALID_NOTEMPTY(self.secondScrollView, UIScrollView))
        {
            [self.myOrderHintLabel removeFromSuperview];
            [self.myOrderView removeFromSuperview];
            
            [self.secondScrollView removeFromSuperview];
            self.secondScrollView = nil;
        }
    }
    
    [self.firstScrollView setFrame:CGRectMake(horizontalMargin,
                                              0.0f,
                                              viewsWidth,
                                              height)];
    
    CGFloat trackOrderViewWidth = viewsWidth;
    
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
    
    [self.myOrderViewLabel setFrame:CGRectMake(horizontalMargin,
                                               0.0f,
                                               trackOrderViewWidth - (2 * horizontalMargin),
                                               26.0f)];
    
    [self.myOrderViewSeparator setFrame:CGRectMake(0.0f,
                                                   CGRectGetMaxY(self.myOrderViewLabel.frame),
                                                   trackOrderViewWidth,
                                                   1.0f)];
    
    if(VALID_NOTEMPTY(self.secondScrollView, self.myOrderView))
    {
        [self.myOrderHintLabel setTag:kMyOrderViewTag];
        CGFloat myOrderViewHeight = CGRectGetMaxY(self.trackOrderButton.frame) + 6.0f;
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
    
    [self setupEmptyOrderHistoryViews:width height:height interfaceOrientation:interfaceOrientation];
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
    
    // This layout should start on the second page of the scrollview
    CGFloat startingX = width;
    [self.emptyOrderHistoryView setFrame:CGRectMake(startingX + emptyOrderHistoryViewHorizontalMargin,
                                                    emptyOrderHistoryViewVerticalMargin,
                                                    width - (2 * emptyOrderHistoryViewHorizontalMargin),
                                                    0.0f)];
    
    CGFloat emptyOrderViewActualSize = 0.0f;
    UIImage *emptyOrderImage = [UIImage imageNamed:@"noOrdersImage"];
    emptyOrderViewActualSize += emptyOrderImage.size.height;
    
    
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

@end

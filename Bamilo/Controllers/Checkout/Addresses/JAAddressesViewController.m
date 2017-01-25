//
//  JAAddressesViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAddressesViewController.h"
#import "JACartListHeaderView.h"
#import "JAAddressCell.h"
#import "JASwitchCell.h"
#import "JAUtils.h"
#import "RIAddress.h"
#import "RIForm.h"
#import "RIField.h"
#import "JAButtonWithBlur.h"
#import "RICustomer.h"
#import "JAClickableView.h"
#import "JAOrderSummaryView.h"
#import "UIImage+Mirror.h"
#import "UIView+Mirror.h"
#import "JACheckoutBottomView.h"
#import "JAProductInfoHeaderLine.h"
#import "JACenterNavigationController.h"

@interface JAAddressesViewController ()
<UITableViewDataSource,
UITableViewDelegate>
{
    // Bottom view
    JACheckoutBottomView *_bottomView;
}

// Addresses
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (strong, nonatomic) NSDictionary *addresses;
@property (strong, nonatomic) RIAddress *shippingAddress;
@property (strong, nonatomic) RIAddress *billingAddress;

@property (strong, nonatomic) UITableView *shippingAddressTableView;
@property (strong, nonatomic) UITableView *billingAddressTableView;
@property (strong, nonatomic) UITableView *otherAddressesTableView;

@property (nonatomic, assign) BOOL useSameAddressAsBillingAndShipping;


// Order summary
@property (strong, nonatomic) JAOrderSummaryView *orderSummary;

@property (assign, nonatomic) BOOL shouldForceAddAddress;

@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JAAddressesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.apiResponse = RIApiResponseSuccess;
    self.firstLoading = YES;
    
    self.shouldForceAddAddress = YES;
    
    self.navBarLayout.showBackButton = YES;
    
    if (self.fromCheckout) {
        self.navBarLayout.showCartButton = NO;
        self.navBarLayout.title = STRING_CHECKOUT;
    }else{
        self.navBarLayout.title = STRING_MY_ADDRESSES;
    }
    
    self.screenName = @"Addresses";
    
    self.view.backgroundColor = JAWhiteColor;
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.contentScrollView setShowsHorizontalScrollIndicator:NO];
    [self.contentScrollView setShowsVerticalScrollIndicator:NO];
    
    
    self.shippingAddressTableView = [UITableView new];
    [self.shippingAddressTableView setScrollEnabled:NO];
    [self.shippingAddressTableView setDelegate:self];
    [self.shippingAddressTableView setDataSource:self];
    [self.shippingAddressTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.contentScrollView addSubview:self.shippingAddressTableView];
    
    self.billingAddressTableView = [UITableView new];
    [self.billingAddressTableView setScrollEnabled:NO];
    [self.billingAddressTableView setDelegate:self];
    [self.billingAddressTableView setDataSource:self];
    [self.billingAddressTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.contentScrollView addSubview:self.billingAddressTableView];
    
    self.otherAddressesTableView = [UITableView new];
    [self.otherAddressesTableView setScrollEnabled:NO];
    [self.otherAddressesTableView setDelegate:self];
    [self.otherAddressesTableView setDataSource:self];
    [self.otherAddressesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.contentScrollView addSubview:self.otherAddressesTableView];
    
    
    [self.view addSubview:self.contentScrollView];
    
    _bottomView = [[JACheckoutBottomView alloc] initWithFrame:CGRectMake(0.f, self.view.frame.size.height - 56, self.view.frame.size.width, 56) orientation:[[UIApplication sharedApplication] statusBarOrientation]];
    [_bottomView setTotalValue:self.cart.cartValueFormatted];
    [self.view addSubview:_bottomView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self setCart:[JACenterNavigationController sharedInstance].cart];
    [_bottomView setTotalValue:self.cart.cartValueFormatted];
    if (self.fromCheckout) {
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            [_bottomView setNoTotal:YES];
        }else{
            [_bottomView setNoTotal:NO];
        }
    }else{
        [_bottomView setNoTotal:YES];
    }
    
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) && self.fromCheckout)
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    if(VALID_NOTEMPTY(self.addresses, NSDictionary))
    {
        [self setupViews:newWidth toInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self getAddressList];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"AddressesList"];
}

- (void)getAddressList
{
    [self showLoading];
    [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
        self.addresses = adressList;
        if(VALID_NOTEMPTY(self.addresses, NSDictionary))
        {
            if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
            {
                [self.orderSummary setHidden:NO];
            }
            
            [self.contentScrollView setHidden:NO];
            [_bottomView setHidden:NO];
            
            [self hideLoading];
            
            self.shippingAddress = [self.addresses objectForKey:@"shipping"];
            self.billingAddress = [self.addresses objectForKey:@"billing"];
            
            if([[self.shippingAddress uid] isEqualToString:[self.billingAddress uid]])
            {
                self.useSameAddressAsBillingAndShipping = YES;
            }
            else
            {
                self.useSameAddressAsBillingAndShipping = NO;
            }
            
            [self finishedLoadingAddresses];
        }
        else
        {
            [self hideLoading];
            
            if(self.shouldForceAddAddress)
            {
                // shouldForceAddAddress should be setted to NO otherwise, everytime that the user goes back in add address screen the screen will reopen
                self.shouldForceAddAddress = NO;
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:NO], [NSNumber numberWithBool:self.fromCheckout]] forKeys:@[@"show_back_button", @"from_checkout"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification	 object:nil];
            }
        }
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        self.apiResponse = apiResponse;
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"NativeCheckoutError" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutError]
                                                  data:[trackingDictionary copy]];
        
        
        [self.contentScrollView setHidden:YES];
        [_bottomView setHidden:YES];
        
        if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
        {
            [self.orderSummary setHidden:YES];
        }
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(getAddressList) objects:nil];
        
        [self hideLoading];
    }];
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat scrollViewStartY = 0.0f;
    
    if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
    {
        [self.orderSummary removeFromSuperview];
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)  && (width < self.view.frame.size.width) && self.fromCheckout)
    {
        CGFloat orderSummaryRightMargin = 0.0f;
        self.orderSummary = [[JAOrderSummaryView alloc] initWithFrame:CGRectMake(width,
                                                                                 scrollViewStartY,
                                                                                 self.view.frame.size.width - width - orderSummaryRightMargin,
                                                                                 self.view.frame.size.height - scrollViewStartY)];
        
        [self.orderSummary loadWithCart:self.cart];
        [self.view addSubview:self.orderSummary];
    }
    
    [self.contentScrollView setFrame:CGRectMake(0.0f,
                                                scrollViewStartY,
                                                width,
                                                self.view.frame.size.height - scrollViewStartY)];
    
    CGFloat cellHeight = [self tableView:self.shippingAddressTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGFloat headerHeight = [self tableView:self.shippingAddressTableView heightForHeaderInSection:0];
    CGFloat footerHeight = [self tableView:self.shippingAddressTableView heightForFooterInSection:0];
    CGFloat totalShippingCollectionViewHeight = headerHeight + cellHeight + footerHeight;
    [self.shippingAddressTableView setFrame:CGRectMake(0.0f,
                                                       0.0f,
                                                       self.contentScrollView.frame.size.width,
                                                       totalShippingCollectionViewHeight)];
    
    CGFloat totalBillingCollectionViewHeight = totalShippingCollectionViewHeight;
    if (self.useSameAddressAsBillingAndShipping) {
        totalBillingCollectionViewHeight = 0.0f;
    }
    [self.billingAddressTableView setFrame:CGRectMake(0.0f,
                                                      CGRectGetMaxY(self.shippingAddressTableView.frame),
                                                      self.contentScrollView.frame.size.width,
                                                      totalBillingCollectionViewHeight)];

    NSArray* otherAddresses = [self.addresses objectForKey:@"other"];
    CGFloat totalOtherAddressesTableHeight = headerHeight + cellHeight * otherAddresses.count + footerHeight;
    if (0 == otherAddresses.count) {
        totalOtherAddressesTableHeight = 0.0f;
    }
    [self.otherAddressesTableView setFrame:CGRectMake(0.0f,
                                                      CGRectGetMaxY(self.billingAddressTableView.frame),
                                                      self.contentScrollView.frame.size.width,
                                                      totalOtherAddressesTableHeight)];
    
    
    [self.shippingAddressTableView reloadData];
    [self.billingAddressTableView reloadData];
    [self.otherAddressesTableView reloadData];
    
    [_bottomView setFrame:CGRectMake(0.0f,
                                            self.view.frame.size.height - _bottomView.frame.size.height,
                                            width,
                                            _bottomView.frame.size.height)];
    if(self.fromCheckout)
    {
        [_bottomView setButtonText:STRING_NEXT target:self action:@selector(nextStepButtonPressed)];
        [_bottomView setHidden:NO];
    }
    else
    {
        [_bottomView setHidden:YES];
        [_bottomView setFrame:CGRectZero];
    }
    
    
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, CGRectGetMaxY(self.otherAddressesTableView.frame) + _bottomView.frame.size.height + 5.0f)];
    
    [self.contentScrollView setHidden:NO];
    
    if (RI_IS_RTL) {
        [_bottomView setTotalValue:_bottomView.totalValue];
        [self.view flipAllSubviews];
    }
}

-(void)finishedLoadingAddresses
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) && self.fromCheckout)
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis =  [NSNumber numberWithInt:(int)([self.startLoadingTime timeIntervalSinceNow]*-1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName label:_billingAddress.uid];
        self.firstLoading = NO;
    }
}

-(BOOL)checkIfAddressIsAdded:(RIAddress*)addressToAdd addresses:(NSArray*)addresses
{
    BOOL checkIfAddressIsAdded = NO;
    
    for(RIAddress *address in addresses)
    {
        if([[addressToAdd uid] isEqualToString:[address uid]])
        {
            checkIfAddressIsAdded = YES;
            break;
        }
    }
    return checkIfAddressIsAdded;
}

- (void)editShippingAddressPressed
{
    [self editAddressPressedForAddress:self.shippingAddress];
}

- (void)editBillingAddressPressed
{
    [self editAddressPressedForAddress:self.billingAddress];
}

- (void)editOtherAddressPressed:(UIControl*)sender
{
    NSInteger index = sender.tag;
    
    NSArray* otherAddresses = [self.addresses objectForKey:@"other"];
    RIAddress* address = [otherAddresses objectAtIndex:index];
    
    [self editAddressPressedForAddress:address];
}

- (void)editAddressPressedForAddress:(RIAddress*)address
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutEditAddressScreenNotification
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjects:@[address, [NSNumber numberWithBool:self.fromCheckout]] forKeys:@[@"address_to_edit", @"from_checkout"]]];
}

#pragma mark UITableView delegate and datasource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kProductInfoHeaderLineHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kAddressCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 38.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat totalNumberOfAddressesInTableView = 1;
    
    if(tableView == self.otherAddressesTableView)
    {
        NSArray* otherAddresses = [self.addresses objectForKey:@"other"];
        totalNumberOfAddressesInTableView = [otherAddresses count] + 1;
    }
    
    return totalNumberOfAddressesInTableView;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title;
    if(tableView == self.shippingAddressTableView)
    {
        if(self.useSameAddressAsBillingAndShipping) {
            title = STRING_SHIPPING_BILLING_ADDRESS;
        } else {
            title = STRING_SHIPPING_ADDRESSES;
        }
    }
    else if(tableView == self.billingAddressTableView)
    {
        title = STRING_BILLING_ADDRESSES;
    } else if(tableView == self.otherAddressesTableView) {
        title = STRING_OTHER_ADDRESSES;
    }
    
    UIView* content = [UIView new];
    [content setFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, kProductInfoHeaderLineHeight)];
    
    JAProductInfoHeaderLine* headerLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0.0f, 0.0f, content.frame.size.width, kProductInfoHeaderLineHeight)];
    [headerLine setTitle:title];
    
    if (RI_IS_RTL) {
        [headerLine flipAllSubviews];
    }
    
    [content addSubview:headerLine];
    
    return content;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    JAClickableView* footerView = [JAClickableView new];
    [footerView setBackgroundColor:JAWhiteColor];
    [footerView setFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 38.0f)];
    
    UILabel* addNewAddressLabel = [UILabel new];
    [addNewAddressLabel setFont:JABUTTON2Font];
    [addNewAddressLabel setTextColor:JABlue1Color];
    [addNewAddressLabel setTextAlignment:NSTextAlignmentRight];
    [addNewAddressLabel setText:[STRING_ADD_NEW_ADDRESS uppercaseString]];
    [addNewAddressLabel sizeToFit];
    [addNewAddressLabel setFrame:CGRectMake(16.0f,
                                            10.0f,
                                            tableView.frame.size.width - 16.0f*2,
                                            addNewAddressLabel.frame.size.height)];
    [footerView addSubview:addNewAddressLabel];

    if (RI_IS_RTL) {
        [footerView flipAllSubviews];
    }
    
    [footerView addTarget:self action:@selector(addAddressCellPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return footerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    
    JAAddressCell* cell = (JAAddressCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[JAAddressCell alloc] init];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    RIAddress* address;
    SEL clickMethod;
    
    if(tableView == self.shippingAddressTableView) {
        if (0 == indexPath.row) {
            address = self.shippingAddress;
            clickMethod = @selector(editShippingAddressPressed);
        }
    } else if(tableView == self.billingAddressTableView) {
        if (0 == indexPath.row) {
            address = self.billingAddress;
            clickMethod = @selector(editBillingAddressPressed);
        }
    } else {
        NSArray* otherAddresses = [self.addresses objectForKey:@"other"];
        if (indexPath.row < [otherAddresses count]) {
            address = [otherAddresses objectAtIndex:indexPath.row];
        }
        clickMethod = @selector(editOtherAddressPressed:);
    }
    
    [cell loadWithWidth:self.contentScrollView.frame.size.width address:address];
    [cell.editAddressButton setTag:indexPath.row];
    [cell.editAddressButton addTarget:self action:clickMethod forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)addAddressCellPressed:(UIControl*)sender
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:self.fromCheckout]] forKeys:@[@"show_back_button", @"from_checkout"]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

-(void)nextStepButtonPressed
{
    if (self.fromCheckout) {
        [self showLoading];
        
        [RICart setMultistepAddressForShipping:self.shippingAddress.uid
                                       billing:self.billingAddress.uid
                                  successBlock:^(NSString *nextStep) {
                                      [self hideLoading];
                                      [JAUtils goToNextStep:nextStep
                                                   userInfo:nil];
                                  } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                                      NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                      [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
                                      [trackingDictionary setValue:@"NativeCheckoutError" forKey:kRIEventActionKey];
                                      [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
                                      
                                      [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutError]
                                                                                data:[trackingDictionary copy]];
                                      
                                      [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:@selector(nextStepButtonPressed) objects:nil];
                                      [self hideLoading];
                                  }];
    }
}

@end

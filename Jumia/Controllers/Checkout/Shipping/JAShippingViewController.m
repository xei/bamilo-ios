//
//  JAShippingViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAShippingViewController.h"
#import "JAButtonWithBlur.h"
#import "JAShippingCell.h"
#import "JAShippingInfoCell.h"
#import "JAPickupStationInfoCell.h"
#import "JAUtils.h"
#import "JAOrderSummaryView.h"
#import "RIShippingMethodPickupStationOption.h"
#import "RICustomer.h"
#import "UIView+Mirror.h"
#import "UIImage+Mirror.h"
#import "JACheckoutBottomView.h"
#import "RIShippingMethodForm.h"
#import "RISellerDelivery.h"
#import "JASellerDeliveryView.h"
#import "JAProductInfoHeaderLine.h"

#define kPickupStationKey @"pickupstation"

@interface JAShippingViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    // Bottom view
    JACheckoutBottomView *_bottomView;
}

// Shipping methods
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITableView *tableView;

// Picker view
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (strong, nonatomic) NSIndexPath *pickerIndexPath;

// Order summary
@property (strong, nonatomic) JAOrderSummaryView *orderSummary;

@property (strong, nonatomic) RICart *cart;
@property (strong, nonatomic) RIShippingMethodForm* shippingMethodForm;
@property (strong, nonatomic) NSArray *shippingMethods;
@property (strong, nonatomic) NSDictionary *pickupStationRegions;
@property (strong, nonatomic) NSString *selectedRegion;
@property (strong, nonatomic) NSString *selectedRegionId;
@property (strong, nonatomic) NSMutableArray *pickupStationsForRegion;
@property (strong, nonatomic) NSMutableArray *pickupStationHeightsForRegion;
@property (strong, nonatomic) NSString *selectedShippingMethod;
@property (strong, nonatomic) NSIndexPath *tableViewIndexSelected;
@property (strong, nonatomic) NSIndexPath *selectedPickupStationIndexPath;
@property (strong, nonatomic) NSMutableArray *sellerDeliveryViews;

@property (assign, nonatomic) RIApiResponse apiResponse;

@property (nonatomic, assign) BOOL isLoaded;

@end

@implementation JAShippingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Shipping";

    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"CheckoutShippingMethods" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutShipping]
                                              data:[trackingDictionary copy]];
    
    self.navBarLayout.title = STRING_CHECKOUT;
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = NO;
    
    self.view.backgroundColor = JAWhiteColor;
    
    self.pickupStationsForRegion = [[NSMutableArray alloc] init];
    self.pickupStationHeightsForRegion = [[NSMutableArray alloc] init];
    
    self.sellerDeliveryViews = [NSMutableArray new];
    
    self.isLoaded = NO;
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.apiResponse = RIApiResponseSuccess;

    [self continueLoading];
}

-(void)viewDidAppear:(BOOL)animate
{
    [super viewDidAppear:animate];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckoutShipping"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [_bottomView setNoTotal:YES];
    }else{
        [_bottomView setNoTotal:NO];
    }
    
    [self showLoading];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)continueLoading
{
    if (NO == self.isLoaded) {
        if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
        {
            [self showLoading];
        }
        
        [RICart getMultistepShippingWithSuccessBlock:^(RICart *cart) {
            self.isLoaded = YES;
            
            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
            self.cart = cart;
            self.shippingMethodForm = cart.shippingMethodForm;
            
            // LIST OF AVAILABLE SHIPPING METHODS
            self.shippingMethods = [RIShippingMethodForm getShippingMethods:cart.shippingMethodForm];
            
            [self finishedLoadingShippingMethods];
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            self.apiResponse = apiResponse;
            [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(continueLoading) objects:nil];
            [self hideLoading];
        }];
    }
}

- (void) initViews
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.f,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   self.scrollView.frame.size.width,
                                                                   27.0f)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setScrollEnabled:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.scrollView addSubview:self.tableView];
    
    [self.view addSubview:self.scrollView];
    
    _bottomView = [[JACheckoutBottomView alloc] initWithFrame:CGRectMake(0.f, self.view.frame.size.height - 56, self.view.frame.size.width, 56) orientation:self.interfaceOrientation];
    [_bottomView setTotalValue:self.cart.cartValueFormatted];
    [self.view addSubview:_bottomView];
}

-(void)finishedLoadingShippingMethods
{
    if(VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        self.selectedShippingMethod = self.cart.shippingMethod;
        
        if(VALID_NOTEMPTY(self.selectedShippingMethod, NSString))
        {
            for(int i = 0; i < [self.shippingMethods count]; i++)
            {
                NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:i];
                [shippingMethod enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[RIShippingMethod class]]) {
                        RIShippingMethod* method = (RIShippingMethod*)obj;
                        if (method.label == self.selectedShippingMethod) {
                            self.tableViewIndexSelected = [NSIndexPath indexPathForItem:i inSection:0];
                        }
                    }
                }];
            }
        }
        
        CGFloat newWidth = self.view.frame.size.width;
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            newWidth = self.view.frame.size.height + self.view.frame.origin.y;
        }
        
        [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
        
        [self tableView:self.tableView didSelectRowAtIndexPath:self.tableViewIndexSelected];
    }
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
    
    [self hideLoading];
}

- (void) setupSellerDelivery:(CGFloat)width
{
    if (VALID_ISEMPTY(self.sellerDeliveryViews, NSMutableArray)) {
        NSInteger index = 1;
        NSInteger max = [self.cart.sellerDelivery count];
        for (RISellerDelivery* sell in self.cart.sellerDelivery) {
            JASellerDeliveryView* sellerDeliveryView = [[JASellerDeliveryView alloc] init];
            [sellerDeliveryView setupWithSellerDelivery:sell index:index++ ofMax:max width:width];
            [self.scrollView addSubview:sellerDeliveryView];
            [self.sellerDeliveryViews addObject:sellerDeliveryView];
        }
    }
    
    if (VALID_NOTEMPTY(self.sellerDeliveryViews, NSMutableArray)) {
        CGFloat currentY = self.tableView.frame.origin.y + self.tableView.frame.size.height;
        for (JASellerDeliveryView *sell in self.sellerDeliveryViews) {
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 [sell setY:currentY];
                             }];
            currentY += sell.frame.size.height;
            [sell updateWidth:width];
        }
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, currentY)];
    }
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
    {
        [self.orderSummary removeFromSuperview];
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)  && (width < self.view.frame.size.width))
    {
        CGFloat orderSummaryRightMargin = 6.0f;
        self.orderSummary = [[JAOrderSummaryView alloc] initWithFrame:CGRectMake(width,
                                                                                 0.f,
                                                                                 self.view.frame.size.width - width - orderSummaryRightMargin,
                                                                                 self.view.frame.size.height)];
        [self.orderSummary loadWithCart:self.cart shippingMethod:NO];
        [self.view addSubview:self.orderSummary];
    }
    
    [_bottomView setFrame:CGRectMake(0.0f,
                                     self.view.frame.size.height - 56,
                                     width,
                                     56)];
    [_bottomView setButtonText:STRING_NEXT target:self action:@selector(nextStepButtonPressed)];
    [_bottomView setTotalValue:self.cart.cartValueFormatted];
    
    [self.scrollView setFrame:CGRectMake(0.0f,
                                         0.f,
                                         width,
                                         self.view.frame.size.height - _bottomView.frame.size.height)];
    
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                        self.tableView.frame.origin.y,
                                        self.scrollView.frame.size.width,
                                        self.tableView.frame.size.height)];
    [self reloadTableView];
    
    if (RI_IS_RTL) {
        [_bottomView flipViewPositionInsideSuperview];
        [_bottomView flipAllSubviews];
        [self.orderSummary flipViewPositionInsideSuperview];
        [self.orderSummary flipAllSubviews];
        [self.scrollView flipViewPositionInsideSuperview];
    }
}

- (void)reloadTableView
{
    if(VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        CGFloat tableViewHeight = [self tableView:self.tableView heightForHeaderInSection:0] + 5.0f;
        NSInteger numberOfRows = [self tableView:self.tableView numberOfRowsInSection:0];
        for (int i = 0; i < numberOfRows; i++) {
            tableViewHeight += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [UIView animateWithDuration:0.5f
                         animations:^{
                             [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                                                 self.tableView.frame.origin.y,
                                                                 self.tableView.frame.size.width,
                                                                 tableViewHeight)];
                         }];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                                   self.tableView.frame.origin.y + tableViewHeight + _bottomView.frame.size.height + 6.0f)];
        
    }
    
    [self.tableView reloadData];
    [self setupSellerDelivery:self.scrollView.frame.size.width];
}

- (void)openPicker
{
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    
    self.pickerDataSource = [NSMutableArray new];
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    if(VALID_NOTEMPTY(self.pickupStationRegions, NSDictionary))
    {
        NSArray *allKeys = [self.pickupStationRegions allKeys];
        if(VALID_NOTEMPTY(allKeys, NSArray))
        {
            for (int i = 0; i < [allKeys count]; i++)
            {
                NSString *key = [allKeys objectAtIndex:i];
                [self.pickerDataSource addObject:key];
                [dataSource addObject:[self.pickupStationRegions objectForKey:key]];
            }
        }
    }
    
    NSString *previousRegion = @"";
    if(VALID_NOTEMPTY(self.pickerIndexPath, NSIndexPath))
    {
        previousRegion = self.selectedRegion;
    }
    
    [self.picker setDataSourceArray:[dataSource copy]
                       previousText:previousRegion
                    leftButtonTitle:nil];
    
    CGFloat pickerViewHeight = self.view.frame.size.height;
    CGFloat pickerViewWidth = self.view.frame.size.width;
    [self.picker setFrame:CGRectMake(0.0f,
                                     pickerViewHeight,
                                     pickerViewWidth,
                                     pickerViewHeight)];
    [self.view addSubview:self.picker];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.picker setFrame:CGRectMake(0.0f,
                                                          0.0f,
                                                          pickerViewWidth,
                                                          pickerViewHeight)];
                     }];
}

-(void)nextStepButtonPressed
{
    BOOL hasError = NO;
    if(VALID_NOTEMPTY(self.selectedShippingMethod, NSString))
    {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:self.selectedShippingMethod forKey:@"shippingMethodForm[shipping_method]"];
        
        NSString* pickupStationID;
        
        if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
        {
            if(VALID_NOTEMPTY(self.selectedRegionId, NSString) && VALID_NOTEMPTY(self.pickupStationsForRegion, NSMutableArray))
            {
                [parameters setObject:self.selectedRegionId forKey:@"shippingMethodForm[pickup_station_customer_address_region]"];
                
                NSInteger pickupStationIndex = self.selectedPickupStationIndexPath.row - self.tableViewIndexSelected.row - 2;
                RIShippingMethodPickupStationOption *pickupStation = [self.pickupStationsForRegion objectAtIndex:pickupStationIndex];
                [parameters setObject:pickupStation.uid forKey:@"shippingMethodForm[pickup_station]"];
                pickupStationID = pickupStation.uid;
            }
            else
            {
                hasError = YES;
            }
        }
        if(!hasError)
        {
            [self showLoading];
            
            [RICart setMultistepShippingForShippingMethod:self.selectedShippingMethod
                                            pickupStation:pickupStationID
                                                   region:self.selectedRegionId
                                             successBlock:^(NSString *nextStep) {
                                                 [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                                                 [self hideLoading];
                                                 [JAUtils goToNextStep:nextStep
                                                              userInfo:nil];
                                             } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                                                 [self onErrorResponse:apiResponse messages:@[STRING_ERROR_SETTING_SHIPPING_METHOD] showAsMessage:YES selector:@selector(nextStepButtonPressed) objects:nil];
                                                 [self hideLoading];
                                             }];
        }
        else
        {
            [self onErrorResponse:RIApiResponseSuccess messages:@[STRING_ERROR_INVALID_FIELDS] showAsMessage:YES selector:@selector(nextStepButtonPressed) objects:nil];
        }
    }
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow
{
    if(VALID_NOTEMPTY(self.pickupStationRegions, NSDictionary) && VALID_NOTEMPTY(self.pickerIndexPath, NSIndexPath))
    {
        if(VALID_NOTEMPTY(self.pickerDataSource, NSMutableArray) && selectedRow < [self.pickupStationRegions count])
        {
            self.selectedRegionId = [self.pickerDataSource objectAtIndex:selectedRow];
            self.selectedRegion = [self.pickupStationRegions objectForKey:self.selectedRegionId];
            
            self.pickupStationsForRegion = [[NSMutableArray alloc] initWithArray:[RIShippingMethodForm getPickupStationsForRegion:self.selectedRegionId shippingMethod:self.selectedShippingMethod inForm:self.shippingMethodForm]];
            self.pickupStationHeightsForRegion = [[NSMutableArray alloc] init];
            for(RIShippingMethodPickupStationOption *pickupStation in self.pickupStationsForRegion)
            {
                CGFloat size = [JAPickupStationInfoCell getHeightForPickupStation:pickupStation width:self.tableView.frame.size.width];
                
                [self.pickupStationHeightsForRegion addObject:[NSNumber numberWithFloat:size]];
            }
            
            self.selectedPickupStationIndexPath = [NSIndexPath indexPathForItem:(self.pickerIndexPath.item + 1) inSection:self.pickerIndexPath.section];
        }
    }
    
    [self closePicker];
    
    [self reloadTableView];
}

- (void)closePicker
{
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                     }];
}


#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kProductInfoHeaderLineHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    
    if(indexPath.row <= self.tableViewIndexSelected.row || indexPath.row > (self.tableViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
    {
        // Shipping method title cell
        height = 40.0f;
    }
    else if(indexPath.row == (self.tableViewIndexSelected.row + 1))
    {
        // Shipping method info cell
        if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
        {
            height = 55.0f;
        }
        else
        {
            // JAShippingInfoCell Height
            height = 60.0f;
            NSDictionary *shippingMethodDictionary = [self.shippingMethods objectAtIndex:self.tableViewIndexSelected.row];
            
            NSArray *shippingMethodKeys = [shippingMethodDictionary allKeys];
            if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
            {
                NSString *shippingMethodKey = [shippingMethodKeys objectAtIndex:0];
                RIShippingMethod *shippingMethod = [shippingMethodDictionary objectForKey:shippingMethodKey];
                if(VALID_NOTEMPTY(shippingMethod, RIShippingMethod))
                {
                    if (ISEMPTY(shippingMethod.shippingFee) || [shippingMethod.shippingFee isEqualToNumber:[NSNumber numberWithInteger:0]]) {
                        height = 40.0f;
                    }
                }
            }
        }
    }
    else
    {
        // Shipping method option cell
        if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
        {
            NSInteger index = indexPath.row - self.tableViewIndexSelected.row - 2;
            CGFloat pickupStationInfoCellHeight = [JAPickupStationInfoCell getHeightForPickupStation:[self.pickupStationsForRegion objectAtIndex:index] width:self.tableView.frame.size.width];
            
            height = pickupStationInfoCellHeight;
        }
    }
    
    return  height;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = STRING_SHIPPING;
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = [self.shippingMethods count] + 1;
        
    // Add options
    numberOfItemsInSection += [self.pickupStationsForRegion count];
    
    return numberOfItemsInSection;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row <= self.tableViewIndexSelected.row || indexPath.row > (self.tableViewIndexSelected.row + [self.pickupStationsForRegion count] + 1)) {
        // Shipping method title cell
        NSInteger index = indexPath.row;
        if(indexPath.row > (self.tableViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
        {
            index = indexPath.row - ([self.pickupStationsForRegion count] + 1);
        }
        
        NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:index];
        
        NSArray *shippingMethodKeys = [shippingMethod allKeys];
        if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
        {
            NSString *shippingMethodKey = [shippingMethodKeys objectAtIndex:0];
            NSString *cellIdentifier = @"shippingListCell";
            JAShippingCell *shippingCell = (JAShippingCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (ISEMPTY(shippingCell)) {
                shippingCell = [[JAShippingCell alloc] init];
                [shippingCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            [shippingCell loadWithShippingMethod:[shippingMethod objectForKey:shippingMethodKey] width:self.tableView.frame.size.width];
            
            [shippingCell deselectShippingMethod];
            if(VALID_NOTEMPTY(self.tableViewIndexSelected, NSIndexPath) && indexPath.row == self.tableViewIndexSelected.row)
            {
                [shippingCell selectShippingMethod];
            }
            
            shippingCell.clickableView.tag = indexPath.row;
            [shippingCell.clickableView addTarget:self action:@selector(clickViewSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            if(self.tableViewIndexSelected.row == index)
            {
                shippingCell.clickableView.enabled = NO;
            } else {
                shippingCell.clickableView.enabled = YES;
            }
            
            return shippingCell;
        }
    } else if(indexPath.row == (self.tableViewIndexSelected.row + 1)) {
        // Shipping method info cell
        
        if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
        {
            NSString *cellIdentifier = @"pickupRegionsCell";
            JAShippingInfoCell *shippingInfoCell = (JAShippingInfoCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (ISEMPTY(shippingInfoCell)) {
                shippingInfoCell = [[JAShippingInfoCell alloc] init];
                [shippingInfoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            [shippingInfoCell loadWithPickupStationWidth:self.tableView.frame.size.width];
            
            if(VALID_NOTEMPTY(self.selectedRegion, NSString))
            {
                [shippingInfoCell setPickupStationRegion:self.selectedRegion];
            }
            
            return shippingInfoCell;
            
        } else {
            NSString *cellIdentifier = @"shippingInfoCell";
            JAShippingInfoCell *shippingInfoCell = (JAShippingInfoCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (ISEMPTY(shippingInfoCell)) {
                shippingInfoCell = [[JAShippingInfoCell alloc] init];
                [shippingInfoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            NSDictionary *shippingMethodDictionary = [self.shippingMethods objectAtIndex:self.tableViewIndexSelected.row];
            
            NSArray *shippingMethodKeys = [shippingMethodDictionary allKeys];
            if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
            {
                NSString *shippingMethodKey = [shippingMethodKeys objectAtIndex:0];
                RIShippingMethod *shippingMethod = [shippingMethodDictionary objectForKey:shippingMethodKey];
                if(VALID_NOTEMPTY(shippingMethod, RIShippingMethod))
                {
                    NSString *shippingFeeString = [RICountryConfiguration formatPrice:shippingMethod.shippingFee country:[RICountryConfiguration getCurrentConfiguration]];
                    if (ISEMPTY(shippingMethod.shippingFee) || [shippingMethod.shippingFee isEqualToNumber:[NSNumber numberWithInteger:0]]) {
                        shippingFeeString = STRING_FREE;
                    }
                    [shippingInfoCell loadWithShippingFee:shippingFeeString deliveryTime:shippingMethod.deliveryTime width:self.tableView.frame.size.width];
                }
            }
            
            return shippingInfoCell;
        }
    } else {
        // Shipping method option cell
        if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
        {
            NSString *cellIdentifier = @"pickupStationInfoCell";
            JAPickupStationInfoCell *pickupStationInfoCell = (JAPickupStationInfoCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (ISEMPTY(pickupStationInfoCell)) {
                pickupStationInfoCell = [[JAPickupStationInfoCell alloc] init];
                [pickupStationInfoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            if(VALID_NOTEMPTY(self.pickupStationsForRegion, NSMutableArray))
            {
                NSInteger index = indexPath.row - self.tableViewIndexSelected.row - 2;
                [pickupStationInfoCell loadWithPickupStation:[self.pickupStationsForRegion objectAtIndex:index] width:self.tableView.frame.size.width];
                
                if(index == ([self.pickupStationsForRegion count] - 1))
                {
                    [pickupStationInfoCell.separator setHidden:YES];
                    [pickupStationInfoCell.lastSeparator setHidden:NO];
                }
                else
                {
                    [pickupStationInfoCell.separator setHidden:NO];
                    [pickupStationInfoCell.lastSeparator setHidden:YES];
                }
            }
            
            pickupStationInfoCell.clickableView.tag = indexPath.row;
            [pickupStationInfoCell.clickableView addTarget:self action:@selector(clickViewSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            [pickupStationInfoCell deselectPickupStation];
            if(indexPath.row == self.selectedPickupStationIndexPath.row)
            {
                [pickupStationInfoCell selectPickupStation];
            }
            
            return pickupStationInfoCell;
        }
    }
    return nil;
}


#pragma mark UICollectionViewDelegate

- (void)clickViewSelected:(UIControl*)sender
{
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableView && VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        if(indexPath.row <= self.tableViewIndexSelected.row || indexPath.row > (self.tableViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
        {
            // Shipping method title cell
            NSInteger index = indexPath.row;
            if(indexPath.row > (self.tableViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
            {
                index = indexPath.row - ([self.pickupStationsForRegion count] + 1);
            }
            
            // Shipping method info cell
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                self.pickupStationsForRegion = [NSMutableArray new];
                self.selectedRegion = nil;
            }
            
            NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:index];
            NSArray *shippingMethodKeys = [shippingMethod allKeys];
            if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
            {
                self.selectedShippingMethod = [shippingMethodKeys objectAtIndex:0];
                
                if(VALID_NOTEMPTY(self.tableViewIndexSelected, NSIndexPath))
                {
                    JAShippingCell *oldShippingCell = (JAShippingCell*) [tableView cellForRowAtIndexPath:self.tableViewIndexSelected];
                    [oldShippingCell deselectShippingMethod];
                }
                self.tableViewIndexSelected = [NSIndexPath indexPathForItem:index inSection:indexPath.section];
                
                JAShippingCell *shippingCell = (JAShippingCell*)[tableView cellForRowAtIndexPath:indexPath];
                [shippingCell selectShippingMethod];
                
                self.pickupStationRegions = [RIShippingMethodForm getRegionsForShippingMethod:self.selectedShippingMethod inForm:self.shippingMethodForm];
                self.pickerIndexPath = nil;
                
                [self reloadTableView];
            }
        }
        else if(indexPath.row == (self.tableViewIndexSelected.row + 1))
        {
            // Shipping method info cell
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                [self openPicker];
                self.pickerIndexPath = indexPath;
            }
        }
        else
        {
            // Shipping method option cell
            if(VALID_NOTEMPTY(self.selectedPickupStationIndexPath, NSIndexPath))
            {
                JAPickupStationInfoCell *oldPickupStationInfoCell = (JAPickupStationInfoCell*) [tableView cellForRowAtIndexPath:self.selectedPickupStationIndexPath];
                [oldPickupStationInfoCell deselectPickupStation];
            }
            
            JAPickupStationInfoCell *pickupStationInfoCell = (JAPickupStationInfoCell*)[tableView cellForRowAtIndexPath:indexPath];
            [pickupStationInfoCell selectPickupStation];
            
            self.selectedPickupStationIndexPath = indexPath;
        }
    }
}

@end

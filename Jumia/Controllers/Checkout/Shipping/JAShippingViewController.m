//
//  JAShippingViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAShippingViewController.h"
#import "JAButtonWithBlur.h"
#import "JACartListHeaderView.h"
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

#define kPickupStationKey @"pickupstation"

@interface JAShippingViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
>
{
    // Bottom view
    JACheckoutBottomView *_bottomView;
}

// Steps
@property (weak, nonatomic) IBOutlet UIImageView *stepBackground;
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

// Shipping methods
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UICollectionView *collectionView;

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
@property (strong, nonatomic) NSIndexPath *collectionViewIndexSelected;
@property (strong, nonatomic) NSIndexPath *selectedPickupStationIndexPath;
@property (strong, nonatomic) NSMutableArray *sellerDeliveryViews;

@property (assign, nonatomic) RIApiResponse apiResponse;

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
    
    self.pickupStationsForRegion = [[NSMutableArray alloc] init];
    self.pickupStationHeightsForRegion = [[NSMutableArray alloc] init];
    
    self.stepBackground.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepView.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepIcon.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepLabel.font = [UIFont fontWithName:kFontBoldName size:self.stepLabel.font.pointSize];
    [self.stepLabel setText:STRING_CHECKOUT_SHIPPING];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.apiResponse = RIApiResponseSuccess;
    
    self.sellerDeliveryViews = [[NSMutableArray alloc]init];

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
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    [RICart getMultistepShippingWithSuccessBlock:^(RICart *cart) {
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

- (void) initViews
{
    [self setupStepView:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.stepBackground.frame.size.height,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - self.stepBackground.frame.size.height)];
    
    UICollectionViewFlowLayout* collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewFlowLayout setMinimumLineSpacing:0.0f];
    [collectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
    [collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [collectionViewFlowLayout setItemSize:CGSizeZero];
    [collectionViewFlowLayout setHeaderReferenceSize:CGSizeZero];
    
    UINib *shippingListHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    UINib *shippingListCellNib = [UINib nibWithNibName:@"JAShippingCell" bundle:nil];
    UINib *shippingInfoCellNib = [UINib nibWithNibName:@"JAShippingInfoCell" bundle:nil];
    UINib *pickupRegionsCellNib = [UINib nibWithNibName:@"JAPickupRegionsCell" bundle:nil];
    UINib *pickupStationInfoCellNib = [UINib nibWithNibName:@"JAPickupStationInfoCell" bundle:nil];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(6.0f,
                                                                             6.0f,
                                                                             self.scrollView.frame.size.width - 12.0f,
                                                                             27.0f) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.layer.cornerRadius = 5.0f;
    [self.collectionView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.collectionView registerNib:shippingListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"shippingListHeader"];
    [self.collectionView registerNib:shippingListCellNib forCellWithReuseIdentifier:@"shippingListCell"];
    [self.collectionView registerNib:shippingInfoCellNib forCellWithReuseIdentifier:@"shippingInfoCell"];
    [self.collectionView registerNib:pickupRegionsCellNib forCellWithReuseIdentifier:@"pickupRegionsCell"];
    [self.collectionView registerNib:pickupStationInfoCellNib forCellWithReuseIdentifier:@"pickupStationInfoCell"];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setScrollEnabled:NO];
    
    [self.scrollView addSubview:self.collectionView];
    [self.view addSubview:self.scrollView];
    
    _bottomView = [[JACheckoutBottomView alloc] initWithFrame:CGRectMake(0.f, self.view.frame.size.height - 56, self.view.frame.size.width, 56) orientation:self.interfaceOrientation];
    [_bottomView setTotalValue:self.cart.cartValueFormatted];
    [self.view addSubview:_bottomView];
}

- (void) setupStepView:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat stepViewLeftMargin = 130.0f;
    NSString *stepBackgroundImageName = @"headerCheckoutStep3";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            stepViewLeftMargin =  477.0f;
            stepBackgroundImageName = @"headerCheckoutStep3Landscape";
        }
        else
        {
            stepViewLeftMargin = 349.0f;
            stepBackgroundImageName = @"headerCheckoutStep3Portrait";
        }
    }
    UIImage *stepBackgroundImage = [UIImage imageNamed:stepBackgroundImageName];
    
    [self.stepBackground setImage:stepBackgroundImage];
    [self.stepBackground setFrame:CGRectMake(self.stepBackground.frame.origin.x,
                                             self.stepBackground.frame.origin.y,
                                             stepBackgroundImage.size.width,
                                             stepBackgroundImage.size.height)];
    
    [self.stepView setFrame:CGRectMake(stepViewLeftMargin,
                                       (stepBackgroundImage.size.height - self.stepView.frame.size.height) / 2,
                                       self.stepView.frame.size.width,
                                       stepBackgroundImage.size.height)];
    [self.stepLabel sizeToFit];
    
    CGFloat horizontalMargin = 6.0f;
    CGFloat marginBetweenIconAndLabel = 5.0f;
    CGFloat realWidth = self.stepIcon.frame.size.width + marginBetweenIconAndLabel + self.stepLabel.frame.size.width - (2 * horizontalMargin);
    
    self.stepIcon.image = [UIImage imageNamed:@"headerCheckoutStep3Icon"];
    
    if(self.stepView.frame.size.width >= realWidth)
    {
        CGFloat xStepIconValue = ((self.stepView.frame.size.width - realWidth) / 2) - horizontalMargin;
        [self.stepIcon setFrame:CGRectMake(xStepIconValue,
                                           ceilf(((self.stepView.frame.size.height - self.stepIcon.frame.size.height) / 2) - 1.0f),
                                           self.stepIcon.frame.size.width,
                                           self.stepIcon.frame.size.height)];
        
        [self.stepLabel setFrame:CGRectMake(CGRectGetMaxX(self.stepIcon.frame) + marginBetweenIconAndLabel,
                                            4.0f,
                                            self.stepLabel.frame.size.width,
                                            12.0f)];
    }
    else
    {
        [self.stepIcon setFrame:CGRectMake(horizontalMargin,
                                           ceilf(((self.stepView.frame.size.height - self.stepIcon.frame.size.height) / 2) - 1.0f),
                                           self.stepIcon.frame.size.width,
                                           self.stepIcon.frame.size.height)];
        
        [self.stepLabel setFrame:CGRectMake(CGRectGetMaxX(self.stepIcon.frame) + marginBetweenIconAndLabel,
                                            4.0f,
                                            (self.stepView.frame.size.width - self.stepIcon.frame.size.width - marginBetweenIconAndLabel - (2 * horizontalMargin)),
                                            12.0f)];
    }
    
    if(RI_IS_RTL){
        [self.stepBackground setImage:[stepBackgroundImage flipImageWithOrientation:UIImageOrientationUpMirrored]];
        [self.stepIcon flipViewImage];
    }
}

-(void)finishedLoadingShippingMethods
{
    if(VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        for (RIShippingMethodFormField *field in [self.shippingMethodForm fields])
        {
            if([@"shippingMethodForm[shipping_method]" isEqualToString:[field name]])
            {
                self.selectedShippingMethod = [field value];
                break;
            }
        }
        
        if(VALID_NOTEMPTY(self.selectedShippingMethod, NSString))
        {
            for(int i = 0; i < [self.shippingMethods count]; i++)
            {
                NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:i];
                NSArray *shippingMethodKeys = [shippingMethod allKeys];
                if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
                {
                    if([self.selectedShippingMethod isEqualToString:[shippingMethodKeys objectAtIndex:0]])
                    {
                        self.collectionViewIndexSelected = [NSIndexPath indexPathForItem:i inSection:0];
                        break;
                    }
                }
            }
        }
        
        CGFloat newWidth = self.view.frame.size.width;
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            newWidth = self.view.frame.size.height + self.view.frame.origin.y;
        }
        
        [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
        
        [self collectionView:self.collectionView didSelectItemAtIndexPath:self.collectionViewIndexSelected];
    }
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
    
    [self hideLoading];
}

- (void) setupSellerDelivery:(CGFloat)width {
    
    if (VALID_ISEMPTY(self.sellerDeliveryViews, NSMutableArray)) {
        NSInteger index = 1;
        NSInteger max = [self.cart.sellerDelivery count];
        for (RISellerDelivery* sell in self.cart.sellerDelivery) {
            JASellerDeliveryView* seller = [[JASellerDeliveryView alloc] init];
            [seller setupWithSellerDelivery:sell index:index++ ofMax:max width:width];
            [self.scrollView addSubview:seller];
            [self.sellerDeliveryViews addObject:seller];
        }
    }
    CGFloat currentY = self.collectionView.frame.origin.y + self.collectionView.frame.size.height + 24.0f;
    
    if (VALID_NOTEMPTY(self.sellerDeliveryViews, NSMutableArray)) {
     
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
    [self setupStepView:width toInterfaceOrientation:toInterfaceOrientation];
    
    
    if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
    {
        [self.orderSummary removeFromSuperview];
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)  && (width < self.view.frame.size.width))
    {
        CGFloat orderSummaryRightMargin = 6.0f;
        self.orderSummary = [[JAOrderSummaryView alloc] initWithFrame:CGRectMake(width,
                                                                                 self.stepBackground.frame.size.height,
                                                                                 self.view.frame.size.width - width - orderSummaryRightMargin,
                                                                                 self.view.frame.size.height - self.stepBackground.frame.size.height)];
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
                                         self.stepBackground.frame.size.height,
                                         width,
                                         self.view.frame.size.height - self.stepBackground.frame.size.height - _bottomView.frame.size.height)];
    
    [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                             self.collectionView.frame.origin.y,
                                             self.scrollView.frame.size.width - 12.0f,
                                             self.collectionView.frame.size.height)];
    [self reloadCollectionView];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (void)reloadCollectionView
{
    if(VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        CGFloat collectionViewHeight = 27.0f + ([self.shippingMethods count] * 44.0f);
        
        if(VALID_NOTEMPTY(self.selectedShippingMethod, NSString))
        {
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                collectionViewHeight += 50.0f; // JAShippingCell Height
                
                if(VALID_NOTEMPTY(self.pickupStationHeightsForRegion, NSMutableArray))
                {
                    for (NSNumber *pickupStationHeight in self.pickupStationHeightsForRegion)
                    {
                        collectionViewHeight += [pickupStationHeight floatValue];
                    }
                }
            }
            else
            {
                collectionViewHeight += 70.0f; // JAShippingInfoCell Height
            }
        }
        
        [UIView animateWithDuration:0.5f
                         animations:^{
                             [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                                                      self.collectionView.frame.origin.y,
                                                                      self.collectionView.frame.size.width,
                                                                      collectionViewHeight)];
                         }];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                                   self.collectionView.frame.origin.y + collectionViewHeight + _bottomView.frame.size.height + 6.0f)];
        
    }
    
    [self.collectionView reloadData];
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
                
                NSInteger pickupStationIndex = self.selectedPickupStationIndexPath.row - self.collectionViewIndexSelected.row - 2;
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
                                                 [self onErrorResponse:apiResponse messages:@[STRING_ERROR_SETTING_SHIPPING_METHOD] showAsMessage:YES selector:nil objects:nil];
                                                 [self hideLoading];
                                             }];
        }
        else
        {
            [self onErrorResponse:RIApiResponseSuccess messages:@[STRING_ERROR_INVALID_FIELDS] showAsMessage:YES selector:nil objects:nil];
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
                CGFloat size = [JAPickupStationInfoCell getHeightForPickupStation:pickupStation];
                
                [self.pickupStationHeightsForRegion addObject:[NSNumber numberWithFloat:size]];
            }
            
            self.selectedPickupStationIndexPath = [NSIndexPath indexPathForItem:(self.pickerIndexPath.item + 1) inSection:self.pickerIndexPath.section];
        }
    }
    
    [self closePicker];
    
    [self reloadCollectionView];
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

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize sizeForItemAtIndexPath = CGSizeZero;
    
    if(collectionView == self.collectionView)
    {
        if(indexPath.row <= self.collectionViewIndexSelected.row || indexPath.row > (self.collectionViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
        {
            // Shipping method title cell
            sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 40.0f);
        }
        else if(indexPath.row == (self.collectionViewIndexSelected.row + 1))
        {
            // Shipping method info cell
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 50.0f);
            }
            else
            {
                // JAShippingInfoCell Height
                sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 60.0f);
            }
        }
        else
        {
            // Shipping method option cell
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                NSInteger index = indexPath.row - self.collectionViewIndexSelected.row - 2;
                CGFloat pickupStationInfoCellHeight = [JAPickupStationInfoCell getHeightForPickupStation:[self.pickupStationsForRegion objectAtIndex:index]];
                
                return CGSizeMake(self.collectionView.frame.size.width, pickupStationInfoCellHeight);
            }
        }
    }
    
    return sizeForItemAtIndexPath;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize referenceSizeForHeaderInSection = CGSizeZero;
    if(collectionView == self.collectionView)
    {
        referenceSizeForHeaderInSection = CGSizeMake(self.collectionView.frame.size.width, 27.0f);
    }
    
    return referenceSizeForHeaderInSection;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = 0;
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        numberOfItemsInSection = [self.shippingMethods count];
        
        // Add options
        numberOfItemsInSection += [self.pickupStationsForRegion count] + 1;
    }
    return numberOfItemsInSection;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        if(indexPath.row <= self.collectionViewIndexSelected.row || indexPath.row > (self.collectionViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
        {
            // Shipping method title cell
            NSInteger index = indexPath.row;
            if(indexPath.row > (self.collectionViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
            {
                index = indexPath.row - ([self.pickupStationsForRegion count] + 1);
            }
            
            NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:index];
            
            NSArray *shippingMethodKeys = [shippingMethod allKeys];
            if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
            {
                NSString *shippingMethodKey = [shippingMethodKeys objectAtIndex:0];
                NSString *cellIdentifier = @"shippingListCell";
                JAShippingCell *shippingCell = (JAShippingCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                [shippingCell loadWithShippingMethod:[shippingMethod objectForKey:shippingMethodKey]];
                
                [shippingCell deselectShippingMethod];
                if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath) && indexPath.row == self.collectionViewIndexSelected.row)
                {
                    [shippingCell selectShippingMethod];
                }
                
                shippingCell.clickableView.tag = indexPath.row;
                [shippingCell.clickableView addTarget:self action:@selector(clickViewSelected:) forControlEvents:UIControlEventTouchUpInside];
                
                if (([self.shippingMethods count] - 1) == index) {
                    [shippingCell.separator setHidden:YES];
                }
                
                if(self.collectionViewIndexSelected.row == index)
                {
                    [shippingCell.separator setHidden:YES];
                    shippingCell.clickableView.enabled = NO;
                } else {
                    shippingCell.clickableView.enabled = YES;
                }
                
                cell = shippingCell;
            }
        }
        else if(indexPath.row == (self.collectionViewIndexSelected.row + 1))
        {
            // Shipping method info cell
            
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                NSString *cellIdentifier = @"pickupRegionsCell";
                JAShippingInfoCell *shippingInfoCell = (JAShippingInfoCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                [shippingInfoCell loadWithPickupStation];
                
                if(VALID_NOTEMPTY(self.selectedRegion, NSString))
                {
                    [shippingInfoCell setPickupStationRegion:self.selectedRegion];
                }
                
                if(([self.shippingMethods count] - 1) == self.collectionViewIndexSelected.row ||
                   VALID_NOTEMPTY(self.pickupStationsForRegion, NSMutableArray))
                {
                    [shippingInfoCell.separator setHidden:YES];
                }
                else
                {
                    [shippingInfoCell.separator setHidden:NO];
                }
                
                cell = shippingInfoCell;
            }
            else
            {
                NSString *cellIdentifier = @"shippingInfoCell";
                JAShippingInfoCell *shippingInfoCell = (JAShippingInfoCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                NSString *shippingFee = [self.cart shippingValueFormatted];
                if(0 == [[self.cart shippingValue] integerValue])
                {
                    shippingFee = STRING_FREE;
                }
                
                NSDictionary *shippingMethodDictionary = [self.shippingMethods objectAtIndex:self.collectionViewIndexSelected.row];
                
                NSArray *shippingMethodKeys = [shippingMethodDictionary allKeys];
                if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
                {
                    NSString *shippingMethodKey = [shippingMethodKeys objectAtIndex:0];
                    RIShippingMethod *shippingMethod = [shippingMethodDictionary objectForKey:shippingMethodKey];
                    if(VALID_NOTEMPTY(shippingMethod, RIShippingMethod))
                    {
                        NSString *shippingFeeString = [RICountryConfiguration formatPrice:shippingMethod.shippingFee country:[RICountryConfiguration getCurrentConfiguration]];
                        if ([shippingMethod.shippingFee isEqualToNumber:[NSNumber numberWithInteger:0]]) {
                            shippingFeeString = STRING_FREE;
                        }
                        [shippingInfoCell loadWithShippingFee:shippingFeeString deliveryTime:shippingMethod.deliveryTime];
                    }
                }
                
                if(([self.shippingMethods count] - 1) == self.collectionViewIndexSelected.row)
                {
                    [shippingInfoCell.separator setHidden:YES];
                }
                else
                {
                    [shippingInfoCell.separator setHidden:NO];
                }
                
                cell = shippingInfoCell;
            }
        }
        else
        {
            // Shipping method option cell
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                NSString *cellIdentifier = @"pickupStationInfoCell";
                JAPickupStationInfoCell *pickupStationInfoCell = (JAPickupStationInfoCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                
                if(VALID_NOTEMPTY(self.pickupStationsForRegion, NSMutableArray))
                {
                    NSInteger index = indexPath.row - self.collectionViewIndexSelected.row - 2;
                    [pickupStationInfoCell loadWithPickupStation:[self.pickupStationsForRegion objectAtIndex:index]];
                    
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
                
                cell = pickupStationInfoCell;
            }
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    
    if (kind == UICollectionElementKindSectionHeader) {
        JACartListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"shippingListHeader" forIndexPath:indexPath];
        
        if(collectionView == self.collectionView)
        {
            [headerView loadHeaderWithText:STRING_SHIPPING width:self.collectionView.frame.size.width];
        }
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark UICollectionViewDelegate

- (void)clickViewSelected:(UIControl*)sender
{
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        if(indexPath.row <= self.collectionViewIndexSelected.row || indexPath.row > (self.collectionViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
        {
            // Shipping method title cell
            NSInteger index = indexPath.row;
            if(indexPath.row > (self.collectionViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
            {
                index = indexPath.row - ([self.pickupStationsForRegion count] + 1);
            }
            
            NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:index];
            NSArray *shippingMethodKeys = [shippingMethod allKeys];
            if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
            {
                self.selectedShippingMethod = [shippingMethodKeys objectAtIndex:0];
                
                if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath))
                {
                    JAShippingCell *oldShippingCell = (JAShippingCell*) [collectionView cellForItemAtIndexPath:self.collectionViewIndexSelected];
                    [oldShippingCell deselectShippingMethod];
                }
                self.collectionViewIndexSelected = [NSIndexPath indexPathForItem:index inSection:indexPath.section];
                
                JAShippingCell *shippingCell = (JAShippingCell*)[collectionView cellForItemAtIndexPath:indexPath];
                [shippingCell selectShippingMethod];
                
                self.pickupStationRegions = [RIShippingMethodForm getRegionsForShippingMethod:self.selectedShippingMethod inForm:self.shippingMethodForm];
                self.pickerIndexPath = nil;
                
                [self reloadCollectionView];
            }
        }
        else if(indexPath.row == (self.collectionViewIndexSelected.row + 1))
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
                JAPickupStationInfoCell *oldPickupStationInfoCell = (JAPickupStationInfoCell*) [collectionView cellForItemAtIndexPath:self.selectedPickupStationIndexPath];
                [oldPickupStationInfoCell deselectPickupStation];
            }
            
            JAPickupStationInfoCell *pickupStationInfoCell = (JAPickupStationInfoCell*)[collectionView cellForItemAtIndexPath:indexPath];
            [pickupStationInfoCell selectPickupStation];
            
            self.selectedPickupStationIndexPath = indexPath;
        }
    }
}

@end

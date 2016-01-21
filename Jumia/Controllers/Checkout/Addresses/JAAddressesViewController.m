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
#import "JAAddNewAddressCell.h"
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

@interface JAAddressesViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>
{
    // Bottom view
    JACheckoutBottomView *_bottomView;
}

// Steps
@property (weak, nonatomic) IBOutlet UIImageView *stepBackground;
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

// Addresses
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (strong, nonatomic) NSDictionary *addresses;
@property (strong, nonatomic) RIAddress *shippingAddress;
@property (strong, nonatomic) RIAddress *billingAddress;

@property (strong, nonatomic) UICollectionView *shippingAddressCollectionView;
@property (strong, nonatomic) UICollectionView *billingAddressCollectionView;
@property (strong, nonatomic) UICollectionView *otherAddressesCollectionView;

@property (nonatomic, assign) BOOL useSameAddressAsBillingAndShipping;

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;



// Order summary
@property (strong, nonatomic) JAOrderSummaryView *orderSummary;

@property (assign, nonatomic) BOOL firstLoading;
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
    self.navBarLayout.title = STRING_MY_ADDRESSES;
    
    self.screenName = @"Address";
    
    if(self.fromCheckout)
    {
        self.stepBackground.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepView.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepIcon.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepLabel.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepLabel.font = [UIFont fontWithName:kFontBoldName size:self.stepLabel.font.pointSize];
        [self.stepLabel setText:STRING_CHECKOUT_ADDRESS];
    }
    else
    {
        [self.stepBackground removeFromSuperview];
        [self.stepView removeFromSuperview];
        [self.stepIcon removeFromSuperview];
        [self.stepLabel removeFromSuperview];
    }
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.contentScrollView setShowsHorizontalScrollIndicator:NO];
    [self.contentScrollView setShowsVerticalScrollIndicator:NO];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.flowLayout setMinimumLineSpacing:0.0f];
    [self.flowLayout setMinimumInteritemSpacing:0.0f];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.flowLayout setItemSize:CGSizeZero];
    [self.flowLayout setHeaderReferenceSize:CGSizeZero];
    
    UINib *addressListHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    UINib *addressListCellNib = [UINib nibWithNibName:@"JAAddressCell" bundle:nil];
    UINib *addAddressListCellNib = [UINib nibWithNibName:@"JAAddNewAddressCell" bundle:nil];
    UINib *switchListCellNib = [UINib nibWithNibName:@"JASwitchCell" bundle:nil];
    
    self.shippingAddressCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    [self.shippingAddressCollectionView registerNib:addressListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader"];
    [self.shippingAddressCollectionView registerNib:addressListCellNib forCellWithReuseIdentifier:@"addressListCell"];
    [self.shippingAddressCollectionView registerNib:addAddressListCellNib forCellWithReuseIdentifier:@"addAddressListCell"];
    [self.shippingAddressCollectionView registerNib:switchListCellNib forCellWithReuseIdentifier:@"switchListCell"];
    [self.shippingAddressCollectionView setScrollEnabled:NO];
    self.shippingAddressCollectionView.layer.cornerRadius = 5.0f;
    [self.shippingAddressCollectionView setDataSource:self];
    [self.shippingAddressCollectionView setDelegate:self];
    [self.contentScrollView addSubview:self.shippingAddressCollectionView];
    
    UICollectionViewFlowLayout* billingAddressCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [billingAddressCollectionViewFlowLayout setMinimumLineSpacing:0.0f];
    [billingAddressCollectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
    [billingAddressCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [billingAddressCollectionViewFlowLayout setItemSize:CGSizeZero];
    [billingAddressCollectionViewFlowLayout setHeaderReferenceSize:CGSizeZero];
    
    self.billingAddressCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:billingAddressCollectionViewFlowLayout];
    [self.billingAddressCollectionView setScrollEnabled:NO];
    self.billingAddressCollectionView.layer.cornerRadius = 5.0f;
    [self.billingAddressCollectionView registerNib:addressListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader"];
    [self.billingAddressCollectionView registerNib:addressListCellNib forCellWithReuseIdentifier:@"addressListCell"];
    [self.billingAddressCollectionView registerNib:addAddressListCellNib forCellWithReuseIdentifier:@"addAddressListCell"];
    [self.billingAddressCollectionView setDataSource:self];
    [self.billingAddressCollectionView setDelegate:self];
    [self.contentScrollView addSubview:self.billingAddressCollectionView];
    
    UICollectionViewFlowLayout* otherAddressCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [otherAddressCollectionViewFlowLayout setMinimumLineSpacing:0.0f];
    [otherAddressCollectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
    [otherAddressCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [otherAddressCollectionViewFlowLayout setItemSize:CGSizeZero];
    [otherAddressCollectionViewFlowLayout setHeaderReferenceSize:CGSizeZero];
    
    self.otherAddressesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:otherAddressCollectionViewFlowLayout];
    [self.otherAddressesCollectionView setScrollEnabled:NO];
    self.otherAddressesCollectionView.layer.cornerRadius = 5.0f;
    [self.otherAddressesCollectionView registerNib:addressListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader"];
    [self.otherAddressesCollectionView registerNib:addressListCellNib forCellWithReuseIdentifier:@"addressListCell"];
    [self.otherAddressesCollectionView registerNib:addAddressListCellNib forCellWithReuseIdentifier:@"addAddressListCell"];
    [self.otherAddressesCollectionView setDataSource:self];
    [self.otherAddressesCollectionView setDelegate:self];
    [self.contentScrollView addSubview:self.otherAddressesCollectionView];
    
    
    [self.view addSubview:self.contentScrollView];
    
    _bottomView = [[JACheckoutBottomView alloc] initWithFrame:CGRectMake(0.f, self.view.frame.size.height - 56, self.view.frame.size.width, 56) orientation:self.interfaceOrientation];
    [_bottomView setTotalValue:self.cart.cartValueFormatted];
    [self.view addSubview:_bottomView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showLoading];
    
    [self.contentScrollView setHidden:YES];
    [_bottomView setHidden:YES];
    
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:.3];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"AddressesList"];
    
    [self getAddressList];
}

- (void)getAddressList
{
    
    [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
        
        self.addresses = adressList;
        if(VALID_NOTEMPTY(self.addresses, NSDictionary))
        {
            if(self.fromCheckout)
            {
                [self.stepBackground setHidden:NO];
                [self.stepView setHidden:NO];
            }
            
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
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:self.fromCheckout]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button", @"from_checkout"]];
                
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
        
        if(self.fromCheckout)
        {
            [self.stepBackground setHidden:YES];
            [self.stepView setHidden:YES];
        }
        
        if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
        {
            [self.orderSummary setHidden:YES];
        }
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(getAddressList) objects:nil];
        
        [self hideLoading];
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.fromCheckout) {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            [_bottomView setNoTotal:YES];
        }else{
            [_bottomView setNoTotal:NO];
        }
    }else{
        [_bottomView setNoTotal:YES];
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && self.fromCheckout)
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
    
    [self.shippingAddressCollectionView reloadData];
    [self.billingAddressCollectionView reloadData];
    [self.otherAddressesCollectionView reloadData];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void) setupStepView:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat stepViewLeftMargin = 73.0f;
    NSString *stepBackgroundImageName = @"headerCheckoutStep2";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            stepViewLeftMargin =  389.0f;
            stepBackgroundImageName = @"headerCheckoutStep2Landscape";
        }
        else
        {
            stepViewLeftMargin = 261.0f;
            stepBackgroundImageName = @"headerCheckoutStep2Portrait";
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
    }
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat scrollViewStartY = 0.0f;
    if(self.fromCheckout)
    {
        [self setupStepView:width toInterfaceOrientation:toInterfaceOrientation];
        scrollViewStartY = self.stepBackground.frame.size.height;
    }
    
    if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
    {
        [self.orderSummary removeFromSuperview];
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)  && (width < self.view.frame.size.width) && self.fromCheckout)
    {
        CGFloat orderSummaryRightMargin = 6.0f;
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
    
    CGFloat cellHeight = [self collectionView:self.shippingAddressCollectionView layout:self.flowLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].height;
    CGFloat totalShippingCollectionViewHeight = 27.0f + cellHeight + 44.0f;
    [self.shippingAddressCollectionView setFrame:CGRectMake(6.0f,
                                                           6.0f,
                                                           self.contentScrollView.frame.size.width - 12.0f,
                                                           totalShippingCollectionViewHeight)];
    
    CGFloat totalBillingCollectionViewHeight = totalShippingCollectionViewHeight;
    if (self.useSameAddressAsBillingAndShipping) {
        totalBillingCollectionViewHeight = 0.0f;
    }
    [self.billingAddressCollectionView setFrame:CGRectMake(6.0f,
                                                            CGRectGetMaxY(self.shippingAddressCollectionView.frame) + 5.0f,
                                                            self.contentScrollView.frame.size.width - 12.0f,
                                                            totalBillingCollectionViewHeight)];
    
    NSArray* otherAddresses = [self.addresses objectForKey:@"other"];
    [self.otherAddressesCollectionView setFrame:CGRectMake(6.0f,
                                                           CGRectGetMaxY(self.billingAddressCollectionView.frame) + 5.0f,
                                                           self.contentScrollView.frame.size.width - 12.0f,
                                                           otherAddresses.count * cellHeight + 27.0f + 44.0f)];
    
    
    [self.shippingAddressCollectionView reloadData];
    [self.billingAddressCollectionView reloadData];
    [self.otherAddressesCollectionView reloadData];
    
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
    
    
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, CGRectGetMaxY(self.otherAddressesCollectionView.frame) + _bottomView.frame.size.height + 5.0f)];
    
    [self.contentScrollView setHidden:NO];
    
    if (RI_IS_RTL) {
        [_bottomView setTotalValue:_bottomView.totalValue];
        [self.view flipAllSubviews];
    }
}

-(void)finishedLoadingAddresses
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && self.fromCheckout)
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
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

-(void)editAddressButtonPressed:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    
    UIView *view = [sender superview];
    if(VALID_NOTEMPTY(view, UIView))
    {
        UIView *cellView = [view superview];
        if(VALID_NOTEMPTY(cellView, UIView))
        {
            UIView *collectionView = [cellView superview];
            if(VALID_NOTEMPTY(collectionView, UIView))
            {
                RIAddress *addressToEdit = nil;
                if(self.shippingAddressCollectionView == [[[sender superview] superview] superview])
                {
                    addressToEdit = self.shippingAddress;
                }
                else if(self.billingAddressCollectionView == [[[sender superview] superview] superview])
                {
                    addressToEdit = self.billingAddress;
                }
                else if (self.otherAddressesCollectionView == [[[sender superview] superview] superview])
                {
                    NSArray* otherAddresses = [self.addresses objectForKey:@"other"];
                    addressToEdit = [otherAddresses objectAtIndex:tag];
                }
                
                if(VALID_NOTEMPTY(addressToEdit, RIAddress))
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutEditAddressScreenNotification
                                                                        object:nil
                                                                      userInfo:[NSDictionary dictionaryWithObjects:@[addressToEdit, [NSNumber numberWithBool:self.fromCheckout]] forKeys:@[@"address_to_edit", @"from_checkout"]]];
                }
            }
        }
    }
}

#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize sizeForItemAtIndexPath = CGSizeZero;
    
    CGFloat totalNumberOfAddressesInCollectionView = 0;
    
    if(collectionView == self.shippingAddressCollectionView || collectionView == self.billingAddressCollectionView)
    {
        totalNumberOfAddressesInCollectionView = 1;
    }
    else if(collectionView == self.otherAddressesCollectionView)
    {
        NSArray* otherAddresses = [self.addresses objectForKey:@"other"];
        totalNumberOfAddressesInCollectionView = [otherAddresses count];
    }

    if (indexPath.row < totalNumberOfAddressesInCollectionView) {
        // Address
        sizeForItemAtIndexPath = CGSizeMake(self.shippingAddressCollectionView.frame.size.width, 100.0f);
    } else if(indexPath.row == totalNumberOfAddressesInCollectionView) {
        // Add new address
        sizeForItemAtIndexPath = CGSizeMake(self.shippingAddressCollectionView.frame.size.width, 44.0f);
    }
    
    return sizeForItemAtIndexPath;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width, 27.0f);
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CGFloat totalNumberOfAddressesInCollectionView = 0;
    
    if(collectionView == self.shippingAddressCollectionView || collectionView == self.billingAddressCollectionView)
    {
        totalNumberOfAddressesInCollectionView = 2;
    }
    else if(collectionView == self.otherAddressesCollectionView)
    {
        NSArray* otherAddresses = [self.addresses objectForKey:@"other"];
        totalNumberOfAddressesInCollectionView = [otherAddresses count] + 1;
    }
    
    return totalNumberOfAddressesInCollectionView;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    RIAddress* address;
    
    if(collectionView == self.shippingAddressCollectionView) {
        if (0 == indexPath.row) {
            address = self.shippingAddress;
        }
    } else if(collectionView == self.billingAddressCollectionView) {
        if (0 == indexPath.row) {
            address = self.billingAddress;
        }
    } else {
        NSArray* otherAddresses = [self.addresses objectForKey:@"other"];
        if (indexPath.row < [otherAddresses count]) {
            address = [otherAddresses objectAtIndex:indexPath.row];
        }
    }
    
    if (VALID_NOTEMPTY(address, RIAddress)) {
        NSString *cellIdentifier = @"addressListCell";
        JAAddressCell *addressCell = (JAAddressCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        [addressCell loadWithAddress:address];
        [addressCell.editAddressButton setTag:indexPath.row];
        [addressCell.editAddressButton addTarget:self action:@selector(editAddressButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        addressCell.clickableView.tag = indexPath.row;
        
        cell = addressCell;
        
    } else {

        // Add new address
        NSString *cellIdentifier = @"addAddressListCell";
        JAAddNewAddressCell *addAddressCell = (JAAddNewAddressCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        [addAddressCell loadWithText:STRING_ADD_NEW_ADDRESS];
        addAddressCell.clickableView.tag = indexPath.row;
        [addAddressCell.clickableView addTarget:self action:@selector(addAddressCellPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        cell = addAddressCell;
    
    }
    
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    
    if (kind == UICollectionElementKindSectionHeader) {
        JACartListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader" forIndexPath:indexPath];
        
        if(collectionView == self.shippingAddressCollectionView)
        {
            if(self.useSameAddressAsBillingAndShipping)
            {
                [headerView loadHeaderWithText:STRING_DEFAULT_SHIPPING_ADDRESSES width:self.contentScrollView.frame.size.width - 12.0f];
            }
            else
            {
                [headerView loadHeaderWithText:STRING_SHIPPING_ADDRESSES width:self.contentScrollView.frame.size.width - 12.0f];
            }
        }
        else if(collectionView == self.billingAddressCollectionView)
        {
            [headerView loadHeaderWithText:STRING_BILLING_ADDRESSES width:self.contentScrollView.frame.size.width - 12.0f];
        } else if(collectionView == self.otherAddressesCollectionView)
        {
            [headerView loadHeaderWithText:STRING_OTHER_ADDRESSES width:self.contentScrollView.frame.size.width - 12.0f];
        }
        
        reusableview = headerView;
    }
    
    return reusableview;
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

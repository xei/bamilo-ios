//
//  JACampaignsViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 25/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignsViewController.h"
#import "RICart.h"
#import "RICampaign.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import "RITeaserComponent.h"

@interface JACampaignsViewController () <SearchViewControllerDelegate>

@property (nonatomic, strong)NSMutableArray* campaignPages;
@property (nonatomic, strong)JATopTabsView* topTabsView;
@property (nonatomic, strong)UIScrollView* scrollView;

// size picker view
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;

// for the retry connection, is necessary to store this stuff
@property (nonatomic, strong)RICampaignProduct* backupCampaignProduct;
@property (nonatomic, strong)NSString* backupSimpleSku;

@property (nonatomic, assign)BOOL shouldPerformButtonActions;

@property (nonatomic, assign)BOOL pickerNamesAlreadySet;

@property (nonatomic, assign)NSInteger campaignIndex;
@property (nonatomic, assign)NSNumber *clickedCampaignIndex;

@property (nonatomic, assign)JACampaignPageView* campaignPageWithSizePickerOpen;

@property (nonatomic, assign)RIApiResponse apiResponse;

@property (nonatomic, assign)BOOL isLoaded;

@property (nonatomic, strong)NSMutableArray* activeCampaignComponents;

@property (strong, nonatomic) RICart *cart;

@end

@implementation JACampaignsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.campaignIndex = -1;
    self.pickerNamesAlreadySet = NO;
    
    CGRect bounds = [self viewBounds];
    self.topTabsView = [[JATopTabsView alloc] initWithFrame:CGRectMake(bounds.origin.x,
                                                                       bounds.origin.y,
                                                                       bounds.size.width,
                                                                       49.0f)];
    self.topTabsView.delegate = self;
    [self.view addSubview:self.topTabsView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.shouldPerformButtonActions = YES;
    self.isLoaded = NO;
    
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipeGesture.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:leftSwipeGesture];
    [self.view addGestureRecognizer:rightSwipeGesture];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.isLoaded) {
        [self setupCampaings:[self viewBounds].size.width height:[self viewBounds].size.height interfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    } else {
        [self loadCampaigns];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    [self closePicker];
    [self.topTabsView setHidden:YES];
    [self.scrollView setHidden:YES];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setupCampaings:[self viewBounds].size.width height:[self viewBounds].size.height interfaceOrientation:self.interfaceOrientation];
    [self.topTabsView setHidden:NO];
    [self.scrollView setHidden:NO];
    [self hideLoading];    
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)setupCampaings:(CGFloat)width height:(CGFloat)height interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(VALID_NOTEMPTY(self.campaignPages, NSMutableArray) && 1 < [self.campaignPages count] && - 1 < self.campaignIndex) {
        [self.topTabsView setSelectedIndex:self.campaignIndex animated:NO];
    }
    CGRect bounds = [self viewBounds];
    [self.topTabsView setFrame:CGRectMake(bounds.origin.x, bounds.origin.y, width, self.topTabsView.frame.size.height)];
    
    [self.scrollView setFrame:CGRectMake(bounds.origin.x, CGRectGetMaxY(self.topTabsView.frame), width, height - self.topTabsView.frame.size.height )];
    
    if(VALID_NOTEMPTY(self.campaignPages, NSMutableArray)) {
        CGFloat currentX = 0.0f;
        for(JACampaignPageView *campaignPage in self.campaignPages) {
            [campaignPage setFrame:CGRectMake(currentX,
                                              self.scrollView.bounds.origin.y,
                                              self.scrollView.bounds.size.width,
                                              self.scrollView.bounds.size.height)];
            campaignPage.interfaceOrientation = interfaceOrientation;
            currentX += campaignPage.frame.size.width;
        }
        [self.scrollView setContentSize:CGSizeMake(currentX, self.scrollView.frame.size.height)];
    }
}

- (void)loadCampaigns {
    self.campaignPages = [NSMutableArray new];
    CGFloat currentX = 0.0f;
    
    NSInteger startingIndex = 0;
    NSMutableArray* optionList = [NSMutableArray new];
    
    if(VALID_NOTEMPTY(self.campaignId, NSString)) {
        [self createCampaignPageAtX:currentX];
        [self setupCampaings:[self viewBounds].size.width height:[self viewBounds].size.height interfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    } else if (VALID_NOTEMPTY(self.teaserGrouping, RITeaserGrouping) && VALID_NOTEMPTY(self.teaserGrouping.teaserComponents, NSOrderedSet)) {
        startingIndex = 0;RI_IS_RTL?self.teaserGrouping.teaserComponents.count-1:0;
        self.activeCampaignComponents = [NSMutableArray new];
        for (int i = RI_IS_RTL?(int)self.teaserGrouping.teaserComponents.count-1:0;
             RI_IS_RTL?i>=0:i < self.teaserGrouping.teaserComponents.count; RI_IS_RTL?i--:i++) {
            
            RITeaserComponent* component = [self.teaserGrouping.teaserComponents objectAtIndex:i];
            if (VALID_NOTEMPTY(component, RITeaserComponent)) {
                
                BOOL isActive = YES;
                //its active unless there is an ending date AND that date has passed
                if (VALID_NOTEMPTY(component.endingDate, NSDate)) {
                    NSInteger remainingSeconds = (NSInteger)[component.endingDate timeIntervalSinceNow];
                    if (0 >= remainingSeconds) {
                        isActive = NO;
                    }
                }
                
                if (isActive) {
                    JACampaignPageView* campaignPageView = [self createCampaignPageAtX:currentX];
                    currentX += campaignPageView.frame.size.width;
                    
                    if (VALID_NOTEMPTY(component.title, NSString)) {
                        [optionList addObject:component.title];
                        [self.activeCampaignComponents addObject:component];
                        if ([component.title isEqualToString:self.startingTitle]) {
                            startingIndex = RI_IS_RTL?(self.teaserGrouping.teaserComponents.count-1)-i:i;
                        }
                    }
                }
            }
        }
        
        [self setupCampaings:[self viewBounds].size.width height:[self viewBounds].size.height interfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        
        self.pickerNamesAlreadySet = YES;
    } else if (VALID_NOTEMPTY(self.targetString, NSString)) {
        [self createCampaignPageAtX:currentX];
        [self setupCampaings:[self viewBounds].size.width height:[self viewBounds].size.height interfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    
    //this will trigger load methods
    self.topTabsView.startingIndex = startingIndex;
    [self.topTabsView setupWithTabNames:optionList];
    
    self.isLoaded = YES;
}

- (JACampaignPageView*)createCampaignPageAtX:(CGFloat)xPosition {
    JACampaignPageView* campaignPage = [[JACampaignPageView alloc] initWithFrame:CGRectMake(xPosition,
                                                                                            self.scrollView.bounds.origin.y,
                                                                                            self.scrollView.bounds.size.width,
                                                                                            self.scrollView.bounds.size.height)];
    campaignPage.interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    campaignPage.delegate = self;
    [self.campaignPages addObject:campaignPage];
    [self.scrollView addSubview:campaignPage];
    
    return campaignPage;
}

- (void)loadCampaignPageAtIndex:(NSNumber *)index {
    if (self.campaignPages.count > index.intValue) {
        _clickedCampaignIndex = index;
        JACampaignPageView* campaignPageView = [self.campaignPages objectAtIndex:index.intValue];
        if (VALID_NOTEMPTY(campaignPageView, JACampaignPageView) && NO == campaignPageView.isLoaded) {
            if (VALID_NOTEMPTY(self.campaignId, NSString)) {
                [self loadPage:campaignPageView withCampaignId:self.campaignId];
            } else if (VALID_NOTEMPTY(self.activeCampaignComponents, NSMutableArray)) {
                RITeaserComponent* component = [self.activeCampaignComponents objectAtIndex:index.intValue];
                if (VALID_NOTEMPTY(component, RITeaserComponent) && VALID_NOTEMPTY(component.targetString, NSString)) {
                    [self loadPage:campaignPageView withCampaignTargetString:component.targetString];
                }
            } else if (VALID_NOTEMPTY(self.targetString, NSString)) {
                [self loadPage:campaignPageView withCampaignTargetString:self.targetString];
            }
        }
    }
}

- (void)loadPage:(JACampaignPageView*)campaignPage withCampaignTargetString:(NSString*)campaignTargetString {
    if (RIApiResponseNoInternetConnection != self.apiResponse) {
        [self showLoading];
    }
    self.apiResponse = RIApiResponseSuccess;
    [RICampaign getCampaignWithTargetString:campaignTargetString successBlock:^(RICampaign *campaign) {
        if (VALID_NOTEMPTY(self.topTabsView, JATopTabsView) && NO == [self.topTabsView isLoaded]) {
            [self.topTabsView setupWithTabNames:[NSArray arrayWithObject:campaign.name]];
        }
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        [campaignPage loadWithCampaign:campaign];
        [self publishScreenLoadTimeWithName:[self getScreenName] withLabel:campaign.name];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errors) {
        if (apiResponse == RIApiResponseAPIError) {
            for (NSDictionary *error in errors) {
                if (VALID(error, NSDictionary) && VALID([error objectForKey:@"reason"], NSString)) {
                    if ([[error objectForKey:@"reason"] isEqualToString:@"CAMPAIGN_NOT_EXIST"]) {
                        if (VALID_NOTEMPTY(self.topTabsView, JATopTabsView) && NO == [self.topTabsView isLoaded]) {
                            [self.topTabsView setupWithTabNames:[NSArray arrayWithObject:STRING_NOT_AVAILABLE]];
                        }
                        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                        [campaignPage loadWithCampaign:nil];
                        [self hideLoading];
                        return;
                    }
                }
            }
        }
        [self loadCampaignFailedWithResponse:apiResponse];
    }];
}

- (void)loadPage:(JACampaignPageView*)campaignPage withCampaignId:(NSString*)campaignId {
    [self showLoading];
    [RICampaign getCampaignWithId:campaignId successBlock:^(RICampaign *campaign) {
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        [campaignPage loadWithCampaign:campaign];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        if (apiResponse == RIApiResponseAPIError) {
            for (NSDictionary *err in error) {
                if (VALID([err objectForKey:@"reason"], NSString)) {
                    if ([[err objectForKey:@"reason"] isEqualToString:@"CAMPAIGN_NOT_EXIST"]) {
                        if (VALID_NOTEMPTY(self.topTabsView, JATopTabsView) && NO == [self.topTabsView isLoaded]) {
                            [self.topTabsView setupWithTabNames:[NSArray arrayWithObject:STRING_NOT_AVAILABLE]];
                        }
                        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                        [campaignPage loadWithCampaign:nil];
                        [self hideLoading];
                        return;
                    }
                }
            }
        }
        [self loadCampaignFailedWithResponse:apiResponse];
    }];
}

#pragma mark - JACampaignPageViewDelegate
- (void)loadCampaignSuccessWithName:(NSString*)name {
    if (NO == self.pickerNamesAlreadySet) {
        NSArray *optionList = [NSArray arrayWithObject:name];
        //this will trigger load methods
        [self.topTabsView setupWithTabNames:optionList];
    }
    [self hideLoading];
}

- (void)loadCampaignFailedWithResponse:(RIApiResponse)apiResponse {
    self.apiResponse = apiResponse;
    [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadCampaignPageAtIndex:) objects:[NSArray arrayWithObject:_clickedCampaignIndex]];
    [self hideLoading];
}


#pragma mark - JATopTabViewDelegate

- (void)selectedIndex:(NSInteger)index animated:(BOOL)animated {
    self.campaignIndex = index;
    JACampaignPageView* campaignPageView = [self.campaignPages objectAtIndex:index];
    [self.scrollView scrollRectToVisible:campaignPageView.frame animated:animated];
    if (NO == campaignPageView.isLoaded) {
        [self loadCampaignPageAtIndex:[NSNumber numberWithLong:index]];
    }
}

- (IBAction)swipeLeft:(id)sender {
    self.shouldPerformButtonActions = NO;
    [self.topTabsView scrollLeft];
}

- (IBAction)swipeRight:(id)sender {
    self.shouldPerformButtonActions = NO;
    [self.topTabsView scrollRight];
}

#pragma mark - JACampaignPageViewDelegate
- (void)addToCartForProduct:(RICampaignProduct *)campaignProduct withProductSimple:(NSString*)simpleSku {
    //the flag shouldPerformButtonActions is used to fix the scrolling, if the campaignPages.count is 1, then it is not needed
    if (self.shouldPerformButtonActions || 1 == self.campaignPages.count) {
        self.backupCampaignProduct = campaignProduct;
        self.backupSimpleSku = simpleSku;
        [self finishAddToCart];
    }
}

- (void)openCampaignProductWithTarget:(NSString*)targetString {
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo setObject:targetString forKey:@"targetString"];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    if (self.purchaseTrackingInfo) {
        [userInfo setObject:self.purchaseTrackingInfo forKey:@"purchaseTrackingInfo"];
    }
    //the flag shouldPerformButtonActions is used to fix the scrolling, if the campaignPages.count is 1, then it is not needed
    if (self.shouldPerformButtonActions || 1 == self.campaignPages.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication object:nil userInfo:userInfo];
    }
}

- (void)openPickerForCampaignPage:(JACampaignPageView*)campaignPage dataSource:(NSArray*)dataSource previousText:(NSString*)previousText {
    self.campaignPageWithSizePickerOpen = campaignPage;
    
    if(VALID(self.picker, JAPicker)) {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    self.pickerDataSource = [NSMutableArray new];
    
    [self.picker setDataSourceArray:dataSource previousText:previousText leftButtonTitle:nil];
    
    CGFloat pickerViewHeight = self.view.frame.size.height;
    CGFloat pickerViewWidth = self.view.frame.size.width;
    [self.picker setFrame:CGRectMake(0.0f, pickerViewHeight, pickerViewWidth, pickerViewHeight)];
    [self.view addSubview:self.picker];
    
    [UIView animateWithDuration:0.4f animations:^{
        [self.picker setFrame:CGRectMake(0.0f, 0.0f, pickerViewWidth, pickerViewHeight)];
    }];
}

- (void)finishAddToCart {
    [DataAggregator addProductToCart:self simpleSku:self.backupSimpleSku completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            
            [self trackAddToCartAction:YES];
            
            if (VALID_NOTEMPTY(self.purchaseTrackingInfo, NSString)) {
                [[PurchaseBehaviourRecorder sharedInstance] recordAddToCartWithSku:self.backupSimpleSku trackingInfo:self.purchaseTrackingInfo];
            }
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.cart forKey:kUpdateCartNotificationValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
            
            [self onSuccessResponse:RIApiResponseSuccess messages:[self extractSuccessMessages:[data objectForKey:kDataMessages]] showMessage:YES];
            //[self hideLoading];
        } else {
            //EVENT : ADD TO CART
            [self trackAddToCartAction:NO];
            [self onErrorResponse:error.code messages:[error.userInfo objectForKey:kErrorMessages] showAsMessage:YES selector:@selector(finishAddToCart) objects:nil];
            //[self hideLoading];
        }
    }];
}

- (void)trackAddToCartAction:(BOOL)success {
    RIProduct *product = [RIProduct new];
    product.sku = self.backupSimpleSku;
    product.price = self.cart.cartEntity.cartValue;
    //EVENT : ADD TO CART
    [TrackerManager postEventWithSelector:[EventSelectors addToCartEventSelector]
                               attributes:[EventAttributes addToCartWithProduct:product screenName:[self getScreenName] success:success]];
}

#pragma mark - UIScrollViewDelegate
//this depends on animation existing. if in the future there is a case where no animation
//happens on the scroll view, we have to move this to another scrollviewdelegate method
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.shouldPerformButtonActions = YES;
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow {
    [self.campaignPageWithSizePickerOpen selectedSizeIndex:selectedRow];
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    [UIView animateWithDuration:0.4f animations:^{
        self.picker.frame = frame;
    } completion:^(BOOL finished) {
        [self.picker removeFromSuperview];
        self.picker = nil;
    }];
}

- (void)closePicker {
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    [UIView animateWithDuration:0.4f animations:^{
        self.picker.frame = frame;
    } completion:^(BOOL finished) {
        [self.picker removeFromSuperview];
        self.picker = nil;
    }];
}

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"CampaignPage";
}

-(NSString *)getPerformanceTrackerLabel {
    NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];
    return [NSString stringWithFormat:@"%@", [skusFromTeaserInCart allKeys]];
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        case 0:
            self.cart = [data objectForKey:kDataContent];
        break;
            
        default:
            break;
    }
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_CAMPAIGNS;
}

- (NavBarButtonType)navBarleftButton {
    return NavBarButtonTypeSearch;
}

@end

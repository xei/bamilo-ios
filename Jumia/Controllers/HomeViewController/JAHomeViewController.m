//
//  JAHomeViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAHomeViewController.h"
#import "RITeaserGrouping.h"
#import "JATeaserPageView.h"
#import "JATeaserView.h"
#import "JAUtils.h"
#import "RICustomer.h"
#import "JAPromotionPopUp.h"
#import "JAAppDelegate.h"
#import "JAFallbackView.h"
#import "RIAddress.h"
#import "RIForm.h"
#import "JAPicker.h"

@interface JAHomeViewController () <JAPickerDelegate>

@property (strong, nonatomic) JATeaserPageView* teaserPageView;

@property (nonatomic, assign) BOOL isLoaded;

@property (nonatomic, strong)JAFallbackView *fallbackView;

@property (nonatomic, strong) JARadioComponent *radioComponent;
@property (nonatomic, strong) JAPicker *picker;

@end

@implementation JAHomeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"newsletter_subscribed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.navBarLayout.showCartButton = NO;
    //has to be done before calling super
    self.searchBarIsVisible = YES;
    self.tabBarIsVisible = YES;
    
    [super viewDidLoad];
    
    self.screenName = @"ShopMain";
    self.A4SViewControllerAlias = @"HOME";
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
    if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
    {
        [trackingDictionary setValue:[numberOfSessions stringValue] forKey:kRIEventAmountSessions];
    }
    
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    
    if ([RICustomer checkIfUserIsLogged]) {
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
        [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
                RIAddress *shippingAddress = (RIAddress *)[adressList objectForKey:@"shipping"];
                [trackingDictionary setValue:shippingAddress.city forKey:kRIEventCityKey];
                [trackingDictionary setValue:shippingAddress.customerAddressRegion forKey:kRIEventRegionKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookHome]
                                                      data:[trackingDictionary copy]];
            
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            NSLog(@"ERROR: getting customer");
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookHome]
                                                      data:[trackingDictionary copy]];
        }];
    }else{
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookHome]
                                                  data:[trackingDictionary copy]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(campaignTimerEnded)
                                                 name:kCampaignMainTeaserTimerEndedNotification
                                               object:nil];
    
    self.isLoaded = NO;
    
    self.teaserPageView = [[JATeaserPageView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:kHomeShouldReload object:nil];
}

-(void)campaignTimerEnded
{
    if (self.isLoaded) {
        [self.teaserPageView loadTeasersForFrame:[self viewBounds]];
    }
}

- (void)stopLoading
{
    [self hideLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestTeasers];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffMenuSwipePanelNotification
                                                        object:nil];
    
    [self hideLoading];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"HomeShop"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    if(VALID_NOTEMPTY(self.fallbackView, JAFallbackView) && VALID_NOTEMPTY(self.fallbackView.superview, UIView))
    {
        [self.fallbackView setupFallbackView:CGRectMake(self.fallbackView.frame.origin.x,
                                                        self.fallbackView.frame.origin.y,
                                                        [self viewBounds].size.height + [self viewBounds].origin.y,
                                                        [self viewBounds].size.width - [self viewBounds].origin.y)
                                 orientation:toInterfaceOrientation];
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (self.isLoaded) {
        [self.teaserPageView setFrame:[self viewBounds]];
    }
    
    [self hideLoading];
    
    if(VALID_NOTEMPTY(self.fallbackView, JAFallbackView) && VALID_NOTEMPTY(self.fallbackView.superview, UIView))
    {
        [self.fallbackView setupFallbackView:[self viewBounds] orientation:self.interfaceOrientation];
    }
}

- (void)reload
{
    self.isLoaded = NO;
    [self requestTeasers];
}

- (void)requestTeasers
{
    if (self.isLoaded) {
        return;
    }
    
    [RITeaserGrouping getTeaserGroupingsWithSuccessBlock:^(NSDictionary *teaserGroupings, BOOL richTeasers) {
        
        NSArray *forms = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIForm class]) withPropertyName:@"type" andPropertyValue:@"newsletter_homepage"];
        RIForm *form = nil;
        if (forms.count > 0) {
            form = [forms lastObject];
        }
        
        [self.teaserPageView setNewsletterForm:form];
        self.teaserPageView.teaserGroupings = teaserGroupings;
        [self.teaserPageView setGenderPickerDelegate:self];
        [self.teaserPageView loadTeasersForFrame:[self viewBounds]];
        [self.view addSubview:self.teaserPageView];
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
        // notify the InAppNotification SDK that this the active view controller
        [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        self.isLoaded = YES;
        
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
        //if this is the failure came from richBlock, fail gracefully
        if (!self.isLoaded) {
            if(self.firstLoading)
            {
                NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                self.firstLoading = NO;
            }
            
            if(RIApiResponseMaintenancePage == apiResponse || RIApiResponseKickoutView == apiResponse || RIApiResponseNoInternetConnection == apiResponse)
            {
                [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(requestTeasers) objects:nil];
            } else {
                self.fallbackView = [JAFallbackView getNewJAFallbackView];
                [self.fallbackView setupFallbackView:[self viewBounds] orientation:self.interfaceOrientation];
                [self.view addSubview:self.fallbackView];
            }
        }
    } andRichBlock:^(RITeaserGrouping *richTeaserGroupings) {
        NSMutableDictionary *tempTeaserGroupings = [self.teaserPageView.teaserGroupings mutableCopy];
        [tempTeaserGroupings setObject:richTeaserGroupings forKey:richTeaserGroupings.type];
        
        self.teaserPageView.teaserGroupings = [tempTeaserGroupings copy];
        [self.teaserPageView addTeaserGrouping:richTeaserGroupings.type];
    }];
}

- (void)loadPromotion:(RIPromotion*)promotion
{
    JAPromotionPopUp* promotionPopUp = [[JAPromotionPopUp alloc] initWithFrame:[self viewBounds]];
    [promotionPopUp loadWithPromotion:promotion];
    [self.view addSubview:promotionPopUp];
}

#pragma mark - Newsletter

#pragma mark - Picker

- (void)openPicker:(JARadioComponent *)radioComponent
{
    self.radioComponent = radioComponent;
    
    if (VALID(self.picker, JAPicker)) {
        [self.picker removeFromSuperview];
        self.picker = nil;
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.bounds];
    [self.picker setDelegate:self];
    
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    if (VALID_NOTEMPTY([radioComponent options], NSArray)) {
        
        for (id currentObject in [radioComponent options]) {
            if (VALID_NOTEMPTY(currentObject, NSString)) {
                [dataSource addObject:[radioComponent.optionsLabels objectForKey:currentObject]];
            }
        }
    }
    
    [self.picker setDataSourceArray:[dataSource copy]
                       previousText:@""
                    leftButtonTitle:nil];
    
    CGFloat pickerViewHeight = self.view.frame.size.height;
    CGFloat pickerViewWidth = self.view.frame.size.width;
    [self.picker setFrame:CGRectMake(0.0f,
                                     pickerViewHeight,
                                     pickerViewWidth,
                                     pickerViewHeight)];
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.picker setFrame:CGRectMake(0.0f,
                                                          0.0f,
                                                          pickerViewWidth,
                                                          pickerViewHeight)];
                     }];
    
    [self.view addSubview:self.picker];
}
- (void)selectedRow:(NSInteger)selectedRow
{
    if (VALID_NOTEMPTY(self.radioComponent, JARadioComponent)) {
        NSString *selectedValue = [self.radioComponent.options objectAtIndex:selectedRow];
        [self.radioComponent setValue:selectedValue];
        [self.radioComponent.textField setText:[self.radioComponent.optionsLabels objectForKey:selectedValue]];
    }
    [self closePickers];
}

- (void)closePickers
{
    CGRect framePhonePrefix = self.picker.frame;
    framePhonePrefix.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = framePhonePrefix;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                     }];
}

- (void)submitNewsletter:(JADynamicForm *)dynamicForm andEmail:(NSString *)email
{
    [self showLoading];
    [RIForm sendForm:dynamicForm.form parameters:[dynamicForm getValues] successBlock:^(id object) {
        [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIForm class]) withPropertyName:@"type" andPropertyValue:@"newsletter_homepage"];
        [self reload];
        [self onSuccessResponse:RIApiResponseSuccess messages:object showMessage:YES];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
        
        if (apiResponse == RIApiResponseSuccess) {
            [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIForm class]) withPropertyName:@"type" andPropertyValue:@"newsletter_homepage"];
            [self reload];
        }
        if(VALID_NOTEMPTY(errorObject, NSDictionary))
        {
            [dynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(submitNewsletter:andEmail:) objects:@[dynamicForm]];
            }];
        }
        else if(VALID_NOTEMPTY(errorObject, NSArray))
        {
            [dynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(submitNewsletter:andEmail:) objects:@[dynamicForm]];
            }];
        }else{
            [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(submitNewsletter:andEmail:) objects:@[dynamicForm]];
        }
        [self hideLoading];
    }];
}

@end

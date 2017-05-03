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
//#import "RIForm.h"
#import "JAPicker.h"
#import "JANewsletterTeaserView.h"
#import "JACenterNavigationController.h"
#import "JATabBarButton.h"

//#########################################
#import "ViewControllerManager.h"
#import "EmarsysPredictProtocol.h"
#import "NSArray+Extension.h"
#import "RecommendItem.h"
#import "EmarsysRecommendationCarouselView.h"
#import "EmarsysRecommendationMinimalCarouselWidgetView.h"
#import "ThreadManager.h"
#import "EmarsysPredictManager.h"
#import "DeepLinkManager.h"

@interface JAHomeViewController () <JAPickerDelegate, JANewsletterGenderProtocol, EmarsysRecommendationsProtocol, FeatureBoxCollectionViewWidgetViewDelegate>
@property (strong, nonatomic) JATeaserPageView* teaserPageView;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, strong) JAFallbackView *fallbackView;
@property (nonatomic, strong) JARadioComponent *radioComponent;
@property (nonatomic, strong) JAPicker *picker;

@end

@implementation JAHomeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"newsletter_subscribed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showSeparatorView = NO;
    self.searchBarIsVisible = YES;
    self.tabBarIsVisible = YES;
    self.isLoaded = NO;
    
    self.teaserPageView = [[JATeaserPageView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(campaignTimerEnded) name:kCampaignMainTeaserTimerEndedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:kHomeShouldReload object:nil];
    
    [self requestTeasers];
}

- (void)campaignTimerEnded {
    if (self.isLoaded) {
        [self.teaserPageView loadTeasersForFrame:[self viewBounds]];
    }
}

- (void)stopLoading {
    [self hideLoading];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffMenuSwipePanelNotification object:nil];
    
    [self hideLoading];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self presentCoachMarks];
    }
    
    if ([self isBeingPresented] || [self isMovingToParentViewController]) {
        //Perform an action that will only be done once
        [DeepLinkManager listenersReady];
    }
}

- (void)presentCoachMarks {
    
    CGRect searchButtonFrame = self.searchIconImageView.frame; //search button
    JATabBarButton* moreButton = [[ViewControllerManager centerViewController].tabBarView.tabButtonsArray objectAtIndex:4];//morbutton in tab
    CGRect moreButtonFrame = moreButton.frame;
    CGRect menuButtonFrame = [[ViewControllerManager centerViewController].navigationBarView.leftButton frame];//menu button
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        searchButtonFrame.origin.y = searchButtonFrame.origin.y + 64.0f;
        moreButtonFrame.origin.y = self.bounds.size.height + 64.0f;
    } else {
        moreButtonFrame.origin.y = self.bounds.size.height;
    }

    // Setup coach marks
    CGRect coachmark1 = CGRectMake( searchButtonFrame.origin.x - 10, searchButtonFrame.origin.y - 15, searchButtonFrame.size.width +35, searchButtonFrame.size.height + 35);
    CGRect coachmark2 = CGRectMake( menuButtonFrame.origin.x, menuButtonFrame.origin.y + 22, menuButtonFrame.size.width, menuButtonFrame.size.height - 4);
    CGRect coachmark3;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        coachmark3 = CGRectMake( 45, moreButtonFrame.origin.y + 54, moreButtonFrame.size.width - 90, moreButtonFrame.size.height);
    }
    else{
        coachmark3 = CGRectMake( 10, moreButtonFrame.origin.y + 64, moreButtonFrame.size.width - 20, moreButtonFrame.size.height - 10);
    }
    CGRect coachmark4 = CGRectMake( self.view.center.x, self.view.center.y,0,0);

    // Setup coach marks
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:coachmark2],
                                @"caption": @"جستجو در منوی اصلی مجموعه ها",
                                @"shape": [NSNumber numberWithInteger:SHAPE_CIRCLE],
                                @"alignment":[NSNumber numberWithInteger:LABEL_ALIGNMENT_CENTER],
                                @"position":[NSNumber numberWithInteger:LABEL_POSITION_LEFT]
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:coachmark1],
                                @"caption": @"جستجو در فروشگاه \n\n نام محصول، برند و یا مجموعه ای که می خواهید را جستجو کنید",
                                @"shape": [NSNumber numberWithInteger:SHAPE_CIRCLE],
                                @"alignment":[NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT],
                                @"position":[NSNumber numberWithInteger:LABEL_POSITION_RIGHT]
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:coachmark3],
                                @"caption": @"ورود / ساخت حساب کاربری و پیگیری سفارش",
                                @"shape": [NSNumber numberWithInteger:SHAPE_CIRCLE],
                                @"alignment":[NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT],
                                @"position":[NSNumber numberWithInteger:LABEL_POSITION_RIGHT]
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:coachmark4],
                                @"caption": @"حرکت در میان رویدادهای جاری بامیلو",
                                @"shape": [NSNumber numberWithInteger:SHAPE_CIRCLE],
                                @"alignment":[NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT],
                                @"position":[NSNumber numberWithInteger:LABEL_POSITION_TOP],
                                @"showArrow":[NSNumber numberWithBool:YES],
                                @"caption3": @"حرکت عمودی در تمام صفحات",
                                @"caption2":@"حرکت در میان محصولات برگزیده"
                                }
                            ];

    MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
    [self.navigationController.view addSubview:coachMarksView];
    [coachMarksView start];
}


- (void)viewDidDisappear:(BOOL)animated {
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.teaserPageView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"HomeShop"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self showLoading];
    
    if(self.fallbackView && self.fallbackView.superview) {
        [self.fallbackView setupFallbackView:CGRectMake(self.fallbackView.frame.origin.x,
                                                        self.fallbackView.frame.origin.y,
                                                        [self viewBounds].size.height + [self viewBounds].origin.y,
                                                        [self viewBounds].size.width - [self viewBounds].origin.y)
                                 orientation:toInterfaceOrientation];
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.isLoaded) {
        [self.teaserPageView setFrame:[self viewBounds]];
    }
    [self hideLoading];
    if(self.fallbackView && self.fallbackView.superview) {
        [self.fallbackView setupFallbackView:[self viewBounds] orientation:[[UIApplication sharedApplication] statusBarOrientation]];
    }
}

- (void)reload {
    self.isLoaded = NO;
    [self requestTeasers];
}

- (void)requestTeasers {
    if (self.isLoaded) {
        return;
    }
    [RITeaserGrouping getTeaserGroupingsWithSuccessBlock:^(NSDictionary *teaserGroupings, BOOL richTeaserGrouping) {
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
        
        [self publishScreenLoadTime];
        
        //############## when home page is fully loaded & rendered
        [EmarsysPredictManager sendTransactionsOf:self];
        
        // notify the InAppNotification SDK that this the active view controller
        [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        self.isLoaded = YES;
    } failBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
        //if this is the failure came from richBlock, fail gracefully
        if (!self.isLoaded) {
            [self publishScreenLoadTime];
            
            if(RIApiResponseMaintenancePage == apiResponse || RIApiResponseKickoutView == apiResponse || RIApiResponseNoInternetConnection == apiResponse) {
                [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(requestTeasers) objects:nil];
            } else {
                self.fallbackView = [JAFallbackView getNewJAFallbackView];
                [self.fallbackView setupFallbackView:[self viewBounds] orientation:[[UIApplication sharedApplication] statusBarOrientation]];
                [self.view addSubview:self.fallbackView];
            }
        }
    } rickBlock:^(RITeaserGrouping *richTeaserGrouping) {
        NSMutableDictionary *tempTeaserGroupings = [self.teaserPageView.teaserGroupings mutableCopy];
        [tempTeaserGroupings setObject:richTeaserGrouping forKey:richTeaserGrouping.type];
        
        self.teaserPageView.teaserGroupings = [tempTeaserGroupings copy];
        [self.teaserPageView addTeaserGrouping:richTeaserGrouping.type];
    }];
}

- (void)loadPromotion:(RIPromotion*)promotion {
    JAPromotionPopUp* promotionPopUp = [[JAPromotionPopUp alloc] initWithFrame:[self viewBounds]];
    [promotionPopUp loadWithPromotion:promotion];
    [self.view addSubview:promotionPopUp];
}

#pragma mark - Picker
- (void)openPicker:(JARadioComponent *)radioComponent {
    self.radioComponent = radioComponent;
    
    if (self.picker) {
        [self.picker removeFromSuperview];
        self.picker = nil;
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.bounds];
    [self.picker setDelegate:self];
    
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    if ([[radioComponent options] count]) {
        
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
    [self.picker setFrame:CGRectMake(0.0f, pickerViewHeight, pickerViewWidth, pickerViewHeight)];
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.picker setFrame:CGRectMake(0.0f, 0.0f, pickerViewWidth, pickerViewHeight)];
                     }];
    
    [self.view addSubview:self.picker];
}
- (void)selectedRow:(NSInteger)selectedRow {
    if (self.radioComponent) {
        NSString *selectedValue = [self.radioComponent.options objectAtIndex:selectedRow];
        [self.radioComponent setValue:selectedValue];
        [self.radioComponent.textField setText:[self.radioComponent.optionsLabels objectForKey:selectedValue]];
    }
    [self closePickers];
}

- (void)closePickers {
    CGRect framePhonePrefix = self.picker.frame;
    framePhonePrefix.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f animations:^{
        self.picker.frame = framePhonePrefix;
    } completion:^(BOOL finished) {
        [self.picker removeFromSuperview];
        self.picker = nil;
    }];
}

- (void)submitNewsletter:(JADynamicForm *)dynamicForm andEmail:(NSString *)email {
    if([dynamicForm checkErrors]) {
        return;
    }
    [self showLoading];
    [RIForm sendForm:dynamicForm.form parameters:[dynamicForm getValues] successBlock:^(id object, NSArray* successMessages) {
        [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIForm class]) withPropertyName:@"type" andPropertyValue:@"newsletter_homepage"];
        [self reload];
        [self onSuccessResponse:RIApiResponseSuccess messages:object showMessage:YES];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
        
        if (apiResponse == RIApiResponseSuccess) {
            [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIForm class]) withPropertyName:@"type" andPropertyValue:@"newsletter_homepage"];
            [self reload];
        }
        if(errorObject) {
            [dynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(submitNewsletter:andEmail:) objects:@[dynamicForm]];
            }];
        } else if(VALID_NOTEMPTY(errorObject, NSArray)) {
            [dynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(submitNewsletter:andEmail:) objects:@[dynamicForm]];
            }];
        } else {
            [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(submitNewsletter:andEmail:) objects:@[dynamicForm]];
        }
        [self hideLoading];
    }];
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    return @"Home";
}

#pragma mark - DataTrackerProtocol
-(NSString *)getDataTrackerAlias {
    return @"HOME";
}

#pragma EmarsysRecommendationsProtocol

- (BOOL)isPreventSendTransactionInViewWillAppear {
    return YES;
}

- (NSArray<EMRecommendationRequest *> *)getRecommendations {
    
    EMRecommendationRequest *recommend = [EMRecommendationRequest requestWithLogic:@"PERSONAL"];
    recommend.limit = 15;
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
        [self renderRecommendations:result];
    };
    
    return @[recommend];
}

- (void)renderRecommendations:(EMRecommendationResult *)result {
    NSArray<RecommendItem *> *recommendItems = [result.products map:^id(EMRecommendationItem *item) {
        return [RecommendItem instanceWithEMRecommendationItem:item];
    }];
    
    EmarsysRecommendationCarouselView *recommendationView = [EmarsysRecommendationCarouselView nibInstance];
    recommendationView.delegate = self;
    [recommendationView updateTitle:STRING_SPECIFICATIONS];
    
    
    [ThreadManager executeOnMainThread:^{
        [self.teaserPageView addCustomViewToScrollView:recommendationView];
        [recommendationView updateWithModel:recommendItems];
    }];
}

#pragma mark - FeatureBoxCollectionViewWidgetViewDelegate
- (void)selectFeatureItem:(NSObject *)item widgetBox:(id)widgetBox {
    if ([item isKindOfClass:[RecommendItem class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName: kDidSelectTeaserWithPDVUrlNofication
                                                            object: nil
                                                          userInfo: @{@"sku": ((RecommendItem *)item).sku}];
    }
}

@end

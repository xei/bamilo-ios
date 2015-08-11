//
//  JACatalogViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogViewController.h"
#import "RIProduct.h"
#import "JAUtils.h"
#import "RISearchSuggestion.h"
#import "RICustomer.h"
#import "RIFilter.h"
#import "JACatalogWizardView.h"
#import "JAClickableView.h"
#import "JAUndefinedSearchView.h"
#import "JAFilteredNoResultsView.h"
#import "JAAppDelegate.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import "JANavigationBarView.h"
#import "UIImageView+JA.h"
#import "UIImageView+WebCache.h"
#import "JACampaignBannerCell.h"
#import "JACatalogBannerCell.h"
#import "JAProductListFlowLayout.h"
#import "JACatalogCollectionViewCell.h"
#import "JACatalogListCollectionViewCell.h"
#import "JACatalogGridCollectionViewCell.h"

#define JACatalogGridSelected @"CATALOG_GRID_IS_SELECTED"
#define JACatalogViewControllerButtonColor UIColorFromRGB(0xe3e3e3);
#define JACatalogViewControllerMaxProducts 36
#define JACatalogViewControllerMaxProducts_ipad 46

@interface JACatalogViewController ()
<JAFilteredNoResulsViewDelegate>

@property (nonatomic, strong)JACatalogWizardView* wizardView;
@property (nonatomic, strong) JAFilteredNoResultsView *filteredNoResultsView;

@property (nonatomic, strong) JACatalogTopView* catalogTopView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) JAProductListFlowLayout* flowLayout;
@property (nonatomic, strong) NSMutableArray* productsArray;
@property (nonatomic, strong) NSArray* filtersArray;
@property (nonatomic, strong) NSArray* categoriesArray;
@property (nonatomic, strong) RICategory* filterCategory;
@property (nonatomic, assign) BOOL loadedEverything;
@property (nonatomic, assign) RICatalogSorting sortingMethod;
@property (nonatomic, strong) JAUndefinedSearchView *undefinedView;
@property (nonatomic, strong) RIUndefinedSearchTerm *undefinedBackup;
@property (assign, nonatomic) BOOL isFirstLoadTracking;
@property (assign, nonatomic) BOOL isLoadingMoreProducts;
@property (nonatomic, strong) NSString *searchSuggestionOperationID;
@property (nonatomic, strong) NSString *getProductsOperationID;

@property (strong, nonatomic) UIButton *backupButton; // for the retry

@property (nonatomic, strong) NSString* cellIdentifier;
@property (nonatomic, assign) NSInteger numberOfCellsInScreen;
@property (nonatomic, assign) NSInteger maxProducts;

@property (nonatomic, assign) RIApiResponse apiResponse;

@property (nonatomic, strong) JASortingView* sortingView;
@property (nonatomic, strong) RIBanner *banner;
@property (nonatomic, strong) UIImageView* bannerImage;

@end

@implementation JACatalogViewController

@synthesize bannerImage = _bannerImage;
- (UIImageView*)bannerImage
{
    if (VALID_NOTEMPTY(_bannerImage, UIImageView)) { 
        //do nothing
    } else {
        _bannerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     1.0f,
                                                                     1.0f)];
        if (VALID_NOTEMPTY(self.banner, RIBanner)) {
            NSString* imageUrl;
            BOOL isLandscape = self.view.frame.size.width > self.view.frame.size.height?YES:NO;
            if((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) && isLandscape) {
                imageUrl = self.banner.iPadImageUrl;
            } else {
                imageUrl = self.banner.iPhoneImageUrl;
            }
            if (VALID_NOTEMPTY(imageUrl, NSString)) {
                __block UIImageView *blockedImageView = _bannerImage;
                __weak JACatalogViewController* weakSelf = self;
                [_bannerImage setImageWithURL:[NSURL URLWithString:imageUrl]
                                      success:^(UIImage *image, BOOL cached){
                                          [blockedImageView changeImageHeight:0.0f andWidth:weakSelf.collectionView.frame.size.width];
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [weakSelf.collectionView reloadData];
                                          });
                                      }failure:^(NSError *error){}];
            }
        }
    }
    return _bannerImage;
    
}


- (void)showErrorView:(BOOL)isNoInternetConnection startingY:(CGFloat)startingY selector:(SEL)selector objects:(NSArray*)objects;
{
    if (VALID_NOTEMPTY(self.wizardView, JACatalogWizardView)) {
        [self.wizardView removeFromSuperview];
    }

    [super showErrorView:isNoInternetConnection startingY:startingY selector:selector objects:objects];
}

-(void)showNoResultsView:(CGFloat)withVerticalPadding undefinedSearchTerm:(RIUndefinedSearchTerm*)undefinedSearchTerm
{
    [self.wizardView removeFromSuperview];
    
    self.filteredNoResultsView.delegate = nil;
    [self.filteredNoResultsView removeFromSuperview];
    self.filteredNoResultsView = [JAFilteredNoResultsView getFilteredNoResultsView];
    
    self.filteredNoResultsView.tag = 1001;
    
    // fail-safe condition: launches error view in case something goes wrong
    if(self.filteredNoResultsView == nil || ISEMPTY(self.filtersArray))
    {
        if(VALID_NOTEMPTY(undefinedSearchTerm, RIUndefinedSearchTerm))
        {
            self.undefinedBackup = undefinedSearchTerm;
            self.navBarLayout.subTitle = [NSString stringWithFormat:@"0 %@",STRING_ITEMS];
            [self reloadNavBar];
            [self addUndefinedSearchView:self.undefinedBackup frame:CGRectMake(6.0f,
                                                                               self.catalogTopView.frame.origin.y,
                                                                               [self viewBounds].size.width - 12.0f,
                                                                               [self viewBounds].size.height)];
        }
        else
        {
            [self showErrorView:NO startingY:withVerticalPadding selector:@selector(loadMoreProducts) objects:nil];
        }
    }
    else
    {
        self.filteredNoResultsView.delegate = self;
        
        if (VALID_NOTEMPTY(self.wizardView, JACatalogWizardView))
        {
            [self.wizardView removeFromSuperview];
        }
    
        self.catalogTopView.hidden = YES;
        
        [self.bannerImage setHidden:YES];
        
        [self.collectionView setHidden:YES];
        
        [self.filteredNoResultsView setupView:[self viewBounds]];
        
        
        [self.view addSubview:self.filteredNoResultsView];
    }
}

/**
 * delegate method to respond when the edit filters button is pressed in the JAFilteredNoResultsView
 *
 */
-(void)pressedEditFiltersButton:(JAFilteredNoResultsView *)view
{
    [self.filteredNoResultsView removeFromSuperview];
    
    [self.collectionView setHidden:NO];
    
    [self.bannerImage setHidden:NO];
    
    self.catalogTopView.hidden = NO;
    
    [self filterButtonPressed];
}

- (void)showLoading
{
    [super showLoading];
}

- (void)viewDidLoad
{
    self.searchBarIsVisible = YES;
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navBarClicked)
                                                 name:kDidPressNavBar
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changedFavoriteStateOfProduct:)
                                                 name:kProductChangedNotification
                                               object:nil];
    
    self.apiResponse = RIApiResponseSuccess;
    
    if (self.forceShowBackButton)
    {
        self.navBarLayout.showBackButton = YES;
    }
    
    if (VALID_NOTEMPTY(self.searchString, NSString))
    {
        self.screenName = @"SearchResults";
    }
    else
    {
        if(VALID_NOTEMPTY(self.category, RICategory))
        {
            self.screenName = [NSString stringWithFormat:@"Catalog / %@", self.category.name];
        }
        else
        {
            self.screenName = @"Catalog";
        }
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.maxProducts = JACatalogViewControllerMaxProducts_ipad;
    } else {
        self.maxProducts = JACatalogViewControllerMaxProducts;
    }
    
    [self setupViews];
    
    if (VALID_NOTEMPTY(self.searchString, NSString) || VALID_NOTEMPTY(self.category, RICategory) || VALID_NOTEMPTY(self.catalogUrl, NSString))
    {
        [self loadMoreProducts];
    }
    else
    {
        [self getCategories];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(VALID_NOTEMPTY(self.searchSuggestionOperationID, NSString))
    {
        [RISearchSuggestion cancelRequest:self.searchSuggestionOperationID];
        [self hideLoading];
    }
    else if(VALID_NOTEMPTY(self.getProductsOperationID, NSString))
    {
        [RIProduct cancelRequest:self.getProductsOperationID];
        [self hideLoading];
    }
    
    if(VALID_NOTEMPTY(self.collectionView, UICollectionView))
    {
        CGPoint contentOffset = self.collectionView.contentOffset;
        [self.collectionView setContentOffset:contentOffset];
    }
}

- (void)viewDidLayoutSubviews
{
    [self.collectionView setX:6.0f];
    [self.collectionView setWidth:self.view.width - 12.f];
    [self.collectionView setHeight:self.view.height - self.collectionView.y];
    [self.catalogTopView repositionForWidth:self.view.frame.size.width];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"ShopCatalogList"];
}
 
- (void)setupViews
{
    self.productsArray = [NSMutableArray new];
    
    self.isFirstLoadTracking = NO;
    
    self.catalogTopView = [JACatalogTopView getNewJACatalogTopView];
    [self.catalogTopView setFrame:CGRectMake([self viewBounds].origin.x,
                                             [self viewBounds].origin.y,
                                             [self viewBounds].size.width,
                                             self.catalogTopView.frame.size.height)];
    self.catalogTopView.gridSelected = NO;
    self.catalogTopView.delegate = self;
    [self.view addSubview:self.catalogTopView];
    self.catalogTopView.sortingButton.enabled = NO;
    self.catalogTopView.filterButton.enabled = NO;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JACatalogBannerCell" bundle:nil] forCellWithReuseIdentifier:@"bannerCell"];
    [self.collectionView registerClass:[JACatalogListCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogListCollectionViewCell"];
    [self.collectionView registerClass:[JACatalogGridCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogGridCollectionViewCell"];
    
    self.flowLayout = [[JAProductListFlowLayout alloc] init];
    self.flowLayout.manualCellSpacing = 6.0f;
    self.flowLayout.minimumLineSpacing = 6.0f;
    self.flowLayout.minimumInteritemSpacing = 0.f;
    //                                              top, left, bottom, right
    [self.flowLayout setSectionInset:UIEdgeInsetsMake(0.f, 0.0, 0.0, 0.0)];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
    self.sortingMethod = RICatalogSortingPopularity;
    if (VALID_NOTEMPTY(self.sortingMethodFromPush, NSNumber)) {
        self.sortingMethod = [self.sortingMethodFromPush integerValue];
    }
    [self.catalogTopView setSorting:self.sortingMethod];
    [self.catalogTopView repositionForWidth:self.view.frame.size.width];
    
    NSNumber* gridSelected = [[NSUserDefaults standardUserDefaults] objectForKey:JACatalogGridSelected];
    self.catalogTopView.gridSelected = [gridSelected boolValue];
}

- (void)getCategories
{
    if(RIApiResponseSuccess == self.apiResponse || RIApiResponseMaintenancePage == self.apiResponse || RIApiResponseKickoutView == self.apiResponse)
    {
        [self showLoading];
    }
    
    [RICategory getAllCategoriesWithSuccessBlock:^(id categories)
     {
         self.apiResponse = RIApiResponseSuccess;
         [self removeErrorView];
         
         for (RICategory *category in categories)
         {
             if(VALID_NOTEMPTY(self.categoryId, NSString))
             {
                 if ([self.categoryId isEqualToString:category.uid])
                 {
                     self.category = category;
                     break;
                 }
             }
             else if(VALID_NOTEMPTY(self.categoryName, NSString))
             {
                 if ([self.categoryName isEqualToString:category.urlKey])
                 {
                     self.category = category;
                     break;
                 }
             }
         }
         
         if(VALID_NOTEMPTY(self.category, RICategory))
         {
             self.navBarLayout.title = self.category.name;
             
             [self loadMoreProducts];
         }
         else
         {
             self.navBarLayout.title = self.categoryName;
             
             [self loadMoreProducts];
         }
         
         [self hideLoading];
         
     } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
         self.apiResponse = apiResponse;
         
         if(RIApiResponseMaintenancePage == apiResponse)
         {
             [self showMaintenancePage:@selector(getCategories) objects:nil];
         }
         else if(RIApiResponseKickoutView == apiResponse)
         {
             [self showKickoutView:@selector(getCategories) objects:nil];
         }
         else
         {
             BOOL noConnection = NO;
             if (RIApiResponseNoInternetConnection == apiResponse)
             {
                 noConnection = YES;
             }
             [self showErrorView:noConnection startingY:CGRectGetMaxY(self.catalogTopView.frame) selector:@selector(getCategories) objects:nil];
         }
         
         [self hideLoading];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL alreadyShowedWizardCatalog = [[NSUserDefaults standardUserDefaults] boolForKey:kJACatalogWizardUserDefaultsKey];
    if(alreadyShowedWizardCatalog == NO)
    {
        self.wizardView = [[JACatalogWizardView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.wizardView];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJACatalogWizardUserDefaultsKey];
    }
    
    [self changeViewToInterfaceOrientation:self.interfaceOrientation];
    
    if (VALID_NOTEMPTY(self.undefinedBackup, RIUndefinedSearchTerm)){
        
        [self.undefinedView removeFromSuperview];
        [self addUndefinedSearchView:self.undefinedBackup frame:CGRectMake(6.0f,
                                                                           self.catalogTopView.frame.origin.y,
                                                                           [self viewBounds].size.width - 12.0f,
                                                                           [self viewBounds].size.height - self.catalogTopView.frame.origin.y)];
    }
    
    [self.catalogTopView repositionForWidth:self.view.frame.size.width];
}

- (void)resetCatalog
{
    self.productsArray = [NSMutableArray new];
    
    self.loadedEverything = NO;
}

- (void)addProductsToTable:(NSArray*)products
{
    self.apiResponse = RIApiResponseSuccess;
    [self removeErrorView];
    
    BOOL isEmpty = NO;
    if(ISEMPTY(self.productsArray))
    {
        isEmpty = YES;
        self.productsArray = [NSMutableArray new];
    }
    
    if(VALID_NOTEMPTY(products, NSArray))
    {
        [self.productsArray addObjectsFromArray:products];
    }
    
    [self.collectionView reloadData];
    if(isEmpty)
    {
        [self.collectionView setContentOffset:CGPointZero animated:NO];
    }
}

- (void)loadMoreProducts
{
    if(!self.isLoadingMoreProducts)
    {
        self.loadedEverything = NO;
        NSNumber *pageNumber = [NSNumber numberWithInteger:[self getCurrentPage] + 1];
        
        if (VALID_NOTEMPTY(self.searchString, NSString))
        {
            // In case of this is a search
            if(RIApiResponseSuccess == self.apiResponse || RIApiResponseMaintenancePage == self.apiResponse || RIApiResponseKickoutView == self.apiResponse || RIApiResponseAPIError == self.apiResponse)
            {
                [self showLoading];
            }
            
            self.isLoadingMoreProducts =YES;
            
            self.searchSuggestionOperationID = [RISearchSuggestion getResultsForSearch:[self.searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                                                                  page:[pageNumber stringValue]
                                                                              maxItems:[NSString stringWithFormat:@"%ld",(long)self.maxProducts]
                                                                         sortingMethod:self.sortingMethod
                                                                               filters:self.filtersArray
                                                                          successBlock:^(NSArray *results, NSArray *filters, NSNumber *productCount, RIBanner *banner) {
                                                                              
                                                                              [self removeErrorView];
                                                                              
                                                                              self.searchSuggestionOperationID = nil;
                                                                              
                                                                              if (ISEMPTY(self.filtersArray) && NOTEMPTY(filters)) {
                                                                                  self.filtersArray = filters;
                                                                                  self.catalogTopView.filterButton.enabled = YES;
                                                                              }
                                                                              
                                                                              self.catalogTopView.sortingButton.enabled = YES;
                                                                             
                                                                              self.banner = banner;

                                                                              // Track events only in the first load of the products
                                                                              if (!self.isFirstLoadTracking)
                                                                              {
                                                                                  self.isFirstLoadTracking = YES;
                                                                                  
                                                                                  NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                                                  NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
                                                                                  NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                                                                  
                                                                                  [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
                                                                                  [trackingDictionary setValue:@"Search" forKey:kRIEventActionKey];
                                                                                  [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                                                                                  [trackingDictionary setValue:@(results.count) forKey:kRIEventValueKey];
                                                                                  [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                                                                                  [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                                                                                  [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
                                                                                  [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
                                                                                  [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                                                                                  [trackingDictionary setValue:self.searchString forKey:kRIEventKeywordsKey];
                                                                                  NSInteger numberOfResults = 0;
                                                                                  if(VALID_NOTEMPTY(results, NSArray))
                                                                                  {
                                                                                      numberOfResults = [results count];
                                                                                  }
                                                                                  [trackingDictionary setValue:[NSNumber numberWithInteger:numberOfResults] forKey:kRIEventNumberOfProductsKey];
                                                                                  
                                                                                  [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSearch]
                                                                                                                            data:[trackingDictionary copy]];
                                                                                  [FBSDKAppEvents logEvent:FBSDKAppEventNameSearched
                                                                                             parameters:@{FBSDKAppEventParameterNameSearchString: self.searchString,
                                                                                                          FBSDKAppEventParameterNameSuccess: @1 }];
                                                                                  
                                                                                  trackingDictionary = [[NSMutableDictionary alloc] init];
                                                                                  NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
                                                                                  if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
                                                                                  {
                                                                                      [trackingDictionary setValue:[numberOfSessions stringValue] forKey:kRIEventAmountSessions];
                                                                                  }
                                                                                  
                                                                                  [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                                                                                  [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                                                                                  [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
                                                                                  [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
                                                                                  [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                                                                                  
                                                                                  [trackingDictionary setValue:self.searchString forKey:kRIEventQueryKey];
                                                                                  
                                                                                  [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookSearch]
                                                                                                                            data:[trackingDictionary copy]];
                                                                                  
                                                                                  NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                                                                                  [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                                                                                  
                                                                                  trackingDictionary = [[NSMutableDictionary alloc] init];
                                                                                  if(VALID_NOTEMPTY(self.searchString, NSString))
                                                                                  {
                                                                                      [trackingDictionary setValue:self.searchString forKey:kRIEventCategoryNameKey];
                                                                                  }

                                                                                  [trackingDictionary setValue:pageNumber forKey:kRIEventPageNumberKey];
                                                                                  
                                                                                  [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewGTMListing]
                                                                                                                            data:[trackingDictionary copy]];
                                                                                  
                                                                              }
                                                                              
                                                                              NSString* countString = [NSString stringWithFormat:@"%ld %@",(long)[productCount integerValue], STRING_ITEMS];
                                                                              if (1 == [productCount integerValue]) {
                                                                                  countString = [NSString stringWithFormat:@"1 %@", STRING_ITEM];
                                                                              }
                                                                              self.navBarLayout.subTitle = countString;
                                                                              [self reloadNavBar];
                                                                              
                                                                              [self addProductsToTable:results];
                                                                              
                                                                              if (0 == results.count || results.count < self.maxProducts || [productCount integerValue] == self.productsArray.count)
                                                                              {
                                                                                  self.loadedEverything = YES;
                                                                              }
                                                                              
                                                                              self.isLoadingMoreProducts = NO;
                                                                              [self hideLoading];
                                                                              
                                                                          } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm) {
                                                                              self.navBarLayout.subTitle = @"";
                                                                              [self reloadNavBar];
                                                                              
                                                                              self.apiResponse = apiResponse;
                                                                              self.searchSuggestionOperationID = nil;
                                                                              
                                                                              if(VALID_NOTEMPTY(self.productsArray, NSArray))
                                                                              {
                                                                                  NSString *erroMessasge = STRING_ERROR;
                                                                                  if (RIApiResponseNoInternetConnection == apiResponse)
                                                                                  {
                                                                                      erroMessasge = STRING_NO_CONNECTION;
                                                                                  }
                                                                                  
                                                                                  [self showMessage:erroMessasge success:NO];
                                                                              }
                                                                              else
                                                                              {
                                                                                  if(RIApiResponseMaintenancePage == apiResponse)
                                                                                  {
                                                                                      [self showMaintenancePage:@selector(loadMoreProducts) objects:nil];
                                                                                  }
                                                                                  else if(RIApiResponseKickoutView == apiResponse)
                                                                                  {
                                                                                      [self showKickoutView:@selector(loadMoreProducts) objects:nil];
                                                                                  }
                                                                                  else
                                                                                  {
                                                                                      if (RIApiResponseNoInternetConnection == apiResponse)
                                                                                      {
                                                                                          [self showErrorView:YES startingY:CGRectGetMaxY(self.catalogTopView.frame) selector:@selector(loadMoreProducts) objects:nil];
                                                                                          
                                                                                      }
                                                                                      else if(RIApiResponseAPIError == apiResponse)
                                                                                      {
                                                                                          [self removeErrorView];
                                                                                          [self showNoResultsView:CGRectGetMaxY(self.catalogTopView.frame) undefinedSearchTerm:undefSearchTerm];
                                                                                      }
                                                                                  }
                                                                              }
                                                                              
                                                                              [FBSDKAppEvents logEvent:FBSDKAppEventNameSearched
                                                                                         parameters:@{FBSDKAppEventParameterNameSearchString:self.searchString  ,
                                                                                                      FBSDKAppEventParameterNameSuccess: @0 }];
                                                                              
                                                                              self.isLoadingMoreProducts = NO;
                                                                              [self hideLoading];                                                                              
                                                                          }];
        }
        else
        {
            if (NO == self.loadedEverything)
            {
                if(RIApiResponseSuccess == self.apiResponse || RIApiResponseMaintenancePage == self.apiResponse || RIApiResponseKickoutView == self.apiResponse || RIApiResponseAPIError == self.apiResponse)
                {
                    [self showLoading];
                }
                
                self.isLoadingMoreProducts =YES;
                
                NSString* urlToUse = self.catalogUrl;
                if (VALID_NOTEMPTY(self.categoryName, NSString)) {
                    urlToUse = [NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, self.categoryName];
                }
                if (VALID_NOTEMPTY(self.category, RICategory) && VALID_NOTEMPTY(self.category.apiUrl, NSString)) {
                    urlToUse = self.category.apiUrl;
                }
                if (VALID_NOTEMPTY(self.filterCategory, RICategory) && VALID_NOTEMPTY(self.filterCategory.apiUrl, NSString)) {
                    urlToUse = self.filterCategory.apiUrl;
                }
                
                self.getProductsOperationID = [RIProduct getProductsWithCatalogUrl:urlToUse
                                                                     sortingMethod:self.sortingMethod
                                                                              page:[pageNumber integerValue]
                                                                          maxItems:self.maxProducts
                                                                           filters:self.filtersArray
                                                                        filterType:self.filterType
                                                                       filterValue:self.filterValue
                                                                      successBlock:^(NSArray* products, NSString* productCount, NSArray* filters, NSString *categoryId, NSArray* categories, RIBanner* banner) {
                                                                          
                                                                          self.getProductsOperationID = nil;
                                                                          
                                                                          self.banner = banner;
                                                                          
                                                                          NSString* countString = [NSString stringWithFormat:@"%@ %@",productCount, STRING_ITEMS];
                                                                          if (1 == [productCount integerValue]) {
                                                                              countString = [NSString stringWithFormat:@"1 %@", STRING_ITEM];
                                                                          }
                                                                          self.navBarLayout.subTitle = countString;
                                                                          [self reloadNavBar];
                                                                          
                                                                          if (ISEMPTY(self.filtersArray) && NOTEMPTY(filters)) {
                                                                              self.filtersArray = filters;
                                                                              self.catalogTopView.filterButton.enabled = YES;
                                                                          }
                                                                          
                                                                          self.catalogTopView.sortingButton.enabled = YES;
                                                                          
                                                                          RICategory *category = nil;
                                                                          if (NOTEMPTY(categories)) {
                                                                              self.categoriesArray = categories;
                                                                              category = [categories objectAtIndex:0];
                                                                          }
                                                                          
                                                                          NSInteger productCountValue = [productCount intValue];

                                                                          if (0 == products.count || products.count < self.maxProducts || productCountValue == self.productsArray.count)
                                                                          {
                                                                              self.loadedEverything = YES;
                                                                          }
                                                                          
                                                                          NSString *categoryName = @"";
                                                                          NSString *subCategoryName = @"";
                                                                          if(VALID_NOTEMPTY(self.category, RICategory))
                                                                          {
                                                                              if(VALID_NOTEMPTY(self.category.parent, RICategory))
                                                                              {
                                                                                  RICategory *parent = self.category.parent;
                                                                                  while (VALID_NOTEMPTY(parent.parent, RICategory))
                                                                                  {
                                                                                      parent = parent.parent;
                                                                                  }
                                                                                  categoryName = parent.name;
                                                                                  subCategoryName = self.category.name;
                                                                              }
                                                                              else
                                                                              {
                                                                                  categoryName = self.category.name;
                                                                              }
                                                                          }
                                                                          else if(VALID_NOTEMPTY(category, RICategory))
                                                                          {
                                                                              categoryName = category.name;
                                                                          }
                                                                          
                                                                          if (ISEMPTY(self.navBarLayout.title)) {
                                                                              self.navBarLayout.title = categoryName;
                                                                              [self reloadNavBar];
                                                                          }
                                                                          
                                                                          NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                                                          // Track events only in the first load of the products
                                                                          if (!self.isFirstLoadTracking)
                                                                          {
                                                                              self.isFirstLoadTracking = YES;
                                                                              
                                                                              NSMutableArray *productsToTrack = [[NSMutableArray alloc] init];
                                                                              for(RIProduct *product in products)
                                                                              {
                                                                                  [productsToTrack addObject:[product sku]];
                                                                                  if([productsToTrack count] == 3)
                                                                                  {
                                                                                      break;
                                                                                  }
                                                                              }
                                                                              
                                                                              NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                                              NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
                                                                              
                                                                              [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                                                                              [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                                                                              [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
                                                                              [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
                                                                              [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                                                                              [trackingDictionary setValue:productsToTrack forKey:kRIEventSkusKey];
                                                                              
                                                                              [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewListing]
                                                                                                                        data:[trackingDictionary copy]];
                                                                              
                                                                              NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
                                                                              if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
                                                                              {
                                                                                  [trackingDictionary setValue:[numberOfSessions stringValue] forKey:kRIEventAmountSessions];
                                                                              }
                                                                              
                                                                              [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                                                                              [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                                                                              [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
                                                                              [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
                                                                              [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];

                                                                              if(VALID_NOTEMPTY(categoryName, NSString))
                                                                              {
                                                                                  [trackingDictionary setValue:categoryName forKey:kRIEventCategoryNameKey];
                                                                              }
                                                                              
                                                                              if(VALID_NOTEMPTY(category, RICategory))
                                                                              {
                                                                                  [trackingDictionary setValue:category.uid forKey:kRIEventCategoryIdKey];
                                                                              }
                                                                              else if(VALID_NOTEMPTY(categoryId, NSString))
                                                                              {
                                                                                  [trackingDictionary setValue:categoryId forKey:kRIEventCategoryIdKey];
                                                                                  [trackingDictionary setValue:[RICategory getTree:categoryId] forKey:kRIEventTreeKey];
                                                                              }
                                                                              
                                                                              [trackingDictionary setValue:productsToTrack forKey:kRIEventSkusKey];
                                                                              
                                                                              [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewListing]
                                                                                                                        data:[trackingDictionary copy]];
                                                                              
                                                                              NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                                                                              [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                                                                          }
                                                                          
                                                                          trackingDictionary = [[NSMutableDictionary alloc] init];
                                                                          
                                                                          if(VALID_NOTEMPTY(categoryName, NSString))
                                                                          {
                                                                              [trackingDictionary setValue:categoryName forKey:kRIEventCategoryNameKey];
                                                                          }
                                                                          if(VALID_NOTEMPTY(subCategoryName, NSString))
                                                                          {
                                                                              [trackingDictionary setValue:subCategoryName forKey:kRIEventSubCategoryNameKey];
                                                                          }
                                                                          
                                                                          [trackingDictionary setValue:pageNumber forKey:kRIEventPageNumberKey];
                                                                          
                                                                          [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewGTMListing]
                                                                                                                    data:[trackingDictionary copy]];
                                                                          
                                                                          [self addProductsToTable:products];
                                                                          
                                                                          self.isLoadingMoreProducts = NO;
                                                                          [self hideLoading];
                                                                          
                                                                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                                                          self.navBarLayout.subTitle = @"";
                                                                          [self reloadNavBar];
                                                                          
                                                                          self.apiResponse = apiResponse;
                                                                          self.getProductsOperationID = nil;
                                                                          
                                                                          if(VALID_NOTEMPTY(self.productsArray, NSArray))
                                                                          {
                                                                              NSString *erroMessasge = STRING_ERROR;
                                                                              if (RIApiResponseNoInternetConnection == apiResponse)
                                                                              {
                                                                                  erroMessasge = STRING_NO_CONNECTION;
                                                                              }
                                                                              
                                                                              [self showMessage:erroMessasge success:NO];
                                                                          }
                                                                          else
                                                                          {
                                                                              if(RIApiResponseMaintenancePage == apiResponse)
                                                                              {
                                                                                  [self showMaintenancePage:@selector(loadMoreProducts) objects:nil];
                                                                              }
                                                                              else if(RIApiResponseKickoutView == apiResponse)
                                                                              {
                                                                                  [self showKickoutView:@selector(loadMoreProducts) objects:nil];
                                                                              }
                                                                              else
                                                                              {
                                                                                  if (RIApiResponseNoInternetConnection == apiResponse)
                                                                                  {
                                                                                      [self showErrorView:YES startingY:CGRectGetMaxY(self.catalogTopView.frame) selector:@selector(loadMoreProducts) objects:nil];

                                                                                  }
                                                                                  else if(RIApiResponseAPIError == apiResponse)
                                                                                  {
                                                                                      [self showNoResultsView:CGRectGetMaxY(self.catalogTopView.frame) undefinedSearchTerm:nil];
                                                                                  }
                                                                              }
                                                                          }
                                                                          
                                                                          self.isLoadingMoreProducts = NO;
                                                                          [self hideLoading];
                                                                      }];
            }
        }
    }
}

- (NSInteger)getCurrentPage
{
    NSInteger currentPage = 0;
    if (VALID_NOTEMPTY(self.productsArray, NSMutableArray))
    {
        currentPage = self.productsArray.count / self.maxProducts;
    }
    return currentPage;
}

#pragma mark - Actions

- (CGSize)getLayoutItemSizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat width = 0.0f;
    CGFloat height = 0.0f;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            
            if (self.catalogTopView.gridSelected) {
                width = 254.0f;
                height = JACatalogViewControllerGridCellHeight_ipad;
            } else {
                width = 381.0f;
                height = JACatalogViewControllerListCellHeight_ipad;
            }
        } else {
            if (self.catalogTopView.gridSelected) {
                width = 204.0f;
                height = JACatalogViewControllerGridCellHeight_ipad;
            } else {
                width = 339.0f;
                height = JACatalogViewControllerListCellHeight_ipad;
            }
        }
    } else {
        if (self.catalogTopView.gridSelected) {
            width = 157.0f;
            height = JACatalogViewControllerGridCellHeight;
        } else {
            //use view instead of collection view, the list cell has the insets inside itself;
            width = [self viewBounds].size.width;
            height = JACatalogViewControllerListCellHeight;
        }
    }
    
    return CGSizeMake(width, height);
}

- (void)changeViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.bannerImage = nil;
    if (self.catalogTopView.gridSelected) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (UIInterfaceOrientationPortrait == interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
                self.cellIdentifier = @"gridCell_ipad_portrait";
            } else {
                self.cellIdentifier = @"gridCell_ipad_landscape";
            }
        } else {
            self.cellIdentifier = @"gridCell";
        }
    } else {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (UIInterfaceOrientationPortrait == interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
                self.cellIdentifier = @"listCell_ipad_portrait";
            } else {
                self.cellIdentifier = @"listCell_ipad_landscape";
            }
        } else {
            self.cellIdentifier = @"listCell";
        }
    }
    
    if(VALID_NOTEMPTY(self.collectionView.superview, UIView))
    {
        self.numberOfCellsInScreen = [self getNumberOfCellsInScreenForInterfaceOrientation:interfaceOrientation];
        
        [self.collectionView reloadData];
    }
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    if (self.catalogTopView.gridSelected) {
        [trackingDictionary setValue:@"Grid" forKey:kRIEventActionKey];
    } else {
        [trackingDictionary setValue:@"List" forKey:kRIEventActionKey];
    }
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCatalog]
                                              data:[trackingDictionary copy]];
}

- (NSInteger)getNumberOfCellsInScreenForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.catalogTopView.gridSelected) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (UIInterfaceOrientationPortrait == interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
                return 15;
            } else {
                return 20;
            }
        }else{
            return 7;
        }
    } else {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (UIInterfaceOrientationPortrait == interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
                return 18;
            } else {
                return 21;
            }
        }else{
            return 5;
        }
    }
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   CGFloat numberOfCells = self.productsArray.count;
    
    if (VALID_NOTEMPTY(self.banner, RIBanner)) {
        numberOfCells++;
    }

    return numberOfCells;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (VALID_NOTEMPTY(self.banner, RIBanner) && 0 == indexPath.row) {
        return self.bannerImage.frame.size;
    }
    
    if ([self.cellIdentifier isEqualToString:@"listCell"])
        return CGSizeMake(308, 97);
    else if ([self.cellIdentifier isEqualToString:@"listCell_ipad_portrait"])
        return CGSizeMake(375, 97);
    else if ([self.cellIdentifier isEqualToString:@"listCell_ipad_landscape"])
        return CGSizeMake(333.33, 97);
    
    else if ([self.cellIdentifier isEqualToString:@"gridCell"])
        return CGSizeMake(151, 206);
    else if ([self.cellIdentifier isEqualToString:@"gridCell_ipad_portrait"])
        return CGSizeMake(248, 212);
    else if ([self.cellIdentifier isEqualToString:@"gridCell_ipad_landscape"])
        return CGSizeMake(197.6, 212);
    else
        return CGSizeZero;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(3, 0, 0, 0);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger realIndex = indexPath.row;
   
    if (!self.loadedEverything && self.productsArray.count - self.numberOfCellsInScreen <= indexPath.row)
    {
        [self loadMoreProducts];
    }
    
    if (VALID_NOTEMPTY(self.banner, RIBanner)) {
        if (0 == indexPath.row) {
            JACatalogBannerCell *bannerCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bannerCell" forIndexPath:indexPath];
            [bannerCell loadWithImageView:self.bannerImage];
            bannerCell.tag = 0;
            return bannerCell;
        }
        realIndex--;
    }
    
    RIProduct *product = [self.productsArray objectAtIndex:realIndex];
    
    JACatalogCollectionViewCell *cell;
    
    if ([self.cellIdentifier hasPrefix:@"grid"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JACatalogGridCollectionViewCell" forIndexPath:indexPath];
    }else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JACatalogListCollectionViewCell" forIndexPath:indexPath];
    }
    
    cell.favoriteButton.tag = realIndex;
    [cell.favoriteButton addTarget:self
                            action:@selector(addToFavoritesPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    cell.feedbackView.tag = indexPath.row;
    [cell.feedbackView addTarget:self
                          action:@selector(clickableViewPressedInCell:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [cell loadWithProduct:product];
    
    return cell;
    
}

-(void)clickableBannerPressed
{
    if(VALID_NOTEMPTY(self.banner, RIBanner)) {
        
        NSMutableDictionary* userInfo = [NSMutableDictionary new];
        [userInfo setObject:STRING_BACK forKey:@"show_back_button_title"];
        if (VALID_NOTEMPTY(self.banner.title, NSString)) {
            [userInfo setObject:self.banner.title forKey:@"title"];
        }
        
        NSString* notificationName;
        
        if ([self.banner.targetType isEqualToString:@"catalog"]) {
            
            notificationName = kDidSelectTeaserWithCatalogUrlNofication;
            
        } else if ([self.banner.targetType isEqualToString:@"product_detail"]) {
            
            notificationName = kDidSelectTeaserWithPDVUrlNofication;
            
        } else if ([self.banner.targetType isEqualToString:@"static_page"]) {
            
            notificationName = kDidSelectTeaserWithShopUrlNofication;
            
        } else if ([self.banner.targetType isEqualToString:@"campaign"]) {
            
            notificationName = kDidSelectCampaignNofication;

        }
        
        if (VALID_NOTEMPTY(self.banner.url, NSString)) {
            [userInfo setObject:self.banner.url forKey:@"url"];
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                                object:nil
                                                              userInfo:userInfo];
        }
    }
}

- (void)clickableViewPressedInCell:(UIControl*)sender
{
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger realIndex = indexPath.row;
    if (VALID_NOTEMPTY(self.banner, RIBanner)) {
        if (0 == indexPath.row) {
            //click banner
            
            [self clickableBannerPressed];
            
            return;
        }
        realIndex--;
    }
    
    
    RIProduct *product = [self.productsArray objectAtIndex:realIndex];
    
    NSInteger count = self.productsArray.count;
    
    if (count > 20) {
        count = 20;
    }
    
    NSString *temp = self.category.name;
    
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo setObject:product.url forKey:@"url"];
    [userInfo setObject:@"YES" forKey:@"fromCatalog"];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    
    if (self.teaserTrackingInfo) {
        [userInfo setObject:self.teaserTrackingInfo forKey:@"teaserTrackingInfo"];
    }
    
    if (temp.length > 0) {
        [userInfo setObject:self.category forKey:@"category"];
        [[RITrackingWrapper sharedInstance] trackScreenWithName:[NSString stringWithFormat:@"cat_/%@/%@",self.category.urlKey
                                                                 ,product.name]];
    }
    else
    {
        [[RITrackingWrapper sharedInstance] trackScreenWithName:[NSString stringWithFormat:@"Search_%@",product.name]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - JAMainFiltersViewControllerDelegate

- (void)updatedFilters;
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:self.catalogUrl forKey:kRIEventLabelKey];
    [trackingDictionary setValue:STRING_FILTERS forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    
    BOOL filtersSelected = NO;
    if(VALID_NOTEMPTY(self.filtersArray, NSArray))
    {
        for(RIFilter *filter in self.filtersArray)
        {
            if (VALID_NOTEMPTY(filter.uid, NSString) && VALID_NOTEMPTY(filter.options, NSArray) && 0 < filter.options.count)
            {
                NSLog(@"filter name %@ - uid %@", filter.name, filter.uid);
                if ([@"price" isEqualToString:filter.uid])
                {
                    RIFilterOption* filterOption = [filter.options firstObject];
                    if (VALID_NOTEMPTY(filterOption, RIFilterOption))
                    {
                        if (filterOption.lowerValue != filterOption.min || filterOption.upperValue != filterOption.max) {
                            
                            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventIndividualFilter]
                                                                      data:[NSDictionary dictionaryWithObject:filter.name forKey:kRIEventFilterTypeKey]];

                                [trackingDictionary setObject:[NSString stringWithFormat:@"%ld-%ld", (long)filterOption.lowerValue, (long)filterOption.upperValue] forKey:kRIEventPriceFilterKey];
                            
                            filtersSelected = YES;
                        }
                        if (filterOption.discountOnly) {
                            [trackingDictionary setObject:@1 forKey:kRIEventSpecialPriceFilterKey];
                            filtersSelected = YES;
                        }
                    }
                } else
                {
                    for (RIFilterOption* filterOption in filter.options)
                    {
                        if (filterOption.selected)
                        {
                            
                            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventIndividualFilter]
                                                                      data:[NSDictionary dictionaryWithObject:filter.name forKey:kRIEventFilterTypeKey]];
                            if([@"brand" isEqualToString:filter.uid])
                            {
                                if ([trackingDictionary objectForKey:kRIEventBrandFilterKey]) {
                                    [trackingDictionary setObject:[NSString stringWithFormat:@"%@,%@", [trackingDictionary objectForKey:kRIEventBrandFilterKey], filterOption.name] forKey:kRIEventBrandFilterKey];
                                }else{
                                    [trackingDictionary setObject:filterOption.name forKey:kRIEventBrandFilterKey];
                                }
                            }
                            else if([@"color_family" isEqualToString:filter.uid])
                            {
                                if ([trackingDictionary objectForKey:kRIEventColorFilterKey]) {
                                    [trackingDictionary setObject:[NSString stringWithFormat:@"%@,%@", [trackingDictionary objectForKey:kRIEventColorFilterKey], filterOption.name] forKey:kRIEventColorFilterKey];
                                }else{
                                    [trackingDictionary setObject:filterOption.name forKey:kRIEventColorFilterKey];
                                }
                            }else if([@"size" isEqualToString:filter.uid])
                            {
                                if ([trackingDictionary objectForKey:kRIEventSizeFilterKey]) {
                                    [trackingDictionary setObject:[NSString stringWithFormat:@"%@,%@", [trackingDictionary objectForKey:kRIEventSizeFilterKey], filterOption.name] forKey:kRIEventSizeFilterKey];
                                }else{
                                    [trackingDictionary setObject:filterOption.name forKey:kRIEventSizeFilterKey];
                                }
                            }else if([@"category" isEqualToString:filter.uid])
                            {
                                if ([trackingDictionary objectForKey:kRIEventCategoryFilterKey]) {
                                    [trackingDictionary setObject:[NSString stringWithFormat:@"%@,%@", [trackingDictionary objectForKey:kRIEventCategoryFilterKey], filterOption.name] forKey:kRIEventCategoryFilterKey];
                                }else{
                                    [trackingDictionary setObject:filterOption.name forKey:kRIEventCategoryFilterKey];
                                }
                            }
                            
                            filtersSelected = YES;
                        }
                        
                        if (filterOption.discountOnly) {
                            filtersSelected = YES;
                        }
                    }
                }
            }
        }
    }
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFilter]
                                              data:[trackingDictionary copy]];
    
    [self.catalogTopView setFilterSelected:filtersSelected];
    [self resetCatalog];
    [self loadMoreProducts];
}

#pragma mark - kProductChangedNotification
- (void)changedFavoriteStateOfProduct:(NSNotification*)notification;
{
    RIProduct* product = (RIProduct*) notification.object;
    
    if (VALID_NOTEMPTY(product, RIProduct)) {
        for (int i = 0; i < self.productsArray.count; i++)
        {
            RIProduct* currentProduct = [self.productsArray objectAtIndex:i];
            if ([currentProduct.sku isEqualToString:product.sku])
            {
                currentProduct.favoriteAddDate = product.favoriteAddDate;
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]];
            }
        }
    }
}

#pragma mark - JACatalogTopViewDelegate

- (void)filterButtonPressed
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:self forKey:@"delegate"];
    
    if(VALID(self.filtersArray, NSArray))
    {
        [userInfo setObject:self.filtersArray forKey:@"filtersArray"];
    }
    if(VALID(self.categoriesArray, NSArray))
    {
        [userInfo setObject:self.categoriesArray forKey:@"categoriesArray"];
    }
    if(VALID(self.filterCategory, RICategory))
    {
        [userInfo setObject:self.filterCategory forKey:@"selectedCategory"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowFiltersScreenNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)sortingButtonPressed;
{
    [self.sortingView removeFromSuperview];
    self.sortingView = [[JASortingView alloc] init];
    self.sortingView.delegate = self;
    UIView* windowView = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;
    [self.sortingView setupWithFrame:windowView.bounds selectedSorting:self.sortingMethod];
    [windowView addSubview:self.sortingView];
    [self.sortingView animateIn];
}

- (void)viewModeChanged;
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.catalogTopView.gridSelected] forKey:JACatalogGridSelected];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self changeViewToInterfaceOrientation:self.interfaceOrientation];
}

- (void)navBarClicked
{
    NSInteger numberOfCells = [self collectionView:self.collectionView numberOfItemsInSection:0];
    if (VALID_NOTEMPTY(self.collectionView, UICollectionView) && numberOfCells > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Button actions

- (void)addToFavoritesPressed:(UIButton*)button
{
    self.backupButton = button;
    
    [self continueAddingToFavouritesWithButton:self.backupButton];
}

- (void)continueAddingToFavouritesWithButton:(UIButton *)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];

    [self showLoading];
    
    if (!button.selected)
    {
        //add to favorites
        [RIProduct getCompleteProductWithUrl:product.url
                                successBlock:^(id completeProduct) {
                                    [RIProduct addToFavorites:completeProduct successBlock:^{
                                        button.selected = !button.selected;
                                        product.favoriteAddDate = [NSDate date];
                                        
                                        NSNumber *price = (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f) ? product.specialPriceEuroConverted : product.priceEuroConverted;
                                        
                                        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                        [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
                                        [trackingDictionary setValue:@"AddtoWishlist" forKey:kRIEventActionKey];
                                        [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                                        [trackingDictionary setValue:price forKey:kRIEventValueKey];
                                        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                                        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                                        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                                        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                        [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                                        
                                        // Since we're sending the converted price, we have to send the currency as EUR.
                                        // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
                                        [trackingDictionary setValue:price forKey:kRIEventPriceKey];
                                        [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
                                        
                                        [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
                                        [trackingDictionary setValue:product.brand forKey:kRIEventBrandKey];
                                        
                                        NSString *discountPercentage = @"0";
                                        if(VALID_NOTEMPTY(product.maxSavingPercentage, NSString))
                                        {
                                            discountPercentage = product.maxSavingPercentage;
                                        }
                                        [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
                                        [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
                                        [trackingDictionary setValue:@"Catalog" forKey:kRIEventLocationKey];
                                        
                                        NSString *categoryName = @"";
                                        NSString *subCategoryName = @"";
                                        if(VALID_NOTEMPTY(self.category, RICategory))
                                        {
                                            if(VALID_NOTEMPTY(self.category.parent, RICategory))
                                            {
                                                RICategory *parent = self.category.parent;
                                                while (VALID_NOTEMPTY(parent.parent, RICategory))
                                                {
                                                    parent = parent.parent;
                                                }
                                                categoryName = parent.name;
                                                subCategoryName = self.category.name;
                                            }
                                            else
                                            {
                                                categoryName = self.category.name;
                                            }
                                        }
                                        else if(VALID_NOTEMPTY(product.categoryIds, NSOrderedSet))
                                        {
                                            NSArray *categoryIds = [product.categoryIds array];
                                            NSInteger subCategoryIndex = [categoryIds count] - 1;
                                            NSInteger categoryIndex = subCategoryIndex - 1;
                                            
                                            if(categoryIndex >= 0)
                                            {
                                                NSString *categoryId = [categoryIds objectAtIndex:categoryIndex];
                                                categoryName = [RICategory getCategoryName:categoryId];
                                                
                                                NSString *subCategoryId = [categoryIds objectAtIndex:subCategoryIndex];
                                                subCategoryName = [RICategory getCategoryName:subCategoryId];
                                            }
                                            else
                                            {
                                                NSString *categoryId = [categoryIds objectAtIndex:subCategoryIndex];
                                                categoryName = [RICategory getCategoryName:categoryId];
                                            }
                                        }
                                        
                                        if(VALID_NOTEMPTY(categoryName, NSString))
                                        {
                                            [trackingDictionary setValue:categoryName forKey:kRIEventCategoryNameKey];
                                        }
                                        if(VALID_NOTEMPTY(subCategoryName, NSString))
                                        {
                                            [trackingDictionary setValue:subCategoryName forKey:kRIEventSubCategoryNameKey];
                                        }
                                        
                                        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToWishlist]
                                                                                  data:[trackingDictionary copy]];
                                        float value = [price floatValue];
                                        [FBSDKAppEvents logEvent:FBSDKAppEventNameAddedToWishlist
                                                   valueToSum:value
                                                   parameters:@{ FBSDKAppEventParameterNameCurrency    : @"EUR",
                                                                 FBSDKAppEventParameterNameContentType : product.name,
                                                                 FBSDKAppEventParameterNameContentID   : product.sku}];
                                        
                                        
                                        [self hideLoading];
                                        
                                        [self showMessage:STRING_ADDED_TO_WISHLIST success:YES];
                                        
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kProductChangedNotification
                                                                                            object:product];
                                        
                                    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                        NSString *addToWishlistError = STRING_ERROR_ADDING_TO_WISHLIST;
                                        if(RIApiResponseNoInternetConnection == apiResponse)
                                        {
                                            addToWishlistError = STRING_NO_CONNECTION;
                                        }
                                        
                                        [self showMessage:addToWishlistError success:NO];
                                        
                                        [self hideLoading];
                                    }];
                                } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                    
                                    [self showMessage:STRING_ERROR_ADDING_TO_WISHLIST success:NO];
                                    
                                    [self hideLoading];
                                }];
    } else {
        [RIProduct removeFromFavorites:product successBlock:^(void) {
            button.selected = !button.selected;
            product.favoriteAddDate = nil;
            
            NSNumber *price = (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f) ? product.specialPriceEuroConverted : product.priceEuroConverted;
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"RemoveFromWishlist" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
            [trackingDictionary setValue:price forKey:kRIEventValueKey];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
            
            // Since we're sending the converted price, we have to send the currency as EUR.
            // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
            [trackingDictionary setValue:price forKey:kRIEventPriceKey];
            [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
            
            [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
            [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                      data:[trackingDictionary copy]];
            
            //update favoriteProducts
            [self hideLoading];
            
            [self showMessage:STRING_REMOVED_FROM_WISHLIST success:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kProductChangedNotification
                                                                object:product];
            
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            [self hideLoading];
            
            [self showMessage:STRING_ERROR_REMOVING_FROM_WISHLIST success:NO];
        }];
    }
}

#pragma mark - Add the undefined search view

- (void)addUndefinedSearchView:(RIUndefinedSearchTerm *)undefSearch
                         frame:(CGRect)frame
{
    self.undefinedView = [[JAUndefinedSearchView alloc] initWithFrame:frame];
    self.undefinedView.delegate = self;
    
    // Remove the existent components
    [self.catalogTopView removeFromSuperview];
    [self.collectionView removeFromSuperview];
    
    // Build and add the new view
    [self.view addSubview:self.undefinedView];
    
    [self.undefinedView setupWithUndefinedSearchResult:undefSearch
                                            searchText:self.searchString
                                           orientation:self.interfaceOrientation];
    [self.view bringSubviewToFront:self.wizardView];
}

#pragma mark - Undefined view delegate

- (void)didSelectProduct:(NSString *)productUrl
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"fromCatalog"];
    [userInfo setObject:self forKey:@"delegate"];
    if(VALID_NOTEMPTY(productUrl, NSString))
    {
        [userInfo setObject:productUrl forKey:@"url"];
    }
    if(VALID_NOTEMPTY(self.category, RICategory))
    {
        [userInfo setObject:self.category forKey:@"category"];
        if(VALID_NOTEMPTY(self.category.name, NSString))
        {
            [userInfo setObject:self.category.name forKey:@"previousCategory"];
        }
        else
        {
            [userInfo setObject:STRING_BACK forKey:@"previousCategory"];
        }
    }
    else
    {
        [userInfo setObject:STRING_BACK forKey:@"previousCategory"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)didSelectBrand:(NSString *)brandUrl
             brandName:(NSString *)brandName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(98),
                                                                 @"name": brandName,
                                                                 @"url": brandUrl }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(VALID_NOTEMPTY(self.wizardView, JACatalogWizardView))
    {
        CGRect newFrame = CGRectMake(self.wizardView.frame.origin.x,
                                     self.wizardView.frame.origin.y,
                                     self.view.frame.size.height + self.view.frame.origin.y,
                                     self.view.frame.size.width - self.view.frame.origin.y);
        [self.wizardView reloadForFrame:newFrame];
    }
    
    [self changeViewToInterfaceOrientation:toInterfaceOrientation];
    
    [self.undefinedView removeFromSuperview];
    
    [self showLoading];
    
    BOOL currentIsLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    BOOL futureIsLandscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    if (currentIsLandscape != futureIsLandscape) {
        [self.sortingView reloadForFrame:CGRectMake(self.sortingView.frame.origin.x,
                                                    self.sortingView.frame.origin.y,
                                                    self.sortingView.frame.size.height,
                                                    self.sortingView.frame.size.width)];
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    if(VALID_NOTEMPTY(self.wizardView, JACatalogWizardView))
    {
        [self.wizardView reloadForFrame:self.view.bounds];
    }
    if (VALID_NOTEMPTY(self.undefinedBackup, RIUndefinedSearchTerm)){
        
        [self addUndefinedSearchView:self.undefinedBackup frame:CGRectMake(6.0f,
                                                                           self.catalogTopView.frame.origin.y,
                                                                           [self viewBounds].size.width - 12.0f,
                                                                           [self viewBounds].size.height)];
        [self.undefinedView didRotate];
    }

    [self.catalogTopView repositionForWidth:self.view.frame.size.width];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - JASortingView

- (void)selectedSortingMethod:(RICatalogSorting)catalogSorting
{
    if (catalogSorting != self.sortingMethod) {
        self.sortingMethod = catalogSorting;
        [self.catalogTopView setSorting:self.sortingMethod];
        
        self.apiResponse = RIApiResponseSuccess;
        [self removeErrorView];
        
        [self resetCatalog];
        [self loadMoreProducts];
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:self.title forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"SortingOnCatalog" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
        [trackingDictionary setValue:[RIProduct sortingName:self.sortingMethod] forKey:kRIEventSortTypeKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSort]
                                                  data:[trackingDictionary copy]];

    }
}

@end

//
//  JACatalogViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogViewController.h"
#import "RIProduct.h"
#import "JACatalogListCell.h"
#import "JACatalogGridCell.h"
#import "JAUtils.h"
#import "RISearchSuggestion.h"
#import "RICustomer.h"
#import "RIFilter.h"
#import "JACatalogWizardView.h"
#import "JAClickableView.h"

#define JACatalogViewControllerButtonColor UIColorFromRGB(0xe3e3e3);
#define JACatalogViewControllerMaxProducts 36

@interface JACatalogViewController ()

@property (nonatomic, strong)JACatalogWizardView* wizardView;

@property (weak, nonatomic) IBOutlet JAClickableView *filterButton;
@property (weak, nonatomic) IBOutlet JAClickableView *viewToggleButton;
@property (nonatomic, strong)UIImageView* viewToggleButtonIcon;
@property (nonatomic, assign)BOOL gridSelected;
@property (weak, nonatomic) IBOutlet JAPickerScrollView *sortingScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *catalogTopButton;
@property (nonatomic, strong) UICollectionViewFlowLayout* flowLayout;
@property (nonatomic, strong) NSMutableDictionary* productsMap;
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

@end

@implementation JACatalogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    UIImage* filterIcon = [UIImage imageNamed:@"filterIcon"];
    UIImageView* filterIconView = [[UIImageView alloc] initWithImage:filterIcon];
    [filterIconView setFrame:CGRectMake((self.filterButton.bounds.size.width - filterIcon.size.width) / 2,
                                        (self.filterButton.bounds.size.height - filterIcon.size.height) / 2,
                                        filterIcon.size.width,
                                        filterIcon.size.height)];
    filterIconView.center = self.filterButton.center;
    [self.filterButton addSubview:filterIconView];
    [self.filterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage* gridIcon = [UIImage imageNamed:@"gridIcon"];
    self.viewToggleButtonIcon = [[UIImageView alloc] initWithImage:gridIcon];
    [self.viewToggleButtonIcon setFrame:CGRectMake((self.viewToggleButton.bounds.size.width - gridIcon.size.width) / 2,
                                                   (self.viewToggleButton.bounds.size.height - gridIcon.size.height) / 2,
                                                   gridIcon.size.width,
                                                   gridIcon.size.height)];
    [self.viewToggleButton addSubview:self.viewToggleButtonIcon];
    [self.viewToggleButton addTarget:self action:@selector(viewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.gridSelected = NO;
    
    [self setupViews];
    
    if (VALID_NOTEMPTY(self.searchString, NSString) || VALID_NOTEMPTY(self.category, RICategory) || VALID_NOTEMPTY(self.catalogUrl, NSString))
    {
        NSArray* sortList = [NSArray arrayWithObjects:STRING_BEST_RATING, STRING_POPULARITY, STRING_NEW_IN, STRING_PRICE_UP, STRING_PRICE_DOWN, STRING_NAME, STRING_BRAND, nil];
        
        //this will trigger load methods
        [self.sortingScrollView setOptions:sortList];
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
        [self.collectionView setContentOffset:CGPointZero];
    }
}

- (void)setupViews
{
    self.productsMap = [NSMutableDictionary new];
    
    self.isFirstLoadTracking = NO;
    self.filterButton.backgroundColor = JACatalogViewControllerButtonColor;
    self.filterButton.enabled = NO;
    self.viewToggleButton.backgroundColor = JACatalogViewControllerButtonColor;
    
    self.sortingScrollView.delegate = self;
    self.sortingScrollView.startingIndex = 1;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UINib *gridCellNib = [UINib nibWithNibName:@"JACatalogGridCell" bundle:nil];
    [self.collectionView registerNib:gridCellNib forCellWithReuseIdentifier:@"gridCell"];
    UINib *listCellNib = [UINib nibWithNibName:@"JACatalogListCell" bundle:nil];
    [self.collectionView registerNib:listCellNib forCellWithReuseIdentifier:@"listCell"];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
    [self changeToList];
    
    self.sortingMethod = NSIntegerMax;
}

- (void)getCategories
{
    [self showLoading];
    
    [RICategory getAllCategoriesWithSuccessBlock:^(id categories)
     {
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
             self .navBarLayout.title = self.category.name;
             
             NSArray* sortList = [NSArray arrayWithObjects:STRING_BEST_RATING, STRING_POPULARITY, STRING_NEW_IN, STRING_PRICE_UP, STRING_PRICE_DOWN, STRING_NAME, STRING_BRAND, nil];
             
             if(VALID_NOTEMPTY(self.sorting, NSNumber))
             {
                 self.sortingScrollView.startingIndex = [self.sorting integerValue];
                 self.sorting = nil;
             }
             
             //this will trigger load methods
             [self.sortingScrollView setOptions:sortList];
         }
         else
         {
             BOOL noConnection = NO;
             if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
             {
                 noConnection = YES;
             }
             [self showErrorView:noConnection startingY:CGRectGetMaxY(self.sortingScrollView.frame) selector:@selector(getCategories) objects:nil];
             
         }
         
         [self hideLoading];
         
     } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
         if(RIApiResponseMaintenancePage == apiResponse)
         {
             [self showMaintenancePage:@selector(getCategories) objects:nil];
         }
         else
         {
             BOOL noConnection = NO;
             if (RIApiResponseNoInternetConnection == apiResponse)
             {
                 noConnection = YES;
             }
             [self showErrorView:noConnection startingY:CGRectGetMaxY(self.sortingScrollView.frame) selector:@selector(getCategories) objects:nil];
         }
         
         [self hideLoading];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];
    
    BOOL alreadyShowedWizardCatalog = [[NSUserDefaults standardUserDefaults] boolForKey:kJACatalogWizardUserDefaultsKey];
    if(alreadyShowedWizardCatalog == NO)
    {
        self.wizardView = [[JACatalogWizardView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.wizardView];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJACatalogWizardUserDefaultsKey];
    }
}

- (void)resetCatalog
{
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    [self.productsMap setObject:[NSMutableArray new] forKey:key];
    
    self.loadedEverything = NO;
}

- (void)addProdutsToMap:(NSArray*)products
{
    [self removeErrorView];
    
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    NSMutableArray *productsArray = [self.productsMap objectForKey:key];
    
    BOOL isEmpty = NO;
    if(ISEMPTY(productsArray))
    {
        isEmpty = YES;
        productsArray = [NSMutableArray new];
    }
    
    if(VALID_NOTEMPTY(products, NSArray))
    {
        [productsArray addObjectsFromArray:products];
    }
    
    [self.productsMap setObject:productsArray forKey:key];
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
        NSNumber *pageNumber = [NSNumber numberWithInt:[self getCurrentPage] + 1];
        
        if (VALID_NOTEMPTY(self.searchString, NSString))
        {
            // In case of this is a search
            [self showLoading];
            self.isLoadingMoreProducts =YES;
            
            self.searchSuggestionOperationID = [RISearchSuggestion getResultsForSearch:self.searchString
                                                                                  page:[pageNumber stringValue]
                                                                              maxItems:[NSString stringWithFormat:@"%d",JACatalogViewControllerMaxProducts]
                                                                         sortingMethod:self.sortingMethod
                                                                               filters:self.filtersArray
                                                                          successBlock:^(NSArray *results, NSArray *filters, NSNumber *productCount) {
                                                                              self.searchSuggestionOperationID = nil;
                                                                              
                                                                              if (ISEMPTY(self.filtersArray) && NOTEMPTY(filters)) {
                                                                                  self.filtersArray = filters;
                                                                                  self.filterButton.enabled = YES;
                                                                              }
                                                                              
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
                                                                                  [trackingDictionary setValue:[NSNumber numberWithInt:numberOfResults] forKey:kRIEventNumberOfProductsKey];
                                                                                  
                                                                                  [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSearch]
                                                                                                                            data:[trackingDictionary copy]];
                                                                                  
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
                                                                                  
                                                                              }
                                                                              
                                                                              self.navBarLayout.subTitle = [NSString stringWithFormat:@"%d", [productCount integerValue]];
                                                                              [self reloadNavBar];
                                                                              
                                                                              [self addProdutsToMap:results];
                                                                              
                                                                              NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
                                                                              NSMutableArray *productsArray = [self.productsMap objectForKey:key];
                                                                              if (0 == results.count || results.count < JACatalogViewControllerMaxProducts || [productCount integerValue] == productsArray.count)
                                                                              {
                                                                                  self.loadedEverything = YES;
                                                                              }
                                                                              
                                                                              self.isLoadingMoreProducts = NO;
                                                                              [self hideLoading];
                                                                              
                                                                          } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm) {
                                                                              self.searchSuggestionOperationID = nil;
                                                                              
                                                                              NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
                                                                              NSMutableArray *productsArray = [self.productsMap objectForKey:key];
                                                                              if(VALID_NOTEMPTY(productsArray, NSArray))
                                                                              {
                                                                                  NSString *erroMessasge = STRING_ERROR;
                                                                                  if (RIApiResponseNoInternetConnection == apiResponse)
                                                                                  {
                                                                                      erroMessasge = STRING_NO_NEWTORK;
                                                                                  }
                                                                                  
                                                                                  [self showMessage:erroMessasge success:NO];
                                                                              }
                                                                              else
                                                                              {
                                                                                  if (VALID_NOTEMPTY(undefSearchTerm, RIUndefinedSearchTerm))
                                                                                  {
                                                                                      self.navBarLayout.subTitle = @"0";
                                                                                      [self reloadNavBar];
                                                                                      self.undefinedBackup = undefSearchTerm;
                                                                                      [self addUndefinedSearchView:undefSearchTerm frame:self.collectionView.frame];
                                                                                  } else
                                                                                  {
                                                                                      if(RIApiResponseMaintenancePage == apiResponse)
                                                                                      {
                                                                                          [self showMaintenancePage:@selector(loadMoreProducts) objects:nil];
                                                                                      }
                                                                                      else
                                                                                      {
                                                                                          BOOL noConnection = NO;
                                                                                          if (RIApiResponseNoInternetConnection == apiResponse)
                                                                                          {
                                                                                              noConnection = YES;
                                                                                          }
                                                                                          [self showErrorView:noConnection startingY:CGRectGetMaxY(self.sortingScrollView.frame) selector:@selector(loadMoreProducts) objects:nil];
                                                                                      }
                                                                                  }
                                                                              }
                                                                              
                                                                              self.isLoadingMoreProducts = NO;
                                                                              [self hideLoading];
                                                                              
                                                                          }];
        }
        else
        {
            if (NO == self.loadedEverything)
            {
                [self showLoading];
                self.isLoadingMoreProducts =YES;
                
                NSString* urlToUse = self.catalogUrl;
                if (VALID_NOTEMPTY(self.category, RICategory) && VALID_NOTEMPTY(self.category.apiUrl, NSString)) {
                    urlToUse = self.category.apiUrl;
                }
                if (VALID_NOTEMPTY(self.filterCategory, RICategory) && VALID_NOTEMPTY(self.filterCategory.apiUrl, NSString)) {
                    urlToUse = self.filterCategory.apiUrl;
                }
                
                self.getProductsOperationID = [RIProduct getProductsWithCatalogUrl:urlToUse
                                                                     sortingMethod:self.sortingMethod
                                                                              page:[pageNumber integerValue]
                                                                          maxItems:JACatalogViewControllerMaxProducts
                                                                           filters:self.filtersArray
                                                                        filterType:self.filterType
                                                                       filterValue:self.filterValue
                                                                      successBlock:^(NSArray* products, NSString* productCount, NSArray* filters, NSString *categoryId, NSArray* categories) {
                                                                          self.getProductsOperationID = nil;
                                                                          
                                                                          self.navBarLayout.subTitle = productCount;
                                                                          [self reloadNavBar];
                                                                          
                                                                          if (ISEMPTY(self.filtersArray) && NOTEMPTY(filters)) {
                                                                              self.filtersArray = filters;
                                                                              self.filterButton.enabled = YES;
                                                                          }
                                                                          
                                                                          RICategory *category = nil;
                                                                          if (NOTEMPTY(categories)) {
                                                                              self.categoriesArray = categories;
                                                                              category = [categories objectAtIndex:0];
                                                                          }
                                                                          
                                                                          NSInteger productCountValue = [productCount intValue];
                                                                          NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
                                                                          NSMutableArray *productsArray = [self.productsMap objectForKey:key];
                                                                          if (0 == products.count || products.count < JACatalogViewControllerMaxProducts || productCountValue == productsArray.count)
                                                                          {
                                                                              self.loadedEverything = YES;
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
                                                                              
                                                                              if(VALID_NOTEMPTY(self.category, RICategory))
                                                                              {
                                                                                  [trackingDictionary setValue:self.category.name forKey:kRIEventCategoryNameKey];
                                                                                  [trackingDictionary setValue:self.category.uid forKey:kRIEventCategoryIdKey];
                                                                                  
                                                                                  [trackingDictionary setValue:[RICategory getTree:self.category.uid] forKey:kRIEventTreeKey];
                                                                              }
                                                                              else if(VALID_NOTEMPTY(categoryId, NSString))
                                                                              {
                                                                                  [trackingDictionary setValue:category.name forKey:kRIEventCategoryNameKey];
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
                                                                          if(VALID_NOTEMPTY(self.category, RICategory))
                                                                          {
                                                                              [trackingDictionary setValue:self.category.name forKey:kRIEventCategoryNameKey];
                                                                          }
                                                                          [trackingDictionary setValue:pageNumber forKey:kRIEventPageNumberKey];
                                                                          
                                                                          [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewGTMListing]
                                                                                                                    data:[trackingDictionary copy]];
                                                                          
                                                                          [self addProdutsToMap:products];
                                                                          
                                                                          self.isLoadingMoreProducts = NO;
                                                                          [self hideLoading];
                                                                          
                                                                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                                                          self.getProductsOperationID = nil;
                                                                          
                                                                          NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
                                                                          NSMutableArray *productsArray = [self.productsMap objectForKey:key];
                                                                          if(VALID_NOTEMPTY(productsArray, NSArray))
                                                                          {
                                                                              NSString *erroMessasge = STRING_ERROR;
                                                                              if (RIApiResponseNoInternetConnection == apiResponse)
                                                                              {
                                                                                  erroMessasge = STRING_NO_NEWTORK;
                                                                              }
                                                                              
                                                                              [self showMessage:erroMessasge success:NO];
                                                                          }
                                                                          else
                                                                          {
                                                                              if(RIApiResponseMaintenancePage == apiResponse)
                                                                              {
                                                                                  [self showMaintenancePage:@selector(loadMoreProducts) objects:nil];
                                                                              }
                                                                              else
                                                                              {
                                                                                  BOOL noConnection = NO;
                                                                                  if (RIApiResponseNoInternetConnection == apiResponse)
                                                                                  {
                                                                                      noConnection = YES;
                                                                                  }
                                                                                  [self showErrorView:noConnection startingY:CGRectGetMaxY(self.sortingScrollView.frame) selector:@selector(loadMoreProducts) objects:nil];
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
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    NSMutableArray *productsArray = [self.productsMap objectForKey:key];
    if (VALID_NOTEMPTY(productsArray, NSMutableArray))
    {
        currentPage = productsArray.count / JACatalogViewControllerMaxProducts;
    }
    return currentPage;
}

#pragma mark - Actions

- (IBAction)swipeRight:(id)sender
{
    [self.sortingScrollView scrollRight];
}

- (IBAction)swipeLeft:(id)sender
{
    [self.sortingScrollView scrollLeftAnimated:YES];
}

- (void)changeToList
{
    [UIView transitionWithView:self.collectionView
                      duration:.3
                       options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        
                        //use view instead of collection view, the list cell has the insets inside itself;
                        self.flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, JACatalogViewControllerListCellHeight);
                        self.flowLayout.minimumInteritemSpacing = 0.0f;
                        
                    } completion:^(BOOL finished) {
                        
                    }];
    [self.collectionView reloadData];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"List" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCatalog]
                                              data:[trackingDictionary copy]];
}

- (void)changeToGrid
{
    [UIView transitionWithView:self.collectionView
                      duration:.3
                       options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        
                        self.flowLayout.itemSize = CGSizeMake((self.collectionView.frame.size.width / 2) - 2, JACatalogViewControllerGridCellHeight);
                        self.flowLayout.minimumInteritemSpacing = 3.0f;
                        
                    } completion:^(BOOL finished) {
                        
                    }];
    [self.collectionView reloadData];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"Grid" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCatalog]
                                              data:[trackingDictionary copy]];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    NSMutableArray *productsArray = [self.productsMap objectForKey:key];
    return productsArray.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(3, 0, 0, 0);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        self.catalogTopButton.hidden = YES;
    }
    
    if ((YES == self.gridSelected && 7 <= indexPath.row) ||
        (NO == self.gridSelected && 5 <= indexPath.row)) {
        self.catalogTopButton.hidden = NO;
    }
    
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    NSMutableArray *productsArray = [self.productsMap objectForKey:key];
    if (!self.loadedEverything && productsArray.count - 5 <= indexPath.row)
    {
        [self loadMoreProducts];
    }
    
    RIProduct *product = [productsArray objectAtIndex:indexPath.row];
    
    NSString *cellIdentifier;
    if (self.gridSelected) {
        cellIdentifier = @"gridCell";
    }else{
        cellIdentifier = @"listCell";
    }
    
    JACatalogCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.favoriteButton.tag = indexPath.row;
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

- (void)clickableViewPressedInCell:(UIControl*)sender
{
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    NSMutableArray *productsArray = [self.productsMap objectForKey:key];
    RIProduct *product = [productsArray objectAtIndex:indexPath.row];
    
    NSInteger count = productsArray.count;
    
    if (count > 20) {
        count = 20;
    }
    
    NSMutableArray *tempArray = [NSMutableArray new];
    
    for (int i = 0 ; i < count ; i ++) {
        [tempArray addObject:[productsArray objectAtIndex:i]];
    }
    
    NSString *temp = self.category.name;
    
    
    if (temp.length > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"url" : product.url,
                                                                      @"previousCategory" : temp,
                                                                      @"fromCatalog" : @"YES",
                                                                      @"relatedItems" : tempArray,
                                                                      @"delegate" : self,
                                                                      @"category" : self.category,
                                                                      @"show_back_button" : [NSNumber numberWithBool:YES]}];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"url" : product.url,
                                                                      @"fromCatalog" : @"YES",
                                                                      @"previousCategory" : self.navBarLayout.title,
                                                                      @"relatedItems" : tempArray ,
                                                                      @"delegate": self ,
                                                                      @"show_back_button" : [NSNumber numberWithBool:YES]}];
    }
}

#pragma mark - JAPickerScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{
    if (index != self.sortingMethod)
    {
        self.sortingMethod = index;
        
        [self removeErrorView];
        
        NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
        NSMutableArray *productsArray = [self.productsMap objectForKey:key];
        if(ISEMPTY(productsArray))
        {
            [self loadMoreProducts];
        }
        else
        {
            [self.collectionView reloadData];
            [self.collectionView setContentOffset:CGPointZero animated:NO];
        }
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:self.title forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"SortingOnCatalog" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
        [trackingDictionary setValue:[RIProduct sortingName:self.sortingMethod] forKey:kRIEventSortTypeKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSort]
                                                  data:[trackingDictionary copy]];
    }
}

#pragma mark - JAMainFiltersViewControllerDelegate

- (void)updatedFiltersAndCategory:(RICategory *)category;
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:self.catalogUrl forKey:kRIEventLabelKey];
    [trackingDictionary setValue:STRING_FILTERS forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    
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
                            
                            [trackingDictionary setObject:filter.name forKey:kRIEventPriceFilterKey];
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
                                [trackingDictionary setObject:filter.name forKey:kRIEventBrandFilterKey];
                            }
                            else if([@"color_family" isEqualToString:filter.uid])
                            {
                                [trackingDictionary setObject:filter.name forKey:kRIEventColorFilterKey];
                            }
                        }
                    }
                }
            }
        }
    }
    
    if(VALID_NOTEMPTY(category, RICategory))
    {
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventIndividualFilter]
                                                  data:[NSDictionary dictionaryWithObject:@"category" forKey:kRIEventFilterTypeKey]];
        [trackingDictionary setObject:@"category" forKey:kRIEventCategoryFilterKey];
    }
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFilter]
                                              data:[trackingDictionary copy]];
    
    self.filterCategory = category;
    [self resetCatalog];
    [self loadMoreProducts];
}

#pragma mark - JAPDVViewControllerDelegate

- (void)changedFavoriteStateOfProduct:(RIProduct*)product;
{
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    NSMutableArray *productsArray = [self.productsMap objectForKey:key];
    for (int i = 0; i < productsArray.count; i++)
    {
        RIProduct* currentProduct = [productsArray objectAtIndex:i];
        if ([currentProduct.sku isEqualToString:product.sku])
        {
            currentProduct.favoriteAddDate = product.favoriteAddDate;
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]];
        }
    }
}

#pragma mark - Button actions

- (IBAction)filterButtonPressed:(id)sender
{
    JAMainFiltersViewController *mainFiltersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainFiltersViewController"];
    mainFiltersViewController.filtersArray = self.filtersArray;
    mainFiltersViewController.categoriesArray = self.categoriesArray;
    mainFiltersViewController.selectedCategory = self.filterCategory;
    mainFiltersViewController.delegate = self;
    [self.navigationController pushViewController:mainFiltersViewController
                                         animated:YES];
}

- (IBAction)viewButtonPressed:(id)sender
{
    //reverse selection
    self.gridSelected = !self.gridSelected;
    
    UIImage* image;
    if (self.gridSelected) {
        image = [UIImage imageNamed:@"listIcon"];
        [self changeToGrid];
    } else {
        image = [UIImage imageNamed:@"gridIcon"];
        [self changeToList];
    }
    [self.viewToggleButtonIcon setImage:image];
}

- (IBAction)catalogTopButtonPressed:(id)sender
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (void)addToFavoritesPressed:(UIButton*)button
{
    self.backupButton = button;
    
    [self continueAddingToFavouritesWithButton:self.backupButton];
}

- (void)continueAddingToFavouritesWithButton:(UIButton *)button
{
    button.selected = !button.selected;
    
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    NSMutableArray *productsArray = [self.productsMap objectForKey:key];
    
    RIProduct* product = [productsArray objectAtIndex:button.tag];
    if (button.selected) {
        product.favoriteAddDate = [NSDate date];
    } else {
        product.favoriteAddDate = nil;
    }
    [self showLoading];
    if (button.selected)
    {
        //add to favorites
        [RIProduct getCompleteProductWithUrl:product.url
                                successBlock:^(id completeProduct) {
                                    [RIProduct addToFavorites:completeProduct successBlock:^{
                                        
                                        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                        [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
                                        [trackingDictionary setValue:@"AddtoWishlist" forKey:kRIEventActionKey];
                                        [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                                        [trackingDictionary setValue:product.price forKey:kRIEventValueKey];
                                        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                                        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                                        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                                        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                        [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                                        NSNumber *price = (VALID_NOTEMPTY(product.specialPrice, NSNumber)  && [product.specialPrice floatValue] > 0.0f) ? product.specialPrice : product.price;
                                        [trackingDictionary setValue:[price stringValue] forKey:kRIEventPriceKey];
                                        
                                        [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
                                        [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
                                        
                                        [trackingDictionary setValue:product.brand forKey:kRIEventBrandKey];
                                        
                                        NSString *discountPercentage = @"0";
                                        if(VALID_NOTEMPTY(product.maxSavingPercentage, NSString))
                                        {
                                            discountPercentage = product.maxSavingPercentage;
                                        }
                                        [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
                                        [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
                                        [trackingDictionary setValue:@"Catalog" forKey:kRIEventLocationKey];
                                        if(VALID_NOTEMPTY(self.category, RICategory))
                                        {
                                            [trackingDictionary setValue:self.category.name forKey:kRIEventCategoryNameKey];
                                        }
                                        
                                        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToWishlist]
                                                                                  data:[trackingDictionary copy]];
                                        
                                        
                                        [self hideLoading];
                                        
                                        [self showMessage:STRING_ADDED_TO_WISHLIST success:YES];
                                        
                                    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                        NSString *addToWishlistError = STRING_ERROR_ADDING_TO_WISHLIST;
                                        if(RIApiResponseNoInternetConnection == apiResponse)
                                        {
                                            addToWishlistError = STRING_NO_NEWTORK;
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
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"RemoveFromWishlist" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
            [trackingDictionary setValue:product.price forKey:kRIEventValueKey];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
            
            NSNumber *price = (VALID_NOTEMPTY(product.specialPrice, NSNumber)  && [product.specialPrice floatValue] > 0.0f) ? product.specialPrice : product.price;
            [trackingDictionary setValue:[price stringValue] forKey:kRIEventPriceKey];
            [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
            [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
            [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                      data:[trackingDictionary copy]];
            
            //update favoriteProducts
            [self hideLoading];
            
            [self showMessage:STRING_REMOVED_FROM_WISHLIST success:YES];
            
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
    self.filterButton.userInteractionEnabled = NO;
    self.viewToggleButton.userInteractionEnabled = NO;
    self.sortingScrollView.disableDelagation = YES;
    [self.collectionView removeFromSuperview];
    [self.catalogTopButton removeFromSuperview];
    
    // Build and add the new view
    [self.view addSubview:self.undefinedView];
    
    [self.undefinedView setupWithUndefinedSearchResult:undefSearch
                                            searchText:self.searchString];
    
    [self.view bringSubviewToFront:self.wizardView];
}

#pragma mark - Undefined view delegate

- (void)didSelectProduct:(NSString *)productUrl
{
    JAPDVViewController *pdv = [self.storyboard instantiateViewControllerWithIdentifier:@"pdvViewController"];
    pdv.productUrl = productUrl;
    pdv.fromCatalogue = NO;
    pdv.showBackButton = YES;
    pdv.previousCategory = self.category.name;
    pdv.delegate = self;
    pdv.category = self.category;
    
    [self.navigationController pushViewController:pdv
                                         animated:YES];
}

- (void)didSelectBrand:(NSString *)brandUrl
             brandName:(NSString *)brandName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(98),
                                                                 @"name": brandName,
                                                                 @"url": brandUrl }];
}

@end

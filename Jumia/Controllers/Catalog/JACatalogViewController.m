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
#import "JAUndefinedSearchView.h"
#import "JAFilteredNoResultsView.h"

#define JACatalogGridSelected @"CATALOG_GRID_IS_SELECTED"
#define JACatalogViewControllerButtonColor UIColorFromRGB(0xe3e3e3);
#define JACatalogViewControllerMaxProducts 36
#define JACatalogViewControllerMaxProducts_ipad 46

@interface JACatalogViewController ()
<JAFilteredNoResulsViewDelegate>

@property (nonatomic, strong)JACatalogWizardView* wizardView;
@property (nonatomic, strong) JAFilteredNoResultsView *filteredNoResultsView;

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

@property (nonatomic, strong) NSString* cellIdentifier;
@property (nonatomic, assign) NSInteger numberOfCellsInScreen;
@property (nonatomic, assign) NSInteger maxProducts;

@property (nonatomic, assign) NSInteger lastIndex;

@property (nonatomic, assign) RIApiResponse apiResponse;

@end

@implementation JACatalogViewController

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
            self.navBarLayout.subTitle = @"0";
            [self reloadNavBar];
            [self addUndefinedSearchView:undefinedSearchTerm frame:self.collectionView.frame];
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
    
        self.sortingScrollView.hidden = YES;
        self.sortingScrollView.disableDelagation = YES;
        self.viewToggleButton.hidden = YES;
        self.filterButton.hidden = YES;
        
        CGRect frame = CGRectMake(0.0,
                                  0.0,
                                  self.view.frame.size.width,
                                  self.view.frame.size.height);
        
        [self.filteredNoResultsView setupView:frame];
        
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
    self.sortingScrollView.hidden = NO;
    self.viewToggleButton.hidden = NO;
    self.filterButton.hidden = NO;
    self.sortingScrollView.disableDelagation = NO;
    
    [self filterButtonPressed:nil];
}

- (void)showLoading
{
    self.catalogTopButton.hidden=YES;
    [super showLoading];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    UIImage* filterIcon = [UIImage imageNamed:@"filterIcon"];
    UIImageView* filterIconView = [[UIImageView alloc] initWithImage:filterIcon];
    [filterIconView setFrame:CGRectMake((self.filterButton.bounds.size.width - filterIcon.size.width) / 2,
                                        (self.filterButton.bounds.size.height - filterIcon.size.height) / 2,
                                        filterIcon.size.width,
                                        filterIcon.size.height)];
    filterIconView.center = self.filterButton.center;
    [self.filterButton addSubview:filterIconView];
    [self.filterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.gridSelected = NO;
    UIImage* viewToggleIcon = [UIImage imageNamed:@"gridIcon"];
    NSNumber *gridSelected = [[NSUserDefaults standardUserDefaults] objectForKey:JACatalogGridSelected];
    if(VALID_NOTEMPTY(gridSelected, NSNumber) && [gridSelected boolValue])
    {
        self.gridSelected = [gridSelected boolValue];
        viewToggleIcon = [UIImage imageNamed:@"listIcon"];
    }
    
    self.viewToggleButtonIcon = [[UIImageView alloc] initWithImage:viewToggleIcon];
    [self.viewToggleButtonIcon setFrame:CGRectMake((self.viewToggleButton.bounds.size.width - viewToggleIcon.size.width) / 2,
                                                   (self.viewToggleButton.bounds.size.height - viewToggleIcon.size.height) / 2,
                                                   viewToggleIcon.size.width,
                                                   viewToggleIcon.size.height)];
    [self.viewToggleButton addSubview:self.viewToggleButtonIcon];
    [self.viewToggleButton addTarget:self action:@selector(viewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
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
        CGPoint contentOffset = self.collectionView.contentOffset;
        [self.collectionView setContentOffset:contentOffset];
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
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JACatalogGridCell" bundle:nil] forCellWithReuseIdentifier:@"gridCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JACatalogGridCell_ipad_portrait" bundle:nil] forCellWithReuseIdentifier:@"gridCell_ipad_portrait"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JACatalogGridCell_ipad_landscape" bundle:nil] forCellWithReuseIdentifier:@"gridCell_ipad_landscape"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JACatalogListCell" bundle:nil] forCellWithReuseIdentifier:@"listCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JACatalogListCell_ipad_portrait" bundle:nil] forCellWithReuseIdentifier:@"listCell_ipad_portrait"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JACatalogListCell_ipad_landscape" bundle:nil] forCellWithReuseIdentifier:@"listCell_ipad_landscape"];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
    self.sortingMethod = NSIntegerMax;
}

- (void)getCategories
{
    if(RIApiResponseSuccess == self.apiResponse || RIApiResponseMaintenancePage == self.apiResponse)
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
         self.apiResponse = apiResponse;
         [self removeErrorView];
         
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
    
    [self changeViewToInterfaceOrientation:self.interfaceOrientation];
    
    if (VALID_NOTEMPTY(self.undefinedBackup, RIUndefinedSearchTerm)){
        
        [self.undefinedView removeFromSuperview];
        [self addUndefinedSearchView:self.undefinedBackup frame:CGRectMake(6.0f,
                                                                           CGRectGetMaxY(self.sortingScrollView.frame),
                                                                           self.view.frame.size.width - 12.0f,
                                                                           self.view.frame.size.height - CGRectGetMaxY(self.sortingScrollView.frame) - 12.0f)];
    }
}

- (void)resetCatalog
{
    [self.productsMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self.productsMap setObject:[NSMutableArray new] forKey:key];
    }];
    
    self.loadedEverything = NO;
}

- (void)addProdutsToMap:(NSArray*)products
{
    self.apiResponse = RIApiResponseSuccess;
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
            if(RIApiResponseSuccess == self.apiResponse || RIApiResponseMaintenancePage == self.apiResponse || RIApiResponseAPIError == self.apiResponse)
            {
                [self showLoading];
            }
            
            self.isLoadingMoreProducts =YES;
            
            self.searchSuggestionOperationID = [RISearchSuggestion getResultsForSearch:self.searchString
                                                                                  page:[pageNumber stringValue]
                                                                              maxItems:[NSString stringWithFormat:@"%d",self.maxProducts]
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
                                                                                  
                                                                                  trackingDictionary = [[NSMutableDictionary alloc] init];
                                                                                  if(VALID_NOTEMPTY(self.searchString, NSString))
                                                                                  {
                                                                                      [trackingDictionary setValue:self.searchString forKey:kRIEventCategoryNameKey];
                                                                                  }

                                                                                  [trackingDictionary setValue:pageNumber forKey:kRIEventPageNumberKey];
                                                                                  
                                                                                  [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewGTMListing]
                                                                                                                            data:[trackingDictionary copy]];
                                                                                  
                                                                              }
                                                                              
                                                                              self.navBarLayout.subTitle = [NSString stringWithFormat:@"%d", [productCount integerValue]];
                                                                              [self reloadNavBar];
                                                                              
                                                                              [self addProdutsToMap:results];
                                                                              
                                                                              NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
                                                                              NSMutableArray *productsArray = [self.productsMap objectForKey:key];
                                                                              if (0 == results.count || results.count < self.maxProducts || [productCount integerValue] == productsArray.count)
                                                                              {
                                                                                  self.loadedEverything = YES;
                                                                              }
                                                                              
                                                                              self.isLoadingMoreProducts = NO;
                                                                              [self hideLoading];
                                                                              
                                                                          } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm) {
                                                                              self.apiResponse = apiResponse;
                                                                              [self removeErrorView];
                                                                              self.searchSuggestionOperationID = nil;
                                                                              
                                                                              NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
                                                                              NSMutableArray *productsArray = [self.productsMap objectForKey:key];
                                                                              if(VALID_NOTEMPTY(productsArray, NSArray))
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
                                                                                  else
                                                                                  {
                                                                                      if (RIApiResponseNoInternetConnection == apiResponse)
                                                                                      {
                                                                                          [self showErrorView:YES startingY:CGRectGetMaxY(self.sortingScrollView.frame) selector:@selector(loadMoreProducts) objects:nil];
                                                                                          
                                                                                      }
                                                                                      else if(RIApiResponseAPIError == apiResponse)
                                                                                      {
                                                                                          [self showNoResultsView:CGRectGetMaxY(self.sortingScrollView.frame) undefinedSearchTerm:undefSearchTerm];
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
                if(RIApiResponseSuccess == self.apiResponse || RIApiResponseMaintenancePage == self.apiResponse || RIApiResponseAPIError == self.apiResponse)
                {
                    [self showLoading];
                }
                
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
                                                                          maxItems:self.maxProducts
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
                                                                          if (0 == products.count || products.count < self.maxProducts || productCountValue == productsArray.count)
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
                                                                          
                                                                          [self addProdutsToMap:products];
                                                                          
                                                                          self.isLoadingMoreProducts = NO;
                                                                          [self hideLoading];
                                                                          
                                                                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                                                          self.apiResponse = apiResponse;
                                                                          [self removeErrorView];
                                                                          self.getProductsOperationID = nil;
                                                                          
                                                                          NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
                                                                          NSMutableArray *productsArray = [self.productsMap objectForKey:key];
                                                                          if(VALID_NOTEMPTY(productsArray, NSArray))
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
                                                                              else
                                                                              {
                                                                                  if (RIApiResponseNoInternetConnection == apiResponse)
                                                                                  {
                                                                                      [self showErrorView:YES startingY:CGRectGetMaxY(self.sortingScrollView.frame) selector:@selector(loadMoreProducts) objects:nil];

                                                                                  }
                                                                                  else if(RIApiResponseAPIError == apiResponse)
                                                                                  {
                                                                                      [self showNoResultsView:CGRectGetMaxY(self.sortingScrollView.frame) undefinedSearchTerm:nil];
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
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    NSMutableArray *productsArray = [self.productsMap objectForKey:key];
    if (VALID_NOTEMPTY(productsArray, NSMutableArray))
    {
        currentPage = productsArray.count / self.maxProducts;
    }
    return currentPage;
}

#pragma mark - Actions

- (IBAction)swipeRight:(id)sender
{
    [self.sortingScrollView scrollRightAnimated:YES];
}

- (IBAction)swipeLeft:(id)sender
{
    [self.sortingScrollView scrollLeftAnimated:YES];
}

- (CGSize)getLayoutItemSizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat width = 0.0f;
    CGFloat height = 0.0f;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            
            if (self.gridSelected) {
                width = 248.0f;
                height = JACatalogViewControllerGridCellHeight_ipad;
            } else {
                width = 375.0f;
                height = JACatalogViewControllerListCellHeight_ipad;
            }
        } else {
            if (self.gridSelected) {
                width = 196.0f;
                height = JACatalogViewControllerGridCellHeight_ipad;
            } else {
                width = 333.0f;
                height = JACatalogViewControllerListCellHeight_ipad;
            }
        }
    } else {
        if (self.gridSelected) {
            width = (self.collectionView.frame.size.width / 2) - 2;
            height = JACatalogViewControllerGridCellHeight;
        } else {
            //use view instead of collection view, the list cell has the insets inside itself;
            width = self.view.frame.size.width;
            height = JACatalogViewControllerListCellHeight;
        }
    }
    
    return CGSizeMake(width, height);
}

- (CGFloat)getLayoutMinimumSpacingForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSInteger spacing = 0.0f;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            
        } else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
            
        }
    } else {
        if (self.gridSelected) {
            
        } else {
            spacing = 3.0f;
        }
    }
    
    return spacing;
}

- (void)changeViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.gridSelected) {
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
        
        self.flowLayout.itemSize = [self getLayoutItemSizeForInterfaceOrientation:interfaceOrientation];
        self.flowLayout.minimumInteritemSpacing = [self getLayoutMinimumSpacingForInterfaceOrientation:interfaceOrientation];
        [self.collectionView reloadData];
    }
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    if (self.gridSelected) {
        [trackingDictionary setValue:@"Grid" forKey:kRIEventActionKey];
    } else {
        [trackingDictionary setValue:@"List" forKey:kRIEventActionKey];
    }
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCatalog]
                                              data:[trackingDictionary copy]];
}

- (NSInteger)getNumberOfCellsInScreenForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.gridSelected) {
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
    
    if (self.numberOfCellsInScreen <= indexPath.row) {
        self.catalogTopButton.hidden = NO;
    }
    
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    NSMutableArray *productsArray = [self.productsMap objectForKey:key];
    if (!self.loadedEverything && productsArray.count - self.numberOfCellsInScreen <= indexPath.row)
    {
        self.catalogTopButton.hidden = YES;
        [self loadMoreProducts];
    }
    
    RIProduct *product = [productsArray objectAtIndex:indexPath.row];
    
    JACatalogCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
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
        
        self.apiResponse = RIApiResponseSuccess;
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

- (IBAction)viewButtonPressed:(id)sender
{
    //reverse selection
    self.gridSelected = !self.gridSelected;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.gridSelected] forKey:JACatalogGridSelected];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIImage* image;
    if (self.gridSelected) {
        image = [UIImage imageNamed:@"listIcon"];
    } else {
        image = [UIImage imageNamed:@"gridIcon"];
    }
    [self.viewToggleButtonIcon setImage:image];
    
    [self changeViewToInterfaceOrientation:self.interfaceOrientation];
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
    NSNumber *key = [NSNumber numberWithInt:self.sortingMethod];
    NSMutableArray *productsArray = [self.productsMap objectForKey:key];
    
    RIProduct* product = [productsArray objectAtIndex:button.tag];

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
                                        
                                        
                                        [self hideLoading];
                                        
                                        [self showMessage:STRING_ADDED_TO_WISHLIST success:YES];
                                        
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
    
    self.lastIndex = self.sortingScrollView.selectedIndex;
    
    [self changeViewToInterfaceOrientation:toInterfaceOrientation];
    
    [self selectedIndex:self.lastIndex];
    self.sortingScrollView.startingIndex = self.lastIndex;
    [self.sortingScrollView setNeedsLayout];
    
    [self.undefinedView removeFromSuperview];
    
    [self showLoading];
    
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
                                                                           CGRectGetMaxY(self.sortingScrollView.frame),
                                                                           self.view.frame.size.width - 12.0f,
                                                                           self.view.frame.size.height - CGRectGetMaxY(self.sortingScrollView.frame) - 12.0f)];
        [self.undefinedView didRotate];
    }
    [self hideLoading];
    
    // disabling delegation in case there's a filters view when device finishes rotating
    UIView *filtersView = [self.view viewWithTag:1001];
    if(filtersView != nil)
    {
        self.sortingScrollView.disableDelagation = YES;
    }
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end

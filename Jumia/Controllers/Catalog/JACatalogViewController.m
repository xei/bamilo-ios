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
#import "UIImageView+JA.h"
#import "UIImageView+WebCache.h"
#import "JACampaignBannerCell.h"
#import "JACatalogBannerCell.h"
#import "JAProductCollectionViewFlowLayout.h"
#import "JACatalogCollectionViewCell.h"
#import "JACatalogListCollectionViewCell.h"
#import "JACatalogGridCollectionViewCell.h"
#import "RIAddress.h"
#import "JACatalogPictureCollectionViewCell.h"
#import "JACollectionSeparator.h"
#import "RITarget.h"

#define JACatalogGridSelected @"CATALOG_GRID_IS_SELECTED"
#define JACatalogViewControllerButtonColor UIColorFromRGB(0xe3e3e3);
#define JACatalogViewControllerMaxProducts 36
#define JACatalogViewControllerMaxProducts_ipad 46

typedef void (^ProcessActionBlock)(void);

@interface JACatalogViewController ()
<JAFilteredNoResulsViewDelegate>
{
    BOOL _needAddToFavBlock;
    ProcessActionBlock _processActionBlock;
}

//$WIZ$
//@property (nonatomic, strong) JACatalogWizardView* wizardView;
@property (nonatomic, strong) JAFilteredNoResultsView *filteredNoResultsView;

@property (nonatomic, strong) JACatalogTopView* catalogTopView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) JAProductCollectionViewFlowLayout* flowLayout;
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

@synthesize searchString = _searchString;
- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    [self setSearchBarText:self.searchString];
}

-(void)showNoResultsView:(CGFloat)withVerticalPadding undefinedSearchTerm:(RIUndefinedSearchTerm*)undefinedSearchTerm
{
    //$WIZ$
//    [self.wizardView removeFromSuperview];
    
    self.filteredNoResultsView.delegate = nil;
    [self.filteredNoResultsView removeFromSuperview];
    self.filteredNoResultsView = [[JAFilteredNoResultsView alloc] initWithFrame:[self viewBounds]];
    
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
            [self onErrorResponse:RIApiResponseUnknownError messages:nil showAsMessage:NO selector:@selector(loadMoreProducts) objects:nil];
        }
    }
    else
    {
        self.filteredNoResultsView.delegate = self;

        //$WIZ$
//        if (VALID_NOTEMPTY(self.wizardView, JACatalogWizardView))
//        {
//            [self.wizardView removeFromSuperview];
//        }
    
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
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navBarClicked)
                                                 name:kDidPressNavBar
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCategories) name:kSideMenuShouldReload object:nil];
    
    if (VALID_NOTEMPTY(self.category, RICategory)) {
        self.categoryUrlKey = self.category.urlKey;
    }
    
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
            self.screenName = [NSString stringWithFormat:@"Catalog / %@", self.category.label];
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
    
    if (VALID_NOTEMPTY(self.searchString, NSString) || VALID_NOTEMPTY(self.category, RICategory) || VALID_NOTEMPTY(self.catalogTargetString, NSString))
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedProduct:)
                                                 name:kProductChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedProduct:)
                                                 name:kUserLoggedInNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedProduct:)
                                                 name:kUserLoggedOutNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews
{
    [self.collectionView setWidth:self.view.width];
    [self.collectionView setHeight:self.view.height - CGRectGetMaxY(self.catalogTopView.frame)];
    [self.catalogTopView repositionForWidth:self.view.frame.size.width];
    if (self.filteredNoResultsView.superview) {
        [self.filteredNoResultsView setupView:[self viewBounds]];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self trackingEventScreenName:@"ShopCatalogList"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //$WIZ$
//    BOOL alreadyShowedWizardCatalog = [[NSUserDefaults standardUserDefaults] boolForKey:kJACatalogWizardUserDefaultsKey];
//    if(alreadyShowedWizardCatalog == NO)
//    {
//        self.wizardView = [[JACatalogWizardView alloc] initWithFrame:self.view.bounds];
//        [self.view addSubview:self.wizardView];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJACatalogWizardUserDefaultsKey];
//    }
    
    [self changeViewToInterfaceOrientation:self.interfaceOrientation];
    
    if (VALID_NOTEMPTY(self.undefinedBackup, RIUndefinedSearchTerm)){
        
        [self.undefinedView removeFromSuperview];
        [self addUndefinedSearchView:self.undefinedBackup frame:CGRectMake(6.0f,
                                                                           self.catalogTopView.frame.origin.y,
                                                                           [self viewBounds].size.width - 12.0f,
                                                                           [self viewBounds].size.height)];
    }
    
    [self.catalogTopView repositionForWidth:self.view.frame.size.width];
    
    if (_needAddToFavBlock) {
        
        if (_processActionBlock) {
            _processActionBlock();
        }
    }
    if (self.filteredNoResultsView.superview) {
        self.catalogTopView.hidden = YES;
    }
}
 
- (void)setupViews
{
    self.productsArray = [NSMutableArray new];
    
    self.isFirstLoadTracking = NO;
    
    self.catalogTopView = [JACatalogTopView getNewJACatalogTopView];
    [self.catalogTopView setFrame:CGRectMake(0,
                                             [self viewBounds].origin.y,
                                             self.view.frame.size.width,
                                             self.catalogTopView.frame.size.height)];
    self.catalogTopView.cellTypeSelected = JACatalogCollectionViewGridCell;
    self.catalogTopView.delegate = self;
    [self.view addSubview:self.catalogTopView];
    self.catalogTopView.sortingButton.enabled = NO;
    self.catalogTopView.filterButton.enabled = NO;
    
    [self.collectionView setFrame:CGRectMake([self.collectionView frame].origin.x,
                                            CGRectGetMaxY(self.catalogTopView.frame),
                                            self.collectionView.frame.size.width,
                                            self.view.frame.size.height - CGRectGetMaxY(self.catalogTopView.frame))];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JACatalogBannerCell" bundle:nil] forCellWithReuseIdentifier:@"bannerCell"];
    [self.collectionView registerClass:[JACatalogListCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogListCollectionViewCell"];
    [self.collectionView registerClass:[JACatalogGridCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogGridCollectionViewCell"];
    [self.collectionView registerClass:[JACatalogPictureCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogPictureCollectionViewCell"];
    
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0,0,0,self.collectionView.bounds.size.width-7);
    
    self.flowLayout = [[JAProductCollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 1.0f;
    self.flowLayout.minimumInteritemSpacing = 0.f;
    [self.flowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"horizontalSeparator"];
    [self.flowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"verticalSeparator"];

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
    
    if (VALID_NOTEMPTY([[NSUserDefaults standardUserDefaults] objectForKey:JACatalogGridSelected], NSNumber)) {
        NSNumber* cellTypeSelected = [[NSUserDefaults standardUserDefaults] objectForKey:JACatalogGridSelected];
        self.catalogTopView.cellTypeSelected = [cellTypeSelected integerValue];
    }
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
         [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
         
         for (RICategory *category in categories)
         {             
             if (VALID_NOTEMPTY(self.categoryUrlKey, NSString)) {
                 if ([self.categoryUrlKey isEqualToString:category.urlKey]) {
                     self.category = category;
                     break;
                 }
             }
         }
         
         if(VALID_NOTEMPTY(self.category, RICategory))
         {
             self.navBarLayout.title = self.category.label;
             
             self.productsArray = nil;
             [self loadMoreProducts];
         }
         else
         {
             self.categoryName = self.categoryUrlKey;
             [self loadMoreProducts];
         }
         
         [self hideLoading];
         
     } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
         self.apiResponse = apiResponse;
         [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(getCategories) objects:nil];
         [self hideLoading];
     }];
}

- (void)resetCatalog
{
    self.productsArray = [NSMutableArray new];
    
    self.loadedEverything = NO;
}

- (void)addProductsToTable:(NSArray*)products
{
    self.apiResponse = RIApiResponseSuccess;
    [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
    
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
    [self.filteredNoResultsView removeFromSuperview];
    
    if(!self.isLoadingMoreProducts)
    {
        self.loadedEverything = NO;
        NSNumber *pageNumber = [NSNumber numberWithInteger:[self getCurrentPage] + 1];
        
        typedef void (^ProcessProductsBlock)(RICatalog *catalog);
        ProcessProductsBlock processProductsBlock = ^(RICatalog *catalog){
            [self processCatalog:catalog];
        };
        
        typedef void (^ProcessSearchProductsFailureBlock)(RIApiResponse apiResponse,  NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm);
        ProcessSearchProductsFailureBlock processSearchProductsFailureBlock = ^(RIApiResponse apiResponse,  NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm) {
            [self setLoadProductsError:apiResponse errorMessages:errorMessages undefSearchTerm:undefSearchTerm];
        };
        
        typedef void (^ProcessCategoryProductsFailureBlock)(RIApiResponse apiResponse,  NSArray *errorMessages);
        ProcessCategoryProductsFailureBlock processCategoryProductsFailureBlock = ^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self setLoadProductsError:apiResponse errorMessages:errorMessages undefSearchTerm:nil];
        };
        
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
                                                                          successBlock:processProductsBlock
                                                                       andFailureBlock:processSearchProductsFailureBlock];
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
                
                NSString* urlToUse = [RITarget getURLStringforTargetString:self.catalogTargetString];
                if (VALID_NOTEMPTY(self.categoryName, NSString)) {
                    urlToUse = [NSString stringWithFormat:@"%@%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_CATALOG, self.categoryName];
                }
                if (VALID_NOTEMPTY(self.category, RICategory) && VALID_NOTEMPTY(self.category.targetString, NSString)) {
                    urlToUse = [RITarget getURLStringforTargetString:self.category.targetString];
                }
                if (VALID_NOTEMPTY(self.filterCategory, RICategory) && VALID_NOTEMPTY(self.filterCategory.targetString, NSString)) {
                    urlToUse = [RITarget getURLStringforTargetString:self.filterCategory.targetString];
                }
                
                self.getProductsOperationID = [RIProduct getProductsWithCatalogUrl:urlToUse
                                                                     sortingMethod:self.sortingMethod
                                                                              page:[pageNumber integerValue]
                                                                          maxItems:self.maxProducts
                                                                           filters:self.filtersArray
                                                                        filterPush:self.filterPush
                                                                      successBlock:processProductsBlock
                                                                   andFailureBlock:processCategoryProductsFailureBlock];
            }
        }
    }
}

- (void)processCatalog:(RICatalog *)catalog
{
    [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
    
    self.searchSuggestionOperationID = nil;
    self.getProductsOperationID = nil;
    
    if (ISEMPTY(self.filtersArray) && NOTEMPTY(catalog.filters)) {
        self.filtersArray = catalog.filters;
        self.catalogTopView.filterButton.enabled = YES;
    }
    
    self.catalogTopView.sortingButton.enabled = YES;
    
    self.banner = catalog.banner;
    if (VALID_NOTEMPTY(self.banner, RIBanner)) {
        self.flowLayout.hasBanner = YES;
    }
    
    if (NOTEMPTY(catalog.categories)) {
        self.categoriesArray = catalog.categories;
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
            categoryName = parent.label;
            subCategoryName = self.category.label;
        }
        else
        {
            categoryName = self.category.label;
        }
    }else{
        categoryName = self.navBarLayout.title;
    }
    
    if (VALID_NOTEMPTY(catalog.title, NSString)) {
        self.navBarLayout.title = catalog.title;
    }else if (VALID_NOTEMPTY(categoryName, NSString))
    {
        self.navBarLayout.title = categoryName;
    }
    
    // Track events only in the first load of the products
    if (!self.isFirstLoadTracking)
    {
        self.isFirstLoadTracking = YES;
        
        if (VALID_NOTEMPTY(self.searchString, NSString)) {
            [self trackingEventSearchForString:self.searchString with:catalog.totalProducts];
            
            [self trackingEventFacebookSearchWithCategories:catalog.categories];
            
            [self trackingEventLoadingTime];
        }else{
            NSMutableArray *productsToTrack = [[NSMutableArray alloc] init];
            for(RIProduct *product in catalog.products)
            {
                [productsToTrack addObject:[product sku]];
                if([productsToTrack count] == 3)
                {
                    break;
                }
            }
            
            [self trackingEventViewListingForProducts:productsToTrack];
            
            [self trackingEventFacebookListeningForProducts:productsToTrack categories:catalog.categories];
            
            [self trackingEventGTMListingForCategoryName:categoryName andSubCategoryName:subCategoryName];
        }
        
        [self trackingEventLoadingTime];
    }
    
    NSInteger countInteger = [catalog.totalProducts integerValue];
    NSString* countString = [NSString stringWithFormat:@"%ld %@",(long)countInteger, STRING_ITEMS];
    if (1 == countInteger) {
        countString = [NSString stringWithFormat:@"1 %@", STRING_ITEM];
    }
    self.navBarLayout.subTitle = countString;
    [self reloadNavBar];
    
    [self addProductsToTable:catalog.products];
    
    if (0 == countInteger || countInteger < self.maxProducts || countInteger == self.productsArray.count)
    {
        self.loadedEverything = YES;
    }
    
    self.isLoadingMoreProducts = NO;
    [self hideLoading];
}

- (void)setLoadProductsError:(RIApiResponse) apiResponse  errorMessages:(NSArray *)errorMessages undefSearchTerm:(RIUndefinedSearchTerm *)undefSearchTerm
{
    self.navBarLayout.subTitle = @"";
    [self reloadNavBar];
    
    self.apiResponse = apiResponse;
    self.getProductsOperationID = nil;
    
    if(VALID_NOTEMPTY(self.productsArray, NSArray))
    {
        [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:nil objects:nil];
    }
    else
    {
//$WIZ$
//        if (VALID_NOTEMPTY(self.wizardView, JACatalogWizardView))
//        {
//            [self.wizardView removeFromSuperview];
//        }
        
        if(RIApiResponseAPIError == apiResponse)
        {
            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
            [self showNoResultsView:CGRectGetMaxY(self.catalogTopView.frame) undefinedSearchTerm:undefSearchTerm];
        }else{
            [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadMoreProducts) objects:nil];
        }
    }
    
    self.isLoadingMoreProducts = NO;
    [self hideLoading];
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
            
            switch (self.catalogTopView.cellTypeSelected) {
                case JACatalogCollectionViewGridCell:
                    width = self.view.frame.size.width/3;
                    height = JACatalogViewControllerGridCellHeight_ipad;
                    break;
                case JACatalogCollectionViewListCell:
                    width = self.view.frame.size.width;
                    height = JACatalogViewControllerListCellHeight_ipad;
                    break;
                case JACatalogCollectionViewPictureCell:
                    width = self.view.frame.size.width;
                    height = JACatalogViewControllerPictureCellHeight_ipad;
                    break;
            }
        } else {
            switch (self.catalogTopView.cellTypeSelected) {
                case JACatalogCollectionViewGridCell:
                    width =  self.view.frame.size.width/4;
                    height = JACatalogViewControllerGridCellHeight_ipad;
                    break;
                case JACatalogCollectionViewListCell:
                    width =  self.view.frame.size.width/2;
                    height = JACatalogViewControllerListCellHeight_ipad;
                    break;
                case JACatalogCollectionViewPictureCell:
                    width =  self.view.frame.size.width/2;
                    height = JACatalogViewControllerPictureCellHeight_ipad;
                    break;
            }
        }
    } else {
        switch (self.catalogTopView.cellTypeSelected) {
            case JACatalogCollectionViewGridCell:
                width = self.view.frame.size.width/2;
                height = JACatalogViewControllerGridCellHeight;
                break;
            case JACatalogCollectionViewListCell:
                width = self.view.frame.size.width;
                height = JACatalogViewControllerListCellHeight;
                break;
            case JACatalogCollectionViewPictureCell:
                width = self.view.frame.size.width;
                height = JACatalogViewControllerPictureCellHeight;
                break;
        }
    }
    self.flowLayout.itemSize = CGSizeMake(width, height);
    return CGSizeMake(width, height);
}

- (void)changeViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.bannerImage = nil;
    switch (self.catalogTopView.cellTypeSelected) {
        case JACatalogCollectionViewGridCell:
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (UIInterfaceOrientationPortrait == interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
                self.cellIdentifier = @"gridCell_ipad_portrait";
            } else {
                self.cellIdentifier = @"gridCell_ipad_landscape";
            }
        } else {
            self.cellIdentifier = @"gridCell";
        }
            break;
        case JACatalogCollectionViewListCell:
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (UIInterfaceOrientationPortrait == interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
                self.cellIdentifier = @"listCell_ipad_portrait";
            } else {
                self.cellIdentifier = @"listCell_ipad_landscape";
            }
        } else {
            self.cellIdentifier = @"listCell";
        }
            break;
        case JACatalogCollectionViewPictureCell:
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                if (UIInterfaceOrientationPortrait == interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
                    self.cellIdentifier = @"pictureCell_ipad_portrait";
                } else {
                    self.cellIdentifier = @"pictureCell_ipad_landscape";
                }
            } else {
                self.cellIdentifier = @"pictureCell";
            }
            break;
    }
    
    if(VALID_NOTEMPTY(self.collectionView.superview, UIView))
    {
        self.numberOfCellsInScreen = [self getNumberOfCellsInScreenForInterfaceOrientation:interfaceOrientation];
        
        [self.collectionView reloadData];
    }
    
    [self trackingEventCatalog];
}

- (NSInteger)getNumberOfCellsInScreenForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (self.catalogTopView.cellTypeSelected) {
        case JACatalogCollectionViewGridCell:
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                if (UIInterfaceOrientationPortrait == interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
                    return 15;
                } else {
                    return 20;
                }
            }else{
                return 7;
            }
            break;
            
        case JACatalogCollectionViewListCell:
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                if (UIInterfaceOrientationPortrait == interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
                    return 18;
                } else {
                    return 21;
                }
            }else{
                return 5;
            }
            break;
            
        case JACatalogCollectionViewPictureCell:
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                if (UIInterfaceOrientationPortrait == interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation) {
                    return 18;
                } else {
                    return 21;
                }
            }else{
                return 5;
            }
            break;
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
    return [self getLayoutItemSizeForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
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
    }else if ([self.cellIdentifier hasPrefix:@"list"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JACatalogListCollectionViewCell" forIndexPath:indexPath];
    } else if ([self.cellIdentifier hasPrefix:@"picture"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JACatalogPictureCollectionViewCell" forIndexPath:indexPath];
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
    
    [cell.sizeButton setHidden:YES];
    
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
        
        RITarget* target = [RITarget parseTarget:self.banner.targetString];
        
        if ([target.type isEqualToString:@"catalog"]) {
            
            notificationName = kDidSelectTeaserWithCatalogUrlNofication;
            
        } else if ([target.type isEqualToString:@"product_detail"]) {
            
            notificationName = kDidSelectTeaserWithPDVUrlNofication;
            
        } else if ([target.type isEqualToString:@"static_page"]) {
            
            notificationName = kDidSelectTeaserWithShopUrlNofication;
            
        } else if ([target.type isEqualToString:@"campaign"]) {
            
            notificationName = kDidSelectCampaignNofication;

        }
        
        if (VALID_NOTEMPTY(self.banner.targetString, NSString)) {
            [userInfo setObject:self.banner.targetString forKey:@"targetString"];
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
    
    NSString *temp = self.category.label;
    
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo setObject:product.targetString forKey:@"targetString"];
    [userInfo setObject:@"YES" forKey:@"fromCatalog"];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    
    if (self.teaserTrackingInfo) {
        [userInfo setObject:self.teaserTrackingInfo forKey:@"teaserTrackingInfo"];
    }
    
    if (temp.length > 0) {
        [userInfo setObject:self.category forKey:@"category"];
        [self trackingEventScreenName:[NSString stringWithFormat:@"cat_/%@/%@",self.category.urlKey
                                                                 ,product.name]];
    }
    else
    {
        [self trackingEventScreenName:[NSString stringWithFormat:@"Search_%@",product.name]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - JAFiltersViewControllerDelegate

- (void)updatedFilters:updatedFiltersArray;
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    
    BOOL filtersSelected = NO;
    if(VALID_NOTEMPTY(updatedFiltersArray, NSArray))
    {
        self.filtersArray = updatedFiltersArray;
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
                            
                            [self trackingEventIndividualFilter:filter.name];

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
                        if (filterOption.selected && VALID_NOTEMPTY(filterOption.name, NSString))
                        {
                            [self trackingEventIndividualFilter:filter.name];
                            
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
    
    [self trackingEventFilter:trackingDictionary];
    
    [self.catalogTopView setFilterSelected:filtersSelected];
    [self resetCatalog];
    [self loadMoreProducts];
}

#pragma mark - kProductChangedNotification

- (void)updatedProduct:(NSNotification *)notification
{
    if (VALID_NOTEMPTY(notification.object, NSArray)) {
        for (NSString *sku in notification.object) {
            int i = 0;
            for(; i < self.productsArray.count; i++)
            {
                RIProduct *product = [self.productsArray objectAtIndex:i];
                if ([sku isEqualToString:product.sku]) {
                    product.favoriteAddDate = [NSDate new];
                    break;
                }
            }
        }
        
    }else if (VALID_NOTEMPTY(notification.object, NSString)) {
        
        NSString* sku = notification.object;
        int i = 0;
        for(; i < self.productsArray.count; i++)
        {
            RIProduct *product = [self.productsArray objectAtIndex:i];
            if ([sku isEqualToString:product.sku]) {
                product.favoriteAddDate = nil;
                if (notification.userInfo && [notification.userInfo objectForKey:@"favoriteAddDate"]) {
                    NSDate *date =[notification.userInfo objectForKey:@"favoriteAddDate"];
                    product.favoriteAddDate = date;
                }else
                    product.favoriteAddDate = nil;
            }
        }
    }else{
        return;
    }
    [self.collectionView reloadData];
}

#pragma mark - JACatalogTopViewDelegate

- (void)filterButtonPressed
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:self forKey:@"delegate"];
    
    if(VALID(self.filtersArray, NSArray))
    {
        [userInfo setObject:[RIFilter copyFiltersArray:self.filtersArray] forKey:@"filtersArray"];
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
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.catalogTopView.cellTypeSelected] forKey:JACatalogGridSelected];
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
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    if (!button.selected && !VALID_NOTEMPTY(product.favoriteAddDate, NSDate))
    {
        [self addToFavorites:button];
    }else if (button.selected && VALID_NOTEMPTY(product.favoriteAddDate, NSDate))
    {
        [self removeFromFavorites:button];
    }
}

- (BOOL)isUserLoggedInWithBlock:(ProcessActionBlock)block
{
    if(![RICustomer checkIfUserIsLogged]) {
        [self hideLoading];
        _needAddToFavBlock = YES;
        _processActionBlock = block;
        NSMutableDictionary* userInfoLogin = [[NSMutableDictionary alloc] init];
        [userInfoLogin setObject:[NSNumber numberWithBool:NO] forKey:@"from_side_menu"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:nil userInfo:userInfoLogin];
        return NO;
    }
    return YES;
}

- (void)addToFavorites:(UIButton *)button
{
    [self showLoading];
    
    __weak typeof (self) weakSelf = self;
    
    BOOL logged = [self isUserLoggedInWithBlock:^{
        _needAddToFavBlock = NO;
        if(![RICustomer checkIfUserIsLogged]) {
            return;
        }else{
            [weakSelf addToFavorites:button];
        }
    }];
    
    if (!logged) {
        return;
    }
    
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    if (!button.selected && !VALID_NOTEMPTY(product.favoriteAddDate, NSDate))
    {
        [RIProduct addToFavorites:product successBlock:^(RIApiResponse apiResponse,  NSArray *success){
            button.selected = YES;
            product.favoriteAddDate = [NSDate date];
            
            [self trackingEventAddToWishList:product];
            
            [self onSuccessResponse:RIApiResponseSuccess messages:success showMessage:YES];
            [self hideLoading];
            
            NSDictionary *userInfo = nil;
            if (product.favoriteAddDate) {
                userInfo = [NSDictionary dictionaryWithObject:product.favoriteAddDate forKey:@"favoriteAddDate"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kProductChangedNotification
                                                                object:product.sku
                                                              userInfo:userInfo];
            
            [self.collectionView reloadData];
            
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            [self onErrorResponse:apiResponse messages:error showAsMessage:YES selector:nil objects:nil];
            [self hideLoading];
        }];
    }else{
        [self hideLoading];
    }
}

- (void)removeFromFavorites:(UIButton *)button
{
    [self showLoading];
    
    __weak typeof (self) weakSelf = self;
    
    BOOL logged = [self isUserLoggedInWithBlock:^{
        _needAddToFavBlock = NO;
        if(![RICustomer checkIfUserIsLogged]) {
            return;
        }else{
            [weakSelf removeFromFavorites:button];
        }
    }];
    
    if (!logged) {
        return;
    }
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    if (button.selected && VALID_NOTEMPTY(product.favoriteAddDate, NSDate))
    {
        [RIProduct removeFromFavorites:product successBlock:^(RIApiResponse apiResponse, NSArray *success) {
            button.selected = NO;
            product.favoriteAddDate = nil;
            
            [self trackingEventRemoveFromWishlist:product];
            
            [self onSuccessResponse:RIApiResponseSuccess messages:success showMessage:YES];
            //update favoriteProducts
            [self hideLoading];
            
            NSDictionary *userInfo = nil;
            if (product.favoriteAddDate) {
                userInfo = [NSDictionary dictionaryWithObject:product.favoriteAddDate forKey:@"favoriteAddDate"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kProductChangedNotification
                                                                object:product.sku
                                                              userInfo:userInfo];
            
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            
            [self onErrorResponse:apiResponse messages:error showAsMessage:YES selector:nil objects:nil];
            [self hideLoading];
        }];
    }else{
        [self hideLoading];
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
    //$WIZ$
//    [self.view bringSubviewToFront:self.wizardView];
}

#pragma mark - Undefined view delegate

- (void)didSelectProduct:(NSString *)productTargetString
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"fromCatalog"];
    [userInfo setObject:self forKey:@"delegate"];
    if(VALID_NOTEMPTY(productTargetString, NSString))
    {
        [userInfo setObject:productTargetString forKey:@"targetString"];
    }
    if(VALID_NOTEMPTY(self.category, RICategory))
    {
        [userInfo setObject:self.category forKey:@"category"];
        if(VALID_NOTEMPTY(self.category.label, NSString))
        {
            [userInfo setObject:self.category.label forKey:@"previousCategory"];
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

- (void)didSelectBrandTargetString:(NSString *)brandTargetString
                         brandName:(NSString *)brandName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(98),
                                                                 @"name": brandName,
                                                                 @"targetString": brandTargetString }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //$WIZ$
//    if(VALID_NOTEMPTY(self.wizardView, JACatalogWizardView))
//    {
//        CGRect newFrame = CGRectMake(self.wizardView.frame.origin.x,
//                                     self.wizardView.frame.origin.y,
//                                     self.view.frame.size.height + self.view.frame.origin.y,
//                                     self.view.frame.size.width - self.view.frame.origin.y);
//        [self.wizardView reloadForFrame:newFrame];
//    }
    
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
//$WIZ$    
//    if(VALID_NOTEMPTY(self.wizardView, JACatalogWizardView))
//    {
//        [self.wizardView reloadForFrame:self.view.bounds];
//    }
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
        [self killScroll];
        self.sortingMethod = catalogSorting;
        [self.catalogTopView setSorting:self.sortingMethod];
        
        self.apiResponse = RIApiResponseSuccess;
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        
        [self resetCatalog];
        [self loadMoreProducts];
        
        [self trackingEventSort];

    }
}

- (void)killScroll
{
    CGPoint offset = self.collectionView.contentOffset;
    offset.y -= .1;
    [self.collectionView setContentOffset:offset animated:YES];
    offset.y += .1;
    [self.collectionView setContentOffset:offset animated:YES];
}

#pragma mark - Tracking events

- (void)trackingEventFilter:(NSMutableDictionary *)trackingDictionary
{
    NSString* url = [RITarget getURLStringforTargetString:self.catalogTargetString];
    [trackingDictionary setValue:url forKey:kRIEventLabelKey];
    [trackingDictionary setValue:STRING_FILTERS forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFilter]
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventIndividualFilter:(NSString *)filterName
{
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventIndividualFilter]
                                              data:[NSDictionary dictionaryWithObject:filterName forKey:kRIEventFilterTypeKey]];
}

- (void)trackingEventCatalog
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    
    switch (self.catalogTopView.cellTypeSelected) {
        case JACatalogCollectionViewListCell:
            [trackingDictionary setValue:@"List" forKey:kRIEventActionKey];
            break;
        case JACatalogCollectionViewGridCell:
            [trackingDictionary setValue:@"Grid" forKey:kRIEventActionKey];
            break;
        case JACatalogCollectionViewPictureCell:
            [trackingDictionary setValue:@"Picture" forKey:kRIEventActionKey];
            break;
    }
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCatalog]
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventLoadingTime
{
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)trackingEventScreenName:(NSString *)screenName
{
    [[RITrackingWrapper sharedInstance] trackScreenWithName:screenName];
}

- (void)trackingEventAddToWishList:(RIProduct *)product
{
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
            categoryName = parent.label;
            subCategoryName = self.category.label;
        }
        else
        {
            categoryName = self.category.label;
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
}

- (void)trackingEventRemoveFromWishlist:(RIProduct *)product
{
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
}

- (void)trackingEventSort
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:self.title forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"SortingOnCatalog" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:[RIProduct sortingName:self.sortingMethod] forKey:kRIEventSortTypeKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSort]
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventSearchForString:(NSString *)string with:(NSNumber *)numberOfProducts
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"Search" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:numberOfProducts forKey:kRIEventValueKey];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    [trackingDictionary setValue:string forKey:kRIEventKeywordsKey];
    
    [trackingDictionary setValue:[NSNumber numberWithInteger:[numberOfProducts integerValue]] forKey:kRIEventNumberOfProductsKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSearch]
                                              data:[trackingDictionary copy]];
    
    [FBSDKAppEvents logEvent:FBSDKAppEventNameSearched
                  parameters:@{FBSDKAppEventParameterNameSearchString:string,
                               FBSDKAppEventParameterNameSuccess: @1 }];
}

- (void)trackingEventFacebookSearchWithCategories:(NSArray *)categories
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
    if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
    {
        [trackingDictionary setValue:[numberOfSessions stringValue] forKey:kRIEventAmountSessions];
    }
    
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    
    
    if(self.categoryId)
    {
        [trackingDictionary setValue:self.categoryId forKey:kRIEventCategoryIdKey];
        [trackingDictionary setValue:[RICategory getTree:self.categoryId] forKey:kRIEventTreeKey];
    }else if (VALID_NOTEMPTY(categories, NSArray)){
        [trackingDictionary setValue:[categories firstObject] forKey:kRIEventCategoryIdKey];
        [trackingDictionary setValue:[RICategory getTree:[categories firstObject]] forKey:kRIEventTreeKey];
    }
    
    [trackingDictionary setValue:self.searchString forKey:kRIEventQueryKey];
    
    if ([RICustomer checkIfUserIsLogged]) {
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
        [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
            RIAddress *shippingAddress = (RIAddress *)[adressList objectForKey:@"shipping"];
            [trackingDictionary setValue:shippingAddress.city forKey:kRIEventCityKey];
            [trackingDictionary setValue:shippingAddress.customerAddressRegion forKey:kRIEventRegionKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookSearch]
                                                      data:[trackingDictionary copy]];
            
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            NSLog(@"ERROR: getting customer");
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookSearch]
                                                      data:[trackingDictionary copy]];
        }];
    }else{
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookSearch]
                                                  data:[trackingDictionary copy]];
    }
}

- (void)trackingEventGTMListingForCategoryName:(NSString *)categoryName andSubCategoryName:(NSString *)subCategoryName
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(categoryName, NSString))
    {
        [trackingDictionary setValue:categoryName forKey:kRIEventCategoryNameKey];
    }
    if(VALID_NOTEMPTY(subCategoryName, NSString))
    {
        [trackingDictionary setValue:subCategoryName forKey:kRIEventSubCategoryNameKey];
    }
    [self trackingEventGTMListing:trackingDictionary];
}

- (void)trackingEventGTMListing:(NSMutableDictionary *)trackingDictionary
{
    NSNumber *pageNumber = [NSNumber numberWithInteger:[self getCurrentPage] + 1];
    [trackingDictionary setValue:pageNumber forKey:kRIEventPageNumberKey];
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewGTMListing]
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventViewListingForProducts:(NSArray *)productsToTrack
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    [trackingDictionary setValue:productsToTrack forKey:kRIEventSkusKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewListing]
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventFacebookListeningForProducts:(NSArray *)productsToTrack categories:(NSArray *)categories
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
    if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
    {
        [trackingDictionary setValue:[numberOfSessions stringValue] forKey:kRIEventAmountSessions];
    }
    
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    
    if(VALID_NOTEMPTY(self.categoryName, NSString))
    {
        [trackingDictionary setValue:self.categoryName forKey:kRIEventCategoryNameKey];
    }
    
    if(VALID_NOTEMPTY(categories, NSArray))
    {
        [trackingDictionary setValue:[categories firstObject] forKey:kRIEventCategoryIdKey];
        [trackingDictionary setValue:[RICategory getTree:[categories firstObject]] forKey:kRIEventTreeKey];
    }
    
    [trackingDictionary setValue:productsToTrack forKey:kRIEventSkusKey];
    
    if ([RICustomer checkIfUserIsLogged]) {
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
        [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
            RIAddress *shippingAddress = (RIAddress *)[adressList objectForKey:@"shipping"];
            [trackingDictionary setValue:shippingAddress.city forKey:kRIEventCityKey];
            [trackingDictionary setValue:shippingAddress.customerAddressRegion forKey:kRIEventRegionKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewListing] data:[trackingDictionary copy]];
            
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            NSLog(@"ERROR: getting customer");
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewListing] data:[trackingDictionary copy]];
        }];
    }else{
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewListing] data:[trackingDictionary copy]];
    }
}

@end

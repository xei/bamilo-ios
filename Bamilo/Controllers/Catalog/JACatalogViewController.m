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
#import "SearchFilterItem.h"
#import "SearchPriceFilter.h"
#import "JAClickableView.h"
#import "JAUndefinedSearchView.h"
#import "JAFilteredNoResultsView.h"
#import "CatalogNoResultViewController.h"
#import "JAAppDelegate.h"
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
#import "JACenterNavigationController.h"
#import "RICatalogSorting.h"
//##############################
#import "ViewControllerManager.h"
#import "DataManager.h"
#import "PushWooshTracker.h"
#import "SearchEvent.h"
#import "EmarsysMobileEngage.h"
#import "NSMutableArray+Extensions.h"
#import "EmarsysPredictManager.h"
#import "NSArray+Extension.h"
#import "RecommendItem.h"
#import "EventUtilities.h"

#define JACatalogGridSelected @"CATALOG_GRID_IS_SELECTED"
#define JACatalogViewControllerMaxProducts 36
#define JACatalogViewControllerMaxProducts_ipad 46

typedef void (^ProcessActionBlock)(void);

@interface JACatalogViewController () <JAFilteredNoResulsViewDelegate> {
    BOOL _needAddToFavBlock;
    ProcessActionBlock _processActionBlock;
    BOOL _hasBanner;
}

@property (nonatomic, weak) CatalogNoResultViewController* NoResultViewController;
@property (nonatomic, strong) JAFilteredNoResultsView *filteredNoResultsView;
@property (nonatomic, strong) JACatalogTopView* catalogTopView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *NoResultViewControllerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTopConstraint;
@property (nonatomic, strong) JAProductCollectionViewFlowLayout* flowLayout;
@property (nonatomic, strong) NSMutableArray <RIProduct *>* productsArray;
@property (nonatomic, copy)   NSArray<BaseSearchFilterItem*> *filtersArray;
@property (nonatomic, assign) int priceFilterIndex;
@property (nonatomic, strong) RICategory* filterCategory;
@property (nonatomic, assign) BOOL loadedEverything;
@property (nonatomic, assign) RICatalogSortingEnum sortingMethod;
@property (nonatomic, strong) JAUndefinedSearchView *undefinedView;
@property (nonatomic, strong) RIUndefinedSearchTerm *undefinedBackup;
@property (assign, nonatomic) BOOL isFirstLoadTracking;
@property (assign, nonatomic) BOOL isLoadingMoreProducts;
@property (nonatomic, copy) NSString *searchSuggestionOperationID;
@property (nonatomic, copy) NSString *getProductsOperationID;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) NSString *labelName;
@property (strong, nonatomic) UIButton *backupButton;
@property (nonatomic, assign) NSInteger numberOfCellsInScreen;
@property (nonatomic, assign) NSInteger maxProducts;
@property (nonatomic, assign) RIApiResponse apiResponse;
@property (nonatomic, strong) JASortingView* sortingView;
@property (nonatomic, strong) RIBanner *banner;
@property (nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, assign) BOOL hasSubcategoriesForFilter;

@end

@implementation JACatalogViewController {
@private SearchCategoryFilter *subCatFilter;
@protected NSString *fullPathCategory;
}

@synthesize bannerImageView = _bannerImageView;
- (UIImageView*)bannerImageView {
    if (self.banner) {
        if (!_bannerImageView) {
            _bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
            
            __block UIImageView *blockedImageView = _bannerImageView;
            __weak JACatalogViewController *weakSelf = self;
            NSString *imageURL = self.banner.iPhoneImageUrl;
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                imageURL = self.banner.iPadImageUrl;
            }
            
            [_bannerImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(error) {
                    _hasBanner = NO;
                } else {
                    _hasBanner = YES;
                    [blockedImageView changeImageHeight:0.0f andWidth:weakSelf.view.width];
                    [weakSelf.collectionView reloadData];
                }
            }];
        }
    } else {
        _hasBanner = NO;
        _bannerImageView = nil;
    }
    return _bannerImageView;
}

@synthesize searchString = _searchString;
- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    [self setSearchBarText:self.searchString];
}

- (void)showNoResultsView:(CGFloat)withVerticalPadding undefinedSearchTerm:(RIUndefinedSearchTerm*)undefinedSearchTerm {
    
    if(self.filtersArray.count) {
        self.filteredNoResultsView.delegate = nil;
        [self.filteredNoResultsView removeFromSuperview];
        self.filteredNoResultsView = [[JAFilteredNoResultsView alloc] initWithFrame:[self viewBounds]];
        self.filteredNoResultsView.tag = 1001;
        self.filteredNoResultsView.delegate = self;
        
        self.catalogTopView.hidden = YES;
        [self.collectionView setHidden:YES];
        [self.filteredNoResultsView setupView:[self viewBounds]];
        [self.view addSubview:self.filteredNoResultsView];
    }
    
    self.NoResultViewController.searchQuery = self.searchString ? self.searchString : self.categoryName;
    [self.NoResultViewController getSuggestions];
    [self.catalogTopView setHidden:YES];
    [self.collectionView setHidden:YES];
    [self.NoResultViewControllerContainer setHidden:NO];
    
}

#pragma mark - filteredNoResultsViewDelegate
- (void)pressedEditFiltersButton:(JAFilteredNoResultsView *)view {
    [self.collectionView setHidden:NO];
    self.catalogTopView.hidden = NO;
    [self filterButtonPressed];
}

- (void)showLoading {
    [super showLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navBarClicked) name:kDidPressNavBar object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCategories) name:kSideMenuShouldReload object:nil];
    
    //Here we have a real shit!!!!!!
    if (self.category) {
        self.categoryUrlKey = self.category.urlKey;
    } else if (self.categoryUrlKey) {
        self.targetString = [RITarget getTargetString:CATALOG_CATEGORY node:self.categoryUrlKey];
    } else if (self.targetString) {
        RITarget *target = [RITarget parseTarget:self.targetString];
        if (target.targetType == CATALOG_CATEGORY) {
            self.categoryUrlKey = target.node;
        }
    }
    
    if (self.categoryUrlKey) {
        [self getSubcategories];
    }
    
    self.apiResponse = RIApiResponseSuccess;
    
    if (self.forceShowBackButton) {
        self.navBarLayout.showBackButton = YES;
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.maxProducts = JACatalogViewControllerMaxProducts_ipad;
    } else {
        self.maxProducts = JACatalogViewControllerMaxProducts;
    }
    
    [self setupViews];
    
    if (self.searchString.length || self.category || self.targetString.length) {
        [self loadMoreProducts];
    } else {
        [self getCategories];
    }
    
    [self.NoResultViewControllerContainer setHidden:YES];
    
    //EVENT : SEARCH
    [TrackerManager postEvent:[EventFactory search:self.categoryUrlKey keywords:[EventUtilities getSearchKeywords:self.searchString]] forName:[SearchEvent name]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(self.searchSuggestionOperationID.length) {
        [RISearchSuggestion cancelRequest:self.searchSuggestionOperationID];
        [self hideLoading];
    } else if(self.getProductsOperationID.length) {
        [RIProduct cancelRequest:self.getProductsOperationID];
        [self hideLoading];
    }
    
    if(self.collectionView) {
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

- (void)viewWillLayoutSubviews {
    if (_hasBanner) {
        _bannerImageView = nil;
        [self bannerImageView];
    }
    [self.collectionView setWidth:self.view.width];
    [self.collectionView setHeight:self.view.height - CGRectGetMaxY(self.catalogTopView.frame)];
    [self.catalogTopView repositionForWidth:self.view.frame.size.width];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackingEventScreenName:@"ShopCatalogList"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self changeViewToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    if (self.undefinedBackup) {
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
}

- (void)setupViews {
    self.productsArray = [NSMutableArray new];
    
    self.isFirstLoadTracking = NO;
    
    self.catalogTopView = [JACatalogTopView getNewJACatalogTopView];
    [self.catalogTopView setFrame:CGRectMake(0, [self viewBounds].origin.y,
                                             self.view.frame.size.width,
                                             self.catalogTopView.frame.size.height)];
    self.catalogTopView.cellTypeSelected = JACatalogCollectionViewGridCell;
    self.catalogTopView.delegate = self;
    [self.view addSubview:self.catalogTopView];
    self.catalogTopView.sortingButton.enabled = NO;
    self.catalogTopView.filterButton.enabled = NO;
    
    self.collectionViewTopConstraint.constant = self.catalogTopView.frame.size.height;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JACatalogBannerCell" bundle:nil] forCellWithReuseIdentifier:@"bannerCell"];
    [self.collectionView registerClass:[JACatalogListCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogListCollectionViewCell"];
    [self.collectionView registerClass:[JACatalogGridCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogGridCollectionViewCell"];
    [self.collectionView registerClass:[JACatalogPictureCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogPictureCollectionViewCell"];
    
    self.flowLayout = [[JAProductCollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 1.0f;
    self.flowLayout.minimumInteritemSpacing = 0.f;
    [self.flowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"horizontalSeparator"];
    [self.flowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"verticalSeparator"];
    
    //                                              top, left, bottom, right
    [self.flowLayout setSectionInset:UIEdgeInsetsMake(0.f, 0.0, 0.0, 0.0)];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
    self.sortingMethod = -1;
    [self.catalogTopView setSorting:RICatalogSortingPopularity];
    if (self.sortingMethodFromPush) {
        self.sortingMethod = [self.sortingMethodFromPush integerValue];
    }
    [self.catalogTopView setSorting:self.sortingMethod];
    [self.catalogTopView repositionForWidth:self.view.frame.size.width];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:JACatalogGridSelected]) {
        NSNumber* cellTypeSelected = [[NSUserDefaults standardUserDefaults] objectForKey:JACatalogGridSelected];
        self.catalogTopView.cellTypeSelected = [cellTypeSelected integerValue];
    }
}

- (void)getCategories {
    if(RIApiResponseSuccess == self.apiResponse || RIApiResponseMaintenancePage == self.apiResponse || RIApiResponseKickoutView == self.apiResponse) {
        [self showLoading];
    }
    
    [RICategory getAllCategoriesWithSuccessBlock:^(id categories) {
        self.apiResponse = RIApiResponseSuccess;
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        
        for (RICategory *category in categories) {
            if (self.categoryUrlKey.length) {
                if ([self.categoryUrlKey isEqualToString:category.urlKey]) {
                    self.category = category;
                    break;
                }
            }
        }
        
        if(self.category) {
            self.navBarLayout.title = self.category.label;
            self.productsArray = nil;
            [self loadMoreProducts];
        } else {
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

- (void)resetCatalog {
    self.productsArray = [NSMutableArray new];
    self.loadedEverything = NO;
}

- (void)addProductsToTable:(NSArray <RIProduct *>*)products {
    self.apiResponse = RIApiResponseSuccess;
    [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
    
    BOOL isEmpty = NO;
    if(!self.productsArray) {
        isEmpty = YES;
        self.productsArray = [NSMutableArray new];
    }
    
    if(products.count) {
        [self.productsArray addObjectsFromArray:products];
    }
    
    [self.collectionView reloadData];
    if(isEmpty) {
        [self.collectionView setContentOffset:CGPointZero animated:NO];
    }
}

- (void)loadMoreProducts {
    [self.filteredNoResultsView removeFromSuperview];
    [self.NoResultViewControllerContainer setHidden: YES];
    if(!self.isLoadingMoreProducts) {
        self.loadedEverything = NO;
        NSNumber *pageNumber = [NSNumber numberWithInteger:[self getCurrentPage] + 1];
        
        typedef void (^ProcessProductsBlock)(RICatalog *catalog);
        ProcessProductsBlock processProductsBlock = ^(RICatalog *catalog) {
            [self processCatalog:catalog];
        };
        
        typedef void (^ProcessProductsFailureBlock)(RIApiResponse apiResponse,  NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm);
        ProcessProductsFailureBlock processProductsFailureBlock = ^(RIApiResponse apiResponse,  NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm) {
            [self setLoadProductsError:apiResponse errorMessages:errorMessages undefSearchTerm:undefSearchTerm];
        };
        
        if (self.searchString.length) {
            // In case of this is a search
            if(RIApiResponseSuccess == self.apiResponse || RIApiResponseMaintenancePage == self.apiResponse || RIApiResponseKickoutView == self.apiResponse || RIApiResponseAPIError == self.apiResponse) {
                [self showLoading];
            }
            
            self.isLoadingMoreProducts = YES;
            
            self.searchSuggestionOperationID = [RISearchSuggestion getResultsForSearch:[self.searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                                                                  page:[pageNumber stringValue]
                                                                              maxItems:[NSString stringWithFormat:@"%ld",(long)self.maxProducts]
                                                                         sortingMethod:self.sortingMethod
                                                                               filters:self.filtersArray
                                                                          successBlock:processProductsBlock
                                                                       andFailureBlock:processProductsFailureBlock];
        } else {
            if (!self.loadedEverything) {
                if(RIApiResponseSuccess == self.apiResponse || RIApiResponseMaintenancePage == self.apiResponse || RIApiResponseKickoutView == self.apiResponse || RIApiResponseAPIError == self.apiResponse) {
                    [self showLoading];
                }
                
                self.isLoadingMoreProducts = YES;
                
                NSString* urlToUse = [RITarget getURLStringforTargetString:self.targetString];
                if (self.categoryName.length) {
                    urlToUse = [NSString stringWithFormat:@"%@%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_CATALOG_CATEGORY, self.categoryName];
                } else if (self.category && self.category.targetString.length) {
                    urlToUse = [RITarget getURLStringforTargetString:self.category.targetString];
                } else if (self.filterCategory && self.filterCategory.targetString.length) {
                    urlToUse = [RITarget getURLStringforTargetString:self.filterCategory.targetString];
                }
                
                self.getProductsOperationID = [RIProduct getProductsWithCatalogUrl:urlToUse
                                                                     sortingMethod:self.sortingMethod
                                                                              page:[pageNumber integerValue]
                                                                          maxItems:self.maxProducts
                                                                           filters:self.filtersArray
                                                                        filterPush:self.filterPush
                                                                      successBlock:processProductsBlock
                                                                   andFailureBlock:processProductsFailureBlock];
            }
        }
    }
}

- (void)processCatalog:(RICatalog *)catalog {
    [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
    
    self.searchSuggestionOperationID = nil;
    self.getProductsOperationID = nil;
    
    //To get the filters ((once)) in this viewController
    if (!self.filtersArray.count && catalog.filters.count) {
        self.filtersArray = catalog.filters;
        self.priceFilterIndex = catalog.priceFilterIndex;
        self.catalogTopView.filterButton.enabled = YES;
    }
    
    self.catalogTopView.sortingButton.enabled = YES;
    
    self.sortingMethod = [RICatalogSorting sortingEnum:catalog.sort];
    [self.catalogTopView setSorting:self.sortingMethod];
    
    self.banner = catalog.banner;
    
    if (self.banner) {
        [self.collectionView registerClass:[JACampaignBannerCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"bannerCell"];
        [self bannerImageView];
    }
    
    
    NSString *categoryName = @"";
    NSString *subCategoryName = @"";
    
    if(self.category) {
        if(self.category.parent) {
            RICategory *parent = self.category.parent;
            while (parent.parent) {
                parent = parent.parent;
            }
            categoryName = parent.label;
            subCategoryName = self.category.label;
        } else {
            categoryName = self.category.label;
        }
    } else {
        categoryName = self.navBarLayout.title;
    }
    
    if (catalog.title.length) {
        self.navBarLayout.title = catalog.title;
    } else if (categoryName.length) {
        self.navBarLayout.title = categoryName;
    }
    
    // Track events only in the first load of the products
    if (!self.isFirstLoadTracking) {
        self.isFirstLoadTracking = YES;
        
        if (self.searchString.length) {
            [self trackingEventSearchForString:self.searchString with:catalog.totalProducts];
            [self trackingEventLoadingTime];
        } else {
            NSMutableArray *productsToTrack = [[NSMutableArray alloc] init];
            for(RIProduct *product in catalog.products) {
                [productsToTrack addObject:[product sku]];
                if([productsToTrack count] == 3) {
                    break;
                }
            }
            
            RIProduct* firstProduct = [catalog.products firstObject];
            
            [self trackingEventViewListingForProducts:productsToTrack];
            
            [self trackingEventFacebookListeningForProductCategoryName:firstProduct.categoryName];
            
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
    
    if (0 == countInteger || countInteger < self.maxProducts || countInteger == self.productsArray.count) {
        self.loadedEverything = YES;
    }
    
    self.isLoadingMoreProducts = NO;
    [self hideLoading];
    
    //######################################
    fullPathCategory = catalog.breadcrumbs.fullPath;
    [EmarsysPredictManager sendTransactionsOf:self];
}

- (void)setLoadProductsError:(RIApiResponse) apiResponse  errorMessages:(NSArray *)errorMessages undefSearchTerm:(RIUndefinedSearchTerm *)undefSearchTerm {
    self.navBarLayout.subTitle = @"";
    [self reloadNavBar];
    
    self.apiResponse = apiResponse;
    self.getProductsOperationID = nil;
    
    if(self.productsArray.count) {
        [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(loadMoreProducts) objects:nil];
    } else {
        if(RIApiResponseAPIError == apiResponse) {
            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
            
            [self showNoResultsView:CGRectGetMaxY(self.catalogTopView.frame) undefinedSearchTerm:undefSearchTerm];
        } else {
            [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadMoreProducts) objects:nil];
        }
    }
    
    self.isLoadingMoreProducts = NO;
    [self hideLoading];
}

- (NSInteger)getCurrentPage {
    NSInteger currentPage = 0;
    if (self.productsArray.count) {
        currentPage = self.productsArray.count / self.maxProducts;
    }
    return currentPage;
}

#pragma mark - Actions

- (CGSize)getLayoutItemSizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
                    width = self.view.frame.size.width/2;
                    height = JACatalogViewControllerListCellHeight_ipad;
                    break;
                case JACatalogCollectionViewPictureCell:
                    width = self.view.frame.size.width/2;
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
                    width =  self.view.frame.size.width/3;
                    height = JACatalogViewControllerListCellHeight_ipad;
                    break;
                case JACatalogCollectionViewPictureCell:
                    width =  self.view.frame.size.width/3;
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

- (void)changeViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
    
    if(self.collectionView.superview) {
        self.numberOfCellsInScreen = [self getNumberOfCellsInScreenForInterfaceOrientation:interfaceOrientation];
        [self.collectionView reloadData];
    }
    
    [self trackingEventCatalog];
}

- (NSInteger)getNumberOfCellsInScreenForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
            } else {
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
            } else {
                return 5;
            }
            break;
    }
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.productsArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self getLayoutItemSizeForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.loadedEverything && self.productsArray.count - self.numberOfCellsInScreen <= indexPath.row) {
        [self loadMoreProducts];
    }
    
    RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
    
    JACatalogCollectionViewCell *cell;
    
    if ([self.cellIdentifier hasPrefix:@"grid"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JACatalogGridCollectionViewCell" forIndexPath:indexPath];
    } else if ([self.cellIdentifier hasPrefix:@"list"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JACatalogListCollectionViewCell" forIndexPath:indexPath];
    } else if ([self.cellIdentifier hasPrefix:@"picture"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JACatalogPictureCollectionViewCell" forIndexPath:indexPath];
    }
    
    cell.favoriteButton.tag = indexPath.row;
    [cell.favoriteButton addTarget:self
                            action:@selector(addToFavoritesPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    cell.feedbackView.tag = indexPath.row;
    [cell.feedbackView addTarget:self action:@selector(clickableViewPressedInCell:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell setProduct:product];
    
    [cell.sizeButton setHidden:YES];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader && _hasBanner) {
        
        JACampaignBannerCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"bannerCell" forIndexPath:indexPath];
        
        [cell loadWithImageView:self.bannerImageView];
        [cell.feedbackView addTarget:self action:@selector(clickableBannerPressed) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (_hasBanner) {
        return self.bannerImageView.frame.size;
    }
    return CGSizeMake(0, 0);
}

- (void)clickableBannerPressed {
    if(self.banner) {
        RITarget *target = [RITarget parseTarget:self.banner.targetString];
        JAScreenTarget *screenTarget = [[JAScreenTarget alloc] initWithTarget:target];
        if (self.banner.title.length) {
            [screenTarget.navBarLayout setTitle:self.banner.title];
        }
        [[ViewControllerManager centerViewController] openScreenTarget:screenTarget];
    }
}

- (void)clickableViewPressedInCell:(UIControl*)sender {
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
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
    } else {
        [self trackingEventScreenName:[NSString stringWithFormat:@"Search_%@",product.name]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication object:nil userInfo:userInfo];
}

#pragma mark - JAFiltersViewControllerDelegate

- (void)updatedFilters:(NSArray<BaseSearchFilterItem *>*)updatedFiltersArray {
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    
    BOOL filtersSelected = NO;
    if(updatedFiltersArray.count) {
        self.filtersArray = updatedFiltersArray;
        for(BaseSearchFilterItem *filter in self.filtersArray) {
            if (filter.uid.length) {
                if ([filter isKindOfClass:[SearchPriceFilter class]]) {
                    SearchPriceFilter* priceFilter = (SearchPriceFilter *)filter;
                    
                    if (priceFilter.lowerValue != priceFilter.minPrice || priceFilter.upperValue != priceFilter.maxPrice) {
                        
                        [self trackingEventIndividualFilter:filter.name];
                        
                        [trackingDictionary setObject:[NSString stringWithFormat:@"%ld-%ld", (long)priceFilter.lowerValue, (long)priceFilter.upperValue] forKey:kRIEventPriceFilterKey];
                        
                        filtersSelected = YES;
                    }
                    if (priceFilter.discountOnly) {
                        [trackingDictionary setObject:@1 forKey:kRIEventSpecialPriceFilterKey];
                        filtersSelected = YES;
                    }
                } else {
                    for (SearchFilterItemOption* filterOption in ((SearchFilterItem*)filter).options) {
                        if (filterOption.selected && VALID_NOTEMPTY(filterOption.name, NSString)) {
                            
                            [self trackingEventIndividualFilter:filter.name];
                            if([@"brand" isEqualToString:filter.uid]) {
                                if ([trackingDictionary objectForKey:kRIEventBrandFilterKey]) {
                                    [trackingDictionary setObject:[NSString stringWithFormat:@"%@,%@", [trackingDictionary objectForKey:kRIEventBrandFilterKey], filterOption.name] forKey:kRIEventBrandFilterKey];
                                } else {
                                    [trackingDictionary setObject:filterOption.name forKey:kRIEventBrandFilterKey];
                                }
                            } else if([@"color_family" isEqualToString:filter.uid]) {
                                if ([trackingDictionary objectForKey:kRIEventColorFilterKey]) {
                                    [trackingDictionary setObject:[NSString stringWithFormat:@"%@,%@", [trackingDictionary objectForKey:kRIEventColorFilterKey], filterOption.name] forKey:kRIEventColorFilterKey];
                                } else {
                                    [trackingDictionary setObject:filterOption.name forKey:kRIEventColorFilterKey];
                                }
                            } else if([@"size" isEqualToString:filter.uid]) {
                                if ([trackingDictionary objectForKey:kRIEventSizeFilterKey]) {
                                    [trackingDictionary setObject:[NSString stringWithFormat:@"%@,%@", [trackingDictionary objectForKey:kRIEventSizeFilterKey], filterOption.name] forKey:kRIEventSizeFilterKey];
                                } else {
                                    [trackingDictionary setObject:filterOption.name forKey:kRIEventSizeFilterKey];
                                }
                            } else if([@"category" isEqualToString:filter.uid]) {
                                if ([trackingDictionary objectForKey:kRIEventCategoryFilterKey]) {
                                    [trackingDictionary setObject:[NSString stringWithFormat:@"%@,%@", [trackingDictionary objectForKey:kRIEventCategoryFilterKey], filterOption.name] forKey:kRIEventCategoryFilterKey];
                                } else {
                                    [trackingDictionary setObject:filterOption.name forKey:kRIEventCategoryFilterKey];
                                }
                            }
                            
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

- (void)subCategorySelected:(NSString *)subCategoryUrlKey {
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:@{@"category_url_key":subCategoryUrlKey}];
}

#pragma mark - kProductChangedNotification
- (void)updatedProduct:(NSNotification *)notification {
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
        
    } else if (VALID_NOTEMPTY(notification.object, NSString)) {
        NSString* sku = notification.object;
        int i = 0;
        for(; i < self.productsArray.count; i++) {
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
    } else {
        return;
    }
    [self.collectionView reloadData];
}

#pragma mark - JACatalogTopViewDelegate
- (void)filterButtonPressed {
    [self performSegueWithIdentifier: @"showFilterView" sender:nil];
}

- (void)sortingButtonPressed {
    [self.sortingView removeFromSuperview];
    self.sortingView = [[JASortingView alloc] init];
    self.sortingView.delegate = self;
    UIView* windowView = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;
    [self.sortingView setupWithFrame:windowView.bounds selectedSorting:self.sortingMethod];
    [windowView addSubview:self.sortingView];
    [self.sortingView animateIn];
}

- (void)viewModeChanged {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.catalogTopView.cellTypeSelected] forKey:JACatalogGridSelected];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.flowLayout resetSizes];
    [self changeViewToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)navBarClicked {
    NSInteger numberOfCells = [self collectionView:self.collectionView numberOfItemsInSection:0];
    if (VALID_NOTEMPTY(self.collectionView, UICollectionView) && numberOfCells > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Button actions
- (void)addToFavoritesPressed:(UIButton*)button {
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    if (!button.selected && !VALID_NOTEMPTY(product.favoriteAddDate, NSDate))
    {
        [self addToFavorites:button];
    }else if (button.selected && VALID_NOTEMPTY(product.favoriteAddDate, NSDate))
    {
        [self removeFromFavorites:button];
    }
}

- (BOOL)isUserLoggedInWithBlock:(ProcessActionBlock)block {
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

- (void)addToFavorites:(UIButton *)button {
    //[self showLoading];
    
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
    if (!button.selected && !VALID_NOTEMPTY(product.favoriteAddDate, NSDate)) {
        [[ProductDataManager sharedInstance] addToFavorites:self sku:product.sku completion:^(id data, NSError *error) {
            if(error == nil) {
                //EVENT: ADD TO FAVORITES
                [TrackerManager postEvent:[EventFactory addToFavorites:product.categoryUrlKey success:YES] forName:[AddToFavoritesEvent name]];
                
                button.selected = YES;
                product.favoriteAddDate = [NSDate date];
                
                [self trackingEventAddToWishList:product];
                
                [self onSuccessResponse:RIApiResponseSuccess messages:[self extractSuccessMessages:data] showMessage:YES];
                //[self hideLoading];
                
                NSDictionary *userInfo = nil;
                if (product.favoriteAddDate) {
                    userInfo = [NSDictionary dictionaryWithObject:product.favoriteAddDate forKey:@"favoriteAddDate"];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kProductChangedNotification object:product.sku userInfo:userInfo];
                
                [self.collectionView reloadData];
            } else {
                [self onErrorResponse:error.code messages:[error.userInfo objectForKey:kErrorMessages] showAsMessage:YES selector:@selector(addToFavorites:) objects:@[button]];
                //[self hideLoading];
                
                //EVENT: ADD TO FAVORITES
                [TrackerManager postEvent:[EventFactory addToFavorites:product.categoryUrlKey success:NO] forName:[AddToFavoritesEvent name]];
            }
        }];
    }
}

- (void)removeFromFavorites:(UIButton *)button {
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
    if (button.selected && VALID_NOTEMPTY(product.favoriteAddDate, NSDate)) {
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
            [self onErrorResponse:apiResponse messages:error showAsMessage:YES selector:@selector(removeFromFavorites:) objects:@[button]];
            [self hideLoading];
        }];
    } else {
        [self hideLoading];
    }
}

#pragma mark - Add the undefined search view

- (void)addUndefinedSearchView:(RIUndefinedSearchTerm *)undefSearch frame:(CGRect)frame {
    self.undefinedView = [[JAUndefinedSearchView alloc] initWithFrame:frame];
    self.undefinedView.delegate = self;
    
    // Remove the existent components
    [self.catalogTopView removeFromSuperview];
    [self.collectionView removeFromSuperview];
    
    // Build and add the new view
    [self.view addSubview:self.undefinedView];
    
    [self.undefinedView setupWithUndefinedSearchResult:undefSearch
                                            searchText:self.searchString
                                           orientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

#pragma mark - Undefined view delegate

- (void)didSelectProduct:(NSString *)productTargetString {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"fromCatalog"];
    [userInfo setObject:self forKey:@"delegate"];
    if(productTargetString.length) {
        [userInfo setObject:productTargetString forKey:@"targetString"];
    }
    if(self.category) {
        [userInfo setObject:self.category forKey:@"category"];
        if(self.category.label.length) {
            [userInfo setObject:self.category.label forKey:@"previousCategory"];
        } else {
            [userInfo setObject:STRING_BACK forKey:@"previousCategory"];
        }
    } else {
        [userInfo setObject:STRING_BACK forKey:@"previousCategory"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication object:nil userInfo:userInfo];
}

- (void)didSelectBrandTargetString:(NSString *)brandTargetString brandName:(NSString *)brandName {
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(98),
                                                                 @"name": brandName,
                                                                 @"targetString": brandTargetString }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    if (self.undefinedBackup){
        
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
- (void)selectedSortingMethod:(RICatalogSortingEnum)catalogSorting {
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

- (void)killScroll {
    CGPoint offset = self.collectionView.contentOffset;
    offset.y -= .1;
    [self.collectionView setContentOffset:offset animated:YES];
    offset.y += .1;
    [self.collectionView setContentOffset:offset animated:YES];
}

#pragma mark - Tracking events
- (void)trackingEventFilter:(NSMutableDictionary *)trackingDictionary {
    NSString* url = [RITarget getURLStringforTargetString:self.targetString];
    [trackingDictionary setValue:url forKey:kRIEventLabelKey];
    [trackingDictionary setValue:STRING_FILTERS forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFilter] data:[trackingDictionary copy]];
}

- (void)trackingEventIndividualFilter:(NSString *)filterName {
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventIndividualFilter] data:[NSDictionary dictionaryWithObject:filterName forKey:kRIEventFilterTypeKey]];
}

- (void)trackingEventCatalog {
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
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCatalog] data:[trackingDictionary copy]];
}

- (void)trackingEventLoadingTime {
    [self publishScreenLoadTime];
}

- (void)trackingEventScreenName:(NSString *)screenName {
    [[RITrackingWrapper sharedInstance] trackScreenWithName:screenName];
}

- (void)trackingEventAddToWishList:(RIProduct *)product {
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
    [trackingDictionary setValue:product.brand forKey:kRIEventBrandName];
    [trackingDictionary setValue:product.brandUrlKey forKey:kRIEventBrandKey];
    
    NSString *discountPercentage = @"0";
    if(product.maxSavingPercentage.length) {
        discountPercentage = product.maxSavingPercentage;
    }
    [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
    [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventLocationKey];
    
    NSString *categoryName = @"";
    NSString *subCategoryName = @"";
    if(self.category) {
        if(self.category.parent) {
            RICategory *parent = self.category.parent;
            while (parent.parent) {
                parent = parent.parent;
            }
            categoryName = parent.label;
            subCategoryName = self.category.label;
        } else {
            categoryName = self.category.label;
        }
    } else if(product.categoryIds.count) {
        NSArray *categoryIds = product.categoryIds;
        NSInteger subCategoryIndex = [categoryIds count] - 1;
        NSInteger categoryIndex = subCategoryIndex - 1;
        
        if(categoryIndex >= 0) {
            NSString *categoryId = [categoryIds objectAtIndex:categoryIndex];
            categoryName = [RICategory getCategoryName:categoryId];
            
            NSString *subCategoryId = [categoryIds objectAtIndex:subCategoryIndex];
            subCategoryName = [RICategory getCategoryName:subCategoryId];
        } else {
            NSString *categoryId = [categoryIds objectAtIndex:subCategoryIndex];
            categoryName = [RICategory getCategoryName:categoryId];
        }
    }
    
    if(categoryName.length) {
        [trackingDictionary setValue:categoryName forKey:kRIEventCategoryIdKey];
    }
    
    if(subCategoryName.length) {
        [trackingDictionary setValue:subCategoryName forKey:kRIEventSubCategoryIdKey];
    }
    
    if (product.categoryName.length) {
        [trackingDictionary setValue:product.categoryName forKey:kRIEventCategoryNameKey];
    }
    
    if (product.categoryUrlKey.length) {
        [trackingDictionary setValue:product.categoryUrlKey forKey:kRIEventCategoryIdKey];
    }
    
    [trackingDictionary setValue:product.name forKey:kRIEventProductNameKey];
    
    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages) {
        [trackingDictionary setValue:[NSNumber numberWithInteger:favoriteProducts.count] forKey:kRIEventTotalWishlistKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToWishlist] data:[trackingDictionary copy]];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToWishlist] data:[trackingDictionary copy]];
    }];
}

- (void)trackingEventRemoveFromWishlist:(RIProduct *)product {
    NSNumber *price = (product.specialPriceEuroConverted && [product.specialPriceEuroConverted floatValue] > 0.0f) ? product.specialPriceEuroConverted : product.priceEuroConverted;
    
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
    
    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages) {
        
        [trackingDictionary setValue:[NSNumber numberWithInteger:favoriteProducts.count] forKey:kRIEventTotalWishlistKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                  data:[trackingDictionary copy]];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                  data:[trackingDictionary copy]];
    }];
}

- (void)trackingEventSort {
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:self.title forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"SortingOnCatalog" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:[RICatalogSorting sortingName:self.sortingMethod] forKey:kRIEventSortTypeKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSort] data:[trackingDictionary copy]];
}

- (void)trackingEventSearchForString:(NSString *)string with:(NSNumber *)numberOfProducts {
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
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSearch] data:[trackingDictionary copy]];
}

- (void)trackingEventGTMListingForCategoryName:(NSString *)categoryName andSubCategoryName:(NSString *)subCategoryName {
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(categoryName, NSString)) {
        [trackingDictionary setValue:categoryName forKey:kRIEventCategoryIdKey];
    }
    if(VALID_NOTEMPTY(subCategoryName, NSString)) {
        [trackingDictionary setValue:subCategoryName forKey:kRIEventSubCategoryIdKey];
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

- (void)trackingEventViewListingForProducts:(NSArray *)productsToTrack {
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

- (void)trackingEventFacebookListeningForProductCategoryName:(NSString *)categoryName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    
    if (VALID_NOTEMPTY(categoryName, NSString)) {
        [trackingDictionary setValue:categoryName forKey:kRIEventFBContentCategory];
    }
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewListing]
                                              data:[trackingDictionary copy]];
    
}


#pragma segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"embedCatalogNoResult"]) {
        self.NoResultViewController = (CatalogNoResultViewController *) [segue destinationViewController];
    }
    
    if ([segueName isEqualToString: @"showFilterView"]) {
        
        JAFiltersViewController *destinationViewCtrl =  [segue destinationViewController];
        destinationViewCtrl.filtersArray = self.filtersArray ?: @[];
        destinationViewCtrl.subCatsFilter = subCatFilter;
        destinationViewCtrl.priceFilterIndex = self.priceFilterIndex;
        destinationViewCtrl.delegate = self;
        
    }
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    if (self.searchString.length) {
        return @"SearchSuggester";
    } else if(self.category) {
        return [NSString stringWithFormat:@"Catalog / %@", self.category.label];
    } else {
        return @"Catalog";
    }
}

-(NSString *)getPerformanceTrackerLabel {
    if (self.searchString.length) {
        return [self.searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    } else {
        NSString* urlToUse = [RITarget getURLStringforTargetString:self.targetString];
        if (self.categoryName.length) {
            urlToUse = [NSString stringWithFormat:@"%@%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_CATALOG_CATEGORY, self.categoryName];
        } else if (self.category && self.category.targetString.length) {
            urlToUse = [RITarget getURLStringforTargetString:self.category.targetString];
        } else if (self.filterCategory && self.filterCategory.targetString.length) {
            urlToUse = [RITarget getURLStringforTargetString:self.filterCategory.targetString];
        }
        
        return urlToUse;
    }
}

#pragma mark - EmarsysPredictProtocol
- (EMTransaction *)getDataCollection:(EMTransaction *)transaction {
    if (self.searchString.length) {
        [transaction setSearchTerm:self.searchString];
    }
    if (fullPathCategory) {
        [transaction setCategory:fullPathCategory];
    }
    return transaction;
}

- (BOOL)isPreventSendTransactionInViewWillAppear {
    return YES;
}

#pragma mark - EmarsysPredictProtocol
- (NSArray<EMRecommendationRequest *> *)getRecommendations {
    
    EMRecommendationRequest *recommend = [EMRecommendationRequest requestWithLogic:@"SEARCH"];
    recommend.limit = 15;
    
    [recommend excludeItemsWhere:@"item" isIn:[self.productsArray map:^id(RIProduct *item) {
        return item.sku;
    }]];
    
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
        [result.products map:^id(EMRecommendationItem *item) {
            return [RecommendItem instanceWithEMRecommendationItem:item];
        }];
    };
    
    return @[recommend];
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    return;
}

#pragma mark - Helper Methods
- (void)getSubcategories {
    [[DataManager sharedInstance] getSubCategoriesFilter:nil ofCategroyUrlKey:self.categoryUrlKey completion:^(id data, NSError *error) {
        subCatFilter = data;
    }];
}

@end

//
//  JAPDVViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVViewController.h"
#import "JAPDVVariations.h"
#import "JAPDVProductInfo.h"
#import "JAPDVRelatedItem.h"
#import "JAPDVSingleRelatedItem.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+JA.h"
#import "RIImage.h"
#import "RIVariation.h"
#import "RICart.h"
#import "RIProductSimple.h"
#import "JAPicker.h"
#import "JAPDVGallery.h"
#import "RIProductRatings.h"
#import "JANewRatingViewController.h"
#import "JAAppDelegate.h"
#import "JAActivityViewController.h"
#import "RICountry.h"
#import "JAUtils.h"
#import "RICustomer.h"
#import "JAPDVWizardView.h"
#import "JAPDVBundles.h"
#import "JAPDVBundleSingleItem.h"
#import "RIProduct.h"
#import "JAOtherOffersView.h"
#import "JBWhatsAppActivity.h"
#import "JAProductInfoHeaderLine.h"
#import "RIAddress.h"
#import "JABottomBar.h"
#import "RISeller.h"
#import "JACenterNavigationController.h"
#import "JATabBarButton.h"

//##########################
#import "ViewControllerManager.h"
#import "EmarsysPredictManager.h"
#import "CartDataManager.h"
#import "NSArray+Extension.h"
#import "EmarsysRecommendationGridWidgetView.h"
#import "ThreadManager.h"
#import "Bamilo-Swift.h"

typedef void (^ProcessActionBlock)(void);

@interface JAPDVViewController () <JAPDVGalleryDelegate, JAPickerDelegate, JAActivityViewControllerDelegate, FeatureBoxCollectionViewWidgetViewDelegate> {
    BOOL _needRefreshProduct;
    BOOL _needAddToFavBlock;
    ProcessActionBlock _processActionBlock;
    EmarsysRecommendationGridWidgetView *_recommendationView;
}

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UIScrollView *landscapeScrollView;
@property (strong, nonatomic) RIProductRatings *productRatings;
@property (strong, nonatomic) JAPDVImageSection *productImageSection;
@property (strong, nonatomic) JAPDVVariations *variationsSection;
@property (strong, nonatomic) JAPDVProductInfo *productInfoSection;
@property (strong, nonatomic) JAPDVRelatedItem *relatedItemsView;
@property (strong, nonatomic) JAPDVBundles *bundleLayout;
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (strong, nonatomic) JAPDVGallery *galleryPaged;
@property (strong, nonatomic) JABottomBar *ctaView;
@property (assign, nonatomic) NSInteger commentsCount;
@property (assign, nonatomic) BOOL openPickerFromCart;
@property (assign, nonatomic) BOOL viewLoaded;
@property (strong, nonatomic) RIProductSimple *currentSimple;
//$WIZ$
//@property (nonatomic, strong) JAPDVWizardView* wizardView;
@property (assign, nonatomic) RIApiResponse apiResponse;

@property (strong, nonatomic) RIBundle *productBundle;
@property (strong, nonatomic) NSMutableArray *bundleSingleItemsArray;
@property (nonatomic, strong) JAOtherOffersView* otherOffersView;
@property (nonatomic, assign) NSInteger indexOfBundleRelatedToSizePicker;
@property (nonatomic) NSMutableDictionary *selectedBundles;

@property (nonatomic, assign) BOOL hasLoaddedProduct;

@property (strong, nonatomic) UIPopoverController *currentPopoverController;
@property (strong, nonatomic) RICart *cart;
@property (strong, nonatomic) NSArray<RecommendItem *> *recommendItems;
@end

static NSString *recommendationLogic = @"RELATED";

@implementation JAPDVViewController


@synthesize selectedBundles = _selectedBundles;
@synthesize viewLoaded = _viewLoaded;

- (JAPDVImageSection *)productImageSection {
    if (!_productImageSection) {

        _productImageSection = [[JAPDVImageSection alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 500)];
        _productImageSection.delegate = self;
        [_productImageSection.wishListButton addTarget:self action:@selector(wishListButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    _productImageSection.wishListButton.selected = (self.product.favoriteAddDate != nil);
    return _productImageSection;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.apiResponse = RIApiResponseSuccess;

    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.mainScrollView setHidden:YES];
    [self.view addSubview:self.mainScrollView];

    self.landscapeScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.landscapeScrollView setHidden:YES];
    [self.view addSubview:self.landscapeScrollView];
    
    //regiter notifications
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationDidEnterBackgroundNotification:) name: UIApplicationDidEnterBackgroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedProduct:) name:kProductChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedProduct:) name:kUserLoggedInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedProduct:) name:kUserLoggedOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWishList:) name:kUpdateWishListNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.hasLoaddedProduct) {
        if (self.targetString.length || self.productSku.length) {
            [self loadCompleteProduct];
        } else {
            [self trackingEventLoadingTime];
        }
    }
    if (_needAddToFavBlock) {
        if (_processActionBlock) {
            _processActionBlock();
        }
    }
    [self updateCartInNavBar];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self trackingEventScreenName:@"ShopProductDetail"];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification*)notification {
    if(self.currentPopoverController) {
        [self.currentPopoverController dismissPopoverAnimated:NO];
    }

    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if(self.currentPopoverController) {
        [self.currentPopoverController dismissPopoverAnimated:NO];
    }

    [self.mainScrollView setHidden:YES];
    [self.landscapeScrollView setHidden:YES];
    [self.ctaView setHidden:YES];


    if (self.picker) {
        [self closePicker];
    }

    if(self.galleryPaged) {
        UIView *gallerySuperView = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;

        CGFloat width = gallerySuperView.frame.size.height;
        CGFloat height = gallerySuperView.frame.size.width;

        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            if(width < height) {
                width = gallerySuperView.frame.size.width;
                height = gallerySuperView.frame.size.height;
            }
        } else {
            if(width > height) {
                width = gallerySuperView.frame.size.width;
                height = gallerySuperView.frame.size.height;
            }
        }

        [self.galleryPaged reloadFrame:CGRectMake(0.0f, 0.0f, width, height)];
    }

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         [self fillTheViews];
         if(self.galleryPaged) {
             UIView *gallerySuperView = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;

             CGFloat width = gallerySuperView.frame.size.width;
             CGFloat height = gallerySuperView.frame.size.height;
             CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;

             if(UIInterfaceOrientationIsLandscape(orientation)) {
                 if(width < height) {
                     width = gallerySuperView.frame.size.height;
                     height = gallerySuperView.frame.size.width;
                 }
                 if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
                 }
             } else {
                 if(width > height) {
                     width = gallerySuperView.frame.size.height;
                     height = gallerySuperView.frame.size.width;
                 }
             }

             [self.galleryPaged reloadFrame:CGRectMake(0.0f, statusBarHeight, width, height)];
             [self.view bringSubviewToFront:self.galleryPaged];
         }

     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
     }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void) removeSuperviews {
    [self.mainScrollView setHidden:YES];
    [self.landscapeScrollView setHidden:YES];
    for(UIView *subView in self.mainScrollView.subviews) {
        [subView removeFromSuperview];
    }
    if(self.landscapeScrollView) {
        for(UIView *subView in self.landscapeScrollView.subviews) {
            [subView removeFromSuperview];
        }
    }
    if (self.ctaView) {
        [self.ctaView removeFromSuperview];
    }
}

#pragma mark - Product methods
- (void)updatedProduct:(NSNotification*)notification {
    if (VALID_NOTEMPTY(notification.object, NSArray)) {
        for (id object in notification.object) {
            if (VALID_NOTEMPTY(object, NSString) && [object isEqualToString:self.productSku]) {
                self.product.favoriteAddDate = [NSDate new];
                _needRefreshProduct = YES;
                break;
            }
        }
    }
    if (VALID_NOTEMPTY(notification.object, NSString) && [self.productSku isEqualToString:notification.object]) {
        _needRefreshProduct = YES;
    }
}

- (void)updateWishList:(NSNotification *)notification {
    //TODO: THIS view is a total shit!! 
    Product *product = [[notification userInfo] objectForKey:@"NOTIFICATION_UPDATE_PRODUCT_VALUE"];
    BOOL isInWishList = [((NSNumber *)[[notification userInfo] objectForKey:@"NOTIFICATION_UPDATE_BOOL_VALUE"]) boolValue];
    
    if ([product.sku isEqualToString: self.product.sku]) {
        self.product.favoriteAddDate = isInWishList ? [NSDate new] : nil;
        [self.productImageSection.wishListButton setSelected:isInWishList];
    }
}

- (void)loadCompleteProduct {
    if(self.apiResponse == RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess) {
        [self showLoading];
    }
    self.hasLoaddedProduct = NO;
    NSDictionary *richParameter;
    if (VALID_NOTEMPTY(self.richRelevanceParameter, NSString)) {
        richParameter = [NSDictionary dictionaryWithObject:self.richRelevanceParameter forKey:@"rich_parameter"];
    } else {
        richParameter = nil;
    }

    if (VALID_NOTEMPTY(self.targetString, NSString)) {
        [RIProduct getCompleteProductWithTargetString:self.targetString
                                    withRichParameter:richParameter
                                         successBlock:^(id product) {
                                             _needRefreshProduct = NO;
                                             self.apiResponse = RIApiResponseSuccess;
                                             [self loadedProduct:product];
                                             [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                                         } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                             self.apiResponse = apiResponse;
                                                 [self trackingEventLoadingTime];
                                             [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadCompleteProduct) objects:nil];
                                             [self hideLoading];
                                         }];
    } else if (VALID_NOTEMPTY(self.productSku, NSString)) {
        [RIProduct getCompleteProductWithSku:self.productSku
                                successBlock:^(id product) {
                                    self.apiResponse = RIApiResponseSuccess;

                                    [self loadedProduct:product];
                                    [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                                } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                    self.apiResponse = apiResponse;
                                    [self trackingEventLoadingTime];

                                    [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadCompleteProduct) objects:nil];

                                    [self hideLoading];
                                }];
    }
}


- (void)loadedProduct:(RIProduct*) product {
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];

    self.product = product;
    self.productSku = product.sku;

    [self trackingEventViewProduct:product];
    [self trackingEventLoadingTime];

    [RIRecentlyViewedProductSku addToRecentlyViewed:product successBlock:^{
        [self requestBundles];
    } andFailureBlock:nil];

    NSDictionary *userInfo = nil;
    if (self.product.favoriteAddDate) {
        userInfo = [NSDictionary dictionaryWithObject:self.product.favoriteAddDate forKey:@"favoriteAddDate"];
    }

    [self trackingEventMostViewedBrand];
    
//###################
    //EVENT : VIEW PRODUCT
    NSUInteger lenght = self.navigationController.viewControllers.count;
    UIViewController<DataTrackerProtocol> *previousViewController = self.navigationController.viewControllers[lenght - 2];
    
    [TrackerManager postEventWithSelector:[EventSelectors viewProductSelector]
                               attributes:[EventAttributes viewProductWithParentViewScreenName:[previousViewController getScreenName] product:product]];
}

- (void)retryAddToCart {
    [self addToCart];
}

#pragma mark - Product loaded
- (void)productLoaded {
    [self removeSuperviews];

    self.hasLoaddedProduct = YES;

    [self.mainScrollView setFrame:[self viewBounds]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
            CGRect bounds = [self viewBounds];
            CGFloat scrollViewsWidth = bounds.size.width / 2;
            [self.mainScrollView setFrame:CGRectMake(scrollViewsWidth, bounds.origin.y, scrollViewsWidth, bounds.size.height)];
            [self.mainScrollView setHidden:NO];

            [self.landscapeScrollView setFrame:CGRectMake(bounds.origin.x, bounds.origin.y, scrollViewsWidth, bounds.size.height)];
            [self.landscapeScrollView setHidden:NO];
        } else {
            [self.mainScrollView setHidden:NO];
            [self.landscapeScrollView setHidden:YES];
        }
    } else {
        [self.mainScrollView setHidden:NO];
        [self.landscapeScrollView setHidden:YES];
    }

    /*******
     CTA Buttons
     *******/
    self.ctaView = [[JABottomBar alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, kBottomDefaultHeight)];
    BOOL isiPadInLandscape = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
            isiPadInLandscape = YES;
        }
    }
    [self.ctaView setFrame:CGRectMake(self.mainScrollView.x,
                                      self.view.frame.size.height - self.ctaView.frame.size.height,
                                      self.mainScrollView.frame.size.width,
                                      self.ctaView.frame.size.height)];
    [self.view addSubview:self.ctaView];
    [self.ctaView setYBottomAligned:0.f];
    self.mainScrollView.height -= self.ctaView.height;

    [[self.ctaView addSmallButton:[UIImage imageNamed:@"btn_share"] target:self action:@selector(shareProduct)] setBackgroundColor:[Theme color:kColorExtraDarkBlue]];
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] || [[device model] isEqualToString:@"iPhone Simulator"]) {
        [[self.ctaView addSmallButton:[UIImage imageNamed:@"ic_calltoorder"] target:self action:@selector(callToOrder)] setBackgroundColor:[Theme color:kColorExtraDarkBlue]];
    }

    if (!self.product.hasStock) {
        JAButton *saveButton = [self.ctaView addAlternativeButton:STRING_SAVE_ITEM target:self action:@selector(addToWishList)];
        [saveButton setTitleColor:JAOrange1Color forState:UIControlStateNormal];
    } else if (self.product.preOrder) {
        JAButton *button = [self.ctaView addButton:STRING_PRE_ORDER target:self action:@selector(addToCart)];
        [button setBackgroundColor:[Theme color:kColorOrange1]];
    } else {
        JAButton *button = [self.ctaView addButton:STRING_BUY_NOW target:self action:@selector(addToCart)];
        [button setBackgroundColor:[Theme color:kColorOrange1]];
    }
    [self.view bringSubviewToFront:self.picker];
}

- (void)requestBundles {
    //fill the views
    [RIProduct getBundleWithSku:self.product.sku successBlock:^(RIBundle* bundle) {
                       self.productBundle = bundle;
                       _viewLoaded = TRUE;
                       [self fillTheViews];
                       [self hideLoading];
                   } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                       self.productBundle = nil;
                       _viewLoaded = TRUE;
                       [self fillTheViews];
                       [self.bundleLayout removeFromSuperview];
                       [self hideLoading];
                   }];

}

- (void)setProductBundle:(RIBundle *)productBundle {
    _productBundle = productBundle;
    if (!VALID(self.selectedBundles, NSMutableDictionary)) {
        self.selectedBundles = [[NSMutableDictionary alloc]init];

        for (RIProduct* pd in productBundle.bundleProducts) {
            [self.selectedBundles setObject:[pd.productSimples firstObject] forKey:pd.sku];
        }
    }
}

#pragma mark - Fill the views

- (void)fillTheViews {
    if (self.product == nil) {
        return;
    }
    [self productLoaded];
    CGFloat scrollViewY = .0f;
    CGFloat landscapeScrollViewY = 0.0f;
    BOOL isiPadInLandscape = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
            isiPadInLandscape = YES;
        }
    }
    /*******
     Image Section
     *******/
    self.productImageSection.frame = CGRectMake(0.0f, scrollViewY, self.productImageSection.frame.size.width, self.productImageSection.frame.size.height);
    CGRect imageSectionFrame = self.mainScrollView.bounds;
    [self.productImageSection setupWithFrame:imageSectionFrame product:self.product preSelectedSize:self.preSelectedSize];
    if (self.product.seller && [self.product.seller isGlobal]) {
        [self.productImageSection addGlobalButtonTarget:self action:@selector(showSeller)];
    }
    if(isiPadInLandscape) {
        [self.landscapeScrollView addSubview:self.productImageSection];
        landscapeScrollViewY = CGRectGetMaxY(self.productImageSection.frame) + 6.0f;
    } else {
        [self.mainScrollView addSubview:self.productImageSection];
        scrollViewY = CGRectGetMaxY(self.productImageSection.frame) + 6.0f;
    }

    if (self.product.variations.count) {
        self.variationsSection = [JAPDVVariations getNewPDVVariationsSection];
        [self.variationsSection setupWithFrame:self.mainScrollView.frame];
    }

    /*******
     Product Info Section
     *******/

    self.productInfoSection = [[JAPDVProductInfo alloc] init];
    CGRect productInfoSectionFrame = CGRectMake(0, 6, self.mainScrollView.width, 0);
    [self.productInfoSection setupWithFrame:productInfoSectionFrame product:self.product preSelectedSize:self.preSelectedSize];
    if (self.currentSimple) {
        [self.productInfoSection setSpecialPrice:self.currentSimple.specialPriceFormatted andPrice:self.currentSimple.priceFormatted andMaxSavingPercentage:self.product.maxSavingPercentage shouldForceFlip:NO];
    }
    [self.productInfoSection addReviewsTarget:self action:@selector(goToReviews)];
    [self.productInfoSection addSpecificationsTarget:self action:@selector(goToSpecifications)];
    [self.productInfoSection addDescriptionTarget:self action:@selector(goToDescription)];
    [self.productInfoSection addSellerCatalogTarget:self action:@selector(goToSellerCatalog)];
    [self.productInfoSection addSellerLinkTarget:self action:@selector(goToSellerLink)];
    [self.productInfoSection addSizeTarget:self action:@selector(showSizePicker)];
    [self.productInfoSection addVariationsTarget:self action:@selector(goToVariationsScreen)];
    [self.productInfoSection addOtherOffersTarget:self action:@selector(goToOtherSellersScreen)];
    [self.productInfoSection addSisTarget:self action:@selector(goToSisScreen)];
    [self.productInfoSection setY:scrollViewY];
    [self.mainScrollView addSubview:self.productInfoSection];

    scrollViewY += (self.productInfoSection.frame.size.height);

    /*******
     Bundles
     *******/

    [self.bundleLayout removeFromSuperview];
    for (UIView *subview in [self.bundleLayout subviews]) {
        [subview removeFromSuperview];
    }

    if (self.productBundle) {
        CGFloat bundleSingleItemStart = 5.0f;
        self.bundleSingleItemsArray = [NSMutableArray new];

        for(int i= 0; i<self.productBundle.bundleProducts.count; i++) {
            RIProduct *bundleProduct = [self.productBundle.bundleProducts objectAtIndex:i];
            JAPDVBundleSingleItem* bundleSingleItem = [JAPDVBundleSingleItem getNewPDVBundleSingleItem];
            bundleSingleItem.selectedProduct.tag = i;
            NSString* checkmarkImageName = @"selectionCheckmark";
            if (0 == i) {
                checkmarkImageName = @"selectionCheckmarkDisabled";
            }
            [bundleSingleItem.selectedProduct setImage:[UIImage imageNamed:@"noSelectionCheckMark"] forState:UIControlStateNormal];
            [bundleSingleItem.selectedProduct setImage:[UIImage imageNamed:checkmarkImageName] forState:UIControlStateSelected];
            [self.bundleSingleItemsArray addObject:bundleSingleItem];
            [bundleSingleItem.selectedProduct addTarget:self action:@selector(checkBundle:) forControlEvents:UIControlEventTouchUpInside];

            CGRect tempFrame = bundleSingleItem.frame;
            tempFrame.origin.x = bundleSingleItemStart;
            bundleSingleItem.frame = tempFrame;

            if (bundleProduct.images.count) {
                RIImage *imageTemp = [bundleProduct.images firstObject];
                [bundleSingleItem.productImageView sd_setImageWithURL:[NSURL URLWithString:imageTemp.url] placeholderImage:[UIImage imageNamed:@"placeholder_scrollable"]];
            }

            bundleSingleItem.productNameLabel.text = bundleProduct.name;
            bundleSingleItem.productTypeLabel.text = bundleProduct.brand;
            if (VALID_NOTEMPTY(bundleProduct.specialPrice, NSNumber) && 0.0f == [bundleProduct.specialPrice floatValue]) {
                bundleSingleItem.productPriceLabel.text = bundleProduct.priceFormatted;
            } else {
                bundleSingleItem.productPriceLabel.text = bundleProduct.specialPriceFormatted;
            }
            bundleSingleItem.product = bundleProduct;

            if ( 0 == i ) {
                //always selected
                bundleSingleItem.alwaysSelected = YES;
            }

            BOOL isSelected = YES;
            if (VALID_NOTEMPTY(self.selectedBundles, NSMutableDictionary)) {
                isSelected = NO;
                if ([self.selectedBundles objectForKey:bundleSingleItem.product.sku]) {
                    RIProductSimple* ps = [self.selectedBundles objectForKey:bundleSingleItem.product.sku];
                    isSelected = YES;
                    if(VALID_NOTEMPTY(ps, RIProductSimple)) {
                        bundleSingleItem.productSimple = ps;
                        if (0.0f == [ps.specialPrice floatValue]) {
                            bundleSingleItem.productPriceLabel.text = ps.priceFormatted;
                        } else {
                            bundleSingleItem.productPriceLabel.text = ps.specialPriceFormatted;
                        }
                    }
                }
            }
            bundleSingleItem.selected = isSelected;
            [bundleSingleItem bringSubviewToFront:bundleSingleItem.selectedProduct];
            bundleSingleItemStart += bundleSingleItem.frame.size.width + 5.0f;
        }

        self.bundleLayout = [[JAPDVBundles alloc] initWithFrame:CGRectMake(0, scrollViewY, self.mainScrollView.width, 300) withSize:NO];

        if (self.product.fashion) {
            [self.bundleLayout setHeaderText:[STRING_BUY_THE_LOOK uppercaseString]];
        } else {
            [self.bundleLayout setHeaderText:[STRING_COMBOS uppercaseString]];
        }
        for (JAPDVBundleSingleItem* singleItem in self.bundleSingleItemsArray) {
            [self.bundleLayout addBundleItemView:singleItem];
        }
        self.bundleLayout.frame = CGRectMake(6.0f, scrollViewY, self.bundleLayout.frame.size.width, self.bundleLayout.frame.size.height);
        [self.mainScrollView addSubview:self.bundleLayout];
        [self.bundleLayout addBuyingBundleTarget:self action:@selector(goToBundlesScreen)];
        self.bundleLayout.frame = CGRectMake(.0f, scrollViewY, self.bundleLayout.frame.size.width, self.bundleLayout.frame.size.height);
        [self.mainScrollView addSubview:self.bundleLayout];
        scrollViewY += (self.bundleLayout.frame.size.height);
    }


    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, scrollViewY);
    self.landscapeScrollView.contentSize = CGSizeMake(self.landscapeScrollView.frame.size.width, landscapeScrollViewY);

    if (!self.product.hasStock || (VALID(self.currentSimple, RIProductSimple) && [self.currentSimple.quantity isEqualToString:@"0"])) {
        [self.productImageSection setOutOfStock:NO];
    } else {
        [self.productImageSection setOutOfStock:YES];
    }

    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
    if(_viewLoaded){
        _viewLoaded = FALSE;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FirtTimeProductDetailPage"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirtTimeProductDetailPage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        //################ when product is fully loaded & rendered
        [EmarsysPredictManager sendTransactionsOf:self];
    }
}

- (JAPDVRelatedItem *)relatedItemsView {
    if (!VALID_NOTEMPTY(_relatedItemsView, JAPDVRelatedItem) || !_relatedItemsView.superview) {
        _relatedItemsView = [[JAPDVRelatedItem alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.productInfoSection.frame), self.mainScrollView.width, 300)];
        [self.mainScrollView addSubview:_relatedItemsView];
    }
    return _relatedItemsView;
}

#pragma mark - Actions

- (void)goToSelectedRelatedItem:(UIControl*)sender {
    NSArray* relatedProducts = [self.product.relatedProducts allObjects];
    RIProduct *tempProduct = [relatedProducts objectAtIndex:sender.tag];

    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];

    if (VALID_NOTEMPTY(tempProduct.targetString, NSString)) {
        [userInfo setObject:tempProduct.targetString forKey:@"targetString"];
        if (VALID_NOTEMPTY(tempProduct.richRelevanceParameter, NSString)) {
            [userInfo setObject:tempProduct.richRelevanceParameter forKey:@"richRelevance"];
        }
    } else if (VALID_NOTEMPTY(tempProduct.sku, NSString)) {
        [userInfo setObject:tempProduct.sku forKey:@"sku"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication object:nil userInfo:userInfo];
    [self trackingEventRelatedItemSelection:tempProduct];
    [self trackingEventScreenName:[NSString stringWithFormat:@"related_item_%@",tempProduct.name]];
}

- (void)goToDescription {
    [self goToDetails:@"description"];
}

- (void)showSeller {
    [self.mainScrollView setContentOffset:CGPointMake(0, self.productInfoSection.frame.origin.y + [self.productInfoSection getSellerInfoYPosition]) animated:YES];
}

- (void)goToSellerCatalog {
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];

    if(self.product.seller) {
        [userInfo setObject:self.product.seller.name forKey:@"name"];
        [userInfo setObject:self.product.seller.targetString forKey:@"targetString"];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenSellerPage object:self.product.seller userInfo:userInfo];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"SellerPage"];
}

- (void)goToSellerLink {
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(self.product.seller, RISeller)) {
        if ([self.product.seller isGlobal]) {
            [userInfo setObject:self.product.seller.linkTextGlobal forKey:@"title"];
            [userInfo setObject:self.product.seller.linkTargetStringGlobal forKey:@"targetString"];
            [userInfo setObject:STRING_BACK forKey:@"show_back_button_title"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithShopUrlNofication object:nil userInfo:userInfo];
        }
    }
}

- (void)goToSpecifications {
    [self goToDetails:@"specifications"];
}

- (void)goToReviews {
    [self goToDetails:@"reviews"];
}

- (void)goToDetails:(NSString *)screen {
    NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(self.product, RIProduct)) {
        [userInfo setObject:self.product forKey:@"product"];
    }
    [userInfo setObject:screen forKey:@"product.screen"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowProductSpecificationScreenNotification object:nil userInfo:userInfo];
}

- (void)goToBundlesScreen {
    NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
    id obj = nil;
    if(VALID_NOTEMPTY(self.product, RIProduct)) {
        obj = self.product;
        if (VALID_NOTEMPTY(self.productBundle.bundleProducts, NSArray)) {
            [userInfo setObject:self.productBundle.bundleProducts forKeyedSubscript:@"product.bundles"];
        }
    }
    __weak typeof(self) weakSelf = self;
    id block = ^(NSMutableDictionary *bundles){
        weakSelf.selectedBundles = [bundles mutableCopy];
    };
    [userInfo setObject:block forKeyedSubscript:@"product.bundles.onChange"];
    if (self.selectedBundles) {
        [userInfo setObject:self.selectedBundles forKeyedSubscript:@"product.bundles.selected"];
    }
    if (self.productBundle) {
        [userInfo setObject:self.productBundle forKeyedSubscript:@"product.bundle"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenProductBundlesScreen object:obj userInfo:userInfo];
}

- (void)goToVariationsScreen {
    NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
    id obj = nil;
    if(VALID_NOTEMPTY(self.product, RIProduct)) {
        obj = self.product;
        if (VALID_NOTEMPTY(self.product.variations, NSArray)) {
            [userInfo setObject:self.product.variations forKeyedSubscript:@"product.variations"];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenProductVariationsScreen object:obj userInfo:userInfo];
}

- (void)goToSisScreen {
//    [[MainTabBarViewController topNavigationController] openTargetString:self.product.brandTarget];
}

- (void)goToOtherSellersScreen {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenOtherOffers object:self.product];
}

- (void)shareProduct {
    NSString *url = self.product.shareUrl;

    // Share with WhatsApp
//    UIActivity *whatsAppActivity = [[JBWhatsAppActivity alloc] init];

    //NSArray *objectToShare = @[fbmActivity, whatsAppActivity];;
    //crash fix on clicking items with name in farsi
    NSString* webStringURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* urlToBeShared = [NSURL URLWithString:webStringURL];

    WhatsAppMessage *whatsappMsg = [[WhatsAppMessage alloc] initWithMessage:[NSString stringWithFormat:@"%@ %@",STRING_SHARE_PRODUCT_MESSAGE, url] forABID:nil];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[STRING_SHARE_PRODUCT_MESSAGE, urlToBeShared, whatsappMsg] applicationActivities:nil];

    if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){

        //activityController = [[UIActivityViewController alloc] initWithActivityItems:@[STRING_SHARE_PRODUCT_MESSAGE, urlToBeShared, whatsappMsg] applicationActivities:objectToShare];

    }

    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];

    [activityController setValue:[NSString stringWithFormat:STRING_SHARE_OBJECT, APP_NAME]
                          forKey:@"subject"];

    activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        [self trackingEventShared:activityType];
    };

    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        CGRect sharePopoverRect = CGRectMake(self.ctaView.frame.size.width, self.ctaView.frame.size.height / 2, 0.0f, 0.0f);
        UIPopoverController* popoverController =
        [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popoverController presentPopoverFromRect:sharePopoverRect inView:self.ctaView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        popoverController.passthroughViews = nil;
        self.currentPopoverController = popoverController;
    } else {
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)addToWishList {
    [self addToWishList:self.productImageSection.wishListButton];
}

- (void)addToCart {
    if(VALID_NOTEMPTY(self.product.productSimples, NSArray) && self.product.productSimples.count > 1 && !VALID_NOTEMPTY(self.currentSimple, RIProductSimple)) {
        self.openPickerFromCart = YES;
        [self showSizePicker];
    } else {
        //[self showLoading];
        if (!self.currentSimple && self.product.productSimples.count == 1) {
            self.currentSimple = [self.product.productSimples firstObject];
        }
        [DataAggregator addProductToCart:self simpleSku:self.currentSimple.sku completion:^(id data, NSError *error) {
            if(error == nil) {
                [self bind:data forRequestId:0];

                //EVENT: ADD TO CART
                [TrackerManager postEventWithSelector:[EventSelectors addToCartEventSelector]
                                           attributes:[EventAttributes addToCardWithProduct:self.product screenName:[self getScreenName] success:YES]];

                if (VALID_NOTEMPTY(self.purchaseTrackingInfo, NSString)) {
                    [[PurchaseBehaviourRecorder sharedInstance] recordAddToCardWithSku:self.product.sku trackingInfo:self.purchaseTrackingInfo];
//                    NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];
//
//                    NSString *obj = [skusFromTeaserInCart objectForKey:self.product.sku];
//
//                    if (ISEMPTY(obj)) {
//                        [skusFromTeaserInCart setValue:self.purchaseTrackingInfo forKey:self.product.sku];
//                        [[NSUserDefaults standardUserDefaults] setObject:[skusFromTeaserInCart copy] forKey:kSkusFromTeaserInCartKey];
//                    }
                }

                [self trackingEventAddToCart:self.cart];

                NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.cart forKey:kUpdateCartNotificationValue];
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];

                [self onSuccessResponse:RIApiResponseSuccess messages:[self extractSuccessMessages:[data objectForKey:kDataMessages]] showMessage:YES];
                //[self hideLoading];
                
                //##############
                [EmarsysPredictManager sendTransactionsOf:self];
                
                [self updateCartInNavBar];
            } else {
                //EVENT: ADD TO CART
                [TrackerManager postEventWithSelector:[EventSelectors addToCartEventSelector]
                                           attributes:[EventAttributes addToCardWithProduct:self.product screenName:[self getScreenName] success:NO]];
                [self onErrorResponse:error.code messages:[error.userInfo objectForKey:kErrorMessages] showAsMessage:YES selector:@selector(addToCart) objects:nil];
                //[self hideLoading];
            }
        }];
    }
}

- (void)callToOrder {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"تماس با تیم خدمات مشتریان بامیلو" delegate:nil cancelButtonTitle:@"لغو" otherButtonTitles:@"تایید", nil];
    alert.delegate = self;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex ==0) {} else {
        [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
            [self trackingEventCallToOrder];
            NSString *phoneNumber = [@"tel://" stringByAppendingString:[JAUtils convertToEnglishNumber:configuration.phoneNumber]];//tessa
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        }];
    }
}

- (void)showSizePicker {
    self.indexOfBundleRelatedToSizePicker = -1;

    self.pickerDataSource = [NSMutableArray new];
    NSMutableArray *options = [[NSMutableArray alloc] init];

    if(VALID_NOTEMPTY(self.product.productSimples, NSArray)) {
        for (RIProductSimple *simple in self.product.productSimples) {
            if ([simple.quantity integerValue] > 0) {
                [self.pickerDataSource addObject:simple];
                [options addObject:simple.variation];
            }
        }
    }

    NSString* sizeGuideTitle = nil;
    if (VALID_NOTEMPTY(self.product.sizeGuideUrl, NSString)) {
        sizeGuideTitle = STRING_SIZE_GUIDE;
    }

    if (VALID_NOTEMPTY(options, NSMutableArray)) {
        [self loadSizePickerWithOptions:[options copy]
                           previousText:self.productInfoSection.sizesText
                        leftButtonTitle:sizeGuideTitle];
    }
}

- (void)loadSizePickerWithOptions:(NSArray*)options previousText:(NSString*)previousText leftButtonTitle:(NSString*)leftButtonTitle {
    if (!VALID_NOTEMPTY(self.picker, JAPicker)) {

        self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
        [self.picker setDelegate:self];
    }

    if (![self.picker superview]) {
        [self.view addSubview:self.picker];
    }

    [self.picker setDataSourceArray:options previousText:previousText leftButtonTitle:leftButtonTitle];
    CGFloat pickerViewHeight = self.view.frame.size.height;
    CGFloat pickerViewWidth = self.view.frame.size.width;
    [self.picker setFrame:CGRectMake(0.0f, pickerViewHeight, pickerViewWidth, pickerViewHeight)];

    [self.view bringSubviewToFront:self.picker];

    [UIView animateWithDuration:0.4f animations:^{
                         [self.picker setFrame:CGRectMake(0.0f, 0.0f, pickerViewWidth, pickerViewHeight)];
                     }];
}


- (IBAction)checkBundle:(UIButton*)sender {
    NSInteger index = sender.tag;
    JAPDVBundleSingleItem* singleItem = [self.bundleSingleItemsArray objectAtIndex:index];

    singleItem.selected = !singleItem.selected;

    if (!self.selectedBundles) {
        self.selectedBundles = [[NSMutableDictionary alloc] init];
        for (JAPDVBundleSingleItem *item in self.bundleSingleItemsArray) {
            if (![item.product.sku isEqualToString:singleItem.product.sku]) {
                [self.selectedBundles setObject:[item.product.productSimples firstObject] forKey:item.product.sku];
            }
        }
    } else {
        if (singleItem.selected) {
            [self.selectedBundles setObject:[singleItem.product.productSimples firstObject]  forKey:singleItem.product.sku];
        } else {
            [self.selectedBundles removeObjectForKey:singleItem.product.sku];
        }

    }
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow {
    self.currentSimple = [self.pickerDataSource objectAtIndex:selectedRow];

    NSString* option = self.currentSimple.variation;
    if (ISEMPTY(option)) {
        option = @"";
    }
    self.preSelectedSize = option;
    [self.productInfoSection setSizesText:option];
    [self.productInfoSection setSpecialPrice:self.currentSimple.specialPriceFormatted
                                    andPrice:self.currentSimple.priceFormatted
                      andMaxSavingPercentage:self.product.maxSavingPercentage
                             shouldForceFlip:YES];

    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;

    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         if (self.openPickerFromCart) {
                             self.openPickerFromCart = NO;
                             [self addToCart];
                         }
                     }];
}

- (void)closePicker {
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;

    [UIView animateWithDuration:0.4f animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                     }];
}

- (void)leftButtonPressed {
    if (VALID_NOTEMPTY(self.product.sizeGuideUrl, NSString)) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self.product.sizeGuideUrl, @"sizeGuideUrl", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSizeGuideNotification object:nil userInfo:dic];
        [self closePicker];
    }
}

#pragma mark JAPDVImageSectionDelegate
- (void)imageClickedAtIndex:(NSInteger)index {
    [self presentGalleryAtIndex:index];
}

- (void)presentGalleryAtIndex:(NSInteger)index {
    if(VALID(_galleryPaged, JAPDVGallery))
        [_galleryPaged removeFromSuperview];

    UIView *gallerySuperView = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;

    CGFloat width = gallerySuperView.frame.size.width;
    CGFloat height = gallerySuperView.frame.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;

    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        if(width < gallerySuperView.frame.size.height) {
            width = gallerySuperView.frame.size.height;
            height = gallerySuperView.frame.size.width;
        }
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
            statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
    } else {
        if(width > gallerySuperView.frame.size.height)
        {
            width = gallerySuperView.frame.size.height;
            height = gallerySuperView.frame.size.width;
        }
    }

    _galleryPaged = [[JAPDVGallery alloc] initWithFrame:CGRectMake(0, height, width, height-statusBarHeight)];
    CGRect openFrame = CGRectMake(0, statusBarHeight, width, height-statusBarHeight);
    [_galleryPaged loadGalleryWithArray:self.product.images atIndex:index];
    [gallerySuperView addSubview:_galleryPaged];
    [_galleryPaged setBackgroundColor:[UIColor whiteColor]];
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _galleryPaged.frame = openFrame;
                     } completion:nil];
    _galleryPaged.delegate = self;
}

- (void)onIndexChanged:(NSInteger)index {
    [self.productImageSection goToGalleryIndex:index];
}

- (void)dismissGallery {
    CGRect newFrame = self.galleryPaged.frame;
    newFrame.origin.y = self.galleryPaged.frame.size.height;

    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _galleryPaged.frame = newFrame;
    } completion:^(BOOL finished) {
        [_galleryPaged removeFromSuperview];
        _galleryPaged = nil;
    }];
}

- (void)wishListButtonPressed:(UIButton*)button {
    if (!self.productImageSection.wishListButton.selected && !VALID_NOTEMPTY(self.product.favoriteAddDate, NSDate)) {
        [self addToWishList:button];
    } else if (self.productImageSection.wishListButton.selected && VALID_NOTEMPTY(self.product.favoriteAddDate, NSDate)) {
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

- (void)addToWishList:(UIButton *)button {
    __weak typeof (self) weakSelf = self;
    BOOL logged = [self isUserLoggedInWithBlock:^{
        _needAddToFavBlock = NO;
        if(![RICustomer checkIfUserIsLogged]) {
            return;
        } else {
            [weakSelf addToWishList:button];
        }
    }];
    if (!logged) {
        return;
    }
    if (!button.selected && !VALID_NOTEMPTY(self.product.favoriteAddDate, NSDate)) {
        [DataAggregator addToWishListWithTarget:self sku:self.product.sku completion:^(id data, NSError *error) {
            if(error == nil) {
                //EVENT: ADD TO FAVORITES
                [TrackerManager postEventWithSelector:[EventSelectors addToWishListSelector]
                                           attributes:[EventAttributes addToWishListWithProduct:self.product screenName:[self getScreenName] success:YES]];
                
                //[self hideLoading];
                button.selected = YES;
                self.product.favoriteAddDate = [NSDate date];
                [self trackingEventAddToWishList];
                NSDictionary *userInfo = nil;
                if (self.product.favoriteAddDate) {
                    userInfo = [NSDictionary dictionaryWithObject:self.product.favoriteAddDate forKey:@"favoriteAddDate"];
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:kProductChangedNotification object:self.product.sku userInfo:userInfo];

                [self onSuccessResponse:RIApiResponseSuccess messages:[self extractSuccessMessages:data] showMessage:YES];
                [self.delegate addToWishList:self.product.sku add:YES];
            } else {
                [self onErrorResponse:error.code messages:[error.userInfo objectForKey:kErrorMessages] showAsMessage:YES selector:@selector(addToWishList:) objects:@[button]];
                
                //EVENT: ADD TO FAVORITES
                [TrackerManager postEventWithSelector:[EventSelectors addToWishListSelector]
                                           attributes:[EventAttributes addToWishListWithProduct:self.product screenName:[self getScreenName] success:NO]];
            }
        }];
    }
}

- (void)removeFromFavorites:(UIButton *)button {
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
    if (self.productImageSection.wishListButton.selected && VALID_NOTEMPTY(self.product.favoriteAddDate, NSDate)) {
        [DataAggregator removeFromWishListWithTarget:self sku:self.product.sku completion:^(id data, NSError *error) {
            if (error == nil) {
                [self hideLoading];
                button.selected = NO;
    
                self.product.favoriteAddDate = nil;
                [self trackingEventRemoveFromWishlist];
                [self onSuccessResponse:RIApiResponseSuccess messages:[self extractSuccessMessages:data] showMessage:YES];
                NSDictionary *userInfo = nil;
                if (self.product.favoriteAddDate) {
                    userInfo = [NSDictionary dictionaryWithObject:self.product.favoriteAddDate forKey:@"favoriteAddDate"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kProductChangedNotification object:self.product.sku userInfo:userInfo];
                
                [TrackerManager postEventWithSelector:[EventSelectors removeFromWishListSelector] attributes:[EventAttributes removeFromWishListWithProduct:self.product screenName:[self getScreenName]]];
                
                [self.delegate addToWishList:self.product.sku add:NO];
            } else {
                [self onErrorResponse:error.code messages:[error.userInfo objectForKey:kErrorMessages] showAsMessage:YES selector:@selector(removeFromFavorites:) objects:@[button]];
                //[self hideLoading];
                
                //EVENT: Remove FROM FAVORITES
            }
        }];
    }
}

#pragma mark - Activity delegate

- (void)willDismissActivityViewController:(JAActivityViewController *)activityViewController {
    // Track sharing here :)
}

#pragma mark - Tracking Events

- (NSNumber *)getPrice {
    return (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue] > 0.0f)? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;
}

- (void)trackingEventViewProduct:(RIProduct *)product {
    NSNumber *price = [self getPrice];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];

    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];

    [trackingDictionary setValue:[price stringValue] forKey:kRIEventFBValueToSumKey];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventFBContentIdKey];
    [trackingDictionary setValue:@"product" forKey:kRIEventFBContentTypeKey];
    [trackingDictionary setValue:@"EUR" forKey:kRIEventFBCurrency];

    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewProduct]
                                              data:[trackingDictionary copy]];

    trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"ViewProductDetails" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:price forKey:kRIEventValueKey];

    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    if(VALID_NOTEMPTY([RICustomer getCustomerGender], NSString))
    {
        [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
    }
    [trackingDictionary setValue:self.product.sku forKey:kRIEventProductKey];
    [trackingDictionary setObject:self.product.brand forKey:kRIEventBrandName];
    [trackingDictionary setObject:self.product.brandUrlKey forKey:kRIEventBrandKey];

    NSString *discountPercentage = @"0";
    if(VALID_NOTEMPTY(self.product.maxSavingPercentage, NSString)) {
        discountPercentage = self.product.maxSavingPercentage;
    }

    // Since we're sending the converted price, we have to send the currency as EUR.
    // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
    [trackingDictionary setValue:price forKey:kRIEventPriceKey];
    [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];

    [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];

    if(VALID_NOTEMPTY(self.product.avr, NSNumber)) {
        [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
    }

    NSString *categoryName = @"";
    NSString *subCategoryName = @"";
    if(VALID_NOTEMPTY(self.category, RICategory)) {
        if(VALID_NOTEMPTY(self.category.parent, RICategory)) {
            RICategory *parent = self.category.parent;
            while (VALID_NOTEMPTY(parent.parent, RICategory)) {
                parent = parent.parent;
            }
            categoryName = parent.label;
            subCategoryName = self.category.label;
        } else {
            categoryName = self.category.label;
        }
    } else if(VALID_NOTEMPTY(self.product.categoryIds, NSArray)) {
        NSArray *categoryIds = self.product.categoryIds;
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

    if(VALID_NOTEMPTY(categoryName, NSString)) {
        [trackingDictionary setValue:categoryName forKey:kRIEventCategoryIdKey];
    }
    if(VALID_NOTEMPTY(subCategoryName, NSString)) {
        [trackingDictionary setValue:subCategoryName forKey:kRIEventSubCategoryIdKey];
    }

    if (VALID_NOTEMPTY(self.product.categoryName, NSString)) {
        [trackingDictionary setValue:self.product.categoryName forKey:kRIEventCategoryNameKey];
    }
    if (VALID_NOTEMPTY(self.product.categoryUrlKey, NSString)) {
        [trackingDictionary setValue:self.product.categoryUrlKey forKey:kRIEventCategoryIdKey];
    }

    if (VALID_NOTEMPTY(self.product.name, NSString)) {
        [trackingDictionary setValue:self.product.name forKey:kRIEventProductNameKey];
    }

    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewProduct]
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventAddToCart:(RICart *)cart {
    NSNumber *price = [self getPrice];
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:((RIProduct *)[self.product.productSimples firstObject]).sku forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"AddToCart" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:price forKey:kRIEventValueKey];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];

    // Since we're sending the converted price, we have to send the currency as EUR.
    [trackingDictionary setValue:price forKey:kRIEventPriceKey];
    [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];

    [trackingDictionary setValue:self.currentSimple.sku forKey:kRIEventSkuKey];
    [trackingDictionary setValue:self.product.name forKey:kRIEventProductNameKey];

    if(VALID_NOTEMPTY(self.product.categoryIds, NSArray)) {
        NSArray *categoryIds = self.product.categoryIds;
        [trackingDictionary setValue:[categoryIds objectAtIndex:0] forKey:kRIEventCategoryIdKey];
    }

    [trackingDictionary setObject:self.product.brand forKey:kRIEventBrandName];
    [trackingDictionary setObject:self.product.brandUrlKey forKey:kRIEventBrandKey];

    NSString *discountPercentage = @"0";
    if(VALID_NOTEMPTY(self.product.maxSavingPercentage, NSString)) {
        discountPercentage = self.product.maxSavingPercentage;
    }
    [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
    [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
    [trackingDictionary setValue:cart.cartEntity.cartCount forKey:kRIEventQuantityKey];
    [trackingDictionary setValue:@"Product Detail screen" forKey:kRIEventLocationKey];

    NSString *categoryName = @"";
    NSString *subCategoryName = @"";
    if(VALID_NOTEMPTY(self.category, RICategory)) {
        if(VALID_NOTEMPTY(self.category.parent, RICategory)) {
            RICategory *parent = self.category.parent;
            while (VALID_NOTEMPTY(parent.parent, RICategory)) {
                parent = parent.parent;
            }
            categoryName = parent.label;
            subCategoryName = self.category.label;
        } else {
            categoryName = self.category.label;
        }
    } else if(VALID_NOTEMPTY(self.product.categoryIds, NSArray)) {
        NSArray *categoryIds = self.product.categoryIds;
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

    if(VALID_NOTEMPTY(categoryName, NSString)) {
        [trackingDictionary setValue:categoryName forKey:kRIEventCategoryIdKey];
    }
    if(VALID_NOTEMPTY(subCategoryName, NSString)) {
        [trackingDictionary setValue:subCategoryName forKey:kRIEventSubCategoryIdKey];
    }
    if (VALID_NOTEMPTY(self.product.categoryName, NSString)) {
        [trackingDictionary setValue:self.product.categoryName forKey:kRIEventCategoryNameKey];
    }
    if (VALID_NOTEMPTY(self.product.categoryUrlKey, NSString)) {
        [trackingDictionary setValue:self.product.categoryUrlKey forKey:kRIEventCategoryIdKey];
    }

    [trackingDictionary setValue:self.product.name forKey:kRIEventProductNameKey];
    [trackingDictionary setValue:cart.cartEntity.cartValueEuroConverted forKey:kRIEventTotalCartKey];

    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToCart]
                                              data:[trackingDictionary copy]];


    trackingDictionary = [NSMutableDictionary new];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];

    [trackingDictionary setValue:[price stringValue] forKey:kRIEventFBValueToSumKey];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventFBContentIdKey];
    [trackingDictionary setValue:@"product" forKey:kRIEventFBContentTypeKey];
    [trackingDictionary setValue:@"EUR" forKey:kRIEventFBCurrency];

    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookAddToCart]
                                              data:[trackingDictionary copy]];
    [self trackingEventCart:cart];
}

- (void)trackingEventCart:(RICart *)cart {
    NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
    [trackingDictionary setValue:cart.cartEntity.cartValueEuroConverted forKey:kRIEventTotalCartKey];
    [trackingDictionary setValue:cart.cartEntity.cartCount forKey:kRIEventQuantityKey];
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                              data:[trackingDictionary copy]];
    [self trackingEventLastAddedToCart];
}

- (void)trackingEventLastAddedToCart {
    NSMutableDictionary *tracking = [NSMutableDictionary new];
    [tracking setValue:self.product.name forKey:kRIEventProductNameKey];
    [tracking setValue:self.product.sku forKey:kRIEventSkuKey];
    if(VALID_NOTEMPTY(self.product.categoryIds, NSArray)) {
        [tracking setValue:[self.product.categoryIds lastObject] forKey:kRIEventLastCategoryAddedToCartKey];
    }
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastAddedToCart] data:tracking];
}

- (void)trackingEventCallToOrder {
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];

    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCallToOrder]
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventRemoveFromWishlist {
    NSNumber *price = [self getPrice];
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"RemoveFromWishlist" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:price forKey:kRIEventValueKey];

    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
    [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];

    // Since we're sending the converted price, we have to send the currency as EUR.
    // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
    [trackingDictionary setValue:price forKey:kRIEventPriceKey];
    [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];

    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages) {

        [trackingDictionary setValue:[NSNumber numberWithInteger:favoriteProducts.count] forKey:kRIEventTotalWishlistKey];

        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                  data:[trackingDictionary copy]];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                  data:[trackingDictionary copy]];
    }];
}

- (void)trackingEventAddToWishList {
    NSNumber *price = (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue] > 0.0f) ? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;

    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
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

    [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
    [trackingDictionary setObject:self.product.brand forKey:kRIEventBrandName];
    [trackingDictionary setObject:self.product.brandUrlKey forKey:kRIEventBrandKey];

    NSString *discountPercentage = @"0";
    if(VALID_NOTEMPTY(self.product.maxSavingPercentage, NSString)) {
        discountPercentage = self.product.maxSavingPercentage;
    }
    [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
    [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
    [trackingDictionary setValue:@"Product Detail screen" forKey:kRIEventLocationKey];

    NSString *categoryName = @"";
    NSString *subCategoryName = @"";
    if(VALID_NOTEMPTY(self.category, RICategory)) {
        if(VALID_NOTEMPTY(self.category.parent, RICategory)) {
            RICategory *parent = self.category.parent;
            while (VALID_NOTEMPTY(parent.parent, RICategory)) {
                parent = parent.parent;
            }
            categoryName = parent.label;
            subCategoryName = self.category.label;
        } else {
            categoryName = self.category.label;
        }
    } else if(VALID_NOTEMPTY(self.product.categoryIds, NSArray)) {
        NSArray *categoryIds = self.product.categoryIds;
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

    if(VALID_NOTEMPTY(categoryName, NSString)) {
        [trackingDictionary setValue:categoryName forKey:kRIEventCategoryIdKey];
    }
    if(VALID_NOTEMPTY(subCategoryName, NSString)) {
        [trackingDictionary setValue:subCategoryName forKey:kRIEventSubCategoryIdKey];
    }
    if (VALID_NOTEMPTY(self.product.categoryName, NSString)) {
        [trackingDictionary setValue:self.product.categoryName forKey:kRIEventCategoryNameKey];
    }
    if (VALID_NOTEMPTY(self.product.categoryUrlKey, NSString)) {
        [trackingDictionary setValue:self.product.categoryUrlKey forKey:kRIEventCategoryIdKey];
    }

    [trackingDictionary setValue:self.product.name forKey:kRIEventProductNameKey];

    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages) {

        [trackingDictionary setValue:[NSNumber numberWithInteger:favoriteProducts.count] forKey:kRIEventTotalWishlistKey];

        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToWishlist]
                                                  data:[trackingDictionary copy]];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToWishlist]
                                                  data:[trackingDictionary copy]];
    }];
}

- (void)trackingEventShared:(NSString *)activityType {
    NSString *type = @"Shared";
    NSNumber *eventType = [NSNumber numberWithInt:RIEventShareOther];
    if ([activityType isEqualToString:UIActivityTypeMail])
    {
        type = @"Email";
        eventType = [NSNumber numberWithInt:RIEventShareEmail];
    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        type = @"Twitter";
        eventType = [NSNumber numberWithInt:RIEventShareTwitter];
    } else if([activityType isEqualToString:UIActivityTypeMessage]) {
        type = @"SMS";
        eventType = [NSNumber numberWithInt:RIEventShareSMS];
    }

    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
    [trackingDictionary setValue:type forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:self.product.priceEuroConverted forKey:kRIEventValueKey];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];

    NSString *categoryName = @"";
    NSString *subCategoryName = @"";
    if(VALID_NOTEMPTY(self.category, RICategory)) {
        if(VALID_NOTEMPTY(self.category.parent, RICategory)) {
            RICategory *parent = self.category.parent;
            while (VALID_NOTEMPTY(parent.parent, RICategory)) {
                parent = parent.parent;
            }
            categoryName = parent.label;
            subCategoryName = self.category.label;
        } else {
            categoryName = self.category.label;
        }
    } else if(VALID_NOTEMPTY(self.product.categoryIds, NSArray)) {
        NSArray *categoryIds = self.product.categoryIds;
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

    if(VALID_NOTEMPTY(categoryName, NSString)) {
        [trackingDictionary setValue:categoryName forKey:kRIEventCategoryIdKey];
    }
    if(VALID_NOTEMPTY(subCategoryName, NSString)) {
        [trackingDictionary setValue:subCategoryName forKey:kRIEventSubCategoryIdKey];
    }

    [[RITrackingWrapper sharedInstance] trackEvent:eventType
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventRelatedItemSelection:(RIProduct *)product {
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"RelatedItem" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:product.priceEuroConverted forKey:kRIEventValueKey];

    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRelatedItem] data:[trackingDictionary copy]];
}

- (void)trackingEventMostViewedBrand {
    NSString *topBrand = [RIProduct getTopBrand:self.product];
    if (VALID_NOTEMPTY(topBrand, NSString)) {
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventMostViewedBrand] data:[NSDictionary dictionaryWithObject:topBrand forKey:kRIEventBrandName]];
    }
}

- (void)trackingEventScreenName:(NSString *)screenName {
    [[RITrackingWrapper sharedInstance] trackScreenWithName:screenName];
}

- (void)trackingEventLoadingTime {
    [self publishScreenLoadTime];
}

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"PDVView";
}

-(NSString *)getPerformanceTrackerLabel {
    return self.productSku;
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

#pragma mark - EmarsysPredictProtocol
- (EMTransaction *)getDataCollection:(EMTransaction *)transaction {
    if (self.product.sku) {
        [transaction setView:self.product.sku];
    }
    return transaction;
}

- (BOOL)isPreventSendTransactionInViewWillAppear {
    return YES;
}

- (NSArray<EMRecommendationRequest *> *)getRecommendations {
    EMRecommendationRequest *recommend = [EMRecommendationRequest requestWithLogic:recommendationLogic];
    recommend.limit = 100;
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
        [self renderRecommendations:result];
    };
    return @[recommend];
}

- (void)renderRecommendations:(EMRecommendationResult *)result {
    self.recommendItems = [result.products map:^id(EMRecommendationItem *item) {
        return [[RecommendItem alloc] initWithItem:item];
    }];
    if (self.recommendItems.count < 6) { return; }
    NSArray<RecommendItem *>* renderingItems = [self.recommendItems subarrayWithRange:NSMakeRange(0, MIN(6, self.recommendItems.count))];
    if(_recommendationView == nil) {
        _recommendationView = [EmarsysRecommendationGridWidgetView nibInstance];
        _recommendationView.delegate = self;
        
        [_recommendationView setHeight:[EmarsysRecommendationGridWidgetView preferredHeightWithContentModel:renderingItems boundWidth:self.mainScrollView.width]];
        [_recommendationView updateTitle:STRING_BAMILO_RECOMMENDATION_FOR_YOU];
        [_recommendationView setWidgetBacgkround:JABlack300Color];
        [ThreadManager executeOnMainThread:^{
            [_recommendationView setFrame:CGRectMake(0, self.mainScrollView.contentSize.height, self.mainScrollView.width, _recommendationView.height)];
            [self.mainScrollView addSubview:_recommendationView];
            [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, self.mainScrollView.contentSize.height + _recommendationView.height)];
            [_recommendationView updateWithModel:renderingItems];
        }];
    } else {
        [ThreadManager executeOnMainThread:^{
            [_recommendationView updateWithModel:renderingItems];
        }];
    }
}

#pragma mark - FeatureBoxCollectionViewWidgetViewDelegate
- (void)selectFeatureItem:(NSObject *)item widgetBox:(id)widgetBox {
    if ([item isKindOfClass:[RecommendItem class]]) {
        [TrackerManager postEventWithSelector:[EventSelectors recommendationTappedSelector] attributes:[EventAttributes tapEmarsysRecommendationWithScreenName:[self getScreenName] logic:recommendationLogic]];
        [[NSNotificationCenter defaultCenter] postNotificationName: kDidSelectTeaserWithPDVUrlNofication
                                                            object: nil
                                                          userInfo: @{@"sku": ((RecommendItem *)item).sku}];
    }
}

- (void)moreButtonTappedInWidgetView:(id)widgetView {
    AllRecommendationViewController *viewCtrl = (AllRecommendationViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"AllRecommendationViewController" resetCache:YES];
    viewCtrl.recommendItems = self.recommendItems;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - hide tabbar in this view controller
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - NavigationBarProtocol

- (NavBarLeftButtonType)navBarleftButton {
    return NavBarLeftButtonTypeCart;
}

@end

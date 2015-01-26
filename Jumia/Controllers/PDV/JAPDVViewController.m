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
#import "JAPDVGalleryView.h"
#import "RIProductRatings.h"
#import "JARatingsViewController.h"
#import "JAProductDetailsViewController.h"
#import "JANewRatingViewController.h"
#import "JAAppDelegate.h"
#import "JAShareActivityProvider.h"
#import "JAActivityViewController.h"
#import "RICountry.h"
#import "JAButtonWithBlur.h"
#import "JAUtils.h"
#import "RICustomer.h"
#import "JAPDVWizardView.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AQSFacebookMessengerActivity.h"
#import "JAOtherOffersView.h"

@interface JAPDVViewController ()
<
JAPDVGalleryViewDelegate,
JAPickerDelegate,
JAActivityViewControllerDelegate
>

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UIScrollView *landscapeScrollView;
@property (strong, nonatomic) RIProductRatings *productRatings;
@property (strong, nonatomic) JAPDVImageSection *imageSection;
@property (strong, nonatomic) JAPDVVariations *variationsSection;
@property (strong, nonatomic) JAPDVProductInfo *productInfoSection;
@property (strong, nonatomic) JAPDVRelatedItem *relatedItems;
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (strong, nonatomic) JAPDVGalleryView *gallery;
@property (strong, nonatomic) JAButtonWithBlur *ctaView;
@property (assign, nonatomic) NSInteger commentsCount;
@property (assign, nonatomic) BOOL openPickerFromCart;
@property (strong, nonatomic) RIProductSimple *currentSimple;
@property (nonatomic, strong) JAPDVWizardView* wizardView;
@property (assign, nonatomic) RIApiResponse apiResponse;
@property (nonatomic, strong) JAOtherOffersView* otherOffersView;

@property (nonatomic, assign) BOOL hasLoaddedProduct;

@property (strong, nonatomic) UIPopoverController *currentPopoverController;

@end

@implementation JAPDVViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.apiResponse = RIApiResponseSuccess;
    if(VALID_NOTEMPTY(self.product.sku, NSString))
    {
        self.screenName = [NSString stringWithFormat:@"PDS / %@", self.product.sku];
    }
    else
    {
        self.screenName = @"PDS";
    }
    
    self.A4SViewControllerAlias = @"PRODUCT";
    
    self.navBarLayout.showLogo = NO;
    
    self.navBarLayout.showBackButton = self.showBackButton;
    if (self.showBackButton && self.previousCategory.length > 0)
    {
        self.navBarLayout.backButtonTitle = self.previousCategory;
    }
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.mainScrollView setHidden:YES];
    [self.view addSubview:self.mainScrollView];
    
    self.landscapeScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.landscapeScrollView setHidden:YES];
    [self.view addSubview:self.landscapeScrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( applicationDidEnterBackgroundNotification:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL alreadyShowedWizardPDV = [[NSUserDefaults standardUserDefaults] boolForKey:kJAPDVWizardUserDefaultsKey];
    if(alreadyShowedWizardPDV == NO)
    {
        self.wizardView = [[JAPDVWizardView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.wizardView];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJAPDVWizardUserDefaultsKey];
    }
    
    if(self.hasLoaddedProduct)
    {        
        [self removeSuperviews];
        
        [self productLoaded];
    }
    else
    {
        if (VALID_NOTEMPTY(self.productUrl, NSString) || VALID_NOTEMPTY(self.productSku, NSString))
        {
            [self loadCompleteProduct];
        }
        else
        {
            if(self.firstLoading)
            {
                NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                self.firstLoading = NO;
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification*)notification
{
    if(VALID_NOTEMPTY(self.currentPopoverController, UIPopoverController))
    {
        [self.currentPopoverController dismissPopoverAnimated:NO];
    }
    
    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(VALID_NOTEMPTY(self.currentPopoverController, UIPopoverController))
    {
        [self.currentPopoverController dismissPopoverAnimated:NO];
    }
    
    if (RIApiResponseNoInternetConnection != self.apiResponse)
    {
        [self showLoading];
    }
    
    [self.mainScrollView setHidden:YES];
    [self.landscapeScrollView setHidden:YES];
    [self.ctaView setHidden:YES];
    
    if(VALID_NOTEMPTY(self.wizardView, JAPDVWizardView))
    {
        CGRect newFrame = CGRectMake(self.wizardView.frame.origin.x,
                                     self.wizardView.frame.origin.y,
                                     self.view.frame.size.height + self.view.frame.origin.y,
                                     self.view.frame.size.width - self.view.frame.origin.y);
        [self.wizardView reloadForFrame:newFrame];
    }
    
    if(VALID_NOTEMPTY(self.gallery, JAPDVGalleryView))
    {
        UIView *gallerySuperView = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;
        
        CGFloat width = gallerySuperView.frame.size.height;
        CGFloat height = gallerySuperView.frame.size.width;
        
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            if(width < height)
            {
                width = gallerySuperView.frame.size.width;
                height = gallerySuperView.frame.size.height;
            }
        }
        else
        {
            if(width > height)
            {
                width = gallerySuperView.frame.size.width;
                height = gallerySuperView.frame.size.height;
            }
        }
        
        [self.gallery reloadFrame:CGRectMake(0.0f, 0.0f, width, height)];
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self productLoaded];
    
    if(VALID_NOTEMPTY(self.wizardView, JAPDVWizardView))
    {
        [self.wizardView reloadForFrame:self.view.bounds];
    }
    
    if(VALID_NOTEMPTY(self.gallery, JAPDVGalleryView))
    {
        UIView *gallerySuperView = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;
        
        CGFloat width = gallerySuperView.frame.size.width;
        CGFloat height = gallerySuperView.frame.size.height;
        
        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            if(width < height)
            {
                width = gallerySuperView.frame.size.height;
                height = gallerySuperView.frame.size.width;
            }
        }
        else
        {
            if(width > height)
            {
                width = gallerySuperView.frame.size.height;
                height = gallerySuperView.frame.size.width;
            }
        }

        [self.gallery reloadFrame:CGRectMake(0.0f, 0.0f, width, height)];
    }
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void) removeSuperviews
{
    [self.mainScrollView setHidden:YES];
    [self.landscapeScrollView setHidden:YES];
    
    for(UIView *subView in self.mainScrollView.subviews)
    {
        [subView removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.landscapeScrollView, UIScrollView))
    {
        for(UIView *subView in self.landscapeScrollView.subviews)
        {
            [subView removeFromSuperview];
        }
    }

    if(VALID_NOTEMPTY(self.ctaView, JAButtonWithBlur))
    {
        [self.ctaView removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
}

- (void)loadCompleteProduct
{
    if(self.apiResponse == RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    self.hasLoaddedProduct = NO;
    
    if (VALID_NOTEMPTY(self.productUrl, NSString)) {
        [RIProduct getCompleteProductWithUrl:self.productUrl successBlock:^(id product) {
            self.apiResponse = RIApiResponseSuccess;
            
            [self loadedProduct:product];
            [self removeErrorView];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            self.apiResponse = apiResponse;
            [self removeErrorView];
            if(self.firstLoading)
            {
                NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                self.firstLoading = NO;
            }
            
            if(RIApiResponseMaintenancePage == apiResponse)
            {
                [self showMaintenancePage:@selector(loadCompleteProduct) objects:nil];
            }
            else
            {
                BOOL noConnection = NO;
                if (RIApiResponseNoInternetConnection == apiResponse)
                {
                    noConnection = YES;
                }
                [self showErrorView:noConnection startingY:0.0f selector:@selector(loadCompleteProduct) objects:nil];
            }
            
            [self hideLoading];
        }];
    } else if (VALID_NOTEMPTY(self.productSku, NSString)) {
        [RIProduct getCompleteProductWithSku:self.productSku successBlock:^(id product) {
            self.apiResponse = RIApiResponseSuccess;
            
            [self loadedProduct:product];
            [self removeErrorView];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            self.apiResponse = apiResponse;
            [self removeErrorView];
            if(self.firstLoading)
            {
                NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                self.firstLoading = NO;
            }
            
            if(RIApiResponseMaintenancePage == apiResponse)
            {
                [self showMaintenancePage:@selector(loadCompleteProduct) objects:nil];
            }
            else
            {
                BOOL noConnection = NO;
                if (RIApiResponseNoInternetConnection == apiResponse)
                {
                    noConnection = YES;
                }
                [self showErrorView:noConnection startingY:0.0f selector:@selector(loadCompleteProduct) objects:nil];
            }
            
            [self hideLoading];
        }];
    }
}


- (void)loadedProduct:(RIProduct*) product
{
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
    
    [RIProduct addToRecentlyViewed:product successBlock:nil andFailureBlock:nil];
    self.product = product;
    NSNumber *price = (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue]) ? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
    if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
    {
        [trackingDictionary setValue:[numberOfSessions stringValue] forKey:kRIEventAmountSessions];
    }
    
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    if(VALID_NOTEMPTY([RICustomer getCustomerGender], NSString))
    {
        [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
    }
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
    
    // Since we're sending the converted price, we have to send the currency as EUR.
    // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
    [trackingDictionary setValue:price forKey:kRIEventPriceKey];
    [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
    
    [trackingDictionary setValue:self.product.brand forKey:kRIEventBrandKey];
    
    NSString *discount = @"false";
    if (self.product.maxSavingPercentage.length > 0)
    {
        discount = @"true";
    }
    [trackingDictionary setValue:discount forKey:kRIEventDiscountKey];
    
    if (VALID_NOTEMPTY(self.product.productSimples, NSOrderedSet) && 1 == self.product.productSimples.count)
    {
        self.currentSimple = self.product.productSimples[0];
        if (VALID_NOTEMPTY(self.currentSimple.variation, NSString))
        {
            [trackingDictionary setValue:self.currentSimple.variation forKey:kRIEventSizeKey];
        }
    }
    
    if (VALID_NOTEMPTY(self.product.attributeColor, NSString))
    {
        [trackingDictionary setValue:self.product.attributeColor forKey:kRIEventColorKey];
    }
    
    if(VALID_NOTEMPTY(self.category, RICategory))
    {
        [trackingDictionary setValue:[RICategory getTree:self.category.uid] forKey:kRIEventTreeKey];
    }
    
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
    [trackingDictionary setValue:self.product.brand forKey:kRIEventBrandKey];
    
    NSString *discountPercentage = @"0";
    if(VALID_NOTEMPTY(self.product.maxSavingPercentage, NSString))
    {
        discountPercentage = self.product.maxSavingPercentage;
    }
    
    // Since we're sending the converted price, we have to send the currency as EUR.
    // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
    [trackingDictionary setValue:price forKey:kRIEventPriceKey];
    [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
    
    [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
    
    if(VALID_NOTEMPTY(self.product.avr, NSNumber))
    {
        [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
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
    else if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet))
    {
        NSArray *categoryIds = [self.product.categoryIds array];
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

    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewProduct]
                                              data:[trackingDictionary copy]];
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
    
    [self productLoaded];
}

- (void)retryAddToCart
{
    [self addToCart];
}

#pragma mark - Product loaded

- (void)productLoaded
{
    [self removeSuperviews];

    self.hasLoaddedProduct = YES;
    
    [self.mainScrollView setFrame:CGRectMake(0.0f,
                                             0.0f,
                                             self.view.frame.size.width,
                                             self.view.frame.size.height)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            CGFloat scrollViewsWidth = (self.view.frame.size.width / 2);
            [self.mainScrollView setFrame:CGRectMake(0.0f,
                                                     0.0f,
                                                     scrollViewsWidth,
                                                     self.view.frame.size.height)];
            [self.mainScrollView setHidden:NO];
            
            [self.landscapeScrollView setFrame:CGRectMake(scrollViewsWidth,
                                                          0.0f,
                                                          scrollViewsWidth,
                                                          self.view.frame.size.height)];
            [self.landscapeScrollView setHidden:NO];
        }
        else
        {
            [self.mainScrollView setHidden:NO];
            [self.landscapeScrollView setHidden:YES];
        }
    }
    else
    {
        [self.mainScrollView setHidden:NO];
        [self.landscapeScrollView setHidden:YES];
    }
    
    /*******
     CTA Buttons
     *******/
    
    self.ctaView = [[JAButtonWithBlur alloc] initWithFrame:CGRectZero orientation:self.interfaceOrientation];
    
    BOOL isiPadInLandscape = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            isiPadInLandscape = YES;
        }
    }
    
    if(isiPadInLandscape)
    {
        [self.ctaView setFrame:CGRectMake(self.mainScrollView.frame.size.width,
                                          0.0f,
                                          self.landscapeScrollView.frame.size.width,
                                          self.ctaView.frame.size.height)];
        [self.view addSubview:self.ctaView];
        
        // The JAButton
        [self.landscapeScrollView setFrame:CGRectMake(self.mainScrollView.frame.size.width,
                                                      self.ctaView.frame.size.height,
                                                      self.landscapeScrollView.frame.size.width,
                                                      self.view.frame.size.height - self.ctaView.frame.size.height)];
        
    }
    else
    {
        [self.ctaView setFrame:CGRectMake(0.0f,
                                          self.view.frame.size.height - self.ctaView.frame.size.height,
                                          self.mainScrollView.frame.size.width,
                                          self.ctaView.frame.size.height)];
        [self.view addSubview:self.ctaView];
        
        [self.mainScrollView setFrame:CGRectMake(self.mainScrollView.frame.origin.x,
                                                 self.mainScrollView.frame.origin.y,
                                                 self.mainScrollView.frame.size.width,
                                                 self.mainScrollView.frame.size.height - self.ctaView.frame.size.height)];
    }
    
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"])
    {
        [self.ctaView addButton:STRING_CALL_TO_ORDER
                         target:self
                         action:@selector(callToOrder)];
    }
    
    
    [self.ctaView addButton:STRING_ADD_TO_SHOPPING_CART
                     target:self
                     action:@selector(addToCart)];
    
    [RIProductRatings getRatingsForProductWithUrl:[NSString stringWithFormat:@"%@?rating=1&page=1", self.product.url] //@"http://www.jumia.com.ng/mobapi/v1.4/Asha-302---Black-7546.html?rating=1&page=1"
                                     successBlock:^(RIProductRatings *ratings) {
                                         
                                         self.commentsCount = ratings.reviews.count;
                                         
                                         self.productRatings = ratings;
                                         
                                         [self fillTheViews];
                                         
                                         [self hideLoading];
                                     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                         
                                         [self fillTheViews];
                                         
                                         [self hideLoading];
                                     }];
    
    //make sure wizard is in front
    [self.view bringSubviewToFront:self.wizardView];
}

#pragma mark - Fill the views

- (void)fillTheViews
{
    CGFloat mainScrollViewY = 6.0f;
    CGFloat landscapeScrollViewY = 0.0f;
    
    BOOL isiPadInLandscape = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            isiPadInLandscape = YES;
        }
    }
    
    /*******
     Image Section
     *******/
    
    self.imageSection = [JAPDVImageSection getNewPDVImageSection];
    [self.imageSection setupWithFrame:self.mainScrollView.frame product:self.product preSelectedSize:self.preSelectedSize];
    self.imageSection.delegate = self;
    [self.imageSection.wishListButton addTarget:self
                                         action:@selector(addToFavoritesPressed:)
                               forControlEvents:UIControlEventTouchUpInside];
    self.imageSection.wishListButton.selected = VALID_NOTEMPTY(self.product.favoriteAddDate, NSDate);
    self.imageSection.frame = CGRectMake(6.0f,
                                         mainScrollViewY,
                                         self.imageSection.frame.size.width,
                                         self.imageSection.frame.size.height);
    
    [self.imageSection.shareButton addTarget:self
                                      action:@selector(shareProduct)
                            forControlEvents:UIControlEventTouchUpInside];
    
    if(isiPadInLandscape)
    {
        [self.imageSection.sizeClickableView addTarget:self
                                                action:@selector(showSizePicker)
                                      forControlEvents:UIControlEventTouchUpInside];
    }
    [self.mainScrollView addSubview:self.imageSection];
    
    
    if (VALID_NOTEMPTY(self.product.variations, NSOrderedSet))
    {
        self.variationsSection = [JAPDVVariations getNewPDVVariationsSection];
        [self.variationsSection setupWithFrame:self.mainScrollView.frame];
    }
    
    mainScrollViewY += (6.0f + self.imageSection.frame.size.height);
    
    /*******
     Colors / Variation
     *******/
    
    if (VALID_NOTEMPTY(self.product.variations, NSOrderedSet))
    {
        self.variationsSection.frame = CGRectMake(6.0f,
                                                  mainScrollViewY,
                                                  self.variationsSection.frame.size.width,
                                                  self.variationsSection.frame.size.height);
        
        self.variationsSection.titleLabel.text = STRING_VARIATIONS;
        
        CGFloat currentX = 0.0;
        
        CGFloat viewHeight = self.variationsSection.variationsScrollView.frame.size.height;
        CGFloat imageHeight = 30.0f;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            imageHeight = 71.0f;
        }
        
        for (int i = 0; i < [self.product.variations count]; i++)
        {
            RIVariation *variation = [self.product.variations objectAtIndex:i];
            
            JAClickableView* variationClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                                        0.0f,
                                                                                                        viewHeight,
                                                                                                        viewHeight)];
            variationClickableView.tag = i;
            [variationClickableView addTarget:self
                                       action:@selector(openVariation:)
                             forControlEvents:UIControlEventTouchUpInside];
            [self.variationsSection.variationsScrollView addSubview:variationClickableView];
            
            UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake((variationClickableView.bounds.size.width - imageHeight) / 2,
                                                                                      (variationClickableView.bounds.size.height - imageHeight) / 2,
                                                                                      imageHeight,
                                                                                      imageHeight)];
            [newImageView setImageWithURL:[NSURL URLWithString:variation.image.url]
                         placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
            [newImageView changeImageHeight:imageHeight andWidth:0.0f];
            [variationClickableView addSubview:newImageView];
            
            currentX += variationClickableView.frame.size.width;
        }
        
        [self.variationsSection.variationsScrollView setContentSize:CGSizeMake(currentX,
                                                                               viewHeight
                                                                               )];
        
        [self.mainScrollView addSubview:self.variationsSection];
        
        mainScrollViewY += (6.0f + self.variationsSection.frame.size.height);
    }
    
    /*******
     Other Offers Section
     *******/
    
    if (isiPadInLandscape) {
        if (VALID_NOTEMPTY(self.product.offersTotal, NSNumber) && 0 < [self.product.offersTotal integerValue]) {
            self.otherOffersView = [JAOtherOffersView getNewOtherOffersView];
            
            [self.otherOffersView setupWithFrame:self.mainScrollView.frame product:self.product];
            [self.otherOffersView setFrame:CGRectMake(6.0f,
                                                      mainScrollViewY,
                                                      self.otherOffersView.frame.size.width,
                                                      self.otherOffersView.frame.size.height)];
            
            [self.mainScrollView addSubview:self.otherOffersView];
        }
    }

    
    /*******
     Product Info Section
     *******/
    
    self.productInfoSection = [JAPDVProductInfo getNewPDVProductInfoSection];
    [self.productInfoSection setupWithFrame:self.mainScrollView.frame product:self.product preSelectedSize:self.preSelectedSize];
    
    [self.productInfoSection.reviewsClickableView addTarget:self
                                                     action:@selector(goToRatinsMainScreen)
                                           forControlEvents:UIControlEventTouchUpInside];
    
    if (isiPadInLandscape)
    {
        [self.productInfoSection.productFeaturesMore addTarget:self
                                                        action:@selector(gotoDetails)
                                              forControlEvents:UIControlEventTouchUpInside];
        
        [self.productInfoSection.productDescriptionMore addTarget:self
                                                           action:@selector(gotoDetails)
                                                 forControlEvents:UIControlEventTouchUpInside];
        
        self.productInfoSection.frame = CGRectMake(6,
                                                   landscapeScrollViewY,
                                                   self.productInfoSection.frame.size.width,
                                                   self.productInfoSection.frame.size.height);
        
        [self.landscapeScrollView addSubview:self.productInfoSection];
        
        landscapeScrollViewY += (6.0f + self.productInfoSection.frame.size.height);
    }
    else
    {
        [self.productInfoSection.specificationsClickableView addTarget:self
                                                                action:@selector(gotoDetails)
                                                      forControlEvents:UIControlEventTouchUpInside];
        
        self.productInfoSection.frame = CGRectMake(6,
                                                   mainScrollViewY,
                                                   self.productInfoSection.frame.size.width,
                                                   self.productInfoSection.frame.size.height);
        
        [self.mainScrollView addSubview:self.productInfoSection];
        
        [self.productInfoSection.sizeClickableView addTarget:self
                                                      action:@selector(showSizePicker)
                                            forControlEvents:UIControlEventTouchUpInside];
        
        mainScrollViewY += (6.0f + self.productInfoSection.frame.size.height);
    }
    
    /*******
     Related Items
     *******/
    
    [self.relatedItems removeFromSuperview];
    
    if (self.fromCatalogue && VALID_NOTEMPTY(self.arrayWithRelatedItems, NSArray) && 1 < self.arrayWithRelatedItems.count)
    {
        self.relatedItems = [JAPDVRelatedItem getNewPDVRelatedItemSection];
        [self.relatedItems setupWithFrame:self.mainScrollView.frame];
        self.relatedItems.topLabel.text = STRING_RELATED_ITEMS;
        
        CGFloat relatedItemStart = 5.0f;
        
        for (int i = 0; i < self.arrayWithRelatedItems.count; i++) {
            RIProduct* product = [self.arrayWithRelatedItems objectAtIndex:i];
            if (![product.sku isEqualToString:self.product.sku])
            {
                JAPDVSingleRelatedItem *singleItem = [JAPDVSingleRelatedItem getNewPDVSingleRelatedItem];
                singleItem.tag = i;
                [singleItem addTarget:self
                               action:@selector(selectedRelatedItem:)
                     forControlEvents:UIControlEventTouchUpInside];
                
                CGRect tempFrame = singleItem.frame;
                tempFrame.origin.x = relatedItemStart;
                singleItem.frame = tempFrame;
                
                if (VALID_NOTEMPTY(product.images, NSOrderedSet))
                {
                    RIImage *imageTemp = [product.images firstObject];
                    
                    [singleItem.imageViewItem setImageWithURL:[NSURL URLWithString:imageTemp.url]
                                             placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
                }
                
                singleItem.labelBrand.text = product.brand;
                singleItem.labelName.text = product.name;
                singleItem.labelPrice.text = product.priceFormatted;
                singleItem.product = product;
                
                [self.relatedItems.relatedItemsScrollView addSubview:singleItem];
                
                relatedItemStart += singleItem.frame.size.width + 5.0f;
            }
        }
        
        [self.relatedItems.relatedItemsScrollView setContentSize:CGSizeMake(relatedItemStart, self.relatedItems.relatedItemsScrollView.frame.size.height)];
        
        if(isiPadInLandscape)
        {
            self.relatedItems.frame = CGRectMake(6.0f,
                                                 landscapeScrollViewY,
                                                 self.relatedItems.frame.size.width,
                                                 self.relatedItems.frame.size.height);
            [self.landscapeScrollView addSubview:self.relatedItems];
            
            landscapeScrollViewY += (6.0f + self.relatedItems.frame.size.height);
        }
        else
        {
            self.relatedItems.frame = CGRectMake(6.0f,
                                                 mainScrollViewY,
                                                 self.relatedItems.frame.size.width,
                                                 self.relatedItems.frame.size.height);
            [self.mainScrollView addSubview:self.relatedItems];
            
            mainScrollViewY += (6.0f + self.relatedItems.frame.size.height);
        }
    }
    
    if(isiPadInLandscape)
    {
        self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, mainScrollViewY);
        self.landscapeScrollView.contentSize = CGSizeMake(self.landscapeScrollView.frame.size.width, landscapeScrollViewY);
    }
    else
    {
        self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, mainScrollViewY);
    }
    
    if(VALID(self.picker, JAPicker))
    {
        [self showSizePicker];
    }
    
    //make sure wizard is in front
    [self.view bringSubviewToFront:self.wizardView];
}


#pragma mark - Actions

- (void) openVariation:(UIControl*)sender
{
    RIVariation *variation = [self.product.variations objectAtIndex:sender.tag];
    self.productUrl = variation.link;
    [self loadCompleteProduct];
}

- (void)selectedRelatedItem:(UIControl*)sender
{
    RIProduct *tempProduct = [self.arrayWithRelatedItems objectAtIndex:sender.tag];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:@{ @"url" : tempProduct.url,
                                                                  @"previousCategory" : @"",
                                                                  @"show_back_button" : [NSNumber numberWithBool:self.showBackButton],
                                                                  @"delegate" : self.delegate}];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:tempProduct.sku forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"RelatedItem" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:tempProduct.price forKey:kRIEventValueKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRelatedItem]
                                              data:[trackingDictionary copy]];
}

- (void)gotoDetails
{
    NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(self.product, RIProduct))
    {
        [userInfo setObject:self.product forKey:@"product"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowProductSpecificationScreenNotification object:nil userInfo:userInfo];
}

- (void)goToRatinsMainScreen
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation || UIInterfaceOrientationLandscapeRight == self.interfaceOrientation))
    {
        NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
        if(VALID_NOTEMPTY(self.product, RIProduct))
        {
            [userInfo setObject:self.product forKey:@"product"];
        }
        if(VALID_NOTEMPTY(self.productRatings, RIProductRatings))
        {
            [userInfo setObject:self.productRatings forKey:@"productRatings"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowRatingsScreenNotification object:nil userInfo:userInfo];
    }
    else
    {
        if (0 == self.commentsCount)
        {
            
            NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
            if(VALID_NOTEMPTY(self.product, RIProduct))
            {
                [userInfo setObject:self.product forKey:@"product"];
            }
            if(VALID_NOTEMPTY(self.productRatings, RIProductRatings))
            {
                [userInfo setObject:self.productRatings forKey:@"productRatings"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowNewRatingScreenNotification object:nil userInfo:userInfo];
        }
        else
        {
            NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
            if(VALID_NOTEMPTY(self.product, RIProduct))
            {
                [userInfo setObject:self.product forKey:@"product"];
            }
            if(VALID_NOTEMPTY(self.productRatings, RIProductRatings))
            {
                [userInfo setObject:self.productRatings forKey:@"productRatings"];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowRatingsScreenNotification object:nil userInfo:userInfo];
        }
    }
}

- (void)shareProduct
{
    

    NSString *url = self.product.url;

    if(NSNotFound != [url rangeOfString:RI_MOBAPI_PREFIX].location)
    {
        url = [url stringByReplacingOccurrencesOfString:RI_MOBAPI_PREFIX withString:@""];
    }
    
    if(NSNotFound != [url rangeOfString:RI_API_VERSION].location)
    {
        url = [url stringByReplacingOccurrencesOfString:RI_API_VERSION withString:@""];
    }
    
    NSArray *objectsToShare = @[STRING_SHARE_PRODUCT_MESSAGE, [NSURL URLWithString:url]];
    

    UIActivity *fbmActivity = [[AQSFacebookMessengerActivity alloc] init];
    
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:@[fbmActivity]];
    
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
    
    [activityController setValue:STRING_SHARE_OBJECT
                         forKey:@"subject"];
    

    activityController.completionHandler = ^(NSString *activityType, BOOL completed)
    {
        NSString *type = @"Shared";
        NSNumber *eventType = [NSNumber numberWithInt:RIEventShareOther];
        if ([activityType isEqualToString:UIActivityTypeMail])
        {
            type = @"Email";
            eventType = [NSNumber numberWithInt:RIEventShareEmail];
        }
        else if ([activityType isEqualToString:UIActivityTypePostToFacebook])
        {
            type = @"Facebook";
            eventType = [NSNumber numberWithInt:RIEventShareFacebook];
        }
        else if ([activityType isEqualToString:UIActivityTypePostToTwitter])
        {
            type = @"Twitter";
            eventType = [NSNumber numberWithInt:RIEventShareTwitter];
        }
        else if([activityType isEqualToString:UIActivityTypeMessage])
        {
            type = @"SMS";
            eventType = [NSNumber numberWithInt:RIEventShareSMS];
        }
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
        [trackingDictionary setValue:type forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
        [trackingDictionary setValue:self.product.price forKey:kRIEventValueKey];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
        [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];

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
        else if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet))
        {
            NSArray *categoryIds = [self.product.categoryIds array];
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
        
        [[RITrackingWrapper sharedInstance] trackEvent:eventType
                                                  data:[trackingDictionary copy]];
    };

    
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        CGRect sharePopoverRect = CGRectMake(self.imageSection.shareButton.frame.size.width,
                                             self.imageSection.shareButton.frame.size.height / 2,
                                             0.0f,
                                             0.0f);
        
        UIPopoverController* popoverController =
        [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popoverController presentPopoverFromRect:sharePopoverRect inView:self.imageSection.shareButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        popoverController.passthroughViews = nil;
        self.currentPopoverController = popoverController;
    }
    else
    {
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)addToCart
{
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && ([self.imageSection.sizeLabel.text isEqualToString:STRING_SIZE]))
    {
        self.openPickerFromCart = YES;
        [self showSizePicker];
    }
    else if ([self.productInfoSection.sizeLabel.text isEqualToString:STRING_SIZE])
    {
        self.openPickerFromCart = YES;
        [self showSizePicker];
    }
    else
    {
        [self showLoading];
        
        [RICart addProductWithQuantity:@"1"
                                   sku:self.product.sku
                                simple:self.currentSimple.sku
                      withSuccessBlock:^(RICart *cart) {

                          NSNumber *price = (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue] > 0.0f)? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;

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
                          // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
                          [trackingDictionary setValue:price forKey:kRIEventPriceKey];
                          [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
                          
                          [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
                          [trackingDictionary setValue:self.product.name forKey:kRIEventProductNameKey];
                          
                          if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet))
                          {
                              NSArray *categoryIds = [self.product.categoryIds array];
                              [trackingDictionary setValue:[categoryIds objectAtIndex:0] forKey:kRIEventCategoryIdKey];
                          }
                          
                          [trackingDictionary setValue:self.product.brand forKey:kRIEventBrandKey];
                          
                          NSString *discountPercentage = @"0";
                          if(VALID_NOTEMPTY(self.product.maxSavingPercentage, NSString))
                          {
                              discountPercentage = self.product.maxSavingPercentage;
                          }
                          [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
                          [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
                          [trackingDictionary setValue:@"1" forKey:kRIEventQuantityKey];
                          [trackingDictionary setValue:@"Product Detail screen" forKey:kRIEventLocationKey];
                          
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
                          else if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet))
                          {
                              NSArray *categoryIds = [self.product.categoryIds array];
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
                          
                          [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToCart]
                                                                    data:[trackingDictionary copy]];
                          
                          float value = [price floatValue];
                          [FBAppEvents logEvent:FBAppEventNameAddedToCart
                                     valueToSum:value
                                     parameters:@{ FBAppEventParameterNameCurrency    : @"EUR",
                                                   FBAppEventParameterNameContentType : self.product.name,
                                                   FBAppEventParameterNameContentID   : self.product.sku}];
                           
                          NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                          [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                          
                          [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
                          
                          [self hideLoading];
                          
                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                          
                          [self hideLoading];
                          
                          NSString *addToCartError = STRING_ERROR_ADDING_TO_CART;
                          if (RIApiResponseNoInternetConnection == apiResponse)
                          {
                              addToCartError = STRING_NO_CONNECTION;
                          }
                          
                          [self showMessage:addToCartError success:NO];
                      }];
    }
}

- (void)callToOrder
{
    [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCallToOrder]
                                                  data:[trackingDictionary copy]];
        
        
        NSString *phoneNumber = [@"tel://" stringByAppendingString:configuration.phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
    }];
}

- (void)showSizePicker
{
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    
    self.pickerDataSource = [NSMutableArray new];
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    if(VALID_NOTEMPTY(self.product.productSimples, NSOrderedSet))
    {
        for (RIProductSimple *simple in self.product.productSimples)
        {
            if ([simple.quantity integerValue] > 0)
            {
                [self.pickerDataSource addObject:simple];
                [dataSource addObject:simple.variation];
            }
        }
    }
    
    NSString* sizeGuideTitle = nil;
    if (VALID_NOTEMPTY(self.product.sizeGuideUrl, NSString)) {
        sizeGuideTitle = STRING_SIZE_GUIDE;
    }
    [self.picker setDataSourceArray:[dataSource copy]
                       previousText:self.productInfoSection.sizeLabel.text
                    leftButtonTitle:sizeGuideTitle];
    
    CGFloat pickerViewHeight = self.view.frame.size.height;
    CGFloat pickerViewWidth = self.view.frame.size.width;
    [self.picker setFrame:CGRectMake(0.0f,
                                     pickerViewHeight,
                                     pickerViewWidth,
                                     pickerViewHeight)];
    [self.view addSubview:self.picker];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.picker setFrame:CGRectMake(0.0f,
                                                          0.0f,
                                                          pickerViewWidth,
                                                          pickerViewHeight)];
                     }];
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow
{
    self.currentSimple = [self.pickerDataSource objectAtIndex:selectedRow];
    
    NSString* option = self.currentSimple.variation;
    if (ISEMPTY(option)) {
        option = @"";
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            [self.imageSection.sizeLabel setText:option];
        }
        else
        {
            [self.productInfoSection.sizeLabel setText:option];
        }
    }
    else
    {
        [self.productInfoSection.sizeLabel setText:option];
    }
    
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                         
                         if (self.openPickerFromCart)
                         {
                             self.openPickerFromCart = NO;
                             [self addToCart];
                         }
                     }];
}

- (void)closePicker
{
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                     }];
}

- (void)leftButtonPressed;
{
    if (VALID_NOTEMPTY(self.product.sizeGuideUrl, NSString)) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self.product.sizeGuideUrl, @"sizeGuideUrl", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSizeGuideNotification object:nil userInfo:dic];
    }
}

#pragma mark JAPDVImageSectionDelegate

- (void)imageClickedAtIndex:(NSInteger)index
{
    [self presentGalleryAtIndex:index];
}

- (void)presentGalleryAtIndex:(NSInteger)index;
{
    if(VALID(self.gallery, JAPDVGalleryView))
    {
        [self.gallery removeFromSuperview];
    }
    
    self.gallery = [JAPDVGalleryView getNewJAPDVGalleryView];
    self.gallery.delegate = self;
    
    UIView *gallerySuperView = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;
    
    CGFloat width = gallerySuperView.frame.size.width;
    CGFloat height = gallerySuperView.frame.size.height;
    
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        if(width < gallerySuperView.frame.size.height)
        {
            width = gallerySuperView.frame.size.height;
            height = gallerySuperView.frame.size.width;
        }
    }
    else
    {
        if(width > gallerySuperView.frame.size.height)
        {
            width = gallerySuperView.frame.size.height;
            height = gallerySuperView.frame.size.width;
        }
    }
    
    [self.gallery loadGalleryWithArray:[self.product.images array]
                                 frame:CGRectMake(0.0f, 0.0f, width, height)
                               atIndex:index];
    
    CGRect oldFrame = self.gallery.frame;
    CGRect newFrame = oldFrame;
    newFrame.origin.y = self.gallery.frame.size.height;
    self.gallery.frame = newFrame;
    [gallerySuperView addSubview:self.gallery];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.gallery.frame = oldFrame;
                     }];
}

- (void)dismissGallery
{
    CGRect newFrame = self.gallery.frame;
    newFrame.origin.y = self.gallery.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.gallery.frame = newFrame;
                     } completion:^(BOOL finished) {
                         [self.gallery removeFromSuperview];
                         self.gallery = nil;
                     }];
}

- (void)addToFavoritesPressed:(UIButton*)button
{
    button.selected = !button.selected;
    
    NSNumber *price = (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue] > 0.0f)? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;
    
    if (button.selected)
    {
        //add to favorites
        [RIProduct addToFavorites:self.product successBlock:^{
            //[self hideLoading];

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
            [trackingDictionary setValue:self.product.brand forKey:kRIEventBrandKey];
            
            NSString *discountPercentage = @"0";
            if(VALID_NOTEMPTY(self.product.maxSavingPercentage, NSString))
            {
                discountPercentage = self.product.maxSavingPercentage;
            }
            [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
            [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
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
            else if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet))
            {
                NSArray *categoryIds = [self.product.categoryIds array];
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
            [FBAppEvents logEvent:FBAppEventNameAddedToWishlist
                       valueToSum:value
                       parameters:@{ FBAppEventParameterNameCurrency    : @"EUR",
                                     FBAppEventParameterNameContentType : self.product.name,
                                     FBAppEventParameterNameContentID   : self.product.sku}];
            
            if (button.selected) {
                self.product.favoriteAddDate = [NSDate date];
            } else {
                self.product.favoriteAddDate = nil;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(changedFavoriteStateOfProduct:)]) {
                [self.delegate changedFavoriteStateOfProduct:self.product];
            }
            
            [self showMessage:STRING_ADDED_TO_WISHLIST success:YES];
            
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            
            [self showMessage:STRING_ERROR_ADDING_TO_WISHLIST success:NO];
        }];
    }
    else
    {
        [RIProduct removeFromFavorites:self.product successBlock:^(void) {
            //update favoriteProducts
            //[self hideLoading];
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"RemoveFromWishlist" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
            [trackingDictionary setValue:price  forKey:kRIEventValueKey];
            
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
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                      data:[trackingDictionary copy]];
            
            [self showMessage:STRING_REMOVED_FROM_WISHLIST success:YES];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(changedFavoriteStateOfProduct:)]) {
                [self.delegate changedFavoriteStateOfProduct:self.product];
            }
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            
            [self showMessage:STRING_ERROR_ADDING_TO_WISHLIST success:NO];
        }];
    }
}

#pragma mark - Activity delegate

- (void)willDismissActivityViewController:(JAActivityViewController *)activityViewController
{
    // Track sharing here :)
}

@end

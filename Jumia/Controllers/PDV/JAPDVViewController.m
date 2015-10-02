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
#import "JARatingsViewController.h"
#import "JAProductDetailsViewController.h"
#import "JANewRatingViewController.h"
#import "JAAppDelegate.h"
#import "JAActivityViewController.h"
#import "RICountry.h"
#import "JAButtonWithBlur.h"
#import "JAUtils.h"
#import "RICustomer.h"
#import "JAPDVWizardView.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import "AQSFacebookMessengerActivity.h"
#import "JAPDVBundles.h"
#import "JAPDVBundleSingleItem.h"
#import "RIProduct.h"
#import "JAOtherOffersView.h"
#import "JBWhatsAppActivity.h"
#import "JAProductInfoHeaderLine.h"
#import "JABottomBar.h"

@interface JAPDVViewController ()
<
JAPDVGalleryDelegate,
JAPickerDelegate,
JAActivityViewControllerDelegate
>
{
    BOOL _needRefreshProduct;
}

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UIScrollView *landscapeScrollView;
@property (strong, nonatomic) RIProductRatings *productRatings;
@property (strong, nonatomic) JAPDVImageSection *imageSection;
@property (strong, nonatomic) JAPDVVariations *variationsSection;
@property (strong, nonatomic) JAPDVProductInfo *productInfoSection;
@property (strong, nonatomic) JAPDVRelatedItem *relatedItemsView;
//@property (strong, nonatomic) JAPDVRelatedItem *relatedItems;
@property (strong, nonatomic) JAPDVBundles *bundleLayout;
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (strong, nonatomic) JAPDVGallery *galleryPaged;
//@property (strong, nonatomic) JAButtonWithBlur *ctaView;
@property (strong, nonatomic) JABottomBar *ctaView;
@property (assign, nonatomic) NSInteger commentsCount;
@property (assign, nonatomic) BOOL openPickerFromCart;
@property (strong, nonatomic) RIProductSimple *currentSimple;
@property (nonatomic, strong) JAPDVWizardView* wizardView;
@property (assign, nonatomic) RIApiResponse apiResponse;

@property (strong, nonatomic) RIBundle *productBundle;
@property (strong, nonatomic) NSMutableArray *bundleSingleItemsArray;
@property (nonatomic, strong) JAOtherOffersView* otherOffersView;
@property (nonatomic, assign) NSInteger indexOfBundleRelatedToSizePicker;

@property (nonatomic, assign) BOOL hasLoaddedProduct;

@property (strong, nonatomic) UIPopoverController *currentPopoverController;

@end

@implementation JAPDVViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchBarIsVisible = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
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
        [self.navBarLayout setShowBackButton:YES];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductChangedNotification object:self.productUrl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL alreadyShowedWizardPDV = [[NSUserDefaults standardUserDefaults] boolForKey:kJAPDVWizardUserDefaultsKey];
    if(alreadyShowedWizardPDV == NO)
    {
        [self hideLoading];
        self.wizardView = [[JAPDVWizardView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.wizardView];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJAPDVWizardUserDefaultsKey];
    }
    
    if(self.hasLoaddedProduct)
    {
        [self removeSuperviews];
        if (_needRefreshProduct)
            [self loadCompleteProduct];
        else
            [self fillTheViews];
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
                [self trackingEventLoadingTime];
                self.firstLoading = NO;
            }
        }
    }
}

- (void)updatedProduct:(NSNotification*)notification
{
    NSString* productUrl = notification.object;
    if (!VALID_NOTEMPTY(productUrl, NSString) || [self.productUrl isEqualToString:productUrl]) {
        _needRefreshProduct = YES;
    }
}

- (void)setProduct:(RIProduct *)product
{
    _product = product;
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
    
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self trackingEventScreenName:@"ShopProductDetail"];
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
    
    if(VALID_NOTEMPTY(self.galleryPaged, JAPDVGallery))
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
        
        [self.galleryPaged reloadFrame:CGRectMake(0.0f, 0.0f, width, height)];
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self fillTheViews];
    [self hideLoading];
    
    if(VALID_NOTEMPTY(self.wizardView, JAPDVWizardView))
    {
        [self.wizardView reloadForFrame:self.view.bounds];
    }
    
    if(VALID_NOTEMPTY(self.galleryPaged, JAPDVGallery))
    {
        UIView *gallerySuperView = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;
        
        CGFloat width = gallerySuperView.frame.size.width;
        CGFloat height = gallerySuperView.frame.size.height;
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        
        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            if(width < height)
            {
                width = gallerySuperView.frame.size.height;
                height = gallerySuperView.frame.size.width;
            }
            if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
                statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
        }
        else
        {
            if(width > height)
            {
                width = gallerySuperView.frame.size.height;
                height = gallerySuperView.frame.size.width;
            }
        }
        
        [self.galleryPaged reloadFrame:CGRectMake(0.0f, statusBarHeight, width, height)];
        [self.view bringSubviewToFront:self.galleryPaged];
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
    if(self.apiResponse == RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    self.hasLoaddedProduct = NO;
    
    if (VALID_NOTEMPTY(self.productUrl, NSString)) {
        [RIProduct getCompleteProductWithUrl:self.productUrl successBlock:^(id product) {
            _needRefreshProduct = NO;
            self.apiResponse = RIApiResponseSuccess;
            
            [self loadedProduct:product];
            [self removeErrorView];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            self.apiResponse = apiResponse;
            if(self.firstLoading)
            {
                [self trackingEventLoadingTime];
                self.firstLoading = NO;
            }
            
            if(RIApiResponseMaintenancePage == apiResponse)
            {
                [self showMaintenancePage:@selector(loadCompleteProduct) objects:nil];
            }
            else if(RIApiResponseKickoutView == apiResponse)
            {
                [self showKickoutView:@selector(loadCompleteProduct) objects:nil];
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
            if(self.firstLoading)
            {
                [self trackingEventLoadingTime];
                self.firstLoading = NO;
            }
            
            if(RIApiResponseMaintenancePage == apiResponse)
            {
                [self showMaintenancePage:@selector(loadCompleteProduct) objects:nil];
            }
            else if(RIApiResponseKickoutView == apiResponse)
            {
                [self showKickoutView:@selector(loadCompleteProduct) objects:nil];
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
    
    self.product = product;
    [self setTitle:product.brand];
    [self.wizardView setHasNoSeller:product.seller?NO:YES];
    
    [self trackingEventViewProduct:product];
    
    if(self.firstLoading)
    {
        [self trackingEventLoadingTime];
        self.firstLoading = NO;
    }
    
    [RIProduct addToRecentlyViewed:product successBlock:^(RIProduct *product) {
        NSDictionary *userInfo = nil;
        if (self.product.favoriteAddDate) {
            userInfo = [NSDictionary dictionaryWithObject:self.product.favoriteAddDate forKey:@"favoriteAddDate"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kProductChangedNotification
                                                            object:self.productUrl
                                                          userInfo:userInfo];
        [self requestBundles];
    } andFailureBlock:nil];
    
    [self trackingEventMostViewedBrand];
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
    
    [self.mainScrollView setFrame:[self viewBounds]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            CGRect bounds = [self viewBounds];
            CGFloat scrollViewsWidth = bounds.size.width / 2;
            [self.mainScrollView setFrame:CGRectMake(bounds.origin.x,
                                                     bounds.origin.y,
                                                     scrollViewsWidth,
                                                     bounds.size.height)];
            [self.mainScrollView setHidden:NO];
            
            [self.landscapeScrollView setFrame:CGRectMake(scrollViewsWidth,
                                                          bounds.origin.y,
                                                          scrollViewsWidth,
                                                          bounds.size.height)];
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
    
    self.ctaView = [[JABottomBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 49)];
//    self.ctaView = [[JAButtonWithBlur alloc] initWithFrame:CGRectZero orientation:self.interfaceOrientation];
    
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
                                          self.mainScrollView.frame.origin.y,
                                          self.landscapeScrollView.frame.size.width,
                                          self.ctaView.frame.size.height)];
        [self.view addSubview:self.ctaView];
        
        // The JAButton
        [self.landscapeScrollView setFrame:CGRectMake(self.mainScrollView.frame.size.width,
                                                      CGRectGetMaxY(self.ctaView.frame),
                                                      self.landscapeScrollView.frame.size.width,
                                                      self.mainScrollView.frame.size.height - self.ctaView.frame.size.height)];
        
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
    
    [self.ctaView addSmallButton:[UIImage imageNamed:@"placeholder_pdv"] target:self action:@selector(shareProduct)];
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] || [[device model] isEqualToString:@"iPhone Simulator"])
    {
//        [self.ctaView addButton:STRING_CALL_TO_ORDER
//                         target:self
//                         action:@selector(callToOrder)];
        [self.ctaView addSmallButton:[UIImage imageNamed:@"placeholder_pdv"] target:self action:@selector(callToOrder)];
    }
    
    
    [self.ctaView addButton:STRING_BUY_NOW target:self action:@selector(addToCart)];
//    [self.ctaView addButton:STRING_ADD_TO_SHOPPING_CART
//                     target:self
//                     action:@selector(addToCart)];
    
    //make sure wizard is in front
    [self.view bringSubviewToFront:self.wizardView];
}

- (void)requestBundles
{
    //fill the views
    [RIProduct getBundleWithSku:self.product.sku successBlock:^(RIBundle* bundle) {
        self.productBundle = bundle;
        
        [self fillTheViews];
        
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        
        self.productBundle = nil;
        
        [self fillTheViews];
        
        [self.bundleLayout removeFromSuperview];
        
        [self hideLoading];
        
    }];
    
}

#pragma mark - Fill the views

- (void)fillTheViews
{
    [self productLoaded];
    
    CGFloat mainScrollViewY = .0f;
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
    
    self.imageSection = [JAPDVImageSection getNewPDVImageSection:self.product.fashion];
    CGRect imageSectionFrame = CGRectMake(0, 0, self.view.width, self.mainScrollView.height);
    [self.imageSection setupWithFrame:imageSectionFrame product:self.product preSelectedSize:self.preSelectedSize];
    self.imageSection.delegate = self;
    [self.imageSection.wishListButton addTarget:self
                                         action:@selector(addToFavoritesPressed:)
                               forControlEvents:UIControlEventTouchUpInside];
    self.imageSection.wishListButton.selected = VALID_NOTEMPTY(self.product.favoriteAddDate, NSDate);
    self.imageSection.frame = CGRectMake(0.0f,
                                         mainScrollViewY,
                                         self.imageSection.frame.size.width,
                                         self.imageSection.frame.size.height);
    
//    [self.imageSection.shareButton addTarget:self
//                                      action:@selector(shareProduct)
//                            forControlEvents:UIControlEventTouchUpInside];
    
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
        
        [self.variationsSection.variationsScrollView setFrame:CGRectMake(6.0f,
                                                                         _variationsSection.variationsScrollView.frame.origin.y,
                                                                         _variationsSection.bounds.size.width - 12.0f,
                                                                         _variationsSection.variationsScrollView.bounds.size.height)];
        
        self.variationsSection.titleLabel.text = STRING_MORE_CHOICES;
        
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
                         placeholderImage:[UIImage imageNamed:@"placeholder_scrollable"]];
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
    
    self.productInfoSection = [[JAPDVProductInfo alloc] init];
    CGRect productInfoSectionFrame = CGRectMake(0, 6, self.view.width, 0);
    [self.productInfoSection setupWithFrame:productInfoSectionFrame product:self.product preSelectedSize:self.preSelectedSize];
    [self.productInfoSection addReviewsTarget:self action:@selector(goToRatinsMainScreen)];
    [self.productInfoSection addSpecificationsTarget:self action:@selector(gotoDetails)];
    [self.productInfoSection addSizeTarget:self action:@selector(showSizePicker)];
    
    
    if (isiPadInLandscape)
    {
        
        [self.productInfoSection setY:landscapeScrollViewY];
        
        [self.landscapeScrollView addSubview:self.productInfoSection];
        
        landscapeScrollViewY += (6.0f + self.productInfoSection.frame.size.height);
    }
    else
    {
        
        [self.productInfoSection setY:mainScrollViewY];
        
        [self.mainScrollView addSubview:self.productInfoSection];
        
//        [self.productInfoSection.sizeClickableView addTarget:self
//                                                      action:@selector(showSizePicker)
//                                            forControlEvents:UIControlEventTouchUpInside];
        
        mainScrollViewY += (self.productInfoSection.frame.size.height);
    }
    
    /*******
     Bundles
     *******/
    
    [self.bundleLayout removeFromSuperview];
    
    if (VALID_NOTEMPTY(self.productBundle, RIBundle)) {
        CGFloat bundleSingleItemStart = 5.0f;
        self.bundleSingleItemsArray = [NSMutableArray new];

        BOOL atLeastOneProductHasSize = NO;
        
        for(int i= 0;
            i<self.productBundle.bundleProducts.count;
            i++)
        {
            
            RIProduct *bundleProduct = [self.productBundle.bundleProducts objectAtIndex:i];
            
            JAPDVBundleSingleItem* bundleSingleItem;
            if (VALID_NOTEMPTY(bundleProduct.productSimples, NSOrderedSet) && 1 < bundleProduct.productSimples.count) {
                
                bundleSingleItem = [JAPDVBundleSingleItem getNewPDVBundleSingleItemWithSize];
                
                atLeastOneProductHasSize = YES;
                
                [bundleSingleItem.sizeClickableView setTitle:STRING_SIZE forState:UIControlStateNormal];
                [bundleSingleItem.sizeClickableView setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
                [bundleSingleItem.sizeClickableView setFont:[UIFont fontWithName:kFontRegularName size:14.0f]];
                bundleSingleItem.sizeClickableView.tag = i;
                [bundleSingleItem.sizeClickableView addTarget:self
                                                       action:@selector(showSizePickerForBundleSingleItem:)
                                             forControlEvents:UIControlEventTouchUpInside];
            } else {
                bundleSingleItem = [JAPDVBundleSingleItem getNewPDVBundleSingleItem];
            }
            
            bundleSingleItem.selectedProduct.tag = i;
            
            [bundleSingleItem.selectedProduct setImage:[UIImage imageNamed:@"check_empty"] forState:UIControlStateNormal];
            [bundleSingleItem.selectedProduct setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
            
            [self.bundleSingleItemsArray addObject:bundleSingleItem];
            
            [bundleSingleItem.selectedProduct addTarget:self
                                                 action:@selector(checkBundle:)
                                       forControlEvents:UIControlEventTouchUpInside];
            
            CGRect tempFrame = bundleSingleItem.frame;
            tempFrame.origin.x = bundleSingleItemStart;
            bundleSingleItem.frame = tempFrame;
            
            if (VALID_NOTEMPTY(bundleProduct.images, NSOrderedSet))
            {
                RIImage *imageTemp = [bundleProduct.images firstObject];
                
                [bundleSingleItem.productImageView setImageWithURL:[NSURL URLWithString:imageTemp.url]
                                                  placeholderImage:[UIImage imageNamed:@"placeholder_scrollable"]];
            }
            
            bundleSingleItem.productNameLabel.text = bundleProduct.name;
            bundleSingleItem.productTypeLabel.text = bundleProduct.brand;
            if (VALID_NOTEMPTY(bundleProduct.specialPrice, NSNumber) && 0.0f == [bundleProduct.specialPrice floatValue]) {
                bundleSingleItem.productPriceLabel.text = bundleProduct.priceFormatted;
            } else {
                bundleSingleItem.productPriceLabel.text = bundleProduct.specialPriceFormatted;
            }
            bundleSingleItem.product = bundleProduct;
            
            if (0==i) {
                //always selected
                bundleSingleItem.alwaysSelected = YES;
            }
            
            bundleSingleItem.selected = YES; //selected by default
            
            [bundleSingleItem bringSubviewToFront:bundleSingleItem.selectedProduct];
            
            bundleSingleItemStart += bundleSingleItem.frame.size.width + 5.0f;
        }
        
        if (atLeastOneProductHasSize) {
            self.bundleLayout = [[JAPDVBundles alloc] initWithFrame:CGRectMake(0, mainScrollViewY, self.mainScrollView.width, 300) withSize:YES];
        } else {
            self.bundleLayout = [[JAPDVBundles alloc] initWithFrame:CGRectMake(0, mainScrollViewY, self.mainScrollView.width, 300) withSize:NO];
        }
        [self.bundleLayout setHeaderText:[@"Buy the look" uppercaseString]];
        
        for (JAPDVBundleSingleItem* singleItem in self.bundleSingleItemsArray) {
            [self.bundleLayout addBundleItemView:singleItem];
        }
        
//        [self.bundleLayout.bundleScrollView setContentSize:CGSizeMake(bundleSingleItemStart, self.bundleLayout.bundleScrollView.frame.size.height)];
        
        self.bundleLayout.frame = CGRectMake(6.0f,
                                             mainScrollViewY,
                                             self.bundleLayout.frame.size.width,
                                             self.bundleLayout.frame.size.height);
        [self updateBundlesView];
        [self.mainScrollView addSubview:self.bundleLayout];

#warning TODO bundle buynow button
//        [self.bundleLayout.buynowButton addTarget:self
//                                           action:@selector(bundlesBuyNowPressed)
//                                 forControlEvents:UIControlEventTouchUpInside];
        
        if(isiPadInLandscape)
        {
            [self.bundleLayout setFrame:CGRectMake(.0f,
                                                   landscapeScrollViewY,
                                                   self.imageSection.frame.size.width- 6.0f,
                                                   self.bundleLayout.frame.size.height)];
            
            [self.landscapeScrollView addSubview:self.bundleLayout];
            
            landscapeScrollViewY += (self.bundleLayout.frame.size.height);

        }else
        {
            self.bundleLayout.frame = CGRectMake(.0f,
                                                 mainScrollViewY,
                                                 self.bundleLayout.frame.size.width,
                                                 self.bundleLayout.frame.size.height);
            [self.mainScrollView addSubview:self.bundleLayout];
            
            mainScrollViewY += (self.bundleLayout.frame.size.height);
        }
    }
    
    /*******
     Related Items
     *******/
    
    if (VALID_NOTEMPTY(self.product.relatedProducts, NSSet) && 1 < self.product.relatedProducts.count)
    {
        if (VALID_NOTEMPTY(self.relatedItemsView, JAPDVRelatedItem)) {
            for (UIView *view in self.relatedItemsView.subviews) {
                [view removeFromSuperview];
            }
        }
        
#warning TODO String
        [self.relatedItemsView setHeaderText:[@"You may also like" uppercaseString]];
        CGFloat relatedItemX = .0f;
        CGFloat relatedItemY = 0;
        
        //        self.relatedItems = [JAPDVRelatedItem getNewPDVRelatedItemSection];
        //        [self.relatedItems setupWithFrame:self.mainScrollView.frame];
        //        self.relatedItems.topLabel.text = STRING_RELATED_ITEMS;
        
        NSArray* relatedProducts = [self.product.relatedProducts allObjects];
        
        for (int i = 0; i < relatedProducts.count; i++) {
            RIProduct* product = [relatedProducts objectAtIndex:i];
            JAPDVSingleRelatedItem *singleItem = [[JAPDVSingleRelatedItem alloc] initWithFrame:CGRectMake(0, 0, self.mainScrollView.width/2 - 5, 230)];
            singleItem.tag = i;
            [singleItem addTarget:self
                           action:@selector(selectedRelatedItem:)
                 forControlEvents:UIControlEventTouchUpInside];
            
            CGRect tempFrame = singleItem.frame;
            tempFrame.origin.x = relatedItemX;
            tempFrame.origin.y = relatedItemY;
            singleItem.frame = tempFrame;
            singleItem.product = product;
            
            [self.relatedItemsView addRelatedItemView:singleItem];
            
            if ((i+1)%2==0) {
                relatedItemX = 0.0f;
                relatedItemY += singleItem.frame.size.height + 5.0f;
            }else{
                relatedItemX += singleItem.frame.size.width + 5.0f + 5.f;
            }
        }
        
        if(isiPadInLandscape)
        {
            self.relatedItemsView.frame = CGRectMake(0.0f,
                                                 landscapeScrollViewY,
                                                 self.relatedItemsView.frame.size.width,
                                                 self.relatedItemsView.frame.size.height);
            
            landscapeScrollViewY += (6.0f + self.relatedItemsView.frame.size.height);
        }
        else
        {
            self.relatedItemsView.frame = CGRectMake(0.0f,
                                                 mainScrollViewY,
                                                 self.relatedItemsView.frame.size.width,
                                                 self.relatedItemsView.frame.size.height);
            
            mainScrollViewY += (6.0f + self.relatedItemsView.frame.size.height);
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
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (JAPDVRelatedItem *)relatedItemsView
{
    if (!VALID_NOTEMPTY(_relatedItemsView, JAPDVRelatedItem) || !_relatedItemsView.superview) {
        _relatedItemsView = [[JAPDVRelatedItem alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.productInfoSection.frame), self.mainScrollView.width, 300)];
        [self.mainScrollView addSubview:_relatedItemsView];
    }
    return _relatedItemsView;
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
    NSArray* relatedProducts = [self.product.relatedProducts allObjects];
    RIProduct *tempProduct = [relatedProducts objectAtIndex:sender.tag];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:@{ @"url" : tempProduct.url,
                                                                  @"previousCategory" : @"",
                                                                  @"show_back_button" : [NSNumber numberWithBool:YES]}];
    [self trackingEventRelatedItemSelection:tempProduct];
    [self trackingEventScreenName:[NSString stringWithFormat:@"related_item_%@",tempProduct.name]];
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

- (void)shareProduct    // TODO
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
        
    // Share with Facebook Messenger and WhatsApp
    
    UIActivity *fbmActivity = [[AQSFacebookMessengerActivity alloc] init];
    UIActivity *whatsAppActivity = [[JBWhatsAppActivity alloc] init];
    
    NSArray *objectToShare = @[fbmActivity, whatsAppActivity];;
    
    WhatsAppMessage *whatsappMsg = [[WhatsAppMessage alloc] initWithMessage:[NSString stringWithFormat:@"%@ %@",STRING_SHARE_PRODUCT_MESSAGE, url] forABID:nil];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[STRING_SHARE_PRODUCT_MESSAGE, [NSURL URLWithString:url], whatsappMsg] applicationActivities:nil];
    
    if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
       
        activityController = [[UIActivityViewController alloc] initWithActivityItems:@[STRING_SHARE_PRODUCT_MESSAGE, [NSURL URLWithString:url], whatsappMsg] applicationActivities:objectToShare];
         
    }
    
    
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
    
    [activityController setValue:[NSString stringWithFormat:STRING_SHARE_OBJECT, APP_NAME]
                          forKey:@"subject"];
    
    
    activityController.completionHandler = ^(NSString *activityType, BOOL completed)
    {
        [self trackingEventShared:activityType];
    };
    
    
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        CGRect sharePopoverRect = CGRectMake(self.ctaView.frame.size.width,
                                             self.ctaView.frame.size.height / 2,
                                             0.0f,
                                             0.0f);
        
        UIPopoverController* popoverController =
        [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popoverController presentPopoverFromRect:sharePopoverRect inView:self.ctaView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
#warning TODO
//    if((UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && ([self.imageSection.sizeLabel.text isEqualToString:STRING_SIZE])) || [self.productInfoSection.sizeLabel.text isEqualToString:STRING_SIZE])
//    {
//        self.openPickerFromCart = YES;
//        [self showSizePicker];
//    }
//    else
//    {
        [self showLoading];
        
        [RICart addProductWithQuantity:@"1"
                                   sku:self.product.sku
                                simple:self.currentSimple.sku
                      withSuccessBlock:^(RICart *cart) {
                          
                          if (VALID_NOTEMPTY(self.teaserTrackingInfo, NSString)) {
                              NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];
                              
                              NSString* obj = [skusFromTeaserInCart objectForKey:self.product.sku];
                              
                              if (ISEMPTY(obj)) {
                                  [skusFromTeaserInCart setValue:self.teaserTrackingInfo forKey:self.product.sku];
                                  [[NSUserDefaults standardUserDefaults] setObject:[skusFromTeaserInCart copy] forKey:kSkusFromTeaserInCartKey];
                              }
                          }
                          
                          [self trackingEventAddToCart:cart];
                          
                          NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                          [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                          
                          [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
                          
                          [self hideLoading];
                          
                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                          
                          [self hideLoading];
                          
                          NSString *addToCartError = STRING_ERROR_ADDING_TO_CART;
                          NSString *results = [[errorMessages valueForKey:@"description"] componentsJoinedByString:@""];
                          if([results  isEqualToString: @"order_product_sold_out"]){
                              
                              addToCartError = STRING_PRODCUTS_OUT_OF_STOCK;
                          }
                          if (RIApiResponseNoInternetConnection == apiResponse)
                          {
                              addToCartError = STRING_NO_CONNECTION;
                          }
                          
                          [self showMessage:addToCartError success:NO];
                      }];
//    }
}

- (void)callToOrder
{
    [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
        
        [self trackingEventCallToOrder];
        
        NSString *phoneNumber = [@"tel://" stringByAppendingString:configuration.phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
    }];
}

- (void)showSizePickerForBundleSingleItem:(UIButton*)sender
{
    self.indexOfBundleRelatedToSizePicker = sender.tag;
    
    RIProduct* bundleProduct = [self.productBundle.bundleProducts objectAtIndex:sender.tag];
    
    self.pickerDataSource = [NSMutableArray new];
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    if(VALID_NOTEMPTY(bundleProduct.productSimples, NSOrderedSet))
    {
        for (RIProductSimple *simple in bundleProduct.productSimples)
        {
            if ([simple.quantity integerValue] > 0)
            {
                [self.pickerDataSource addObject:simple];
                [options addObject:simple.variation];
            }
        }
    }
    
    JAPDVBundleSingleItem* bundleSingleItem = [self.bundleSingleItemsArray objectAtIndex:sender.tag];
    
    [self loadSizePickerWithOptions:options
                       previousText:bundleSingleItem.sizeClickableView.title
                    leftButtonTitle:nil];
}


- (void)showSizePicker  // TODO
{
//    self.indexOfBundleRelatedToSizePicker = -1;
//    
//    self.pickerDataSource = [NSMutableArray new];
//    NSMutableArray *options = [[NSMutableArray alloc] init];
//    
//    if(VALID_NOTEMPTY(self.product.productSimples, NSOrderedSet))
//    {
//        for (RIProductSimple *simple in self.product.productSimples)
//        {
//            if ([simple.quantity integerValue] > 0)
//            {
//                if (VALID_NOTEMPTY(simple.variation, NSString)) {
//                    [self.pickerDataSource addObject:simple];
//                    [options addObject:simple.variation];
//                }
//            }
//        }
//    }
//    
//    NSString* sizeGuideTitle = nil;
//    if (VALID_NOTEMPTY(self.product.sizeGuideUrl, NSString)) {
//        sizeGuideTitle = STRING_SIZE_GUIDE;
//    }
//    
//    if (VALID_NOTEMPTY(options, NSMutableArray)) {
//        [self loadSizePickerWithOptions:[options copy]
//                           previousText:self.productInfoSection.sizeLabel.text
//                        leftButtonTitle:sizeGuideTitle];
//    }
}

- (void)loadSizePickerWithOptions:(NSArray*)options
                     previousText:(NSString*)previousText
                  leftButtonTitle:(NSString*)leftButtonTitle
{
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    
    [self.picker setDataSourceArray:options
                       previousText:previousText
                    leftButtonTitle:leftButtonTitle];
    
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


- (IBAction)checkBundle:(UIButton*)sender
{
    NSInteger index = sender.tag;
    JAPDVBundleSingleItem* singleItem = [self.bundleSingleItemsArray objectAtIndex:index];
    
    singleItem.selected = !singleItem.selected;
    
    [self updateBundlesView];
}

- (void)updateBundlesView
{
    NSInteger numberOfSelected = 0;
    CGFloat total = 0.0f;
    for (int i = 0; i<self.productBundle.bundleProducts.count; i++) {
        
        JAPDVBundleSingleItem* singleItem = [self.bundleSingleItemsArray objectAtIndex:i];
        
        if (singleItem.selected) {
            numberOfSelected++;
            
            RIProduct* bundleProduct = [self.productBundle.bundleProducts objectAtIndex:i];
            
            if (VALID_NOTEMPTY(bundleProduct.specialPrice, NSNumber) && 0.0f == [bundleProduct.specialPrice floatValue]) {
                total += [bundleProduct.price floatValue];
            } else {
                total += [bundleProduct.specialPrice floatValue];
            }
        }
    }
    
    NSString* totalText = [NSString stringWithFormat:@"%@ %@", STRING_BUNDLE_TOTAL_PRICE, [RICountryConfiguration formatPrice:[NSNumber numberWithFloat:total] country:[RICountryConfiguration getCurrentConfiguration]]];
#warning TODO Bundles Total
//    [self.bundleLayout.totalLabel setText:totalText];
//    
//    if (1 >= numberOfSelected) {
//        self.bundleLayout.buynowButton.enabled = NO;
//    } else {
//        self.bundleLayout.buynowButton.enabled = YES;
//    }
}

-(void)bundlesBuyNowPressed
{
    NSMutableArray* selectedProductSkus = [NSMutableArray new];
    NSMutableArray* selectedProductSimpleSkus = [NSMutableArray new];
    
    for (int i = 0; i<self.productBundle.bundleProducts.count; i++) {
        
        JAPDVBundleSingleItem* singleItem = [self.bundleSingleItemsArray objectAtIndex:i];
        
        if (singleItem.selected) {
            RIProduct* bundleProduct = [self.productBundle.bundleProducts objectAtIndex:i];
            
            
            if (1 == bundleProduct.productSimples.count)
            {
                //found it
                RIProductSimple *simple = [bundleProduct.productSimples firstObject];
                [selectedProductSimpleSkus addObject:simple.sku];
                [selectedProductSkus addObject:bundleProduct.sku];
            }
            else
            {
                //has more than one simple, lets check if there is a simple selected
                NSString* string = singleItem.sizeClickableView.title;
                if ([string isEqualToString:@""] || [string isEqualToString:STRING_SIZE])
                {
                    //nothing is selected, abort
                    
                    [self showMessage:STRING_CHOOSE_SIZE_FOR_ALL_PRODUCTS success:NO];
                    
                    [self addErrorToBundleSizeButtons];
                    return;
                }
                else
                {
                    for (RIProductSimple* simple in bundleProduct.productSimples) {
                        if ([string isEqualToString:simple.variation]) {
                            //found it
                            [selectedProductSimpleSkus addObject:simple.sku];
                            [selectedProductSkus addObject:bundleProduct.sku];
                            break;
                        }
                    }
                }
            }

        }
    }

    
    if (1 < selectedProductSkus.count) { //has to have more than one
        
        [self showLoading];
        
        [RICart addBundleProductsWithSkus:selectedProductSkus
                               simpleSkus:selectedProductSimpleSkus
                                 bundleId:self.productBundle.bundleId
                         withSuccessBlock:^(RICart *cart, NSArray *productsNotAdded) {
                             
                             [self trackingEventAddBundleToCart:cart];
                             
                             NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                             [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                             
                             [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
                             
                             [self hideLoading];
                             
                         } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages, BOOL outOfStock) {
                             
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

- (void)addErrorToBundleSizeButtons
{
    for (JAPDVBundleSingleItem* bundleSingleItem in self.bundleSingleItemsArray) {
        if (bundleSingleItem.selectedProduct.selected) {
            if ([bundleSingleItem.sizeClickableView.title isEqualToString:@""] || [bundleSingleItem.sizeClickableView.title isEqualToString:STRING_SIZE]) {
                [bundleSingleItem.sizeClickableView setTitleColor:UIColorFromRGB(0xcc0000) forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow  // TODO
{
//    self.currentSimple = [self.pickerDataSource objectAtIndex:selectedRow];
//    
//    NSString* option = self.currentSimple.variation;
//    if (ISEMPTY(option)) {
//        option = @"";
//    }
//    
//    
//    if (-1 == self.indexOfBundleRelatedToSizePicker) {
//        //this means the picker was related to the main pdv product
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        {
//            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//            if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
//            {
//                [self.imageSection.sizeLabel setText:option];
//            }
//            else
//            {
//                [self.productInfoSection.sizeLabel setText:option];
//            }
//        }
//        else
//        {
//            [self.productInfoSection.sizeLabel setText:option];
//        }
//    } else {
//        JAPDVBundleSingleItem* bundleSingleItem = [self.bundleSingleItemsArray objectAtIndex:self.indexOfBundleRelatedToSizePicker];
//        [bundleSingleItem.sizeClickableView setTitle:option forState:UIControlStateNormal];
//        [bundleSingleItem.sizeClickableView setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
//    }
//    
//    
//    CGRect frame = self.picker.frame;
//    frame.origin.y = self.view.frame.size.height;
//    
//    [UIView animateWithDuration:0.4f
//                     animations:^{
//                         self.picker.frame = frame;
//                     } completion:^(BOOL finished) {
//                         [self.picker removeFromSuperview];
//                         self.picker = nil;
//                         
//                         if (self.openPickerFromCart)
//                         {
//                             self.openPickerFromCart = NO;
//                             [self addToCart];
//                         }
//                     }];
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
    if(VALID(_galleryPaged, JAPDVGallery))
        [_galleryPaged removeFromSuperview];
    
    UIView *gallerySuperView = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;
    
    CGFloat width = gallerySuperView.frame.size.width;
    CGFloat height = gallerySuperView.frame.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        if(width < gallerySuperView.frame.size.height)
        {
            width = gallerySuperView.frame.size.height;
            height = gallerySuperView.frame.size.width;
        }
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
            statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
    }
    else
    {
        if(width > gallerySuperView.frame.size.height)
        {
            width = gallerySuperView.frame.size.height;
            height = gallerySuperView.frame.size.width;
        }
    }
    
    _galleryPaged = [[JAPDVGallery alloc] initWithFrame:CGRectMake(0, height, width, height-statusBarHeight)];
    CGRect openFrame = CGRectMake(0, statusBarHeight, width, height-statusBarHeight);
    [_galleryPaged loadGalleryWithArray:[self.product.images array] atIndex:index];
    [gallerySuperView addSubview:_galleryPaged];
    [_galleryPaged setBackgroundColor:[UIColor whiteColor]];
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _galleryPaged.frame = openFrame;
                     } completion:nil];
    _galleryPaged.delegate = self;
}

- (void)dismissGallery
{
    CGRect newFrame = self.galleryPaged.frame;
    newFrame.origin.y = self.galleryPaged.frame.size.height;
    
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _galleryPaged.frame = newFrame;
    } completion:^(BOOL finished) {
        [_galleryPaged removeFromSuperview];
        _galleryPaged = nil;
    }];
}


- (void)addToFavoritesPressed:(UIButton*)button
{
    [self showLoading];
    if(![RICustomer checkIfUserIsLogged]) {
        [self hideLoading];
        _needRefreshProduct = YES;
        NSMutableDictionary* userInfoLogin = [[NSMutableDictionary alloc] init];
        [userInfoLogin setObject:[NSNumber numberWithBool:NO] forKey:@"from_side_menu"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification object:nil userInfo:userInfoLogin];
        return;
    }
    
    if (!VALID_NOTEMPTY(self.product.favoriteAddDate, NSDate))
    {
        //add to favorites
        [RIProduct addToFavorites:self.product successBlock:^{
            [self hideLoading];
            button.selected = YES;
            
            self.product.favoriteAddDate = [NSDate date];
            
            [self trackingEventAddToWishlist];
            
            NSDictionary *userInfo = nil;
            if (self.product.favoriteAddDate) {
                userInfo = [NSDictionary dictionaryWithObject:self.product.favoriteAddDate forKey:@"favoriteAddDate"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kProductChangedNotification
                                                                object:self.productUrl
                                                              userInfo:userInfo];
            
            [self showMessage:STRING_ADDED_TO_WISHLIST success:YES];
            
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            
            [self hideLoading];
            [self showMessage:STRING_ERROR_ADDING_TO_WISHLIST success:NO];
        }];
    }
    else
    {
        [RIProduct removeFromFavorites:self.product successBlock:^(void) {
            //update favoriteProducts
            [self hideLoading];
            button.selected = NO;
            
            self.product.favoriteAddDate = nil;
            
            [self trackingEventRemoveFromWishlist];
            
            [self showMessage:STRING_REMOVED_FROM_WISHLIST success:YES];
            NSDictionary *userInfo = nil;
            if (self.product.favoriteAddDate) {
                userInfo = [NSDictionary dictionaryWithObject:self.product.favoriteAddDate forKey:@"favoriteAddDate"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kProductChangedNotification
                                                                object:self.productUrl
                                                              userInfo:userInfo];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            
            [self hideLoading];
            [self showMessage:STRING_ERROR_ADDING_TO_WISHLIST success:NO];
        }];
    }
}

#pragma mark - Activity delegate

- (void)willDismissActivityViewController:(JAActivityViewController *)activityViewController
{
    // Track sharing here :)
}

#pragma mark - Tracking Events

- (NSNumber *)getPrice
{
    return (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue] > 0.0f)? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;
}

- (void)trackingEventViewProduct:(RIProduct *)product
{
    NSNumber *price = [self getPrice];
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
    }else if (VALID_NOTEMPTY(product.categoryIds, NSOrderedSet))
    {
        [trackingDictionary setValue:[RICategory getTree:[product.categoryIds firstObject]] forKey:kRIEventTreeKey];
    }
    
    
    if ([RICustomer checkIfUserIsLogged]) {
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
        [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
            RIAddress *shippingAddress = (RIAddress *)[adressList objectForKey:@"shipping"];
            [trackingDictionary setValue:shippingAddress.city forKey:kRIEventCityKey];
            [trackingDictionary setValue:shippingAddress.customerAddressRegion forKey:kRIEventRegionKey];
            
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewProduct]
                                                      data:[trackingDictionary copy]];
            
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            NSLog(@"ERROR: getting customer");
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewProduct]
                                                      data:[trackingDictionary copy]];
        }];
    }else{
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewProduct]
                                                  data:[trackingDictionary copy]];
    }
    
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
    
    float value = [[self getPrice] floatValue];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameViewedContent
                  valueToSum: value
                  parameters:@{FBSDKAppEventParameterNameContentID: self.product.sku,
                               FBSDKAppEventParameterNameContentType: self.product.name,
                               FBSDKAppEventParameterNameCurrency:@"EUR"}];
}

- (void)trackingEventAddToCart:(RICart *)cart
{
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
    [self trackingEventCart:cart];
}

- (void)trackingEventAddBundleToCart:(RICart *)cart
{
    NSNumber *price = [self getPrice];
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:((RIProduct *)[self.product.productSimples firstObject]).sku forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"BundleAddToCart" forKey:kRIEventActionKey];
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
    
    [self trackingEventCart:cart];
}

- (void)trackingEventCart:(RICart *)cart
{
    float value = [[self getPrice] floatValue];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameAddedToCart
                  valueToSum:value
                  parameters:@{ FBSDKAppEventParameterNameCurrency    : @"EUR",
                                FBSDKAppEventParameterNameContentType : self.product.name,
                                FBSDKAppEventParameterNameContentID   : self.product.sku}];
    
    NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
    [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
    [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                              data:[trackingDictionary copy]];
    
    [self trackingEventLastAddedToCart];
}

- (void)trackingEventLastAddedToCart
{
    NSMutableDictionary *tracking = [NSMutableDictionary new];
    [tracking setValue:self.product.name forKey:kRIEventProductNameKey];
    [tracking setValue:self.product.sku forKey:kRIEventSkuKey];
    if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet)) {
        [tracking setValue:[self.product.categoryIds lastObject] forKey:kRIEventLastCategoryAddedToCartKey];
    }
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastAddedToCart] data:tracking];
}

- (void)trackingEventCallToOrder
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCallToOrder]
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventRemoveFromWishlist
{
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
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventAddToWishlist
{
    NSNumber *price = [self getPrice];
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
    [FBSDKAppEvents logEvent:FBSDKAppEventNameAddedToWishlist
                  valueToSum:value
                  parameters:@{ FBSDKAppEventParameterNameCurrency    : @"EUR",
                                FBSDKAppEventParameterNameContentType : self.product.name,
                                FBSDKAppEventParameterNameContentID   : self.product.sku}];
}

- (void)trackingEventShared:(NSString *)activityType
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
}

- (void)trackingEventRelatedItemSelection:(RIProduct *)product
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"RelatedItem" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:product.price forKey:kRIEventValueKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRelatedItem]
                                              data:[trackingDictionary copy]];
}

- (void)trackingEventMostViewedBrand
{
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventMostViewedBrand] data:[NSDictionary dictionaryWithObject:[RIProduct getTopBrand:self.product] forKey:kRIEventBrandKey]];
}

- (void)trackingEventScreenName:(NSString *)screenName
{
    [[RITrackingWrapper sharedInstance] trackScreenWithName:screenName];
}

- (void)trackingEventLoadingTime
{
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

@end

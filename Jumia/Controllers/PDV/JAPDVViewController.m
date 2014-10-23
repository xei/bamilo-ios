//
//  JAPDVViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVViewController.h"
#import "JAPDVImageSection.h"
#import "JAPDVVariations.h"
#import "JAPDVProductInfo.h"
#import "JAPDVRelatedItem.h"
#import "JAPDVSingleRelatedItem.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+JA.h"
#import "RIImage.h"
#import "RIVariation.h"
#import "RIProductReview.h"
#import "RICart.h"
#import "RIProductSimple.h"
#import "JAPDVPicker.h"
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

@interface JAPDVViewController ()
<
JAPDVGalleryViewDelegate,
JAActivityViewControllerDelegate
>

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) RIProductRatings *productRatings;
@property (strong, nonatomic) JAPDVImageSection *imageSection;
@property (strong, nonatomic) JAPDVVariations *variationsSection;
@property (strong, nonatomic) JAPDVProductInfo *productInfoSection;
@property (strong, nonatomic) JAPDVRelatedItem *relatedItems;
@property (strong, nonatomic) JAPDVPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (strong, nonatomic) JAPDVGalleryView *gallery;
@property (strong, nonatomic) JAButtonWithBlur *ctaView;
@property (assign, nonatomic) NSInteger commentsCount;
@property (assign, nonatomic) BOOL openPickerFromCart;
@property (strong, nonatomic) RIProductSimple *currentSimple;

@property (nonatomic, strong) JAPDVWizardView* wizardView;

@end

@implementation JAPDVViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         0.0f,
                                                                         self.view.frame.size.width,
                                                                         self.view.frame.size.height - 64.0f)];
    [self.view addSubview:self.mainScrollView];
    
    // Always load the product details when entering PDV
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
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadCompleteProduct
{
    [self showLoading];
    
    if (VALID_NOTEMPTY(self.productUrl, NSString)) {
        [RIProduct getCompleteProductWithUrl:self.productUrl successBlock:^(id product) {
            [self loadedProduct:product];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
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
            [self loadedProduct:product];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
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
    NSNumber *price = VALID_NOTEMPTY(self.product.specialPrice, NSNumber) ? self.product.specialPrice : self.product.price;

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
    [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
    
    [trackingDictionary setValue:[price stringValue] forKey:kRIEventPriceKey];
    [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
    
    [trackingDictionary setValue:self.product.brand forKey:kRIEventBrandKey];
    
    NSString *discount = @"false";
    if (self.product.maxSavingPercentage.length > 0)
    {
        discount = @"true";
    }
    [trackingDictionary setValue:discount forKey:kRIEventDiscountKey];
    
    if (VALID_NOTEMPTY(self.product.productSimples, NSArray) && 1 == self.product.productSimples.count)
    {
        RIProductSimple *tempProduct = self.product.productSimples[0];
        if (VALID_NOTEMPTY(tempProduct.attributeSize, NSString))
        {
            [trackingDictionary setValue:tempProduct.attributeSize forKey:kRIEventSizeKey];
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
    [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
    [trackingDictionary setValue:self.product.sku forKey:kRIEventProductKey];
    [trackingDictionary setValue:self.product.brand forKey:kRIEventBrandKey];
    [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
    
    NSString *discountPercentage = @"0";
    if(VALID_NOTEMPTY(self.product.maxSavingPercentage, NSString))
    {
        discountPercentage = self.product.maxSavingPercentage;
    }

    [trackingDictionary setValue:[price stringValue] forKey:kRIEventPriceKey];
    [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
    [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
    if(VALID_NOTEMPTY(self.category, RICategory))
    {
        [trackingDictionary setValue:self.category.name forKey:kRIEventCategoryNameKey];
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
    self.imageSection = [JAPDVImageSection getNewPDVImageSection];
    [self.imageSection.wishListButton addTarget:self
                                         action:@selector(addToFavoritesPressed:)
                               forControlEvents:UIControlEventTouchUpInside];
    self.imageSection.wishListButton.selected = VALID_NOTEMPTY(self.product.favoriteAddDate, NSDate);
    
    if (VALID_NOTEMPTY(self.product.variations, NSOrderedSet))
    {
        self.variationsSection = [JAPDVVariations getNewPDVVariationsSection];
    }
    
    self.productInfoSection = [JAPDVProductInfo getNewPDVProductInfoSection];
    
    [RIProductRatings getRatingsForProductWithUrl:[NSString stringWithFormat:@"%@?rating=3&page=1", self.product.url] //@"http://www.jumia.com.ng/mobapi/v1.4/Asha-302---Black-7546.html?rating=1&page=1"
                                     successBlock:^(RIProductRatings *ratings) {
                                         
                                         self.commentsCount = [ratings.commentsCount integerValue];
                                         
                                         self.productRatings = ratings;
                                         
                                         [self fillTheViews];
                                         
                                         [self hideLoading];
                                     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                         
                                         [self fillTheViews];
                                         
                                         [self hideLoading];
                                     }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRatingsMain"])
    {
        [segue.destinationViewController setProductRatings:self.productRatings];
        [segue.destinationViewController setProduct:self.product];
    }
    else if ([segue.identifier isEqualToString:@"segueToDetails"])
    {
        [segue.destinationViewController setProduct:self.product];
    }
    else if ([segue.identifier isEqualToString:@"segueNewReview"])
    {
        [segue.destinationViewController setProduct:self.product];
    }
}

#pragma mark - Fill the views

- (void)fillTheViews
{
    float startingElement = 6.0f;
    
    /*******
     Image Section
     *******/
    
    self.imageSection.frame = CGRectMake(6.0f,
                                         startingElement,
                                         self.imageSection.frame.size.width,
                                         self.imageSection.frame.size.height);
    
    self.imageSection.layer.cornerRadius = 4.0f;
    
    RIImage *image = [self.product.images firstObject];
    [self.imageSection.mainImage setImageWithURL:[NSURL URLWithString:image.url]
                                placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
    [self.imageSection.imageClickableView addTarget:self
                                             action:@selector(presentGallery)
                                   forControlEvents:UIControlEventTouchUpInside];
    
    self.imageSection.productNameLabel.text = self.product.brand;
    self.imageSection.productDescriptionLabel.text = self.product.name;
    
    if (VALID_NOTEMPTY(self.product.maxSavingPercentage, NSString))
    {
        self.imageSection.discountLabel.text = [NSString stringWithFormat:@"-%@%%", self.product.maxSavingPercentage];
    } else
    {
        self.imageSection.discountLabel.hidden = YES;
    }
    
    [self.imageSection.shareButton addTarget:self
                                      action:@selector(shareProduct)
                            forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *img = [UIImage imageNamed:@"img_badge_discount"];
    CGSize imgSize = self.imageSection.discountLabel.frame.size;
    
    UIGraphicsBeginImageContext(imgSize);
    [img drawInRect:CGRectMake(0,0,imgSize.width,imgSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imageSection.discountLabel.backgroundColor = [UIColor colorWithPatternImage:newImage];
    [self.imageSection.mainImage setAccessibilityLabel:@"pdv_main_image"];
    
    [self.mainScrollView addSubview:self.imageSection];
    
    startingElement += (4.0f + self.imageSection.frame.size.height);
    
    /*******
     Colors / Variation
     *******/
    
    if (VALID_NOTEMPTY(self.product.variations, NSOrderedSet))
    {
        self.variationsSection.frame = CGRectMake(6.0f,
                                                  startingElement,
                                                  self.variationsSection.frame.size.width,
                                                  self.variationsSection.frame.size.height);
        
        self.variationsSection.layer.cornerRadius = 4.0f;
        
        self.variationsSection.titleLabel.text = STRING_VARIATIONS;
        
        CGFloat currentX = 0.0;
        
        for (int i = 0; i < [self.product.variations count]; i++)
        {
            RIVariation *variation = [self.product.variations objectAtIndex:i];
            
            JAClickableView* variationClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                                        0.0f,
                                                                                                        40.0f,
                                                                                                        50.0f)];
            variationClickableView.tag = i;
            [variationClickableView addTarget:self
                                       action:@selector(openVariation:)
                             forControlEvents:UIControlEventTouchUpInside];
            [self.variationsSection.variationsScrollView addSubview:variationClickableView];
            
            UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake((variationClickableView.bounds.size.width - 30.0f) / 2,
                                                                                      (variationClickableView.bounds.size.height - 30.0f) / 2,
                                                                                      30.0f,
                                                                                      30.0f)];
            [newImageView setImageWithURL:[NSURL URLWithString:variation.image.url]
                         placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
            [newImageView changeImageSize:30.0f andWidth:0.0f];
            [variationClickableView addSubview:newImageView];
            
            currentX += variationClickableView.frame.size.width;
        }
        [self.variationsSection.variationsScrollView setContentSize:CGSizeMake(currentX,
                                                                               self.variationsSection.variationsScrollView.frame.size.height)];
        
        [self.mainScrollView addSubview:self.variationsSection];
        
        startingElement += (4 + self.variationsSection.frame.size.height);
    }
    
    /*******
     Product Info Section
     *******/
    
    self.productInfoSection.frame = CGRectMake(6,
                                               startingElement,
                                               self.productInfoSection.frame.size.width,
                                               self.productInfoSection.frame.size.height);
    
    [self.productInfoSection setPriceWithNewValue:self.product.specialPriceFormatted
                                      andOldValue:self.product.priceFormatted];
    
    [self.productInfoSection setNumberOfStars:[self.product.avr integerValue]];
    
    if (self.commentsCount > 0)
    {
        self.productInfoSection.numberOfReviewsLabel.text = [NSString stringWithFormat:STRING_REVIEWS, self.productRatings.commentsCount];
    }
    else
    {
        self.productInfoSection.numberOfReviewsLabel.text = STRING_RATE_NOW;
    }
    
    [self.productInfoSection.reviewsClickableView addTarget:self
                                                     action:@selector(goToRatinsMainScreen)
                                           forControlEvents:UIControlEventTouchUpInside];
    
    self.productInfoSection.specificationsLabel.text = STRING_SPECIFICATIONS;
    
    self.productInfoSection.layer.cornerRadius = 4.0f;
    
    /*
     Check if there is size
     
     if there is only one size: put that size and remove the action
     if there are more than one size, open the picker
     
     */
    if (ISEMPTY(self.product.productSimples))
    {
        [self.productInfoSection removeSizeOptions];
    }
    else if (1 == self.product.productSimples.count)
    {
        [self.productInfoSection.sizeClickableView setEnabled:NO];
        self.currentSimple = self.product.productSimples[0];
        
        if (VALID_NOTEMPTY(self.currentSimple.attributeSize, NSString))
        {
            [self.productInfoSection.sizeLabel setText:self.currentSimple.attributeSize];
        }
        else
        {
            [self.productInfoSection removeSizeOptions];
            [self.productInfoSection layoutSubviews];
        }
    }
    else if (1 < self.product.productSimples.count)
    {
        [self.productInfoSection.sizeClickableView setEnabled:YES];
        [self.productInfoSection.sizeLabel setText:STRING_SIZE];
        
        [self.productInfoSection.sizeClickableView addTarget:self
                                                      action:@selector(showSizePicker)
                                            forControlEvents:UIControlEventTouchUpInside];
        
        if (VALID_NOTEMPTY(self.preSelectedSize, NSString))
        {
            for (RIProductSimple *simple in self.product.productSimples)
            {
                if ([simple.attributeSize isEqualToString:self.preSelectedSize])
                {
                    [self.productInfoSection.sizeLabel setText:simple.attributeSize];
                    break;
                }
            }
        }
    }
    
    
    [self.productInfoSection.specificationsClickableView addTarget:self
                                                            action:@selector(gotoDetails)
                                                  forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:self.productInfoSection];
    
    startingElement += (4.0f + self.productInfoSection.frame.size.height);
    
    /*******
     Related Items
     *******/
    
    [self.relatedItems removeFromSuperview];

    if (self.fromCatalogue && VALID_NOTEMPTY(self.arrayWithRelatedItems, NSArray) && 1 < self.arrayWithRelatedItems.count)
    {
        self.relatedItems = [JAPDVRelatedItem getNewPDVRelatedItemSection];
        self.relatedItems.topLabel.text = STRING_RELATED_ITEMS;
        self.relatedItems.frame = CGRectMake(6.0f,
                                             CGRectGetMaxY(self.productInfoSection.frame) + 4.0f,
                                             self.relatedItems.frame.size.width,
                                             self.relatedItems.frame.size.height);
        
        self.relatedItems.layer.cornerRadius = 4.0f;
        
        [self.mainScrollView addSubview:self.relatedItems];
        
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
                
                relatedItemStart += singleItem.frame.size.width;
            }
        }
        
        [self.relatedItems.relatedItemsScrollView setContentSize:CGSizeMake(relatedItemStart, self.relatedItems.relatedItemsScrollView.frame.size.height)];
        
        startingElement += (4.0f + self.relatedItems.frame.size.height);
    }
    
    /*******
     CTA Buttons
     *******/
    
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *model = device.model;
    
    self.ctaView = [[JAButtonWithBlur alloc] initWithFrame:CGRectZero];
    
    [self.ctaView setFrame:CGRectMake(0,
                                      self.view.frame.size.height - 56,
                                      self.view.frame.size.width,
                                      60)];
    
    if ([model isEqualToString:@"iPhone"])
    {
        [self.ctaView addButton:STRING_CALL_TO_ORDER
                         target:self
                         action:@selector(callToOrder)];
    }
    
    
    [self.ctaView addButton:STRING_ADD_TO_SHOPPING_CART
                     target:self
                     action:@selector(addToCart)];
    
    [self.view addSubview:self.ctaView];
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, startingElement + self.ctaView.frame.size.height);
    
    //make sure wizard is in front
    [self.view bringSubviewToFront:self.wizardView];
}


#pragma mark - Actions

- (void) openVariation:(UIControl*)sender
{
    RIVariation *variation = [self.product.variations objectAtIndex:sender.tag];
    self.productUrl = variation.link;
    
    [self showLoading];
    [RIProduct getCompleteProductWithUrl:self.productUrl successBlock:^(id product) {
        [RIProduct addToRecentlyViewed:product successBlock:nil andFailureBlock:nil];
        self.product = product;
        [self productLoaded];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        [self hideLoading];
    }];
}

- (void)selectedRelatedItem:(UIControl*)sender
{
    RIProduct *tempProduct = [self.arrayWithRelatedItems objectAtIndex:sender.tag];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:@{ @"url" : tempProduct.url,
                                                                  @"previousCategory" : @"",
                                                                  @"show_back_button" : [NSNumber numberWithBool:self.showBackButton]}];
    
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
    [self performSegueWithIdentifier:@"segueToDetails"
                              sender:nil];
}

- (void)goToRatinsMainScreen
{
    if (0 == self.commentsCount) {
        [self performSegueWithIdentifier:@"segueNewReview"
                                  sender:nil];
    } else {
        [self performSegueWithIdentifier:@"showRatingsMain"
                                  sender:nil];
    }
}

- (void)shareProduct
{
    JAShareActivityProvider *provider = [[JAShareActivityProvider alloc] initWithProduct:self.product];
    
    NSArray *objectsToShare = @[provider];
    
    JAActivityViewController *activityController = [[JAActivityViewController alloc] initWithActivityItems:objectsToShare
                                                                                     applicationActivities:nil];
    
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
        if(VALID_NOTEMPTY(self.category, RICategory))
        {
            [trackingDictionary setValue:self.category.name forKey:kRIEventCategoryNameKey];
        }
        
        [[RITrackingWrapper sharedInstance] trackEvent:eventType
                                                  data:[trackingDictionary copy]];
    };
    
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToTwitter];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)addToCart
{
    if ([self.productInfoSection.sizeLabel.text isEqualToString:STRING_SIZE])
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
                          
                          NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                          [trackingDictionary setValue:((RIProduct *)[self.product.productSimples firstObject]).sku forKey:kRIEventLabelKey];
                          [trackingDictionary setValue:@"AddToCart" forKey:kRIEventActionKey];
                          [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                          [trackingDictionary setValue:((RIProduct *)[self.product.productSimples firstObject]).price forKey:kRIEventValueKey];
                          [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                          [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                          [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                          NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                          [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                          
                          NSNumber *price = VALID_NOTEMPTY(self.product.specialPrice, NSNumber) ? self.product.specialPrice : self.product.price;
                          [trackingDictionary setValue:[price stringValue] forKey:kRIEventPriceKey];
                          
                          [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
                          [trackingDictionary setValue:self.product.name forKey:kRIEventProductNameKey];
                          
                          if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet))
                          {
                              NSArray *categoryIds = [self.product.categoryIds array];
                              [trackingDictionary setValue:[categoryIds objectAtIndex:0] forKey:kRIEventCategoryIdKey];
                          }
                          
                          [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
                          
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
                          if(VALID_NOTEMPTY(self.category, RICategory))
                          {
                              [trackingDictionary setValue:self.category.name forKey:kRIEventCategoryNameKey];
                          }
                          
                          [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToCart]
                                                                    data:[trackingDictionary copy]];
                          
                          NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                          [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                          
                          [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
                          
                          [self hideLoading];
                          
                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                          
                          [self hideLoading];
                          
                          NSString *addToCartError = STRING_ERROR_ADDING_TO_CART;
                          if (RIApiResponseNoInternetConnection == apiResponse)
                          {
                              addToCartError = STRING_NO_NEWTORK;
                          }

                          [self showMessage:addToCartError success:NO];
                      }];
    }
}

- (void)callToOrder
{
    [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
        UIDevice *device = [UIDevice currentDevice];
        if ([[device model] isEqualToString:@"iPhone"] ) {
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
        }
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
    }];
}

- (void)showSizePicker
{
    self.picker = [JAPDVPicker getNewJAPDVPicker];
    
    self.pickerDataSource = [NSMutableArray new];
    
    if (self.product.productSimples.count > 0) {
        for (RIProductSimple *simple in self.product.productSimples) {
            if ([simple.quantity integerValue] > 0) {
                [self.pickerDataSource addObject:simple];
            }
        }
    }
    
    [self.picker setDataSourceArray:[self.pickerDataSource copy]
                       previousText:self.productInfoSection.sizeLabel.text];
    
    [self.picker.doneButton addTarget:self
                               action:@selector(didSelectedValueInPicker)
                     forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = self.picker.frame;
    frame.origin.y = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame.size.height;
    frame.size.height = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame.size.height;
    self.picker.frame = frame;
    [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.picker];
    frame.origin.y = 0.0f;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     }];
}

- (void)didSelectedValueInPicker
{
    NSUInteger selectedRow = [self.picker.picker selectedRowInComponent:0];
    self.currentSimple = [self.pickerDataSource objectAtIndex:selectedRow];
    
    NSString* option = self.currentSimple.attributeSize;
    if (ISEMPTY(option)) {
        option = self.currentSimple.color;
        if (ISEMPTY(option)) {
            option = self.currentSimple.variation;
        }
    }
    [self.productInfoSection.sizeLabel setText:option];
    
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         
                         if (self.openPickerFromCart)
                         {
                             self.openPickerFromCart = NO;
                             [self addToCart];
                         }
                     }];
}

- (void)presentGallery
{
    self.gallery = [JAPDVGalleryView getNewJAPDVGalleryView];
    [self.gallery layoutSubviews];
    self.gallery.delegate = self;
    
    [self.gallery loadGalleryWithArray:[self.product.images array]];
    
    CGRect tempFrame = self.gallery.frame;
    tempFrame.origin.y = [[[UIApplication sharedApplication] delegate] window].rootViewController.view.frame.size.height;
    self.gallery.frame = tempFrame;
    
    [[[[UIApplication sharedApplication] delegate] window].rootViewController.view addSubview:self.gallery];
    
    tempFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.gallery.frame = tempFrame;
                     }];
}

- (void)dismissGallery
{
    CGRect tempFrame = self.gallery.frame;
    tempFrame.origin.y = [[[UIApplication sharedApplication] delegate] window].rootViewController.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.gallery.frame = tempFrame;
                     } completion:^(BOOL finished) {
                         [self.gallery removeFromSuperview];
                     }];
}

- (void)addToFavoritesPressed:(UIButton*)button
{
    button.selected = !button.selected;
    
    if (button.selected) {
        //add to favorites
        [RIProduct addToFavorites:self.product successBlock:^{
            //[self hideLoading];
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"AddtoWishlist" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
            [trackingDictionary setValue:self.product.price forKey:kRIEventValueKey];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
            
            NSNumber *price = VALID_NOTEMPTY(self.product.specialPrice, NSNumber) ? self.product.specialPrice : self.product.price;
            [trackingDictionary setValue:[price stringValue] forKey:kRIEventPriceKey];

            [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
            [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
            [trackingDictionary setValue:self.product.brand forKey:kRIEventBrandKey];
            
            NSString *discountPercentage = @"0";
            if(VALID_NOTEMPTY(self.product.maxSavingPercentage, NSString))
            {
                discountPercentage = self.product.maxSavingPercentage;
            }
            [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
            [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
            [trackingDictionary setValue:@"Catalog" forKey:kRIEventLocationKey];
            if(VALID_NOTEMPTY(self.category, RICategory))
            {
                [trackingDictionary setValue:self.category.name forKey:kRIEventCategoryNameKey];
            }
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToWishlist]
                                                      data:[trackingDictionary copy]];
            
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
    } else {
        [RIProduct removeFromFavorites:self.product successBlock:^(void) {
            //update favoriteProducts
            //[self hideLoading];
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"RemoveFromWishlist" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];

            NSNumber *price = VALID_NOTEMPTY(self.product.specialPrice, NSNumber) ? self.product.specialPrice : self.product.price;
            [trackingDictionary setValue:[price stringValue] forKey:kRIEventPriceKey];
            
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
            [trackingDictionary setValue:[self.product.price stringValue] forKey:kRIEventPriceKey];
            [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
            [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
            [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
            
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

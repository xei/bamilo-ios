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

@interface JAPDVViewController ()
<
JAPDVGalleryViewDelegate,
JAActivityViewControllerDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) RIProductRatings *productRatings;
@property (strong, nonatomic) JAPDVImageSection *imageSection;
@property (strong, nonatomic) JAPDVVariations *variationsSection;
@property (strong, nonatomic) JAPDVProductInfo *productInfoSection;
@property (strong, nonatomic) JAPDVRelatedItem *relatedItems;
@property (strong, nonatomic) JAPDVPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (strong, nonatomic) JAPDVGalleryView *gallery;
@property (weak, nonatomic) IBOutlet UIView *ctaView;
@property (assign, nonatomic) NSInteger commentsCount;
@property (assign, nonatomic) BOOL openPickerFromCart;
@property (strong, nonatomic) RIProductSimple *currentSimple;

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
            
            BOOL noConnection = NO;
            if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
            {
                noConnection = YES;
            }
            [self showErrorView:noConnection startingY:0.0f selector:@selector(loadCompleteProduct) objects:nil];
            
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
            
            BOOL noConnection = NO;
            if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
            {
                noConnection = YES;
            }
            [self showErrorView:noConnection startingY:0.0f selector:@selector(loadCompleteProduct) objects:nil];
            
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
    
    [self hideLoading];
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
    self.imageSection.wishListButton.selected = [self.product.isFavorite boolValue];
    
    if (self.product.variations.count > 0) {
        self.variationsSection = [JAPDVVariations getNewPDVVariationsSection];
    }
    
    self.productInfoSection = [JAPDVProductInfo getNewPDVProductInfoSection];
    
    self.relatedItems = [JAPDVRelatedItem getNewPDVRelatedItemSection];
    
    [self fillTheViews];
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
    float startingElement = 6.0;
    
    /*******
     Image Section
     *******/
    
    self.imageSection.frame = CGRectMake(6,
                                         startingElement,
                                         self.imageSection.frame.size.width,
                                         self.imageSection.frame.size.height);
    
    self.imageSection.layer.cornerRadius = 4.0f;
    
    RIImage *image = [self.product.images firstObject];
    [self.imageSection.mainImage setImageWithURL:[NSURL URLWithString:image.url]
                                placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(presentGallery)];
    
    self.imageSection.mainImage.userInteractionEnabled = YES;
    [self.imageSection.mainImage addGestureRecognizer:tap];
    
    self.imageSection.productNameLabel.text = self.product.brand;
    self.imageSection.productDescriptionLabel.text = self.product.name;
    
    if (self.product.maxSavingPercentage.length > 0) {
        self.imageSection.discountLabel.text = [NSString stringWithFormat:@"-%@%%", self.product.maxSavingPercentage];
    } else {
        self.imageSection.discountLabel.hidden = YES;
    }
    
    [self.imageSection.shareButton addTarget:self
                                      action:@selector(shareProduct)
                            forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *img = [UIImage imageNamed:@"img_badge_discount"];
    CGSize imgSize = self.imageSection.discountLabel.frame.size;
    
    UIGraphicsBeginImageContext( imgSize );
    [img drawInRect:CGRectMake(0,0,imgSize.width,imgSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imageSection.discountLabel.backgroundColor = [UIColor colorWithPatternImage:newImage];
    
    [self.mainScrollView addSubview:self.imageSection];
    
    startingElement += (4 + self.imageSection.frame.size.height);
    
    /*******
     Colors / Variation
     *******/
    
    if (self.product.variations.count > 0) {
        
        self.variationsSection.frame = CGRectMake(6,
                                                  startingElement,
                                                  self.variationsSection.frame.size.width,
                                                  self.variationsSection.frame.size.height);
        
        self.variationsSection.layer.cornerRadius = 4.0f;
        
        self.variationsSection.titleLabel.text = STRING_VARIATIONS;
        
        float start = 0.0;
        
        for (int i = 0; i < [self.product.variations count]; i++) {
            RIVariation *variation = [self.product.variations objectAtIndex:i];
            
            UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start, 0.0f, 30.0f, 30.0f)];
            [newImageView setImageWithURL:[NSURL URLWithString:variation.image.url]
                         placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
            [newImageView changeImageSize:30.0f andWidth:0.0f];
            [newImageView setTag:i];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(openVariation:)];
            [newImageView addGestureRecognizer:tap];
            [newImageView setUserInteractionEnabled:YES];
            [self.variationsSection.variationsScrollView addSubview:newImageView];
            
            start += 40.0;
        }
        
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
    
    self.productInfoSection.sizeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [self showLoading];
    
    [self.productInfoSection setNumberOfStars:[self.product.avr integerValue]];
    
    [RIProductRatings getRatingsForProductWithUrl:[NSString stringWithFormat:@"%@?rating=3&page=1", self.product.url] //@"http://www.jumia.com.ng/mobapi/v1.4/Asha-302---Black-7546.html?rating=1&page=1"
                                     successBlock:^(RIProductRatings *ratings) {
                                         
                                         self.commentsCount = [ratings.commentsCount integerValue];
                                         
                                         if ([ratings.commentsCount integerValue] > 0)
                                         {
                                             self.productInfoSection.numberOfReviewsLabel.text = [NSString stringWithFormat:STRING_REVIEWS, ratings.commentsCount];
                                         }
                                         else
                                         {
                                             self.productInfoSection.numberOfReviewsLabel.text = STRING_RATE_NOW;
                                         }
                                         
                                         self.productRatings = ratings;
                                         
                                         [self hideLoading];
                                         
                                         [self.productInfoSection.goToReviewsButton addTarget:self
                                                                                       action:@selector(goToRatinsMainScreen)
                                                                             forControlEvents:UIControlEventTouchUpInside];
                                         
                                     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                         
                                         [self hideLoading];
                                         
                                     }];
    
    self.productInfoSection.specificationsLabel.text = STRING_SPECIFICATIONS;
    
    self.productInfoSection.layer.cornerRadius = 4.0f;
    
    /*
     Check if there is size
     
     if there is only one size: put that size and remove the action
     if there are more than one size, open the picker
     
     */
    if (self.product.productSimples.count == 0)
    {
        [self.productInfoSection removeSizeOptions];
    }
    else if (self.product.productSimples.count == 1)
    {
        [self.productInfoSection.sizeButton setEnabled:NO];
        self.currentSimple = self.product.productSimples[0];
        
        if (VALID_NOTEMPTY(self.currentSimple.attributeSize, NSString))
        {
            [self.productInfoSection.sizeButton setTitle:self.currentSimple.attributeSize
                                                forState:UIControlStateNormal];
        }
        else
        {
            [self.productInfoSection removeSizeOptions];
            [self.productInfoSection layoutSubviews];
        }
    }
    else if (self.product.productSimples.count > 1)
    {
        [self.productInfoSection.sizeButton setEnabled:YES];
        [self.productInfoSection.sizeButton setTitle:STRING_SIZE
                                            forState:UIControlStateNormal];
        
        [self.productInfoSection.sizeButton addTarget:self
                                               action:@selector(showSizePicker)
                                     forControlEvents:UIControlEventTouchUpInside];
        
        if (self.preSelectedSize.length > 0)
        {
            for (RIProductSimple *simple in self.product.productSimples)
            {
                if ([simple.attributeSize isEqualToString:self.preSelectedSize])
                {
                    [self.productInfoSection.sizeButton setTitle:simple.attributeSize
                                                        forState:UIControlStateNormal];
                    break;
                }
            }
        }
    }
    
    
    [self.productInfoSection.goToSpecificationsButton addTarget:self
                                                         action:@selector(gotoDetails)
                                               forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:self.productInfoSection];
    
    startingElement += (4 + self.productInfoSection.frame.size.height);
    
    /*******
     Related Items
     *******/
    
    if (self.fromCatalogue)
    {
        if (VALID_NOTEMPTY(self.arrayWithRelatedItems, NSArray) && self.arrayWithRelatedItems.count > 1)
        {
            self.relatedItems.topLabel.text = STRING_RELATED_ITEMS;
            
            self.relatedItems.frame = CGRectMake(6,
                                                 startingElement,
                                                 self.relatedItems.frame.size.width,
                                                 self.relatedItems.frame.size.height);
            
            self.relatedItems.layer.cornerRadius = 4.0f;
            
            [self.mainScrollView addSubview:self.relatedItems];
            
            startingElement += (4 + self.relatedItems.frame.size.height);
            
            float relatedItemStart = 5.0f;
            
            for (RIProduct *product in self.arrayWithRelatedItems)
            {
                if (![product.sku isEqualToString:self.product.sku])
                {
                    if (product.images.count > 0)
                    {
                        JAPDVSingleRelatedItem *singleItem = [JAPDVSingleRelatedItem getNewPDVSingleRelatedItem];
                        
                        CGRect tempFrame = singleItem.frame;
                        tempFrame.origin.x = relatedItemStart;
                        singleItem.frame = tempFrame;
                        
                        if (product.images.count > 0) {
                            RIImage *imageTemp = [product.images firstObject];
                            
                            [singleItem.imageViewItem setImageWithURL:[NSURL URLWithString:imageTemp.url]
                                                     placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
                        }
                        
                        singleItem.labelBrand.text = product.brand;
                        singleItem.labelName.text = product.name;
                        singleItem.labelPrice.text = product.priceFormatted;
                        singleItem.product = product;
                        
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(selectedRelatedItem:)];
                        singleItem.userInteractionEnabled = YES;
                        [singleItem addGestureRecognizer:tap];
                        
                        [self.relatedItems.relatedItemsScrollView addSubview:singleItem];
                        
                        relatedItemStart += 110.0f;
                    }
                }
            }
            
            [self.relatedItems.relatedItemsScrollView setContentSize:CGSizeMake(relatedItemStart, self.relatedItems.relatedItemsScrollView.frame.size.height)];
        }
        else
        {
            [self.relatedItems removeFromSuperview];
        }
    }
    
    /*******
     CTA Buttons
     *******/
    
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *model = device.model;
    
    JAButtonWithBlur *ctaView = [[JAButtonWithBlur alloc] initWithFrame:CGRectZero];
    
    [ctaView setFrame:CGRectMake(0,
                                 self.view.frame.size.height - 56,
                                 self.view.frame.size.width,
                                 60)];
    
    if ([model isEqualToString:@"iPhone"])
    {
        [ctaView addButton:STRING_CALL_TO_ORDER
                    target:self
                    action:@selector(callToOrder)];
    }
    
    
    [ctaView addButton:STRING_ADD_TO_SHOPPING_CART
                target:self
                action:@selector(addToCart)];
    
    [self.view addSubview:ctaView];
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, startingElement + ctaView.frame.size.height);
}


#pragma mark - Actions

- (void) openVariation:(UITapGestureRecognizer *)gr {
    
    UIImageView *variationImageView = (UIImageView *)gr.view;
    NSInteger tag = variationImageView.tag;
    
    RIVariation *variation = [self.product.variations objectAtIndex:tag];
    self.productUrl = variation.link;
    
    [self showLoading];
    [RIProduct getCompleteProductWithUrl:self.productUrl successBlock:^(id product) {
        [RIProduct addToRecentlyViewed:product successBlock:nil andFailureBlock:nil];
        self.product = product;
        [self hideLoading];
        [self productLoaded];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        [self hideLoading];
    }];
}

- (void)selectedRelatedItem:(UITapGestureRecognizer *)tap
{
    JAPDVSingleRelatedItem *view = (JAPDVSingleRelatedItem *)tap.view;
    
    RIProduct *tempProduct = view.product;
    
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
    if ([self.productInfoSection.sizeButton.titleLabel.text isEqualToString:STRING_SIZE])
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
                          if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
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
                       previousText:self.productInfoSection.sizeButton.titleLabel.text];
    
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
    
    [self.productInfoSection.sizeButton setTitle:self.currentSimple.attributeSize
                                        forState:UIControlStateNormal];
    
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
            
            self.product.isFavorite = [NSNumber numberWithBool:button.selected];
            
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

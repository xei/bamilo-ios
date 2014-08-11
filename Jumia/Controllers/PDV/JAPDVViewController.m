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
#import "JACTAButtons.h"
#import "JAPDVRelatedItem.h"
#import "JAPDVSingleRelatedItem.h"
#import "UIImageView+WebCache.h"
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

@interface JAPDVViewController ()
<
    JAPDVGalleryViewDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) RIProductRatings *productRatings;
@property (strong, nonatomic) JAPDVImageSection *imageSection;
@property (strong, nonatomic) JAPDVVariations *variationsSection;
@property (strong, nonatomic) JAPDVProductInfo *productInfoSection;
@property (strong, nonatomic) JACTAButtons *ctaButtons;
@property (strong, nonatomic) JAPDVRelatedItem *relatedItems;
@property (strong, nonatomic) JAPDVPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (strong, nonatomic) JAPDVGalleryView *gallery;

@end

@implementation JAPDVViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageSection = [JAPDVImageSection getNewPDVImageSection];
    
    if (self.product.variations.count > 0) {
        self.variationsSection = [JAPDVVariations getNewPDVVariationsSection];
    }
    
    self.productInfoSection = [JAPDVProductInfo getNewPDVProductInfoSection];
    
    self.ctaButtons = [JACTAButtons getNewPDVCTAButtons];
    
    self.relatedItems = [JAPDVRelatedItem getNewPDVRelatedItemSection];
    
    [self fillTheViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRatingsMain"]) {
        [segue.destinationViewController setProductRatings:self.productRatings];
        [segue.destinationViewController setProductBrand:self.product.brand];
        [segue.destinationViewController setProductNewPrice:self.product.specialPrice];
        [segue.destinationViewController setProductOldPrice:self.product.price];
    } else if ([segue.identifier isEqualToString:@"segueToDetails"]) {
        [segue.destinationViewController setStringBrand:self.product.brand];
        [segue.destinationViewController setStringName:self.product.name];
        [segue.destinationViewController setStringNewPrice:self.product.specialPrice];
        [segue.destinationViewController setStringOldPrice:self.product.price];
        [segue.destinationViewController setFeaturesText:self.product.attributeShortDescription];
        [segue.destinationViewController setDescriptionText:self.product.descriptionString];
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
    [self.imageSection.mainImage setImageWithURL:[NSURL URLWithString:image.url]];
    
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
    
    [self.imageSection.wishListButton addTarget:self
                                         action:@selector(addProductToWishList)
                               forControlEvents:UIControlEventTouchUpInside];
    
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
        
        self.variationsSection.titleLabel.text = @"Variations";
        
        float start = 0.0;
        
        for (RIVariation *variation in self.product.variations) {
            
            UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start, 0.0, 30.0, 30.0)];
            [newImageView setImageWithURL:[NSURL URLWithString:variation.image.url]];
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
    
    [self.productInfoSection setPriceWithNewValue:[self.product.specialPrice stringValue]
                                      andOldValue:[self.product.price stringValue]];
    
    [self showLoading];
    
    [RIProductRatings getRatingsForProductWithUrl:@"http://www.jumia.com.ng/mobapi/v1.4/Asha-302---Black-7546.html?rating=1&page=1"
                                     successBlock:^(RIProductRatings *ratings) {
                                        
                                         self.productInfoSection.numberOfReviewsLabel.text = [NSString stringWithFormat:@"%@ Reviews", ratings.commentsCount];
                                         
                                         NSInteger media = 0;
                                         
                                         for (RIRatingComment *rating in ratings.comments) {
                                             media += [rating.avgRating integerValue];
                                         }
                                         
                                         media = (media / ratings.comments.count);
                                         
                                         [self.productInfoSection setNumberOfStars:media];
                                         
                                         self.productRatings = ratings;
                                         
                                         [self hideLoading];
                                         
                                         [self.productInfoSection.goToReviewsButton addTarget:self
                                                                                       action:@selector(goToRatinsMainScreen)
                                                                             forControlEvents:UIControlEventTouchUpInside];
                                         
                                     } andFailureBlock:^(NSArray *errorMessages) {
                                         
                                         [self hideLoading];
                                         
                                     }];
    
    self.productInfoSection.specificationsLabel.text = @"Specifications";
    
    self.productInfoSection.layer.cornerRadius = 4.0f;
    
    [self.productInfoSection.sizeButton addTarget:self
                                           action:@selector(showSizePicker)
                                 forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.productInfoSection.goToSpecificationsButton addTarget:self
                                                         action:@selector(gotoDetails)
                                               forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:self.productInfoSection];
    
    startingElement += (4 + self.productInfoSection.frame.size.height);
    
    /*******
     Related Items
     *******/
    
    if (self.fromCatalogue) {
        
        self.relatedItems.frame = CGRectMake(6,
                                             startingElement,
                                             self.relatedItems.frame.size.width,
                                             self.relatedItems.frame.size.height);
        
        self.relatedItems.layer.cornerRadius = 4.0f;
        
        [self.mainScrollView addSubview:self.relatedItems];
        
        startingElement += (4 + self.relatedItems.frame.size.height);
    }
    
    /*******
        CTA Buttons
     *******/
    
    self.ctaButtons.frame = CGRectMake(6,
                                       startingElement+2,
                                       self.ctaButtons.frame.size.width,
                                       self.ctaButtons.frame.size.height);
    
#warning need to change the product parser to include the phone_number
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.product]]]) {
        [self.ctaButtons layoutViewWithNumberOfButton:2];
    } else {
        [self.ctaButtons layoutViewWithNumberOfButton:1];
    }
    
    [self.ctaButtons.addToCartButton addTarget:self
                                        action:@selector(addToCart)
                              forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:self.ctaButtons];
    
    startingElement += (6 + self.ctaButtons.frame.size.height);
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, startingElement + 6);
}

#pragma mark - Actions

- (void)gotoDetails
{
    [self performSegueWithIdentifier:@"segueToDetails"
                              sender:nil];
}

- (void)goToRatinsMainScreen
{
    [self performSegueWithIdentifier:@"showRatingsMain"
                              sender:nil];
}

- (void)shareProduct
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:self.product.name];
        [self presentViewController:tweetSheet
                           animated:YES
                         completion:nil];
    }
}

- (void)addProductToWishList
{
    
}

- (void)addToCart
{
    [self showLoading];
    
    [RICart addProductWithQuantity:@"1"
                               sku:self.product.sku
                            simple:((RIProduct *)[self.product.productSimples firstObject]).sku
                  withSuccessBlock:^(RICart *cart) {
                      
                      [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                 message:@"Product added"
                                                delegate:nil
                                       cancelButtonTitle:nil
                                        otherButtonTitles:@"Ok", nil] show];
                      
                      [self hideLoading];
                      
                  } andFailureBlock:^(NSArray *errorMessages) {
                      
                      [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                  message:@"Error adding to the cart"
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"Ok", nil] show];
                      
                      [self hideLoading];
                      
                  }];
}

- (void)callToOrder
{
    
}

- (void)showSizePicker
{
    self.picker = [JAPDVPicker getNewJAPDVPicker];
    
    self.pickerDataSource = [NSMutableArray new];
    
    if (self.product.productSimples.count > 0) {
        for (RIProductSimple *simple in self.product.productSimples) {
            if (simple.stock > 0) {
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
    frame.origin.y = self.view.frame.size.height;
    self.picker.frame = frame;
    [self.view addSubview:self.picker];
    frame.origin.y = 0.0f;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     }];
}

- (void)didSelectedValueInPicker
{
    NSUInteger selectedRow = [self.picker.picker selectedRowInComponent:0];
    RIProductSimple *simple = [self.pickerDataSource objectAtIndex:selectedRow];
    
    [self.productInfoSection.sizeButton setTitle:simple.attributeSize
                                        forState:UIControlStateNormal];
    
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
  
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                     }];
}

- (void)presentGallery
{
    self.gallery = [JAPDVGalleryView getNewJAPDVGalleryView];
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

@end

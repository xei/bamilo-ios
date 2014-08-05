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

@interface JAPDVViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) RIProductReview *productReview;
@property (strong, nonatomic) JAPDVImageSection *imageSection;
@property (strong, nonatomic) JAPDVVariations *variationsSection;
@property (strong, nonatomic) JAPDVProductInfo *productInfoSection;
@property (strong, nonatomic) JACTAButtons *ctaButtons;
@property (strong, nonatomic) JAPDVRelatedItem *relatedItems;

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
    
    [self.mainScrollView addSubview:self.imageSection];
    
    RIImage *image = [self.product.images firstObject];
    [self.imageSection.mainImage setImageWithURL:[NSURL URLWithString:image.url]];
    
    self.imageSection.productNameLabel.text = self.product.brand;
    self.imageSection.productDescriptionLabel.text = self.product.name;
    
    if (self.product.maxSavingPercentage.length > 0) {
        self.imageSection.discountLabel.text = [NSString stringWithFormat:@"-%@%%", self.product.maxSavingPercentage];
    } else {
        self.imageSection.discountLabel.hidden = YES;
    }
    
    startingElement += (4 + self.imageSection.frame.size.height);
    
    /*******
        Colors / Variation
     *******/
    
    if (self.product.variations.count > 0) {
        
        self.variationsSection.layer.cornerRadius = 4.0f;
        
        self.variationsSection.titleLabel.text = @"Variations";
        
        float start = 0.0;
        
        for (RIVariation *variation in self.product.variations) {
            
            UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start, 0.0, 30.0, 30.0)];
            [newImageView setImageWithURL:[NSURL URLWithString:variation.image.url]];
            [self.variationsSection.variationsScrollView addSubview:newImageView];
            
            start += 40.0;
        }
        
        self.variationsSection.frame = CGRectMake(6,
                                                  startingElement,
                                                  self.variationsSection.frame.size.width,
                                                  self.variationsSection.frame.size.height);
        
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
    
    [RIProductReview getReviewForProductWithSku:self.product.sku
                                   successBlock:^(id review) {
                                       
                                       self.productReview = review;
                                       
                                       self.productInfoSection.numberOfReviewsLabel.text = [self.productReview.commentsCount stringValue];
                                       
#warning missing the number of stars
                                       
                                       [self hideLoading];
                                       
                                   } andFailureBlock:^(NSArray *errorMessages) {
                                       
                                       [self hideLoading];
                                       
                                   }];
    
    self.productInfoSection.specificationsLabel.text = @"Specifications";
    
    self.productInfoSection.layer.cornerRadius = 4.0f;
    
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
    
    [self.ctaButtons layoutView];
    
    [self.mainScrollView addSubview:self.ctaButtons];
    
    startingElement += (6 + self.ctaButtons.frame.size.height);
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, startingElement + 700);
    
}

@end

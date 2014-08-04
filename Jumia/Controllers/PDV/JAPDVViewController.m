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
    
    self.productInfoSection.frame = CGRectMake(6,
                                              startingElement,
                                              308,
                                              172);
    
    [self.mainScrollView addSubview:self.productInfoSection];
    
    startingElement += (4 + self.productInfoSection.frame.size.height);
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, startingElement + 30);
    
}

@end

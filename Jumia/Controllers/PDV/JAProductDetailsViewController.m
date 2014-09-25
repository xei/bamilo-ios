//
//  JAProductDetailsViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 08/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAProductDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JAPriceView.h"

@interface JAProductDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelBrand;
@property (weak, nonatomic) IBOutlet UILabel *labelNewPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelOldPrice;
@property (weak, nonatomic) IBOutlet UIScrollView *contenteScrollView;
@property (weak, nonatomic) IBOutlet UIView *featuresView;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet UIImageView *featuresLineImage;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionLineImage;
@property (weak, nonatomic) IBOutlet UILabel *featuresTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *featuresTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistance;
@property (nonatomic, strong) JAPriceView *priceView;

@end

@implementation JAProductDetailsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.labelBrand.text = self.stringBrand;
    self.labelName.text = self.stringName;
    
    self.view.backgroundColor = JABackgroundGrey;
    self.featuresTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.descriptionTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.contenteScrollView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    
    [self.labelNewPrice removeFromSuperview];
    [self.labelOldPrice removeFromSuperview];
    
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:self.stringOldPrice
                     specialPrice:self.stringNewPrice
                         fontSize:14.0f
            specialPriceOnTheLeft:NO];
    
    self.priceView.frame = CGRectMake(12.0f,
                                      68.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.view addSubview:self.priceView];
    
    self.featuresView.layer.cornerRadius = 4.0f;
    self.descriptionView.layer.cornerRadius = 4.0f;
    
    if (self.featuresText.length == 0)
    {
        [self.descriptionView removeFromSuperview];
        
        self.featuresTitleLabel.text = STRING_PRODUCT_FEATURES;
        
        self.featuresTextLabel.text = self.descriptionText;
        [self.featuresTextLabel sizeToFit];
        
        self.featuresView.frame = CGRectMake(self.featuresView.frame.origin.x,
                                             self.featuresView.frame.origin.y,
                                             self.featuresView.frame.size.width,
                                             self.featuresTextLabel.frame.size.height + 70);
        
        [self.contenteScrollView setContentSize:CGSizeMake(320, self.featuresView.frame.size.height - 15)];
    }
    else
    {
        self.featuresTitleLabel.text = STRING_PRODUCT_FEATURES;
        self.descriptionTitleLabel.text = STRING_PRODUCT_DESCRIPTION;

        self.featuresTextLabel.text = self.featuresText;
        [self.featuresTextLabel sizeToFit];
        
        self.featuresView.frame = CGRectMake(self.featuresView.frame.origin.x,
                                             self.featuresView.frame.origin.y,
                                             self.featuresView.frame.size.width,
                                             self.featuresTextLabel.frame.size.height + 70);
        
        self.descriptionTextLabel.text = self.descriptionText;
        [self.descriptionTextLabel sizeToFit];
        
        self.descriptionView.frame = CGRectMake(self.descriptionView.frame.origin.x,
                                                self.descriptionView.frame.origin.y,
                                                self.descriptionView.frame.size.width,
                                                self.descriptionTextLabel.frame.size.height + 70);
        
        [self.contenteScrollView setContentSize:CGSizeMake(320, self.featuresView.frame.size.height + self.descriptionView.frame.size.height)];
    }
    
    self.bottomDistance.constant = 6;
    
    [self.view updateConstraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

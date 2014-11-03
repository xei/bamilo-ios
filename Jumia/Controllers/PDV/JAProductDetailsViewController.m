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
#import "RIProduct.h"

@interface JAProductDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelBrand;
@property (weak, nonatomic) IBOutlet UILabel *labelNewPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelOldPrice;
@property (weak, nonatomic) IBOutlet UIScrollView *contenteScrollView;
@property (strong, nonatomic) UIView *featuresView;
@property (strong, nonatomic) UILabel *featuresTitleLabel;
@property (strong, nonatomic) UIView *featuresSeparator;
@property (strong, nonatomic) UILabel *featuresTextLabel;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) UILabel *descriptionTitleLabel;
@property (strong, nonatomic) UIView *descriptionSeparator;
@property (strong, nonatomic) UILabel *descriptionTextLabel;

@property (nonatomic, strong) JAPriceView *priceView;

@end

@implementation JAProductDetailsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(VALID_NOTEMPTY(self.product.sku, NSString))
    {
        self.screenName = [NSString stringWithFormat:@"PDSSecondScreen / %@", self.product.sku];
    }
    else
    {
        self.screenName = @"PDSSecondScreen";
    }
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.view.backgroundColor = JABackgroundGrey;
    
    self.contenteScrollView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    self.contenteScrollView.translatesAutoresizingMaskIntoConstraints = YES;

    self.topView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.labelBrand.text = self.product.brand;
    self.labelName.text = self.product.name;
    [self.labelName sizeToFit];
    
    if(VALID(self.priceView, JAPriceView))
    {
        [self.priceView removeFromSuperview];
    }
    
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:self.product.priceFormatted
                     specialPrice:self.product.specialPriceFormatted
                         fontSize:14.0f
            specialPriceOnTheLeft:NO];
    
    self.priceView.frame = CGRectMake(12.0f,
                                      CGRectGetMaxY(self.labelName.frame) + 4.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.view addSubview:self.priceView];
    
    [self setupViews];
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void) setupViews
{
    CGFloat topViewMinHeight = CGRectGetMaxY(self.priceView.frame);
    if(topViewMinHeight < 38.0f)
    {
        topViewMinHeight = 38.0f;
    }
    topViewMinHeight += 6.0f;
    
    [self.topView setFrame:CGRectMake(0.0f,
                                      0.0f,
                                      self.view.frame.size.width,
                                      topViewMinHeight)];
    
    [self.contenteScrollView setFrame:CGRectMake(0.0f,
                                                 topViewMinHeight,
                                                 self.view.frame.size.width,
                                                 self.view.frame.size.height - topViewMinHeight - CGRectGetMinY(self.topView.frame))];
    
    if(VALID(self.featuresView, UIView))
    {
        for(UIView *subView in self.featuresView.subviews)
        {
            [subView removeFromSuperview];
        }
        [self.featuresView removeFromSuperview];
    }
    
    if(VALID(self.descriptionView, UIView))
    {
        for(UIView *subView in self.descriptionView.subviews)
        {
            [subView removeFromSuperview];
        }
        [self.descriptionView removeFromSuperview];
    }

    self.featuresView = [[UIView alloc] initWithFrame:CGRectMake(6.0f,
                                                                 6.0f,
                                                                 self.contenteScrollView.frame.size.width - 12.0f,
                                                                 0.0f)];
    [self.featuresView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.featuresView.layer.cornerRadius = 5.0f;
    [self.contenteScrollView addSubview:self.featuresView];
    
    self.featuresTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f,
                                                                        2.0f,
                                                                        self.featuresView.frame.size.width - 6.0f,
                                                                        21.0f)];
    [self.featuresTitleLabel setNumberOfLines:1];
    [self.featuresTitleLabel setText:STRING_PRODUCT_FEATURES];
    [self.featuresTitleLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.featuresTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.featuresView addSubview:self.featuresTitleLabel];
    
    self.featuresSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      26.0f,
                                                                      self.featuresView.frame.size.width,
                                                                      1.0f)];
    [self.featuresSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.featuresView addSubview:self.featuresSeparator];
    
    self.featuresTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f,
                                                                       33.0f,
                                                                       self.featuresView.frame.size.width - 6.0f,
                                                                       0.0f)];
    [self.featuresTextLabel setNumberOfLines:0];
    [self.featuresTextLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.featuresTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
    [self.featuresView addSubview:self.featuresTextLabel];
    
    if (VALID_NOTEMPTY(self.product.attributeShortDescription, NSString))
    {
        [self.featuresTextLabel setText:self.product.attributeShortDescription];
        [self.featuresTextLabel sizeToFit];
        [self.featuresView setFrame:CGRectMake(6.0f,
                                               6.0f,
                                               self.contenteScrollView.frame.size.width - 12.0f,
                                               CGRectGetMaxY(self.featuresTextLabel.frame) + 6.0f)];
        
        self.descriptionView = [[UIView alloc] initWithFrame:CGRectMake(6.0f,
                                                                        6.0f,
                                                                        self.contenteScrollView.frame.size.width - 12.0f,
                                                                        0.0f)];
        [self.descriptionView setBackgroundColor:UIColorFromRGB(0xffffff)];
        self.descriptionView.layer.cornerRadius = 5.0f;
        [self.contenteScrollView addSubview:self.descriptionView];
        
        self.descriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f,
                                                                               2.0f,
                                                                               self.descriptionView.frame.size.width - 6.0f,
                                                                               21.0f)];
        [self.descriptionTitleLabel setNumberOfLines:1];
        [self.descriptionTitleLabel setText:STRING_PRODUCT_DESCRIPTION];
        [self.descriptionTitleLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
        [self.descriptionTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
        [self.descriptionView addSubview:self.descriptionTitleLabel];
        
        self.descriptionSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             26.0f,
                                                                             self.descriptionView.frame.size.width,
                                                                             1.0f)];
        [self.descriptionSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
        [self.descriptionView addSubview:self.descriptionSeparator];
        
        self.descriptionTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f,
                                                                              33.0f,
                                                                              self.descriptionView.frame.size.width - 6.0f,
                                                                              0.0f)];
        [self.descriptionTextLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.descriptionTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
        [self.descriptionTextLabel setNumberOfLines:0];
        [self.descriptionView addSubview:self.descriptionTextLabel];
        
        [self.descriptionTextLabel setText:self.product.descriptionString];
        [self.descriptionTextLabel sizeToFit];
        [self.descriptionView setFrame:CGRectMake(6.0f,
                                                  CGRectGetMaxY(self.featuresView.frame) + 6.0f,
                                                  self.contenteScrollView.frame.size.width - 12.0f,
                                                  CGRectGetMaxY(self.descriptionTextLabel.frame) + 6.0f)];
        
        [self.contenteScrollView setContentSize:CGSizeMake(self.view.frame.size.width,
                                                           CGRectGetMaxY(self.descriptionView.frame) + 6.0f)];
    }
    else
    {
        [self.featuresTextLabel setText:self.product.descriptionString];
        [self.featuresTextLabel sizeToFit];
        [self.featuresView setFrame:CGRectMake(6.0f,
                                               6.0f,
                                               self.contenteScrollView.frame.size.width - 12.0f,
                                               CGRectGetMaxY(self.featuresTextLabel.frame) + 6.0f)];
        
        [self.contenteScrollView setContentSize:CGSizeMake(self.view.frame.size.width,
                                                           CGRectGetMaxY(self.featuresView.frame) + 6.0f)];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupViews];
    [self hideLoading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

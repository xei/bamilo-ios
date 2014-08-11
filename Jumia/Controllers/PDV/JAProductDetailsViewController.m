//
//  JAProductDetailsViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 08/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAProductDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>

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

@end

@implementation JAProductDetailsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowBackNofication
                                                        object:nil];
    
    self.labelBrand.text = self.stringBrand;
    self.labelName.text = self.stringName;
    self.labelNewPrice.text = [self.stringNewPrice stringValue];
    self.labelOldPrice.text = [self.stringOldPrice stringValue];
    
    self.featuresView.layer.cornerRadius = 4.0f;
    self.descriptionView.layer.cornerRadius = 4.0f;
    
    self.featuresTitleLabel.text = @"Product Features";
    self.descriptionTitleLabel.text = @"Product Description";
    
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
    
    [self.contenteScrollView layoutSubviews];
    
    [self.contenteScrollView setContentSize:CGSizeMake(320, self.featuresView.frame.size.height + self.descriptionView.frame.size.height - 35)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

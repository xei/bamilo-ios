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
    
    self.navBarLayout.showBackButton = YES;
    
    self.labelBrand.text = self.stringBrand;
    self.labelName.text = self.stringName;
    
    if(VALID_NOTEMPTY(self.stringOldPrice, NSString))
    {
        self.labelNewPrice.text = self.stringOldPrice;
        
        [self.labelOldPrice removeFromSuperview];
    }
    else
    {
        NSMutableAttributedString *stringOldPrice = [[NSMutableAttributedString alloc] initWithString:self.stringOldPrice];
        NSInteger stringOldPriceLenght = self.stringOldPrice.length;
        UIFont *stringOldPriceFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                                     size:14.0];
        UIColor *stringOldPriceColor = [UIColor colorWithRed:204.0/255.0
                                                       green:204.0/255.0
                                                        blue:204.0/255.0
                                                       alpha:1.0f];
        
        [stringOldPrice addAttribute:NSFontAttributeName
                               value:stringOldPriceFont
                               range:NSMakeRange(0, stringOldPriceLenght)];
        
        [stringOldPrice addAttribute:NSStrokeColorAttributeName
                               value:stringOldPriceColor
                               range:NSMakeRange(0, stringOldPriceLenght)];
        
        [stringOldPrice addAttribute:NSStrikethroughStyleAttributeName
                               value:@(1)
                               range:NSMakeRange(0, stringOldPriceLenght)];
        
        self.labelOldPrice.attributedText = stringOldPrice;
        
        self.labelNewPrice.text = self.stringNewPrice;
        
        [self.labelNewPrice sizeToFit];
        [self.labelOldPrice sizeToFit];
        
        float x = self.labelNewPrice.frame.origin.x + self.labelNewPrice.frame.size.width + 5;
        CGRect temp = self.labelOldPrice.frame;
        temp.origin.x = x;
        self.labelOldPrice.frame = temp;
        
        [self.topView layoutSubviews];
    }
    
    self.featuresView.layer.cornerRadius = 4.0f;
    self.descriptionView.layer.cornerRadius = 4.0f;
    
    if (self.featuresText.length == 0)
    {
        [self.descriptionView removeFromSuperview];
        
        self.featuresTitleLabel.text = @"Product Features";
        
        self.featuresTextLabel.text = self.descriptionText;
        [self.featuresTextLabel sizeToFit];
        
        self.featuresView.frame = CGRectMake(self.featuresView.frame.origin.x,
                                             self.featuresView.frame.origin.y,
                                             self.featuresView.frame.size.width,
                                             self.featuresTextLabel.frame.size.height + 70);
        
        [self.contenteScrollView layoutSubviews];
        
        [self.contenteScrollView setContentSize:CGSizeMake(320, self.featuresView.frame.size.height - 15)];
    }
    else
    {
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

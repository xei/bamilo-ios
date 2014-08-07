//
//  JANewRatingViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANewRatingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface JANewRatingViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelNewPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelFixed;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelAppearance;
@property (weak, nonatomic) IBOutlet UILabel *labelQuality;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendReview;
@property (weak, nonatomic) IBOutlet UIView *centerView;

@end

@implementation JANewRatingViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.brandLabel.text = self.ratingProductBrand;
    self.nameLabel.text = self.ratingProductNameForLabel;
    self.oldPriceLabel.text = [self.ratingProductOldPriceForLabel stringValue];
    
    if (self.ratingProductNewPriceForLabel) {
        self.labelNewPrice.text = [self.ratingProductNewPriceForLabel stringValue];
    } else {
        [self.labelNewPrice removeFromSuperview];
    }
    
    self.labelFixed.text = @"You have used this Product? Rate it now!";
    self.labelPrice.text = @"Price";
    self.labelAppearance.text = @"Appearance";
    self.labelQuality.text = @"Quality";
    self.titleTextField.placeholder = @"Title";
    self.commentTextField.placeholder = @"Title";
    
    [self.sendReview setTitle:@"Send Review"
                     forState:UIControlStateNormal];
    
    self.centerView.layer.cornerRadius = 4.0f;
    self.sendReview.layer.cornerRadius = 4.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Send review

- (IBAction)sendReview:(id)sender
{
    
}

- (IBAction)changeStars:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    
    switch (tag) {
        case 1001:
        {
            [((UIButton *)[self.view viewWithTag:1001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1002]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1003]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
        }
            break;
            
        case 1002:
        {
            [((UIButton *)[self.view viewWithTag:1001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1003]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
        }
            break;
            
        case 1003:
        {
            [((UIButton *)[self.view viewWithTag:1001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
        }
            break;
            
        case 1004:
        {
            [((UIButton *)[self.view viewWithTag:1001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1004]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
        }
            break;
            
        case 1005:
        {
            [((UIButton *)[self.view viewWithTag:1001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1004]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1005]) setImage:[self getFilledStar] forState:UIControlStateNormal];
        }
            break;
            
        case 2001:
        {
            
        }
            break;
            
        case 2002:
        {
            
        }
            break;
            
        case 2003:
        {
            
        }
            break;
            
        case 2004:
        {
            
        }
            break;
            
        case 2005:
        {
            
        }
            break;
            
        case 3001:
        {
            
        }
            break;
            
        case 3002:
        {
            
        }
            break;
            
        case 3003:
        {
            
        }
            break;
            
        case 3004:
        {
            
        }
            break;
            
        case 3005:
        {
            
        }
            break;
            
        default:
            break;
    }
}

- (UIImage *)getEmptyStar
{
    return [UIImage imageNamed:@"img_rating_star_big_empty"];
}

- (UIImage *)getFilledStar
{
    return [UIImage imageNamed:@"img_rating_star_big_full"];
}

@end

//
//  JANewRatingViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANewRatingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RIForm.h"
#import "RIField.h"
#import "RIProductRatings.h"

@interface JANewRatingViewController ()
<
    UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelNewPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelFixed;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelAppearance;
@property (weak, nonatomic) IBOutlet UILabel *labelQuality;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewName;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewComment;
@property (weak, nonatomic) IBOutlet UIButton *sendReview;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (assign, nonatomic) CGRect originalFrame;
@property (assign, nonatomic) NSInteger priceStars;
@property (assign, nonatomic) NSInteger appearanceStars;
@property (assign, nonatomic) NSInteger qualityStars;

@end

@implementation JANewRatingViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.originalFrame = self.centerView.frame;
    
    self.brandLabel.text = self.ratingProductBrand;
    self.nameLabel.text = self.ratingProductNameForLabel;
    
    [((UIButton *)[self.view viewWithTag:1001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:2001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:3001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
    
    if ([self.ratingProductNewPriceForLabel floatValue] > 0.0)
    {
        NSMutableAttributedString *stringOldPrice = [[NSMutableAttributedString alloc] initWithString:self.ratingProductOldPriceForLabel];
        NSInteger stringOldPriceLenght = self.ratingProductOldPriceForLabel.length;
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
        
        self.oldPriceLabel.attributedText = stringOldPrice;
        
        NSMutableAttributedString *stringNewPrice = [[NSMutableAttributedString alloc] initWithString:self.ratingProductNewPriceForLabel];
        NSInteger stringNewPriceLenght = self.ratingProductNewPriceForLabel.length;
        UIFont *stringNewPriceFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                                     size:14.0];
        UIColor *stringNewPriceColor = [UIColor colorWithRed:204.0/255.0
                                                       green:0.0/255.0
                                                        blue:0.0/255.0
                                                       alpha:1.0f];
        
        [stringNewPrice addAttribute:NSFontAttributeName
                               value:stringNewPriceFont
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        [stringNewPrice addAttribute:NSStrokeColorAttributeName
                               value:stringNewPriceColor
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        self.labelNewPrice.attributedText = stringNewPrice;
        
        [self.labelNewPrice sizeToFit];
        [self.labelPrice sizeToFit];
        [self.topView layoutSubviews];
    }
    else
    {
        NSMutableAttributedString *stringNewPrice = [[NSMutableAttributedString alloc] initWithString:self.ratingProductOldPriceForLabel];
        NSInteger stringNewPriceLenght = self.ratingProductOldPriceForLabel.length;
        UIFont *stringNewPriceFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                                     size:14.0];
        UIColor *stringNewPriceColor = [UIColor colorWithRed:204.0/255.0
                                                       green:0.0/255.0
                                                        blue:0.0/255.0
                                                       alpha:1.0f];
        
        [stringNewPrice addAttribute:NSFontAttributeName
                               value:stringNewPriceFont
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        [stringNewPrice addAttribute:NSStrokeColorAttributeName
                               value:stringNewPriceColor
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        self.labelNewPrice.attributedText = stringNewPrice;
        
        [self.oldPriceLabel removeFromSuperview];
        [self.labelNewPrice sizeToFit];
        [self.topView layoutSubviews];
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

    [self showLoading];
    
    [RIForm getForm:@"rating"
       successBlock:^(RIForm *form) {
           
           for (RIField *field in form.fields) {
               if ([field.uid isEqualToString:@"RatingForm_name"]) {
                   self.nameTextField.hidden = NO;
                   self.nameTextField.placeholder = @"Name";
                   self.nameTextField.delegate = self;
                   self.imageViewName.hidden = NO;
               } else if ([field.uid isEqualToString:@"RatingForm_title"]) {
                   self.titleTextField.hidden = NO;
                   self.titleTextField.placeholder = @"Title";
                   self.titleTextField.delegate = self;
                   self.imageViewTitle.hidden = NO;
               } else if ([field.uid isEqualToString:@"RatingForm_comment"]) {
                   self.commentTextField.hidden = NO;
                   self.commentTextField.placeholder = @"Comment";
                   self.commentTextField.delegate = self;
                   self.imageViewComment.hidden = NO;
               }
           }
           
           [self hideLoading];
           
       } failureBlock:^(NSArray *errorMessage) {
           
           [self hideLoading];

           [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                       message:@"There was an error"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK", nil] show];
       }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Textfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.originalFrame.origin.y == self.centerView.frame.origin.y) {
        [UIView animateWithDuration:0.5f
                         animations:^{
                             CGRect frame = self.centerView.frame;
                             frame.origin.y -= 100;
                             self.centerView.frame = frame;
                         }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.centerView.frame = self.originalFrame;
                     }];
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Send review

- (IBAction)sendReview:(id)sender
{
    if ((self.nameTextField.text.length > 0) && (self.commentTextField.text.length > 0) && (self.titleTextField.text.length > 0))
    {
        [self showLoading];
        
        NSInteger finalRating = (self.priceStars  + self.appearanceStars + self.qualityStars) / 3;
        
        [RIProductRatings sendRatingWithSku:self.ratingProductSku
                                      stars:[NSString stringWithFormat:@"%d", finalRating]
                                     userId:@"0"
                                       name:self.nameTextField.text
                                      title:self.titleTextField.text
                                    comment:self.commentTextField.text
                               successBlock:^(BOOL success) {
                                   
                                   [self hideLoading];
                                   
                                   [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                               message:@"Review submited with sucess."
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"Ok", nil] show];
                                   
                               } andFailureBlock:^(NSArray *errorMessages) {
                                  
                                   [self hideLoading];
                                   
                                   [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                               message:@"There was an error sending the review!"
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"Ok", nil] show];
                                   
                               }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                   message:@"Please fill all the fields."
                                  delegate:nil
                         cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
    }
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
            self.priceStars = 1;
        }
            break;
            
        case 1002:
        {
            [((UIButton *)[self.view viewWithTag:1001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1003]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.priceStars = 2;
        }
            break;
            
        case 1003:
        {
            [((UIButton *)[self.view viewWithTag:1001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.priceStars = 3;
        }
            break;
            
        case 1004:
        {
            [((UIButton *)[self.view viewWithTag:1001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1004]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.priceStars = 4;
        }
            break;
            
        case 1005:
        {
            [((UIButton *)[self.view viewWithTag:1001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1004]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:1005]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            self.priceStars = 5;
        }
            break;
            
        case 2001:
        {
            [((UIButton *)[self.view viewWithTag:2001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2002]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2003]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.appearanceStars = 1;
        }
            break;
            
        case 2002:
        {
            [((UIButton *)[self.view viewWithTag:2001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2003]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.appearanceStars = 2;
        }
            break;
            
        case 2003:
        {
            [((UIButton *)[self.view viewWithTag:2001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.appearanceStars = 3;
        }
            break;
            
        case 2004:
        {
            [((UIButton *)[self.view viewWithTag:2001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2004]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.appearanceStars = 4;
        }
            break;
            
        case 2005:
        {
            [((UIButton *)[self.view viewWithTag:2001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2004]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:2005]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            self.appearanceStars = 5;
        }
            break;
            
        case 3001:
        {
            [((UIButton *)[self.view viewWithTag:3001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3002]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3003]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.qualityStars = 1;
        }
            break;
            
        case 3002:
        {
            [((UIButton *)[self.view viewWithTag:3001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3003]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.qualityStars = 2;
        }
            break;
            
        case 3003:
        {
            [((UIButton *)[self.view viewWithTag:3001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3004]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.qualityStars = 3;
        }
            break;
            
        case 3004:
        {
            [((UIButton *)[self.view viewWithTag:3001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3004]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3005]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.qualityStars = 4;
        }
            break;
            
        case 3005:
        {
            [((UIButton *)[self.view viewWithTag:3001]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3002]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3003]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3004]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self.view viewWithTag:3005]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            self.qualityStars = 5;
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

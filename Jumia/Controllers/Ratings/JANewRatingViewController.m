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
#import "RIRatings.h"
#import "JADynamicForm.h"
#import "JAStarsComponent.h"
#import "RICustomer.h"

@interface JANewRatingViewController ()
<
    UITextFieldDelegate,
    JADynamicFormDelegate,
    UIAlertViewDelegate
>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelNewPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelFixed;
@property (weak, nonatomic) IBOutlet UIButton *sendReview;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic) JADynamicForm *ratingDynamicForm;
@property (assign, nonatomic) CGRect originalFrame;
@property (strong, nonatomic) NSMutableArray *ratingStarsArray;

@end

@implementation JANewRatingViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    
    self.originalFrame = self.centerView.frame;
    
    self.brandLabel.text = self.ratingProductBrand;
    self.nameLabel.text = self.ratingProductNameForLabel;
    
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
    
    [self.sendReview setTitle:@"Send Review"
                     forState:UIControlStateNormal];
    
    [self.sendReview setTitleColor:UIColorFromRGB(0x4e4e4e)
                          forState:UIControlStateNormal];
    
    self.centerView.layer.cornerRadius = 4.0f;

    [self showLoading];
    
    __block float startingY = self.labelFixed.frame.origin.y + 22;
    
    [RIRatings getRatingsWithSuccessBlock:^(id ratings) {
        
        self.ratingStarsArray = [NSMutableArray new];
        
        for (RIRatingsDetails *option in ratings) {
            
            JAStarsComponent *stars = [JAStarsComponent getNewJAStarsComponent];
            stars.title.text = option.title;
            stars.ratingOptions = option.options;
            stars.starValue = 1;
            
            CGRect frame = stars.frame;
            frame.origin.y = startingY;
            
            stars.frame = frame;
            
            [self.centerView addSubview:stars];
            startingY += stars.frame.size.height + 6;
            
            [self.ratingStarsArray addObject:stars];
        }
        
        [RIForm getForm:@"rating"
           successBlock:^(RIForm *form) {
               
               self.ratingDynamicForm = [[JADynamicForm alloc] initWithForm:form
                                                                   delegate:self
                                                           startingPosition:startingY-10];
               
               for (UIView *view in self.ratingDynamicForm.formViews)
               {
                   [self.centerView addSubview:view];
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
        
    } andFailureBlock:^(NSArray *errorMessages) {
        
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

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         CGRect frame = self.centerView.frame;
                         
                         if (self.centerView.frame.origin.y < 0)
                         {
                             frame.origin.y -= 44;
                         }
                         else
                         {
                             frame.origin.y -= (view.center.y - 35);
                         }
                         
                         self.centerView.frame = frame;
                     }];
}

- (void)lostFocus
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.centerView.frame = self.originalFrame;
                     }];
}

#pragma mark - Send review

- (IBAction)sendReview:(id)sender
{
    [self showLoading];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self.ratingDynamicForm getValues]];
    
    for (JAStarsComponent *component in self.ratingStarsArray)
    {
        RIRatingsOptions *option = [component.ratingOptions objectAtIndex:(component.starValue - 1)];
        NSString *key = [NSString stringWithFormat:@"rating-option--%@", option.fkRatingType];
        
        [parameters addEntriesFromDictionary:@{key: option.value}];
    }
    
    [parameters addEntriesFromDictionary:@{@"rating-customer": [RICustomer getCustomerId]}];
    [parameters addEntriesFromDictionary:@{@"rating-catalog-sku": self.ratingProductSku}];
    
    [RIForm sendForm:self.ratingDynamicForm.form
          parameters:parameters
        successBlock:^(id object) {
            
            [self hideLoading];
            
            [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                        message:@"Review submited with sucess."
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Ok", nil] show];
            
            
        } andFailureBlock:^(id errorObject) {
            
            [self hideLoading];
            
            
            if(VALID_NOTEMPTY(errorObject, NSDictionary))
            {
                [self.ratingDynamicForm validateFields:errorObject];
                
                [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                            message:@"Invalid fields"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
            }
            else if(VALID_NOTEMPTY(errorObject, NSArray))
            {
                [self.ratingDynamicForm checkErrors];
                
                [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                            message:[errorObject componentsJoinedByString:@","]
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
            }
            else
            {
                [self.ratingDynamicForm checkErrors];
                
                [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                            message:@"Generic error"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
            }
        }];
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

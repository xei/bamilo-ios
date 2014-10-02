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
#import "JAPriceView.h"
#import "JAUtils.h"
#import "RIProduct.h"

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
@property (nonatomic, strong) JAPriceView *priceView;
@property (assign, nonatomic) NSInteger numberOfFields;

@end

@implementation JANewRatingViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(VALID_NOTEMPTY(self.product.sku, NSString))
    {
        self.screenName = [NSString stringWithFormat:@"WriteRatingScreen / %@", self.product.sku];
    }
    else
    {
        self.screenName = @"WriteRatingScreen";
    }
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.originalFrame = self.centerView.frame;
    
    self.brandLabel.text = self.product.brand;
    self.nameLabel.text = self.product.name;
    
    [self.oldPriceLabel removeFromSuperview];
    [self.labelNewPrice removeFromSuperview];
    
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:self.product.priceFormatted
                     specialPrice:self.product.specialPriceFormatted
                         fontSize:14.0f
            specialPriceOnTheLeft:NO];
    self.priceView.frame = CGRectMake(12.0f,
                                      68.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.view addSubview:self.priceView];
    
    self.labelFixed.text = STRING_RATE_PRODUCT;
    
    [self.sendReview setTitle:STRING_SEND_REVIEW
                     forState:UIControlStateNormal];
    
    [self.sendReview setTitleColor:UIColorFromRGB(0x4e4e4e)
                          forState:UIControlStateNormal];
    
    self.centerView.layer.cornerRadius = 4.0f;

    [self showLoading];
    
    __block float startingY = self.labelFixed.frame.origin.y + 22;
    
    [RIRatings getRatingsWithSuccessBlock:^(id ratings) {
        
        self.ratingStarsArray = [NSMutableArray new];
        
        self.numberOfFields = 0;
        
        for (RIRatingsDetails *option in ratings) {
            
            JAStarsComponent *stars = [JAStarsComponent getNewJAStarsComponent];
            stars.title.text = option.title;
            stars.ratingOptions = option.options;
            stars.starValue = 1;
            stars.idRatingType = option.idRatingType;
            
            CGRect frame = stars.frame;
            frame.origin.y = startingY;
            
            stars.frame = frame;
            
            [self.centerView addSubview:stars];
            startingY += stars.frame.size.height + 6;
            
            [self.ratingStarsArray addObject:stars];
            
            self.numberOfFields++;
        }
        
        [RIForm getForm:@"rating"
           successBlock:^(RIForm *form) {
               
               self.ratingDynamicForm = [[JADynamicForm alloc] initWithForm:form
                                                                   delegate:self
                                                           startingPosition:startingY-10];
               
               NSInteger count = 0;
               
               for (UIView *view in self.ratingDynamicForm.formViews)
               {
                   view.tag = count;
                   [self.centerView addSubview:view];
                   count++;
               }
               
               NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
               [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];

               [self hideLoading];
               
           } failureBlock:^(NSArray *errorMessage) {
               
               NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
               [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];

               [self hideLoading];
               
               [self showMessage:STRING_ERROR success:NO];
           }];
        
    } andFailureBlock:^(NSArray *errorMessages) {
        
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        
        [self hideLoading];
        
        [self showMessage:STRING_ERROR success:NO];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    __block CGRect frame = self.originalFrame;
    __block CGRect tempFrame = self.view.frame;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         if (self.numberOfFields == 1) {
                             if (tempFrame.size.height > 417) {
                                 frame.origin.y -= (44 * view.tag);
                             } else {
                                 frame.origin.y -= (44 * (view.tag + 1));
                             }
                         } else {
                             if (tempFrame.size.height > 417) {
                                 frame.origin.y -= (44 * (view.tag + 1));
                             } else {
                                 frame.origin.y -= (44 * (view.tag + 3));
                             }
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
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        [self showErrorView:YES controller:self selector:@selector(continueSendingReview) objects:nil];
    }
    else
    {
        [self continueSendingReview];
    }
}

- (void)continueSendingReview
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
    [parameters addEntriesFromDictionary:@{@"rating-catalog-sku": self.product.sku}];
    
    [RIForm sendForm:self.ratingDynamicForm.form
          parameters:parameters
        successBlock:^(id object) {
            
            NSMutableDictionary *globalRateDictionary = [[NSMutableDictionary alloc] init];
            [globalRateDictionary setObject:self.product.sku forKey:kRIEventSkuKey];
            [globalRateDictionary setObject:self.product.brand forKey:kRIEventBrandKey];
            NSNumber *price = VALID_NOTEMPTY(self.product.specialPrice, NSNumber) ? self.product.specialPrice : self.product.price;
            [globalRateDictionary setValue:[price stringValue] forKey:kRIEventPriceKey];
            
            for (JAStarsComponent *component in self.ratingStarsArray)
            {
                NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
                [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                [trackingDictionary setValue:@(component.starValue) forKey:kRIEventValueKey];
                
                if ([component.idRatingType isEqualToString:@"1"])
                {
                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.starValue] forKey:kRIEventRatingPriceKey];
                    [trackingDictionary setValue:@"RateProductPrice" forKey:kRIEventActionKey];
                }
                else if ([component.idRatingType isEqualToString:@"2"])
                {
                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.starValue] forKey:kRIEventRatingAppearanceKey];
                    [trackingDictionary setValue:@"RateProductAppearance" forKey:kRIEventActionKey];
                }
                else if ([component.idRatingType isEqualToString:@"3"])
                {
                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.starValue] forKey:kRIEventRatingQualityKey];
                    [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
                }
                else
                {
                    // There is no indication about the default tracking for rating
                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.starValue] forKey:kRIEventRatingKey];
                    [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
                }
                
                [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
                
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRateProduct]
                                                          data:[trackingDictionary copy]];
            }

            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRateProductGlobal]
                                                      data:[globalRateDictionary copy]];

            [self hideLoading];
            
            [self showMessage:STRING_REVIEW_SENT success:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
                                                                object:nil
                                                              userInfo:nil];            
        } andFailureBlock:^(id errorObject) {
            
            [self hideLoading];
            
            if(VALID_NOTEMPTY(errorObject, NSDictionary))
            {
                [self.ratingDynamicForm validateFields:errorObject];
                
                [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
            }
            else if(VALID_NOTEMPTY(errorObject, NSArray))
            {
                [self.ratingDynamicForm checkErrors];
                
                [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
            }
            else
            {
                [self.ratingDynamicForm checkErrors];
                
                [self showMessage:STRING_ERROR success:NO];
            }
        }];
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

@end

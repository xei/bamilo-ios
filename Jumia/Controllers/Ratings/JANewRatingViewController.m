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

@interface JANewRatingViewController ()
<
    UITextFieldDelegate,
    JADynamicFormDelegate,
    UIAlertViewDelegate,
    JANoConnectionViewDelegate
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
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.originalFrame = self.centerView.frame;
    
    self.brandLabel.text = self.ratingProductBrand;
    self.nameLabel.text = self.ratingProductNameForLabel;
    
    [self.oldPriceLabel removeFromSuperview];
    [self.labelNewPrice removeFromSuperview];
    
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:self.ratingProductOldPriceForLabel
                     specialPrice:self.ratingProductNewPriceForLabel
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
               
               [self hideLoading];
               
           } failureBlock:^(NSArray *errorMessage) {
               
               [self hideLoading];
               
               JAErrorView *errorView = [JAErrorView getNewJAErrorView];
               [errorView setErrorTitle:STRING_ERROR
                               andAddTo:self];
           }];
        
    } andFailureBlock:^(NSArray *errorMessages) {
        
        [self hideLoading];
        
        JAErrorView *errorView = [JAErrorView getNewJAErrorView];
        [errorView setErrorTitle:STRING_ERROR
                        andAddTo:self];
        
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

#pragma mark - No connection delegate

- (void)retryConnection
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self continueSendingReview];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueSendingReview];
    }
}

#pragma mark - Send review

- (IBAction)sendReview:(id)sender
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self continueSendingReview];
        }];
        
        [self.view addSubview:lostConnection];
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
    [parameters addEntriesFromDictionary:@{@"rating-catalog-sku": self.ratingProductSku}];
    
    [RIForm sendForm:self.ratingDynamicForm.form
          parameters:parameters
        successBlock:^(id object) {
            
            for (JAStarsComponent *component in self.ratingStarsArray)
            {
                NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                [trackingDictionary setValue:self.ratingProductSku forKey:kRIEventLabelKey];
                [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                [trackingDictionary setValue:@(component.starValue) forKey:kRIEventValueKey];
                
                if ([component.idRatingType isEqualToString:@"1"])
                {
                    [trackingDictionary setValue:@"RateProductPrice" forKey:kRIEventActionKey];
                }
                else if ([component.idRatingType isEqualToString:@"2"])
                {
                    [trackingDictionary setValue:@"RateProductAppearance" forKey:kRIEventActionKey];
                }
                else if ([component.idRatingType isEqualToString:@"3"])
                {
                    [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
                }
                else
                {
                    // There is no indication about the default tracking for rating
                    [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
                }
                
                [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                [trackingDictionary setValue:self.ratingProductSku forKey:kRIEventSkuKey];
                
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRateProduct]
                                                          data:[trackingDictionary copy]];
            }
            
            [self hideLoading];
            
            JASuccessView *success = [JASuccessView getNewJASuccessView];
            [success setSuccessTitle:STRING_REVIEW_SENT
                            andAddTo:self];
            
        } andFailureBlock:^(id errorObject) {
            
            [self hideLoading];
            
            if(VALID_NOTEMPTY(errorObject, NSDictionary))
            {
                [self.ratingDynamicForm validateFields:errorObject];
                
                JAErrorView *errorView = [JAErrorView getNewJAErrorView];
                [errorView setErrorTitle:STRING_ERROR_INVALID_FIELDS
                                andAddTo:self];
            }
            else if(VALID_NOTEMPTY(errorObject, NSArray))
            {
                [self.ratingDynamicForm checkErrors];
                
                JAErrorView *errorView = [JAErrorView getNewJAErrorView];
                [errorView setErrorTitle:[errorObject componentsJoinedByString:@","]
                                andAddTo:self];
            }
            else
            {
                [self.ratingDynamicForm checkErrors];
                
                JAErrorView *errorView = [JAErrorView getNewJAErrorView];
                [errorView setErrorTitle:@"Generic error"
                                andAddTo:self];
            }
        }];
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
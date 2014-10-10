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

@property (assign, nonatomic) CGRect scrollViewInitialRect;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) UILabel *fixedLabel;
@property (strong, nonatomic) UIButton *sendReviewButton;

@property (strong, nonatomic) JADynamicForm *ratingDynamicForm;
@property (strong, nonatomic) NSMutableArray *ratingStarsArray;
@property (nonatomic, strong) JAPriceView *priceView;
@property (assign, nonatomic) NSInteger numberOfFields;

@end

@implementation JANewRatingViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:@"UIKeyboardWillShowNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:@"UIKeyboardWillHideNotification"
                                               object:nil];
    
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
    
    self.scrollViewInitialRect = CGRectMake(self.view.bounds.origin.x,
                                            CGRectGetMaxY(self.topView.frame),
                                            self.view.bounds.size.width,
                                            self.view.bounds.size.height - CGRectGetMaxY(self.topView.frame) - 64.0f);
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.scrollViewInitialRect];
    [self.view addSubview:self.scrollView];
    
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
    
    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(6.0f,
                                                               6.0f,
                                                               308.0f,
                                                               312.0f)];
    self.centerView.backgroundColor = [UIColor whiteColor];
    self.centerView.layer.cornerRadius = 5.0f;
    [self.scrollView addSubview:self.centerView];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             self.centerView.frame.size.height + 2*self.centerView.frame.origin.y);
    
    self.fixedLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f,
                                                                6.0f,
                                                                296.0f,
                                                                16.0f)];
    self.fixedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f];
    self.fixedLabel.text = STRING_RATE_PRODUCT;
    [self.centerView addSubview:self.fixedLabel];
    
    
    UIImage* buttonImageNormal = [UIImage imageNamed:@"orangeMedium_normal"];
    UIImage* buttonImageHighlighted = [UIImage imageNamed:@"orangeMedium_highlighted"];
    UIImage* buttonImageDisabled = [UIImage imageNamed:@"orangeMedium_disabled"];
    self.sendReviewButton = [[UIButton alloc] initWithFrame:CGRectMake(6.0f,
                                                                       262.0f,
                                                                       buttonImageNormal.size.width,
                                                                       buttonImageNormal.size.height)];
    [self.sendReviewButton setTitle:STRING_SEND_REVIEW
                           forState:UIControlStateNormal];
    [self.sendReviewButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                                forState:UIControlStateNormal];
    self.sendReviewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    [self.sendReviewButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
    [self.sendReviewButton setBackgroundImage:buttonImageHighlighted forState:UIControlStateHighlighted];
    [self.sendReviewButton setBackgroundImage:buttonImageDisabled forState:UIControlStateDisabled];
    [self.sendReviewButton addTarget:self action:@selector(sendReview:) forControlEvents:UIControlEventTouchUpInside];
    [self.centerView addSubview:self.sendReviewButton];
    

    [self showLoading];
    
    __block float currentY = self.fixedLabel.frame.origin.y + 22;
    
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
            frame.origin.y = currentY;
            
            stars.frame = frame;
            
            [self.centerView addSubview:stars];
            currentY += stars.frame.size.height + 6;
            
            [self.ratingStarsArray addObject:stars];
            
            self.numberOfFields++;
        }
        
        [RIForm getForm:@"rating"
           successBlock:^(RIForm *form) {
               
               self.ratingDynamicForm = [[JADynamicForm alloc] initWithForm:form
                                                                   delegate:self
                                                           startingPosition:currentY-10];
               
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
               
           } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
               
               NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
               [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];

               [self hideLoading];
               
               if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
               {
                   [self showMessage:STRING_NO_NEWTORK success:NO];
               }
               else
               {
                   [self showMessage:STRING_ERROR success:NO];
               }
           }];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        
        [self hideLoading];
        
        if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
        {
            [self showMessage:STRING_NO_NEWTORK success:NO];
        }
        else
        {
            [self showMessage:STRING_ERROR success:NO];
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
//    __block CGRect frame = self.originalFrame;
//    __block CGRect tempFrame = self.view.frame;
//    
//    [UIView animateWithDuration:0.5f
//                     animations:^{
//                         
//                         if (self.numberOfFields == 1) {
//                             if (tempFrame.size.height > 417) {
//                                 frame.origin.y -= (44 * view.tag);
//                             } else {
//                                 frame.origin.y -= (44 * (view.tag + 1));
//                             }
//                         } else {
//                             if (tempFrame.size.height > 417) {
//                                 frame.origin.y -= (44 * (view.tag + 1));
//                             } else {
//                                 frame.origin.y -= (44 * (view.tag + 3));
//                             }
//                         }
//                         
//                         self.centerView.frame = frame;
//                     }];
}

- (void)lostFocus
{
//    [UIView animateWithDuration:0.5f
//                     animations:^{
//                         self.centerView.frame = self.originalFrame;
//                     }];
}

#pragma mark - Send review

- (void)sendReview:(id)sender
{
    [self continueSendingReview];
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
        } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
            
            [self hideLoading];
            
            if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
            {
                [self showMessage:STRING_NO_NEWTORK success:NO];
            }
            else if(VALID_NOTEMPTY(errorObject, NSDictionary))
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

#pragma mark - Keyboard notifications

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:CGRectMake(self.scrollViewInitialRect.origin.x,
                                             self.scrollViewInitialRect.origin.y,
                                             self.scrollViewInitialRect.size.width,
                                             self.scrollViewInitialRect.size.height - kbSize.height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:self.scrollViewInitialRect];
    }];
}


@end

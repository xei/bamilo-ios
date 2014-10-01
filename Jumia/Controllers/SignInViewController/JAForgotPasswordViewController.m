//
//  JAForgotPasswordViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 14/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAForgotPasswordViewController.h"
#import "RIForm.h"
#import "RICustomer.h"

@interface JAForgotPasswordViewController ()
<
    JADynamicFormDelegate,
    JANoConnectionViewDelegate
>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) NSMutableArray *fieldsArray;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (strong, nonatomic) UIButton *forgotPasswordButton;
@property (assign, nonatomic) CGFloat forgotPasswordViewCurrentY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forgotPasswordViewHeightConstrain;

@end

@implementation JAForgotPasswordViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"ForgotPassword";
    
    self.navBarLayout.showLogo = NO;
    
    self.contentView.layer.cornerRadius = 5.0f;
    
    self.firstLabel.text = STRING_TYPE_YOUR_EMAIL;
    self.secondLabel.text = STRING_WE_WILL_SEND_PASSWORD;
    
    self.forgotPasswordViewCurrentY = CGRectGetMaxY(self.secondLabel.frame) + 1.0f;
    
    [self showLoading];
    
    [RIForm getForm:@"forgotpassword"
       successBlock:^(RIForm *form)
     {
         self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:self.forgotPasswordViewCurrentY];
         [self.dynamicForm setDelegate:self];
         self.fieldsArray = [self.dynamicForm.formViews copy];
         
         for(UIView *view in self.dynamicForm.formViews)
         {
             [self.contentView addSubview:view];
             self.forgotPasswordViewCurrentY = CGRectGetMaxY(view.frame);
         }
         
         [self finishedFormLoading];
         
         [self hideLoading];
         
     }
       failureBlock:^(NSArray *errorMessage)
     {
         [self finishedFormLoading];
         
         [self hideLoading];
         
         [self showMessage:STRING_ERROR success:NO];
         
         [self.navigationController popViewControllerAnimated:YES];
     }];
}

-(void)finishedFormLoading
{
    self.forgotPasswordViewCurrentY += 30.f;
    
    self.forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotPasswordButton setFrame:CGRectMake(6.0f, self.forgotPasswordViewCurrentY, 296.0f, 44.0f)];
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.forgotPasswordButton setTitle:STRING_SUBMIT forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotPasswordButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.contentView addSubview:self.forgotPasswordButton];
    self.forgotPasswordViewCurrentY = CGRectGetMaxY(self.forgotPasswordButton.frame) + 6.0f;
    
    self.forgotPasswordViewHeightConstrain.constant = self.forgotPasswordViewCurrentY;
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
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
            [self continueForgotPassword];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueForgotPassword];
    }
}

#pragma mark - Action

- (void)forgotPasswordButtonPressed:(id)sender
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self continueForgotPassword];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueForgotPassword];
    }
}

- (void)continueForgotPassword
{
    [self.dynamicForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:[self.dynamicForm getValues]
        successBlock:^(id object)
     {
         [self.dynamicForm resetValues];
         [self hideLoading];
         
         [self showMessage:STRING_EMAIL_SENT success:YES];         
     } andFailureBlock:^(id errorObject)
     {
         [self hideLoading];
         
         if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.dynamicForm validateFields:errorObject];
             
             [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.dynamicForm checkErrors];
             
             [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
         }
         else
         {
             [self.dynamicForm checkErrors];
             
             [self showMessage:STRING_ERROR success:NO];
         }
     }];
}

@end

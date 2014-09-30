//
//  JAUserDataViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 17/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAUserDataViewController.h"
#import "RICustomer.h"
#import "RIForm.h"
#import "JAButtonWithBlur.h"

@interface JAUserDataViewController ()
<
    JADynamicFormDelegate,
    JANoConnectionViewDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *personalDataView;
@property (weak, nonatomic) IBOutlet UILabel *personalTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *personalLine;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIView *changePasswordView;
@property (weak, nonatomic) IBOutlet UILabel *changePasswordTitle;
@property (weak, nonatomic) IBOutlet UIImageView *changePasswordImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *changePasswordHeight;
@property (strong, nonatomic) JADynamicForm *changePasswordForm;
@property (assign, nonatomic) float formHeight;
@property (assign, nonatomic) NSInteger numberOfFields;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation JAUserDataViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"CustomerData";
    
    self.numberOfFields = 0;
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_USER_DATA;
    
    self.personalDataView.layer.cornerRadius = 4.0f;
    self.changePasswordView.layer.cornerRadius = 4.0f;
    self.personalTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.personalTitleLabel.text = STRING_YOUR_PERSONAL_DATA;
    
    self.personalLine.backgroundColor = UIColorFromRGB(0xfaa41a);
    self.changePasswordImageView.backgroundColor = UIColorFromRGB(0xfaa41a);
    
    self.nameLabel.textColor = UIColorFromRGB(0x666666);
    self.emailLabel.textColor = UIColorFromRGB(0x666666);
    
    self.changePasswordTitle.textColor = UIColorFromRGB(0x4e4e4e);
    self.changePasswordTitle.text = STRING_NEW_PASSWORD;
    
    [self showLoading];
    
    self.formHeight = 30.0f;
    
    [RIForm getForm:@"changepassword"
       successBlock:^(RIForm *form) {
           
           self.changePasswordForm = [[JADynamicForm alloc] initWithForm:form
                                                                delegate:self
                                                        startingPosition:self.formHeight];
           
           for(UIView *view in self.changePasswordForm.formViews)
           {
               view.tag = self.numberOfFields;
               [self.changePasswordView addSubview:view];
               self.formHeight = CGRectGetMaxY(view.frame);
               self.numberOfFields++;
           }
           
           [RICustomer getCustomerWithSuccessBlock:^(id customer) {
               
               self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", ((RICustomer *)customer).firstName, ((RICustomer *)customer).lastName];
               self.emailLabel.text = ((RICustomer *)customer).email;
               
               [self hideLoading];
               
           } andFailureBlock:^(NSArray *errorMessages) {
               
               [self hideLoading];
           }];
           
           self.changePasswordHeight.constant = self.formHeight + 20;
           [self.view updateConstraints];
           
           [self.saveButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];           
           [self.saveButton setTitle:STRING_SAVE_LABEL forState:UIControlStateNormal];
           [self.saveButton addTarget:self action:@selector(saveNewPassword) forControlEvents:UIControlEventTouchUpInside];
           
       } failureBlock:^(NSArray *errorMessage) {
           
           [self hideLoading];
           
           [self showMessage:STRING_EDIT_ADDRESS success:NO];           
       }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - JADynamicForm delegate

- (void)changedFocus:(UIView *)view
{
    self.contentScrollView.contentSize = CGSizeMake(320, self.contentScrollView.frame.size.height + (self.numberOfFields * 44));
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [self.contentScrollView setContentOffset:CGPointMake(0, (view.tag * 44) + 20)
                                                         animated:YES];
                     }];
}

- (void)lostFocus
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [self.contentScrollView scrollsToTop];
                         
                         self.contentScrollView.contentSize = CGSizeMake(320, self.contentScrollView.frame.size.height - (self.numberOfFields * 44));
                     }];
}

#pragma mark - Actions

- (void)saveNewPassword
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self continueSavingPassword];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueSavingPassword];
    }
}

- (void)continueSavingPassword
{
    [self.changePasswordForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.changePasswordForm form]
          parameters:[self.changePasswordForm getValues]
        successBlock:^(id object)
     {
         [self.changePasswordForm resetValues];
         
         [self hideLoading];
                  
         [[NSNotificationCenter defaultCenter] postNotificationName:kDidSaveUserDataNotification object:nil];
         [self.navigationController popViewControllerAnimated:YES];
         
     } andFailureBlock:^(id errorObject)
     {
         [self hideLoading];
         
         if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.changePasswordForm validateFields:errorObject];
             
             [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.changePasswordForm checkErrors];
             
             [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
         }
         else
         {
             [self.changePasswordForm checkErrors];
             
             [self showMessage:STRING_ERROR success:NO];
         }
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
            [self continueSavingPassword];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueSavingPassword];
    }
}

@end

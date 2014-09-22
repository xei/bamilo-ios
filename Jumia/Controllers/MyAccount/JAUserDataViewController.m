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
    JADynamicFormDelegate
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
@property (strong, nonatomic) JAButtonWithBlur *ctaView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;

@end

@implementation JAUserDataViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberOfFields = 0;
    
    self.buttonView.backgroundColor = JABackgroundGrey;
    
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
           
           self.ctaView = [[JAButtonWithBlur alloc] initWithFrame:CGRectZero];
           self.ctaView.backgroundColor = [UIColor clearColor];
           
           [self.ctaView setFrame:CGRectMake(0,
                                             0,
                                             self.view.frame.size.width,
                                             60)];
           
           [self.ctaView addButton:STRING_SAVE_CHANGES
                            target:self
                            action:@selector(saveNewPassword)];
           
           [self.buttonView addSubview:self.ctaView];
           
       } failureBlock:^(NSArray *errorMessage) {
           
           [self hideLoading];
           
           JAErrorView *errorView = [JAErrorView getNewJAErrorView];
           [errorView setErrorTitle:STRING_EDIT_ADDRESS
                           andAddTo:self];

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
    [self.changePasswordForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.changePasswordForm form]
          parameters:[self.changePasswordForm getValues]
        successBlock:^(id object)
     {
         [self.changePasswordForm resetValues];
         
         [self hideLoading];
         
         JASuccessView *success = [JASuccessView getNewJASuccessView];
         [success setSuccessTitle:STRING_CHANGED_PASSWORD_SUCCESS
                         andAddTo:self];
         
     } andFailureBlock:^(id errorObject)
     {
         [self hideLoading];
         
         if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.changePasswordForm validateFields:errorObject];
             
             [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                         message:STRING_ERROR_INVALID_FIELDS
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:STRING_OK, nil] show];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.changePasswordForm checkErrors];
             
             [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                         message:[errorObject componentsJoinedByString:@","]
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:STRING_OK, nil] show];
         }
         else
         {
             [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                         message:@"Generic error"
                                        delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:STRING_OK, nil] show];
         }
     }];
}

@end

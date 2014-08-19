//
//  JASignInViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASignInViewController.h"
#import "RIForm.h"
#import "RIField.h"
#import "RICustomer.h"
#import <FacebookSDK/FacebookSDK.h>

@interface JASignInViewController ()
<
    UITextFieldDelegate,
    FBLoginViewDelegate
>

@property (strong, nonatomic) NSMutableArray *fieldsArray;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *labelLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIView *forgotView;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookLogin;
@property (strong, nonatomic) FBLoginView *facebookLoginView;

@end

@implementation JASignInViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginView.layer.cornerRadius = 4.0f;
    self.signUpView.layer.cornerRadius = 4.0f;
    self.forgotView.layer.cornerRadius = 4.0f;
    
    self.labelLogin.text = @"Login";
    self.fieldsArray = [NSMutableArray new];
    
    [self.buttonLogin setTitle:@"Login"
                      forState:UIControlStateNormal];
    
    [self.signUpButton setTitle:@"Signup"
                       forState:UIControlStateNormal];
    
    [self.forgotButton setTitle:@"Forgot password"
                       forState:UIControlStateNormal];
    
    [self.facebookLogin setTitle:@"Login with Facebook"
                        forState:UIControlStateNormal];
    
    self.facebookLogin.hidden = YES;
    
    self.facebookLoginView = [[FBLoginView alloc] init];
    self.facebookLoginView.delegate = self;
    self.facebookLoginView.frame = self.facebookLogin.frame;
    self.facebookLoginView.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_birthday"];
    [self.loginView addSubview:self.facebookLoginView];
    
    self.signUpButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.forgotButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [RIForm getForm:@"login"
       successBlock:^(RIForm *form) {
           
           float startingY = 40.0f;
           
           for (RIField *field in form.fields)
           {
               if ([field.type isEqualToString:@"email"])
               {
                   JATextField *textField = [JAFormComponent getNewJATextField];
                   textField.field = field;
                   
                   textField.layer.cornerRadius = 4.0f;
                   CGRect frame = textField.frame;
                   frame.origin.y = startingY;
                   textField.frame = frame;
                   startingY += (textField.frame.size.height + 8);
                   
                   textField.textField.placeholder = field.label;
                   textField.textField.delegate = self;
                   
                   [self.loginView addSubview:textField];
                   [self.fieldsArray addObject:textField];
               }
               else if ([field.type isEqualToString:@"password"] || [field.type isEqualToString:@"password2"])
               {
                   JATextField *textField = [JAFormComponent getNewJATextField];
                   textField.field = field;
                   
                   textField.layer.cornerRadius = 4.0f;
                   CGRect frame = textField.frame;
                   frame.origin.y = startingY;
                   textField.frame = frame;
                   startingY += (textField.frame.size.height + 8);
                   
                   textField.textField.placeholder = field.label;
                   textField.textField.secureTextEntry = YES;
                   textField.textField.delegate = self;
                   
                   [self.loginView addSubview:textField];
                   [self.fieldsArray addObject:textField];
               }
           }
           
       } failureBlock:^(NSArray *errorMessage) {
           
           [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                       message:@"There was an error"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK", nil] show];
           
       }];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([RICustomer checkIfUserIsLogged]) {
        NSLog(@"User logged");
    } else {
        NSLog(@"User not logged");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)signUp:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowBackNofication
                                                        object:nil];
    
    [self performSegueWithIdentifier:@"segueSignUp"
                              sender:nil];
}

- (IBAction)forgot:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowBackNofication
                                                        object:nil];
    
    [self performSegueWithIdentifier:@"segueToForgot"
                              sender:nil];
}

- (IBAction)login:(id)sender
{
    [self.view endEditing:YES];
    
    BOOL hasErrors = NO;
    
    for (id obj in self.fieldsArray)
    {
        if ([obj isKindOfClass:[JATextField class]])
        {
            if (![obj isValid])
            {
                hasErrors = YES;
                break;
            }
        }
    }
    
    if (hasErrors) {
        return;
    }
    
    NSMutableDictionary *temp = [NSMutableDictionary new];
    
    for (JATextField *textField in self.fieldsArray)
    {
        RIField *field = textField.field;
        NSDictionary *dicToAdd = @{ field.name : textField.textField.text };
        [temp addEntriesFromDictionary:dicToAdd];
    }
    
    [self showLoading];
    
    [RICustomer loginCustomerWithParameters:[temp copy]
                               successBlock:^(RICustomer *customer) {
                                   
                                   [self hideLoading];
                                   
                                   [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                                       object:@{@"index": @(0),
                                                                                                @"name": @"Home"}];

                                   [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                                       object:nil];
                                   
                               } andFailureBlock:^(NSArray *errorObject) {
                                   
                                   [self hideLoading];
                                   
                                   [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                               message:@"Error doing login."
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"OK", nil] show];
                               }];
}

- (IBAction)loginViaFacebook:(id)sender
{

}

#pragma mark - Facebook Delegate

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    if (![RICustomer checkIfUserIsLogged])
    {
        [self showLoading];
        
        NSString *email = [user objectForKey:@"email"];
        NSString *firstName = [user objectForKey:@"first_name"];
        NSString *lastName = [user objectForKey:@"last_name"];
        NSString *birthday = [user objectForKey:@"birthday"];
        NSString *gender = [user objectForKey:@"gender"];
        
        NSDictionary *parameters = @{ @"email": email,
                                      @"first_name": firstName,
                                      @"last_name": lastName,
                                      @"birthday": birthday,
                                      @"gender": gender };
        
        [RICustomer loginCustomerByFacebookWithParameters:parameters
                                             successBlock:^(id customer) {
                                                 [self hideLoading];
                                                 
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                                                     object:@{@"index": @(0),
                                                                                                              @"name": @"Home"}];
                                                 
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                                                     object:nil];
                                             } andFailureBlock:^(NSArray *errorObject) {
                                                 [self hideLoading];
                                                 
                                                 [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                                             message:@"Error doing login."
                                                                            delegate:nil
                                                                   cancelButtonTitle:nil
                                                                   otherButtonTitles:@"OK", nil] show];
                                             }];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"Showing logged in user");
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"Showing logged in user");
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end

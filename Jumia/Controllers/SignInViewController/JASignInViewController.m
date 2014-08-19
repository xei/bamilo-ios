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
    UITextFieldDelegate
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

@end

@implementation JASignInViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginView.layer.cornerRadius = 4.0f;
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

- (IBAction)loginViaFacebook:(id)sender
{
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
         if (!error) {
             
             UIAlertView *tmp = [[UIAlertView alloc]
                                 initWithTitle:@"Upload to FB?"
                                 message:[NSString stringWithFormat:@"Upload to ""%@"" Account?", user.name]
                                 delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@"No",@"Yes", nil];
             [tmp show];
             
         }
     }];
    
//    FBRequest *request = [FBRequest requestForMe];
//    
//    // Send request to Facebook
//    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        if (!error) {
//            // result is a dictionary with the user's Facebook data
//            NSDictionary *userData = (NSDictionary *)result;
//            
//            NSString *facebookID = userData[@"id"];
//            NSString *name = userData[@"name"];
//            NSString *location = userData[@"location"][@"name"];
//            NSString *gender = userData[@"gender"];
//            NSString *birthday = userData[@"birthday"];
//            NSString *relationship = userData[@"relationship_status"];
//            
//            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
//            
//            // Now add the data to the UI elements
//            // ...
//        }
//    }];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end

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
#import "RILogin.h"

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

@end

@implementation JASignInViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginView.layer.cornerRadius = 4.0f;
    self.signUpView.layer.cornerRadius = 4.0f;
    
    self.labelLogin.text = @"Login";
    self.fieldsArray = [NSMutableArray new];
    
    [self.buttonLogin setTitle:@"Login"
                      forState:UIControlStateNormal];
    
    [self.signUpButton setTitle:@"Signup"
                       forState:UIControlStateNormal];
    
    self.signUpButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [RIForm getForm:@"login"
       successBlock:^(RIForm *form) {
           
           float startingY = 40.0f;
           
           for (RIField *field in form.fields)
           {
               JATextField *textField = [[JATextField alloc] initWithFrame:CGRectMake(6.0f,
                                                                                      startingY,
                                                                                      self.loginView.frame.size.width - 12.0f,
                                                                                      27.0f)];
               
               textField.textField.borderStyle = UITextBorderStyleRoundedRect;
               textField.layer.cornerRadius = 4.0f;
               
               textField.textField.placeholder = field.type;
               textField.textField.delegate = self;
               textField.field = field;
               
               [self.loginView addSubview:textField];
               [self.fieldsArray addObject:textField];
               
               startingY += 40.0f;
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
    if ([[RILogin sharedInstance] checkIfUserIsLogged]) {
        NSLog(@"User logged");
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

- (IBAction)login:(id)sender
{
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
                                   
                                   [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                               message:@"Login with sucess"
                                                              delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"OK", nil] show];
                                   
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

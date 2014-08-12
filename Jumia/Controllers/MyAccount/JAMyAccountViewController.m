//
//  JAMyAccountViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyAccountViewController.h"
#import "RIForm.h"
#import "RIField.h"
#import "RICustomer.h"

@interface JAMyAccountViewController ()
<
    UITextFieldDelegate
>

@property (strong, nonatomic) NSMutableArray *fieldsArray;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *labelLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

@end

@implementation JAMyAccountViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginView.layer.cornerRadius = 4.0f;
    self.labelLogin.text = @"Login";
    self.fieldsArray = [NSMutableArray new];
    
    [self.buttonLogin setTitle:@"Login"
                      forState:UIControlStateNormal];
    
    [RIForm getForm:@"login"
       successBlock:^(RIForm *form) {
           
           float startingY = 40.0f;
           
           for (RIField *field in form.fields)
           {
               UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(6.0f,
                                                                                      startingY,
                                                                                      self.loginView.frame.size.width - 12.0f,
                                                                                      27.0f)];
               
               textField.borderStyle = UITextBorderStyleRoundedRect;
               textField.layer.cornerRadius = 4.0f;
               
               textField.placeholder = field.type;
               textField.delegate = self;
               
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)login:(id)sender
{

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end

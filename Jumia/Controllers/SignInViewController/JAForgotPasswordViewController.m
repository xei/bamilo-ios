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

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *buttonRequest;
@property (weak, nonatomic) IBOutlet UILabel *labelTop;
@property (strong, nonatomic) NSMutableArray *fieldsArray;
@property (strong, nonatomic) JADynamicForm *dynamicForm;

@end

@implementation JAForgotPasswordViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    
    self.labelTop.text = @"Forgot password";
    self.contentView.layer.cornerRadius = 4.0f;
    
    [self showLoading];
    
    [RIForm getForm:@"forgotpassword"
       successBlock:^(RIForm *form) {
           
           [self hideLoading];
           
           self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:35.0f];
           self.fieldsArray = [self.dynamicForm.formViews copy];
           for(UIView *view in self.dynamicForm.formViews)
           {
               [self.contentView addSubview:view];
           }
           
           [self.buttonRequest setTitle:@"Register"
                               forState:UIControlStateNormal];
           
           [self.buttonRequest addTarget:self
                                  action:@selector(requestPassword)
                        forControlEvents:UIControlEventTouchUpInside];
           
       } failureBlock:^(NSArray *errorMessage) {
           [self hideLoading];
           
           [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                       message:@"There was an error"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK", nil] show];
           
           [self.navigationController popViewControllerAnimated:YES];
       }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Action

- (void)requestPassword
{
    [self.view endEditing:YES];
    
    BOOL hasErrors = [self.dynamicForm checkErrors];
    
    if(!hasErrors)
    {
        NSDictionary *temp = [self.dynamicForm getValues];
        
        [self showLoading];
        
        [RICustomer requestPasswordReset:^(RICustomer *customer) {
            
            [self hideLoading];
            
            [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                        message:@"Request sent with success!"
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } andFailureBlock:^(NSArray *errorObject) {
            
            [self hideLoading];
            
            [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                        message:@"Error reseting password."
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }];
    }
}

@end

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
    UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *buttonRequest;
@property (weak, nonatomic) IBOutlet UILabel *labelTop;
@property (strong, nonatomic) NSMutableArray *fieldsArray;

@end

@implementation JAForgotPasswordViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelTop.text = @"Forgot password";
    self.contentView.layer.cornerRadius = 4.0f;
    
    [self showLoading];
    
    [RIForm getForm:@"forgotpassword"
       successBlock:^(RIForm *form) {
           [self hideLoading];
        
           float startingY = 35.0f;
           
           for (RIField *field in form.fields)
           {
               if ([field.type isEqualToString:@"string"] || [field.type isEqualToString:@"email"])
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
                   
                   [self.contentView addSubview:textField];
                   [self.fieldsArray addObject:textField];
               }
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

@end

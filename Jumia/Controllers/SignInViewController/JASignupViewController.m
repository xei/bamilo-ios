//
//  JASignupViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASignupViewController.h"
#import "RIForm.h"
#import "RIField.h"
#import "RIFieldDataSetComponent.h"
#import "JAFormComponent.h"
#import "RICustomer.h"

@interface JASignupViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) UIButton *registerButton;
@property (weak, nonatomic) UIButton *registerByFacebook;
@property (strong, nonatomic) NSMutableArray *fieldsArray;
@property (assign, nonatomic) CGRect originalFrame;
@property (strong, nonatomic) RIForm *tempForm;

@end

@implementation JASignupViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.originalFrame = self.contentScrollView.frame;
    self.fieldsArray = [NSMutableArray new];
    
    [self showLoading];
    
    [RIForm getForm:@"register"
       successBlock:^(RIForm *form) {
           [self hideLoading];
           
           self.tempForm = form;
           
           CGFloat maxY = 0.0f;
           NSArray *views = [JAFormComponent generateForm:[form.fields array] startingY:0.0f];
           self.fieldsArray = [views copy];
           for(UIView *view in views)
           {
               [self.contentScrollView addSubview:view];
               if(CGRectGetMaxY(view.frame) > maxY)
               {
                   maxY = CGRectGetMaxY(view.frame);
               }
           }
           
           [self.contentScrollView layoutIfNeeded];
           
           self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
           self.registerButton.frame = CGRectMake(6.0, maxY, self.contentScrollView.frame.size.width - 12.0, 44.0);
           
           [self.registerButton setTitle:@"Register"
                                forState:UIControlStateNormal];
           
           [self.registerButton setTitleColor:[UIColor orangeColor]
                                     forState:UIControlStateNormal];
           
           [self.registerButton addTarget:self
                                   action:@selector(registerCustomer)
                         forControlEvents:UIControlEventTouchUpInside];
           
           CGRect frame = self.registerButton.frame;
           frame.origin.y = maxY;
           self.registerButton.frame = frame;
           maxY += (self.registerButton.frame.size.height + 8);
           
           [self.contentScrollView addSubview:self.registerButton];
           
           [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, maxY)];
           
       } failureBlock:^(NSArray *errorMessage) {
           [self hideLoading];
           
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

#pragma mark - Actions

- (void)registerCustomer
{
    [self.view endEditing:YES];
    
    BOOL hasErrors = [JAFormComponent hasErrors:self.fieldsArray];
    
    if(!hasErrors)
    {
        NSDictionary *tempDic = [JAFormComponent getValues:self.fieldsArray form:self.tempForm];
        
        [self showLoading];
        
        [RICustomer registerCustomerWithParameters:[tempDic copy]
                                      successBlock:^(id customer) {
                                          [self hideLoading];
                                          
                                          [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                                              object:@{@"index": @(0),
                                                                                                       @"name": @"Home"}];
                                          
                                      } andFailureBlock:^(NSArray *errorObject) {
                                          [self hideLoading];
                                          
                                          [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                                                      message:@"Error registering user"
                                                                     delegate:nil
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:@"Ok", nil] show];
                                      }];
    }
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView *superView = textField.superview;
    
    CGPoint scrollPoint = CGPointMake(0.0, superView.frame.origin.y - 130);
    [self.contentScrollView setContentOffset:scrollPoint
                                    animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.contentScrollView.frame = self.originalFrame;
                     }];
    
    [textField resignFirstResponder];
    
    return YES;
}

@end

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
#import "RICustomer.h"

@interface JASignupViewController ()
<JADynamicFormDelegate>

@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *registerButton;
@property (strong, nonatomic) NSMutableArray *fieldsArray;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (assign, nonatomic) CGRect originalFrame;
@property (assign, nonatomic) CGFloat registerViewCurrentY;

@end

@implementation JASignupViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.title = @"Create Account";
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f)];
    [self.contentScrollView setShowsHorizontalScrollIndicator:NO];
    [self.contentScrollView setShowsVerticalScrollIndicator:NO];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.contentView.layer.cornerRadius = 5.0f;
    
    [self.contentScrollView addSubview:self.contentView];
    [self.view addSubview:self.contentScrollView];
    
    self.registerViewCurrentY = 0.0f;
    
    self.originalFrame = self.contentScrollView.frame;
    self.fieldsArray = [NSMutableArray new];
    
    [self showLoading];
    
    [RIForm getForm:@"register"
       successBlock:^(RIForm *form) {
           [self hideLoading];
           
           self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:self.registerViewCurrentY];
           [self.dynamicForm setDelegate:self];
           self.fieldsArray = [self.dynamicForm.formViews copy];
           
           for(UIView *view in self.dynamicForm.formViews)
           {
               [self.contentView addSubview:view];
               self.registerViewCurrentY = CGRectGetMaxY(view.frame);
           }
           
           [self finishedFormLoading];
           
       } failureBlock:^(NSArray *errorMessage) {
           [self hideLoading];
           
           [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                       message:@"There was an error"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK", nil] show];
       }];
}

- (void)finishedFormLoading
{
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerButton setFrame:CGRectMake(6.0f, self.registerViewCurrentY, 296.0f, 44.0f)];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(registerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.contentView addSubview:self.registerButton];
    
    self.registerViewCurrentY = CGRectGetMaxY(self.registerButton.frame) + 5.0f;
    // Forgot Password
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setFrame:CGRectMake(6.0f, self.registerViewCurrentY, 296.0f, 30.0f)];
    [self.loginButton setBackgroundColor:[UIColor clearColor]];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateSelected];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.contentView addSubview:self.loginButton];
    self.registerViewCurrentY = CGRectGetMaxY(self.loginButton.frame) + 3.0f;
    
    [self.contentView setFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.registerViewCurrentY)];
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.contentView.frame.origin.y + self.contentView.frame.size.height + 6.0f)];
}

#pragma mark - Actions

- (void)registerButtonPressed:(id)sender
{
    BOOL hasErrors = [self.dynamicForm checkErrors];
    
    if(!hasErrors)
    {
        NSDictionary *parameters = [self.dynamicForm getValues];
        
        [self showLoading];
        
        [RIForm sendForm:self.dynamicForm.form parameters:parameters successBlock:^(id object) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                object:@{@"index": @(0),
                                                                         @"name": @"Home"}];
            
            
            [self hideLoading];
            
        } andFailureBlock:^(NSArray *errorObject) {
            [self hideLoading];
            
            [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                        message:[errorObject componentsJoinedByString:@","]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }];
    }
}

- (void)loginButtonPressed:(id)sender
{
    
}

//#pragma mark - TextField Delegate
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    UIView *superView = textField.superview;
//
//    CGPoint scrollPoint = CGPointMake(0.0, superView.frame.origin.y - 130);
//    [self.contentScrollView setContentOffset:scrollPoint
//                                    animated:YES];
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [UIView animateWithDuration:0.5f
//                     animations:^{
//                         self.contentScrollView.frame = self.originalFrame;
//                     }];
//
//    [textField resignFirstResponder];
//
//    return YES;
//}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    CGPoint scrollPoint = CGPointMake(0.0, view.frame.origin.y);
    [self.contentScrollView setContentOffset:scrollPoint
                                    animated:YES];
}

- (void) lostFocus
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.contentScrollView.frame = self.originalFrame;
                     }];
}

@end

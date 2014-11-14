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

#define kDynamicFormFieldsTag 1

@interface JAForgotPasswordViewController ()
<
JADynamicFormDelegate
>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) NSMutableArray *fieldsArray;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (strong, nonatomic) UIButton *forgotPasswordButton;
@property (assign, nonatomic) CGFloat forgotPasswordViewCurrentY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forgotPasswordViewHeightConstrain;
@end

@implementation JAForgotPasswordViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"ForgotPassword";
    
    self.navBarLayout.showLogo = NO;
    
    self.contentView.layer.cornerRadius = 5.0f;
    
    self.firstLabel.text = STRING_TYPE_YOUR_EMAIL;
    self.secondLabel.text = STRING_WE_WILL_SEND_PASSWORD;
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.firstLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.secondLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self showLoading];
    
    [RIForm getForm:@"forgotpassword"
       successBlock:^(RIForm *form)
     {
         self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:self.forgotPasswordViewCurrentY];
         [self.dynamicForm setDelegate:self];
         
         [self setupView];
         
         [self hideLoading];
         
     }
       failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
     {
         [self finishedFormLoading];
         
         [self hideLoading];
         
         [self showMessage:STRING_ERROR success:NO];
         
         [self.navigationController popViewControllerAnimated:YES];
     }];
}

-(void)finishedFormLoading
{
    CGFloat widthVariable = 12.0f;
    if(UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)
    {
        widthVariable = 256.0f;
    }
    
    self.forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotPasswordButton setFrame:CGRectMake(widthVariable/2,
                                                   self.forgotPasswordViewCurrentY + 30.0f,
                                                   self.contentView.frame.size.width - widthVariable,
                                                   44.0f)];
    
    NSString *orangeButtonName = @"orangeBig_%@";
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        if((UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)||(UIInterfaceOrientationLandscapeLeft == self.self.interfaceOrientation)){
            orangeButtonName = @"orangeFullPortrait_%@";
        }else{
            orangeButtonName = @"orangeMediumPortrait_%@";
        }
    }
    
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"normal"]]forState:UIControlStateNormal];
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]]forState:UIControlStateHighlighted];
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]]forState:UIControlStateSelected];
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"disabled"]]forState:UIControlStateDisabled];
    [self.forgotPasswordButton setTitle:STRING_SUBMIT forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotPasswordButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.contentView addSubview:self.forgotPasswordButton];
    
    self.forgotPasswordViewCurrentY = CGRectGetMaxY(self.forgotPasswordButton.frame) + 6.0f;
    
    self.forgotPasswordViewHeightConstrain.constant = self.forgotPasswordViewCurrentY;
    
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x,
                                          self.contentView.frame.origin.y,
                                          self.contentView.frame.size.width,
                                          CGRectGetMaxY(self.forgotPasswordButton.frame) + 6.0f)];
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
}

#pragma mark - Action

- (void)forgotPasswordButtonPressed:(id)sender
{
    [self continueForgotPassword];
}

- (void)continueForgotPassword
{
    [self.dynamicForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:[self.dynamicForm getValues]
        successBlock:^(id object)
     {
         [self.dynamicForm resetValues];
         [self hideLoading];
         
         [self showMessage:STRING_EMAIL_SENT success:YES];
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         [self hideLoading];
         
         if (RIApiResponseNoInternetConnection == apiResponse)
         {
             [self showMessage:STRING_NO_NEWTORK success:NO];
         }
         else if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.dynamicForm validateFields:errorObject];
             
             [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.dynamicForm checkErrors];
             
             [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
         }
         else
         {
             [self.dynamicForm checkErrors];
             
             [self showMessage:STRING_ERROR success:NO];
         }
     }];
}

-(void)setupView
{
    self.forgotPasswordViewCurrentY = CGRectGetMaxY(self.secondLabel.frame) + 1.0f;
    
    CGFloat widthVariable = 12.0f;
    CGFloat firstLabelPosition = 15.0f;
    CGFloat dynamicFormPosition = 74.0f;
    
    if(UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)
    {
        widthVariable = 256.0f;
        firstLabelPosition = 30.0f;
        dynamicFormPosition = 101.0f;
    }
    
    [self.firstLabel setFrame:CGRectMake(widthVariable/2,  self.firstLabel.frame.origin.y, self.view.frame.size.width - widthVariable, self.firstLabel.frame.size.height)];
    [self.secondLabel setFrame:CGRectMake(widthVariable/2, self.secondLabel.frame.origin.y, self.secondLabel.frame.size.width, self.secondLabel.frame.size.height)];
    
    self.fieldsArray = [self.dynamicForm.formViews copy];
    
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x,
                                          self.contentView.frame.origin.y,
                                          self.view.frame.size.width - 12.0f,
                                          self.contentView.frame.size.height)];
    
    for(UIView *view in self.dynamicForm.formViews)
    {
        [view setTag:kDynamicFormFieldsTag];
        [self.contentView addSubview:view];
        [view setFrame:CGRectMake(widthVariable / 2,
                                  self.forgotPasswordViewCurrentY,
                                  self.contentView.frame.size.width - widthVariable,
                                  view.frame.size.height)];
        self.forgotPasswordViewCurrentY += view.frame.size.height;
    }
    
    [self finishedFormLoading];
}

- (void)removeViews
{
    [self.forgotPasswordButton removeFromSuperview];
    
    NSArray *subViews = self.contentView.subviews;
    for(UIView *view in subViews)
    {
        if(kDynamicFormFieldsTag == view.tag)
        {
            [view removeFromSuperview];
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self removeViews];
    
    [self showLoading];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self setupView];
    
    [self hideLoading];
}
@end

//
//  JANewsletterSubscriptionViewController.m
//  Jumia
//
//  Created by telmopinto on 15/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JANewsletterSubscriptionViewController.h"
#import "RIForm.h"
#import "RITarget.h"
#import "JAClickableView.h"

@interface JANewsletterSubscriptionViewController () <JADynamicFormDelegate>

@property (nonatomic, strong)RIForm* newsletterSubscriptionForm;
@property (nonatomic, strong)JADynamicForm* dynamicForm;
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)JAClickableView* submitButton;

@end

@implementation JANewsletterSubscriptionViewController

-(UIScrollView*)scrollView
{
    if (!VALID_NOTEMPTY(_scrollView, UIScrollView)) {
        _scrollView = [[UIScrollView alloc] initWithFrame:[self viewBounds]];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    self.tabBarIsVisible = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadForms];
}


- (void)loadForms
{
    [self showLoading];
    
    if (VALID_NOTEMPTY(self.targetString, NSString)) {
        
        RITarget* target = [RITarget parseTarget:self.targetString];
     
        if (VALID_NOTEMPTY(target.node, NSString)) {
            [RIForm getForm:target.node forceRequest:YES successBlock:^(RIForm * newsletterSubscriptionForm) {
                
                self.newsletterSubscriptionForm = newsletterSubscriptionForm;
                
                [self setupViews];
                
                [self hideLoading];
                
            } failureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                
                [self hideLoading];

                [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadForms) objects:nil];
            }];
    
        }
    }
}

- (void)setupViews
{
    [self.scrollView setFrame:[self viewBounds]];
    
    if (VALID_NOTEMPTY(self.newsletterSubscriptionForm, RIForm)) {
        
        if (NO == VALID_NOTEMPTY(self.dynamicForm, JADynamicForm)) {
            self.dynamicForm = [[JADynamicForm alloc] initWithForm:self.newsletterSubscriptionForm startingPosition:0.0f];
            [self.dynamicForm setDelegate:self];
        }
        
        CGFloat maxY = 0.0f;
        for(UIView *view in self.dynamicForm.formViews)
        {
            [self.scrollView addSubview:view];
            maxY = CGRectGetMaxY(view.frame);
            view.width = self.scrollView.width;
        }
        
        if (NO == VALID_NOTEMPTY(self.submitButton, JAClickableView)) {
            self.submitButton = [[JAClickableView alloc] init];
            [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
            [self.submitButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
            [self.submitButton addTarget:self action:@selector(submitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:self.submitButton];
        }
        [self.submitButton setFrame:CGRectMake(0.0f, maxY, self.scrollView.frame.size.width, 44.0f)];
        
        maxY = CGRectGetMaxY(self.submitButton.frame);
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                                   maxY)];
    }
}

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    [self setupViews];
}

- (void)submitButtonPressed
{
    [self showLoading];
    [RIForm sendForm:self.newsletterSubscriptionForm extraArguments:nil parameters:[self.dynamicForm getValues] successBlock:^(id object, NSArray* successMessages) {
        [self hideLoading];
       
        if (self.delegate && [self.delegate respondsToSelector:@selector(newsletterSubscriptionSelected:)]) {
            [self.delegate newsletterSubscriptionSelected:YES];
        }
        
        [self onSuccessResponse:0 messages:successMessages showMessage:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
    } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
        [self hideLoading];
        
        [self onErrorResponse:apiResponse messages:nil showAsMessage:YES selector:@selector(submitButtonPressed) objects:nil];
    }];
}

@end

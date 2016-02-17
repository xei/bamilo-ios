//
//  JANewsletterViewController.m
//  Jumia
//
//  Created by telmopinto on 09/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JANewsletterViewController.h"
#import "RIForm.h"
#import "JADynamicForm.h"
#import "JANewsletterSubscriptionViewController.h"
#import "JAClickableView.h"

@interface JANewsletterViewController () <JADynamicFormDelegate, JANewsletterSubscriptionDelegate>

@property (nonatomic, strong)RIForm* newsletterPreferencesForm;
@property (nonatomic, strong)JADynamicForm* dynamicForm;
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)JAClickableView* saveClickableView;
@property (nonatomic, strong)UIView* saveContentView;

@end

@implementation JANewsletterViewController

-(UIScrollView*)scrollView
{
    if (!VALID_NOTEMPTY(_scrollView, UIScrollView)) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [self viewBounds].size.width, [self viewBounds].size.height - 70.0f)];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

-(JAClickableView*)saveClickableView
{
    if (!VALID_NOTEMPTY(_saveClickableView, JAClickableView)) {
        _saveClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(16.0f, 10.0f, self.saveContentView.frame.size.width - 16.0f*2, 50.0f)];
        _saveClickableView.backgroundColor = JAOrange1Color;
        [_saveClickableView setTitle:[STRING_SAVE_LABEL uppercaseString] forState:UIControlStateNormal];
        [_saveClickableView setFont:JACaption2Font];
        [self.saveContentView addSubview:_saveClickableView];
    }
    return _saveClickableView;
}

-(UIView*)saveContentView
{
    if (!VALID_NOTEMPTY(_saveContentView, UIView)) {
        _saveContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [self viewBounds].size.height - 70.0f, self.view.frame.size.width, 70.0f)];
        [self.view addSubview:_saveContentView];
        
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _saveContentView.frame.size.width, 1.0f)];
        separator.backgroundColor = JABlack400Color;
        [_saveContentView addSubview:separator];
    }
    return _saveContentView;
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
    
    [RIForm getForm:@"managenewsletterpreferences" forceRequest:YES successBlock:^(RIForm * newsletterPreferencesForm) {
        
        self.newsletterPreferencesForm = newsletterPreferencesForm;
        
        [self setupViews];
        
        [self hideLoading];
        
    } failureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        
        [self hideLoading];
        //$$$DO ERROR HANDLING
    }];
}

- (void)setupViews
{
    if (VALID_NOTEMPTY(self.newsletterPreferencesForm, RIForm)) {
        
        self.dynamicForm = [[JADynamicForm alloc] initWithForm:self.newsletterPreferencesForm startingPosition:0.0f];
        [self.dynamicForm setDelegate:self];
        
        for(UIView *view in self.dynamicForm.formViews)
        {
            [self.scrollView addSubview:view];
        }
        
        [self dynamicFormChangedHeight];
        
        [self.saveClickableView addTarget:self action:@selector(saveClickableViewPressed) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)saveClickableViewPressed
{
    [self showLoading];
    
    NSDictionary* parameters = [self.dynamicForm getValues];
    
    [RIForm sendForm:self.newsletterPreferencesForm extraArguments:nil parameters:parameters successBlock:^(id object) {
        [self hideLoading];
        
        [self.navigationController popViewControllerAnimated:YES];
    } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
        [self hideLoading];
        //$$$ HANDLE ERROR
    }];
}

#pragma mark JADynamicFormDelegate

- (void)dynamicFormChangedHeight
{
    CGFloat maxY = 0.0f;
    for(UIView *view in self.dynamicForm.formViews)
    {
        maxY = CGRectGetMaxY(view.frame);
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                               maxY)];
}

- (void)screenRadioWasPressedWithTargetString:(NSString *)targetString
{
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo setObject:targetString forKey:@"targetString"];
    [userInfo setObject:self forKey:@"delegate"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowNewsletterSubscriptionsScreenNotification object:nil userInfo:[userInfo copy]];
    
}

#pragma mark JANewsletterSubscriptionDelegate

- (void)newsletterSubscriptionSelected:(BOOL)selected;
{
    [self.dynamicForm unsubscribedNewsletters];
}

@end

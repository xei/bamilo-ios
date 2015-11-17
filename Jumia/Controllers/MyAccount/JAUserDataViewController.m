//
//  JAUserDataViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 17/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAUserDataViewController.h"
#import "RICustomer.h"
#import "RIForm.h"

@interface JAUserDataViewController ()
<
JADynamicFormDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *personalDataView;
@property (weak, nonatomic) IBOutlet UILabel *personalTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *personalLine;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIView *changePasswordView;
@property (weak, nonatomic) IBOutlet UILabel *changePasswordTitle;
@property (weak, nonatomic) IBOutlet UIImageView *changePasswordImageView;
@property (strong, nonatomic) JADynamicForm *changePasswordForm;
@property (assign, nonatomic) CGFloat currentY;
@property (assign, nonatomic) NSInteger numberOfFields;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) RICustomer *customer;
@property (assign, nonatomic) NSInteger numberOfRequests;
@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JAUserDataViewController

@synthesize numberOfRequests = _numberOfRequests;
-(void)setNumberOfRequests:(NSInteger)numberOfRequests
{
    _numberOfRequests = numberOfRequests;
    if(0 == _numberOfRequests)
    {
        [self finishedRequests];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.apiResponse = RIApiResponseSuccess;
    self.screenName = @"CustomerData";
    
    self.numberOfFields = 0;
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_USER_DATA;
    
    self.personalDataView.layer.cornerRadius = 5.0f;
    self.personalDataView.hidden = YES;
    
    self.personalTitleLabel.font = [UIFont fontWithName:kFontRegularName size:self.personalTitleLabel.font.pointSize];
    self.personalTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.personalTitleLabel.text = STRING_YOUR_PERSONAL_DATA;
    
    self.nameLabel.font = [UIFont fontWithName:kFontLightName size:self.nameLabel.font.pointSize];
    self.nameLabel.textColor = UIColorFromRGB(0x666666);
    
    self.emailLabel.font = [UIFont fontWithName:kFontLightName size:self.emailLabel.font.pointSize];
    self.emailLabel.textColor = UIColorFromRGB(0x666666);
    
    self.personalLine.backgroundColor = UIColorFromRGB(0xfaa41a);
    
    self.changePasswordView.layer.cornerRadius = 5.0f;
    self.changePasswordView.hidden = YES;
    
    self.changePasswordImageView.backgroundColor = UIColorFromRGB(0xfaa41a);
    self.changePasswordTitle.font = [UIFont fontWithName:kFontRegularName size:self.changePasswordTitle.font.pointSize];
    self.changePasswordTitle.textColor = UIColorFromRGB(0x4e4e4e);
    self.changePasswordTitle.text = STRING_NEW_PASSWORD;
    
    self.saveButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.saveButton.titleLabel.font.pointSize];
    [self.saveButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.saveButton setTitle:STRING_SAVE_LABEL forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(saveNewPassword) forControlEvents:UIControlEventTouchUpInside];
    
    self.currentY = 32.0f;
    
    [self makeRequests];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    
    [self setupViews:newWidth toInterfaceOrientation:toInterfaceOrientation];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupViews:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                                selector:@selector(hideKeyboard)
                                                name:kOpenMenuNotification
                                                object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"UserData"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)hideKeyboard
{
        [self.changePasswordForm resignResponder];
}

- (void)makeRequests
{
    self.numberOfRequests = 2;
    
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    self.apiResponse = RIApiResponseSuccess;
    
    [RIForm getForm:@"change_password"
       successBlock:^(RIForm *form)
     {
         self.changePasswordForm = [[JADynamicForm alloc] initWithForm:form
                                                      startingPosition:self.currentY
                                                             widthSize:self.changePasswordView.frame.size.width
                                                    hasFieldNavigation:YES];
         
         self.changePasswordForm.delegate = self;
         
         self.numberOfRequests--;
         [self removeErrorView];
     } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
     {
         self.apiResponse = apiResponse;
         self.numberOfRequests--;
     }];
    
    [RICustomer getCustomerWithSuccessBlock:^(id customer)
     {
         self.customer = customer;
         self.numberOfRequests--;
         
         
     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages)
     {
         self.numberOfRequests--;
         self.apiResponse = apiResponse;
     }];
}

- (void)finishedRequests
{
    if(RIApiResponseSuccess == self.apiResponse && VALID_NOTEMPTY(self.changePasswordForm, JADynamicForm) && VALID_NOTEMPTY(self.customer, RICustomer))
    {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.customer.firstName, self.customer.lastName];
        self.emailLabel.text = self.customer.email;
        
        for(UIView *view in self.changePasswordForm.formViews)
        {
            view.tag = self.numberOfFields;
            [self.changePasswordView addSubview:view];
            self.currentY = CGRectGetMaxY(view.frame);
            self.numberOfFields++;
        }
        
        [self setupViews:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    }
    else if(RIApiResponseMaintenancePage == self.apiResponse)
    {
        [self showMaintenancePage:@selector(makeRequests) objects:nil];
    }
    else if(RIApiResponseKickoutView == self.apiResponse)
    {
        [self showKickoutView:@selector(makeRequests) objects:nil];
    }
    else
    {
        BOOL noConnection = NO;
        if (RIApiResponseNoInternetConnection == self.apiResponse)
        {
            noConnection = YES;
        }
        [self showErrorView:noConnection startingY:0.0f selector:@selector(makeRequests) objects:nil];
    }
    
    [self hideLoading];
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.personalTitleLabel setX:6.f];
    [self.changePasswordTitle setX:6.f];
    [self.personalDataView setFrame:CGRectMake(self.personalDataView.frame.origin.x,
                                               self.personalDataView.frame.origin.y,
                                               width - (2 * self.personalDataView.frame.origin.x),
                                               self.personalDataView.frame.size.height)];
    
    [self.changePasswordView setFrame:CGRectMake(self.changePasswordView.frame.origin.x,
                                                 self.changePasswordView.frame.origin.y,
                                                 width - (2 * self.changePasswordView.frame.origin.x),
                                                 self.currentY + 15.0f)];
    
    [self.personalLine setFrame:CGRectMake(self.personalLine.frame.origin.x,
                                           self.personalLine.frame.origin.y,
                                           self.personalDataView.frame.size.width,
                                           self.personalLine.frame.size.height)];
    
    [self.changePasswordImageView setFrame:CGRectMake(self.changePasswordImageView.frame.origin.x,
                                                      self.changePasswordImageView.frame.origin.y,
                                                      self.changePasswordView.frame.size.width,
                                                      self.changePasswordImageView.frame.size.height)];
    
    CGFloat leftMargin = 17.0f;
    CGFloat dynamicFormleftMargin = 0.0f;
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        leftMargin = 145.0f;
        dynamicFormleftMargin = 128.0f;
    }
    
    [self.saveButton setFrame:CGRectMake(6.0f + dynamicFormleftMargin, CGRectGetMaxY(self.changePasswordView.frame) + 6.0f, self.changePasswordView.frame.size.width - (2 * dynamicFormleftMargin), self.saveButton.frame.size.height)];
    
    [self.contentScrollView setFrame:CGRectMake(0.0f,
                                                self.contentScrollView.frame.origin.y,
                                                self.view.width,
                                                self.view.height - self.contentScrollView.frame.origin.y)];
    
    [self.nameLabel setFrame:CGRectMake(leftMargin,
                                        self.nameLabel.frame.origin.y,
                                        self.personalDataView.frame.size.width - (2 * leftMargin),
                                        self.nameLabel.frame.size.height)];
    
    [self.emailLabel setFrame:CGRectMake(leftMargin,
                                         self.emailLabel.frame.origin.y,
                                         self.personalDataView.frame.size.width - (2 * leftMargin),
                                         self.emailLabel.frame.size.height)];
    
    
    for(UIView *view in self.changePasswordForm.formViews)
    {
        [view setFrame:CGRectMake(dynamicFormleftMargin,
                                  view.frame.origin.y,
                                  self.changePasswordView.frame.size.width - (2 * dynamicFormleftMargin),
                                  view.frame.size.height)];
    }
    [self.personalDataView setHidden:NO];
    [self.changePasswordView setHidden:NO];
    
    if(RI_IS_RTL){
        [self.personalDataView flipSubviewPositions];
        [self.changePasswordView flipSubviewPositions];
        [self.personalDataView flipSubviewAlignments];
        [self.changePasswordView flipSubviewAlignments];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - JADynamicForm delegate

- (void)changedFocus:(UIView *)view
{
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width,
                                                    self.contentScrollView.frame.size.height + (self.numberOfFields * 44));
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [self.contentScrollView setContentOffset:CGPointMake(0, (view.tag * 44) + 20)
                                                         animated:YES];
                     }];
}

- (void)lostFocus
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [self.contentScrollView scrollsToTop];
                         
                         self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width,
                                                                         self.contentScrollView.frame.size.height - (self.numberOfFields * 44));
                     }];
}

#pragma mark - Actions

- (void)saveNewPassword
{
    [self continueSavingPassword];
}

- (void)continueSavingPassword
{
    [self.changePasswordForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.changePasswordForm form]
          parameters:[self.changePasswordForm getValues]
        successBlock:^(id object)
     {
         [self.changePasswordForm resetValues];
         
         [self hideLoading];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:kDidSaveUserDataNotification object:nil];
         [self.navigationController popViewControllerAnimated:YES];
         
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         [self hideLoading];
         
         if(RIApiResponseNoInternetConnection == apiResponse)
         {
             [self showMessage:STRING_NO_CONNECTION success:NO];
         }
         else if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.changePasswordForm validateFields:errorObject];
             
             [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.changePasswordForm checkErrors];
             
             [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
         }
         else
         {
             [self.changePasswordForm checkErrors];
             
             [self showMessage:STRING_ERROR success:NO];
         }
     }];
}
@end

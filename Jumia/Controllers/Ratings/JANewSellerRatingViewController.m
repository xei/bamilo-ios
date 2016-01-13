//
//  JANewSellerRatingViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 03/03/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JANewSellerRatingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RIForm.h"
#import "RIField.h"
#import "RIProductRatings.h"
#import "JADynamicForm.h"
#import "JAAddRatingView.h"
#import "RICustomer.h"
#import "JAPriceView.h"
#import "JAUtils.h"
#import "RIProduct.h"
#import "RISeller.h"
#import "JARatingsViewMedium.h"
//#import <FacebookSDK/FacebookSDK.h>

#define kDistanceBetweenStarsAndText 70.0f

@interface JANewSellerRatingViewController ()
<
UITextFieldDelegate,
UIAlertViewDelegate
>
{
    JARatingsViewMedium* _ratingsView;
    CGFloat _ratingsViewWidth, _ratingsViewHeight;
    BOOL _didAppeared;
    BOOL _didSubViews;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *sellerNameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) CGRect scrollViewInitialRect;
@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) UILabel *fixedLabel;
@property (strong, nonatomic) UIButton *sendReviewButton;

@property (nonatomic, strong) RIForm* reviewsForm;
@property (nonatomic, strong) JADynamicForm* reviewsDynamicForm;
@property (nonatomic, strong) UIView* reviewsContentView;

@property (assign, nonatomic) NSInteger numberOfRequests;
@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JANewSellerRatingViewController

@synthesize numberOfRequests=_numberOfRequests;
-(void)setNumberOfRequests:(NSInteger)numberOfRequests
{
    _numberOfRequests=numberOfRequests;
    if (0 == numberOfRequests) {
        [self finishedRequests];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(VALID_NOTEMPTY(self.product.sku, NSString))
    {
        self.screenName = [NSString stringWithFormat:@"WriteSellerRatingScreen / %@", self.product.sku];
    }
    else
    {
        self.screenName = @"WriteSellerRatingScreen";
    }
    
    self.apiResponse = RIApiResponseSuccess;
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.sellerNameLabel.font = [UIFont fontWithName:kFontMediumName size:self.sellerNameLabel.font.pointSize];
    
    self.topView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.sellerNameLabel.text = self.product.seller.name;
    self.sellerNameLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboards)
                                                 name:kOpenMenuNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if (!self.reviewsForm) {
        [self formRequest];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    //[super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _didAppeared = YES;
    
    if(_didSubViews)
    {
        if ([self landscapePopViewController]) {
            return;
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    _didAppeared = NO;
    _didSubViews = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _didSubViews = YES;
    if(_didAppeared)
        [self landscapePopViewController];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self hideViews];
    
    [self showLoading];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self hideLoading];
    
    if(UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation || UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)
    {
        NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
        [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"animated"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification object:self userInfo:userInfo];
    }
    else
    {
        [self.topView setHidden:NO];
        [self.scrollView setHidden:NO];
    }
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (BOOL)landscapePopViewController
{
    if(UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation || UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)
    {
        [self hideLoading];
        NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
        [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"animated"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification object:self userInfo:userInfo];
        return YES;
    }
    return NO;
}

- (void)formRequest
{
    self.numberOfRequests = 0;
    
    [self hideViews];
    if(RIApiResponseSuccess != self.apiResponse)
    {
        if(VALID_NOTEMPTY(self.reviewsDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.reviewsDynamicForm.formViews, NSMutableArray))
        {
            [self showLoading];
        }
        
        self.apiResponse = RIApiResponseSuccess;
    }
    else
    {
        [self showLoading];
    }
    
    if ([[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
        self.numberOfRequests++;
        [RIForm getForm:@"seller_review"
           successBlock:^(RIForm *form)
         {
             self.reviewsForm = form;
             self.numberOfRequests--;
         } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
             self.apiResponse = apiResponse;
             self.numberOfRequests--;
         }];
    }
}

- (void)hideViews
{
    [self.topView setHidden:YES];
    [self.scrollView setHidden:YES];
}

-(void)finishedRequests
{
    if(RIApiResponseSuccess == self.apiResponse)
    {
        [self onSuccessResponse:self.apiResponse messages:nil showMessage:NO];
        [self setupViews];
    }
    if(VALID_NOTEMPTY(self.reviewsDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.reviewsDynamicForm.formViews, NSMutableArray))
    {
        [self onErrorResponse:self.apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(formRequest) objects:nil];
    }
    else
    {
        [self onErrorResponse:self.apiResponse messages:nil showAsMessage:NO selector:@selector(formRequest) objects:nil];
    }
    
    [self hideLoading];
}

-(void)setupTopView
{
    [self.sellerNameLabel setFrame:CGRectMake(12.0f,
                                              6.0f,
                                              self.view.frame.size.width - 24.0f,
                                              self.view.frame.size.height)];
    [self.sellerNameLabel sizeToFit];
    
    
    CGFloat topViewMinHeight = CGRectGetMaxY(self.sellerNameLabel.frame) + 6.0f;
    
    if (!_ratingsView) {
        _ratingsView = [JARatingsViewMedium getNewJARatingsViewMedium];
        [self.topView addSubview:_ratingsView];
        _ratingsViewWidth = _ratingsView.width;
        _ratingsViewHeight = _ratingsView.height;
    }
    [_ratingsView setRating:[self.sellerAverageReviews integerValue]];
    [_ratingsView setFrame:CGRectMake(12.0f,
                                     topViewMinHeight,
                                     _ratingsViewWidth,
                                     _ratingsViewHeight)];
    
    topViewMinHeight += _ratingsView.frame.size.height + 11.0f;
    
    [self.topView setFrame:CGRectMake(0.0f,
                                      0.0f,
                                      self.view.frame.size.width,
                                      topViewMinHeight)];
    [self.topView setHidden:NO];
}

-(void)setupViews
{
    [self setupTopView];
    
    CGFloat verticalMargin = 6.0f;
    CGFloat horizontalMargin = 6.0f;
    
    BOOL isiPad = NO;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        isiPad = YES;
    }
    CGFloat scrollViewWidth = self.view.frame.size.width;
    
    [self.scrollView setFrame:CGRectMake(0.0f,
                                         CGRectGetMaxY(self.topView.frame),
                                         scrollViewWidth,
                                         self.view.frame.size.height - CGRectGetMaxY(self.topView.frame))];
    self.scrollViewInitialRect = self.scrollView.frame;
    
    if(VALID(self.centerView, UIView))
    {
        [self.centerView removeFromSuperview];
    }
    self.centerView = [[UIView alloc] init];
    self.centerView.backgroundColor = [UIColor whiteColor];
    self.centerView.layer.cornerRadius = 5.0f;
    
    CGFloat centerViewWidth = scrollViewWidth - (2 * horizontalMargin);
    CGFloat dynamicFormHorizontalMargin = 6.0f;
    if(isiPad)
    {
        dynamicFormHorizontalMargin = 230.0f;
    }
    
    if(VALID_NOTEMPTY(self.fixedLabel, UILabel))
    {
        [self.fixedLabel removeFromSuperview];
    }
    
    self.fixedLabel = [[UILabel alloc] initWithFrame:CGRectMake(dynamicFormHorizontalMargin,
                                                                verticalMargin,
                                                                centerViewWidth - (2 * dynamicFormHorizontalMargin),
                                                                16.0f)];
    self.fixedLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
    self.fixedLabel.text = STRING_REVIEW_THIS_SELLER;
    self.fixedLabel.textColor = UIColorFromRGB(0x666666);
    
    [self.centerView addSubview:self.fixedLabel];
    
    CGFloat currentY = CGRectGetMaxY(self.fixedLabel.frame) + 12.0f;
    CGFloat spaceBetweenFormFields = 6.0f;
    
    if (self.reviewsForm) {
        CGFloat initialContentY = 0;
        self.reviewsDynamicForm = [[JADynamicForm alloc] initWithForm:self.reviewsForm
                                                     startingPosition:initialContentY
                                                            widthSize:centerViewWidth
                                                   hasFieldNavigation:YES];
        self.reviewsContentView = [UIView new];
        for (int i = 0; i < self.reviewsDynamicForm.formViews.count; i++)
        {
            UIView* view = [self.reviewsDynamicForm.formViews objectAtIndex:i];
            view.tag = i;
            CGRect frame = view.frame;
            if(isiPad)
            {
                frame.origin.x = dynamicFormHorizontalMargin;
                frame.size.width = centerViewWidth - (2 * dynamicFormHorizontalMargin);
            }
            else
            {
                frame.size.width = centerViewWidth;
            }
            view.frame = frame;
            
            [self.reviewsContentView addSubview:view];
            
            initialContentY += view.frame.size.height + spaceBetweenFormFields;
        }
        [self.reviewsContentView setFrame:CGRectMake(0.0,
                                                     currentY,
                                                     centerViewWidth,
                                                     initialContentY)];
        [self.centerView addSubview:self.reviewsContentView];
    }
    
    
    if (VALID_NOTEMPTY(self.reviewsContentView, UIView)){
        currentY += self.reviewsContentView.frame.size.height;
    }
    
    // Add space between last form field and send review button
    currentY += 38.0f;
    
    NSString *imageNameFormat = @"orangeMedium_%@";
    if(isiPad)
    {
        imageNameFormat = @"orangeMediumPortrait_%@";
    }
    UIImage* buttonImageNormal = [UIImage imageNamed:[NSString stringWithFormat:imageNameFormat, @"normal"]];
    UIImage* buttonImageHighlighted = [UIImage imageNamed:[NSString stringWithFormat:imageNameFormat, @"highlighted"]];
    UIImage* buttonImageDisabled = [UIImage imageNamed:[NSString stringWithFormat:imageNameFormat, @"disabled"]];
    self.sendReviewButton = [[UIButton alloc] initWithFrame:CGRectMake(6.0f,
                                                                       currentY,
                                                                       buttonImageNormal.size.width,
                                                                       buttonImageNormal.size.height)];
    [self.sendReviewButton setTitle:STRING_SEND_REVIEW
                           forState:UIControlStateNormal];
    [self.sendReviewButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                                forState:UIControlStateNormal];
    self.sendReviewButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:16.0f];
    [self.sendReviewButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
    [self.sendReviewButton setBackgroundImage:buttonImageHighlighted forState:UIControlStateHighlighted];
    [self.sendReviewButton setBackgroundImage:buttonImageHighlighted forState:UIControlStateSelected];
    [self.sendReviewButton setBackgroundImage:buttonImageDisabled forState:UIControlStateDisabled];
    [self.sendReviewButton addTarget:self action:@selector(sendReview:) forControlEvents:UIControlEventTouchUpInside];
    [self.centerView addSubview:self.sendReviewButton];
    
    [self.centerView setFrame:CGRectMake(horizontalMargin,
                                         verticalMargin,
                                         centerViewWidth,
                                         CGRectGetMaxY(self.sendReviewButton.frame) + verticalMargin)];
    [self.scrollView addSubview:self.centerView];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             self.centerView.frame.size.height + self.centerView.frame.origin.y);
    
    [self.scrollView setHidden:NO];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Send review

- (void)sendReview:(id)sender
{
    [self showLoading];
    
    [self.reviewsDynamicForm resignResponder];
    
    RIForm* currentForm;
    JADynamicForm* currentDynamicForm;
    currentForm = self.reviewsForm;
    currentDynamicForm = self.reviewsDynamicForm;
    if ([[RICountryConfiguration getCurrentConfiguration].reviewRequiresLogin boolValue] && NO == [RICustomer checkIfUserIsLogged]) {
        [self hideLoading];
        NSMutableDictionary* userInfoLogin = [[NSMutableDictionary alloc] init];
        [userInfoLogin setObject:[NSNumber numberWithBool:NO] forKey:@"from_side_menu"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:nil userInfo:userInfoLogin];
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[currentDynamicForm getValues]];
    
    if (VALID_NOTEMPTY(self.product.seller.uid, NSString)) {
        NSString* sellerIdKey = [currentDynamicForm getFieldNameForKey:@"sellerId"];
        [parameters addEntriesFromDictionary:@{sellerIdKey: self.product.seller.uid}];
    }
    
    [RIForm sendForm:currentForm
          parameters:parameters
        successBlock:^(id object) {
            
            [self hideLoading];
            
            [self onSuccessResponse:RIApiResponseSuccess messages:@[STRING_REVIEW_SENT] showMessage:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kCloseTopTwoScreensNotification
                                                                object:nil
                                                              userInfo:nil];
        } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
            
            [self hideLoading];
            
            if(VALID_NOTEMPTY(errorObject, NSDictionary))
            {
                [currentDynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                    [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(sendReview:) objects:sender];
                }];
            }
            else if(VALID_NOTEMPTY(errorObject, NSArray))
            {
                [currentDynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                    [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(sendReview:) objects:sender];
                }];
            }
            else
            {
                [currentDynamicForm checkErrors];
                [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(sendReview:) objects:sender];
            }
        }];
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

#pragma mark - Keyboard notifications

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat height = kbSize.height;
    if(self.view.frame.size.width == kbSize.height)
    {
        height = kbSize.width;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:CGRectMake(self.scrollViewInitialRect.origin.x,
                                             self.scrollViewInitialRect.origin.y,
                                             self.scrollViewInitialRect.size.width,
                                             self.scrollViewInitialRect.size.height - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:self.scrollViewInitialRect];
    }];
}

-(void)hideKeyboards
{
    [self.reviewsDynamicForm resignResponder];
}
@end


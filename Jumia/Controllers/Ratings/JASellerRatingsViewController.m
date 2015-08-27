//
//  JASellerRatingsViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 27/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JASellerRatingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JAReviewCell.h"
#import "JANewRatingViewController.h"
#import "JAPriceView.h"
#import "JADynamicForm.h"
#import "JAAddRatingView.h"
#import "JARatingsViewMedium.h"
#import "RIProduct.h"
#import "RISeller.h"
#import "RIForm.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import "RICategory.h"
//#import <FacebookSDK/FacebookSDK.h>

#define kDistanceBetweenStarsAndText 70.0f

@interface JASellerRatingsViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    JARatingsViewMedium *_ratingsView;
    CGFloat _ratingsViewWidth, _ratingsViewHeight;
}

@property (nonatomic, strong)RISellerReviewInfo* sellerReviewInfo;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *sellerNameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *resumeView;
@property (weak, nonatomic) IBOutlet UILabel *labelUsedProduct;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewButton;
@property (weak, nonatomic) IBOutlet UITableView *tableViewComments;

@property (weak, nonatomic) IBOutlet UIView *emptyReviewsView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyReviewsImageView;
@property (weak, nonatomic) IBOutlet UILabel *emptyReviewsLabel;
// iPad landscape components only
@property (weak, nonatomic) IBOutlet UIScrollView *writeReviewScrollView;
@property (assign, nonatomic) CGRect writeReviewScrollViewInitialRect;

@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) UILabel *fixedLabel;
@property (strong, nonatomic) UIButton *sendReviewButton;

@property (nonatomic, strong) RIForm* reviewsForm;
@property (nonatomic, strong) JADynamicForm* reviewsDynamicForm;
@property (nonatomic, strong) UIView* reviewsContentView;

@property (assign, nonatomic) NSInteger numberOfRequests;
@property (assign, nonatomic) RIApiResponse apiResponse;
@property (assign, nonatomic) BOOL requestsDone;
@property (assign, nonatomic) NSInteger maxReviews;
@property (strong, nonatomic) NSMutableArray *reviewsArray;
@property (assign, nonatomic) BOOL loadedEverything;
@end

@implementation JASellerRatingsViewController

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
    
    self.maxReviews = 15;
    
    if(VALID_NOTEMPTY(self.product.seller.name, NSString))
    {
        self.screenName = [NSString stringWithFormat:@"SellerReviewsScreen / %@", self.product.seller.name];
    }
    else
    {
        self.screenName = @"SellerReviewsScreen";
    }
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.sellerNameLabel.font = [UIFont fontWithName:kFontMediumName size:self.sellerNameLabel.font.pointSize];
    self.labelUsedProduct.font = [UIFont fontWithName:kFontLightName size:self.labelUsedProduct.font.pointSize];
    self.writeReviewButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.writeReviewButton.titleLabel.font.pointSize];
    self.emptyReviewsLabel.font = [UIFont fontWithName:kFontRegularName size:self.emptyReviewsLabel.font.pointSize];
    
    self.sellerNameLabel.text = self.product.seller.name;
    
    self.requestsDone = NO;
    
    self.loadedEverything = NO;
    
    self.apiResponse = RIApiResponseSuccess;
    
    self.reviewsArray = [NSMutableArray new];
        
    [self hideViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)addReviewsToTable:(NSArray*)reviews
{
    self.apiResponse = RIApiResponseSuccess;
    [self removeErrorView];
    
    BOOL isEmpty = NO;
    if(ISEMPTY(self.reviewsArray))
    {
        isEmpty = YES;
        self.reviewsArray = [NSMutableArray new];
    }
    
    if(VALID_NOTEMPTY(reviews, NSArray))
    {
        [self.reviewsArray addObjectsFromArray:reviews];
    }
    
    [self.tableViewComments reloadData];
    if(isEmpty)
    {
        [self.tableViewComments setContentOffset:CGPointZero animated:NO];
    }
}


- (void)sellerReviewsRequest
{
    
    NSInteger currentPage = 0;
    if (VALID_NOTEMPTY(self.sellerReviewInfo, RISellerReviewInfo)) {
        if ([self.sellerReviewInfo.currentPage integerValue] == [self.sellerReviewInfo.totalPages integerValue]) {
            self.loadedEverything = YES;
            return;
        }
            
        currentPage = [self.sellerReviewInfo.currentPage integerValue] + 1;
    }
    [self showLoading];
    [RISellerReviewInfo getSellerReviewForProductWithUrl:self.product.url pageSize:self.maxReviews pageNumber:currentPage successBlock:^(RISellerReviewInfo *sellerReviewInfo) {
        self.sellerReviewInfo = sellerReviewInfo;
        
        [self removeErrorView];
        
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
        {
            [self formRequest];
        }
        else
        {
            self.numberOfRequests = 0;
        }
        
        [self addReviewsToTable:self.sellerReviewInfo.reviews];
        
        [self hideLoading];

    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        self.apiResponse = apiResponse;
        
        if(RIApiResponseSuccess != self.apiResponse)
        {
            if (RIApiResponseNoInternetConnection == self.apiResponse)
            {
                [self showErrorView:YES startingY:0.0f selector:@selector(sellerReviewsRequest) objects:nil];
            }
            else
            {
                [self showErrorView:NO startingY:0.0f selector:@selector(sellerReviewsRequest) objects:nil];
            }
        }
        self.numberOfRequests = 0;
        [self hideLoading];
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"SellerReviewsScreen"];
    
    if(self.requestsDone)
    {
        [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
    }
    else
    {
        [self showLoading];
        
        [self sellerReviewsRequest];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self showLoading];
    
    [self hideViews];
    
    [self.reviewsDynamicForm resignResponder];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self hideLoading];
    
    [self setupViews];
    
}

- (void)formRequest
{
    self.numberOfRequests = 0;
    self.apiResponse = RIApiResponseSuccess;
    
    self.numberOfRequests++;
    [RIForm getForm:@"sellerreview"
       successBlock:^(RIForm *form)
     {
         self.reviewsForm = form;
         self.numberOfRequests--;
     } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
         self.apiResponse = apiResponse;
         self.numberOfRequests--;
     }];
}

- (void)finishedRequests
{
    [self setupViews];
    
    [self hideLoading];
    
    [self removeErrorView];
    
    if(RIApiResponseSuccess != self.apiResponse)
    {
        if (RIApiResponseNoInternetConnection == self.apiResponse)
        {
            [self showErrorView:YES startingY:0.0f selector:@selector(formRequest) objects:nil];
        }
        else
        {
            [self showErrorView:NO startingY:0.0f selector:@selector(formRequest) objects:nil];
        }
    }
    
    self.requestsDone = YES;
}

- (void)hideViews
{
    [self.topView setHidden:YES];
    [self.resumeView setHidden:YES];
    [self.tableViewComments setHidden:YES];
    
    if(self.emptyReviewsView)
    {
        [self.emptyReviewsView setHidden:YES];
    }
    
    if(self.writeReviewScrollView)
    {
        [self.writeReviewScrollView setHidden:YES];
    }
}

- (void)setupViews
{
    CGFloat horizontalMargin = 6.0f;
    CGFloat verticalMargin = 6.0f;
    
    BOOL isiPad = NO;
    BOOL isInLandscape = NO;
    BOOL hasComments = NO;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        isiPad = YES;
    }
    if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation || UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)
    {
        isInLandscape = YES;
    }
    
    if(VALID_NOTEMPTY(self.sellerReviewInfo, RISellerReviewInfo) && VALID_NOTEMPTY(self.sellerReviewInfo.reviews, NSArray))
    {
        hasComments = YES;
    }
    
    [self setupTopView];
    
    CGFloat viewsWidth = self.view.frame.size.width - (2 * horizontalMargin);
    
    if (self.contentScrollView) {
        [self.contentScrollView setFrame:CGRectMake(0, CGRectGetMaxY(self.topView.frame), self.view.frame.size.width, self.view.height-CGRectGetMaxY(self.topView.frame))];
    }
    
    if(!isiPad || !isInLandscape)
    {
        [self setupResumeView:viewsWidth];
    }
    
    CGFloat originY = CGRectGetMaxY(self.resumeView.frame) + verticalMargin;
    if (NO == [[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
        
        originY = verticalMargin;
    }
    self.tableViewComments.delegate = self;
    self.tableViewComments.dataSource = self;
    self.tableViewComments.layer.cornerRadius = 5.0f;
    self.tableViewComments.allowsSelection = NO;
    
    if(isInLandscape)
    {
        [self.resumeView setHidden:YES];
        [self.writeReviewScrollView setHidden:NO];
        
        originY = CGRectGetMaxY(self.topView.frame) + verticalMargin;
        CGFloat tableHeight = self.view.frame.size.height - originY - verticalMargin;
        if (self.contentScrollView) {
            originY = verticalMargin;
            tableHeight = self.view.height - self.contentScrollView.y - verticalMargin;
        }
        
        
        CGFloat rightSideViewsWidth = 0.0f;
        
        if (NO == [[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
            
            //keep them the same
            
        } else {
            
            // The 18.0f pixeis are the left, middle and right margins
            viewsWidth = ((self.view.frame.size.width - 18.0f) / 2);
            rightSideViewsWidth = viewsWidth;
        }
        
        
        [self.tableViewComments setFrame:CGRectMake(horizontalMargin,
                                                    originY,
                                                    viewsWidth,
                                                    tableHeight)];
        
        if(hasComments)
        {
            [self.emptyReviewsView setHidden:YES];
            [self.tableViewComments setHidden:NO];
        }
        else
        {
            [self.tableViewComments setHidden:YES];
            [self.emptyReviewsView setHidden:NO];
        }
        
        [self setupSendReviewView:rightSideViewsWidth originY:originY];
        
        [self setupEmptyReviewsView:viewsWidth originY:originY];
    }
    else
    {
        CGFloat startingYForContent = originY;
        
        if (NO == [[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
            
            [self.resumeView setHidden:YES];
        } else {
            [self.resumeView setHidden:NO];
        }
        
        CGFloat tableHeight = self.view.frame.size.height - startingYForContent - verticalMargin;
        if (self.contentScrollView) {
            tableHeight = self.view.height - self.contentScrollView.y - verticalMargin - startingYForContent;
        }
        
        [self.writeReviewScrollView setHidden:YES];
        
        if(hasComments)
        {
            [self.tableViewComments setFrame:CGRectMake(horizontalMargin,
                                                        startingYForContent,
                                                        viewsWidth,
                                                        tableHeight)];
            [self.tableViewComments setHidden:NO];
            [self.emptyReviewsView setHidden:YES];
        }
        else
        {
            [self.tableViewComments setHidden:YES];
            [self.emptyReviewsView setHidden:NO];
            [self setupEmptyReviewsView:viewsWidth originY:startingYForContent];
            [self.view bringSubviewToFront:self.tableViewComments];
        }
    }
    
    [self.tableViewComments reloadData];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
    
    self.writeReviewScrollViewInitialRect = self.writeReviewScrollView.frame;
}

- (void)setupTopView
{
    [self.topView setWidth:self.view.width];
    [self.sellerNameLabel setFrame:CGRectMake(12.0f,
                                              6.0f,
                                              self.view.frame.size.width - 24.0f,
                                              self.view.frame.size.height)];
    [self.sellerNameLabel sizeToFit];
            
    CGFloat topViewMinHeight = CGRectGetMaxY(self.sellerNameLabel.frame) + 6.0f;
    
    if (!_ratingsView) {
        _ratingsView = [JARatingsViewMedium getNewJARatingsViewMedium];
        _ratingsViewWidth = _ratingsView.width;
        _ratingsViewHeight = _ratingsView.height;
        [self.topView addSubview:_ratingsView];
    }
    
    [_ratingsView setRating:[self.sellerReviewInfo.averageReviews integerValue]];
    [_ratingsView setX:12.0f];
    [_ratingsView setWidth:_ratingsViewWidth];
    [_ratingsView setY:topViewMinHeight];
    
    topViewMinHeight = CGRectGetMaxY(_ratingsView.frame) + 11.0f;
    
    [self.topView setFrame:CGRectMake(0.0f,
                                      0.0f,
                                      self.view.frame.size.width,
                                      70)];
    
    [self.topView setHidden:NO];
}

- (void)setupResumeView:(CGFloat)width
{
    CGFloat verticalMargin = 6.f;
    CGFloat horizontalMargin = 6.0f;
    CGFloat currentY = 6.0f;
    
    self.resumeView.layer.cornerRadius = 5.0f;
    if (!self.contentScrollView) {
        verticalMargin = CGRectGetMaxY(self.topView.frame) + verticalMargin;
    }
    [self.resumeView setFrame:CGRectMake(horizontalMargin,
                                         verticalMargin,
                                         width,
                                         currentY + 20.0f)];
    
    if (NO == [[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
        
        [self.labelUsedProduct removeFromSuperview];
        [self.writeReviewButton removeFromSuperview];
    } else {
        self.labelUsedProduct.text = STRING_REVIEW_THIS_SELLER;
        self.labelUsedProduct.textAlignment = NSTextAlignmentCenter;
        [self.labelUsedProduct setTextColor:UIColorFromRGB(0x666666)];
        [self.labelUsedProduct setFrame:CGRectMake(self.labelUsedProduct.frame.origin.x,
                                                   currentY,
                                                   self.view.frame.size.width - 12.0f - (2* self.labelUsedProduct.frame.origin.x),
                                                   self.labelUsedProduct.frame.size.height)];
        [self.writeReviewButton setTitle:STRING_WRITE_REVIEW
                                forState:UIControlStateNormal];
        [self.writeReviewButton sizeToFit];
        [self.writeReviewButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                                     forState:UIControlStateNormal];
        
        currentY = CGRectGetMaxY(self.writeReviewButton.frame);
        
        [self.writeReviewButton setX:[self.writeReviewButton superview].width/2 - self.writeReviewButton.width/2];
    }
    
    [self.resumeView setHeight:currentY + 20.0f];
}

- (void)setupSendReviewView:(CGFloat)width originY:(CGFloat)originY
{
    BOOL isiPad = NO;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        isiPad = YES;
    }
    
    CGFloat verticalMargin = 6.0f;
    
    // This value is calculated by adding the left and middle margin of the two main views
    CGFloat horizontalMargin = 12.0f;
    [self.writeReviewScrollView setFrame:CGRectMake(width + horizontalMargin,
                                                    originY,
                                                    width,
                                                    self.view.frame.size.height - originY)];
    
    if(VALID(self.centerView, UIView))
    {
        [self.centerView removeFromSuperview];
    }
    self.centerView = [[UIView alloc] init];
    self.centerView.backgroundColor = [UIColor whiteColor];
    self.centerView.layer.cornerRadius = 5.0f;
    
    CGFloat dynamicFormHorizontalMargin = 60.0f;
    if(VALID_NOTEMPTY(self.fixedLabel, UILabel))
    {
        [self.fixedLabel removeFromSuperview];
    }
    
    self.fixedLabel = [[UILabel alloc] initWithFrame:CGRectMake(dynamicFormHorizontalMargin,
                                                                verticalMargin,
                                                                width - (2 * dynamicFormHorizontalMargin),
                                                                16.0f)];
    self.fixedLabel.textAlignment = NSTextAlignmentCenter;
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
                                                            widthSize:width
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
                frame.size.width = width - (2 * dynamicFormHorizontalMargin);
            }
            else
            {
                frame.size.width = width;
            }
            view.frame = frame;
            
            [self.reviewsContentView addSubview:view];
            
            initialContentY += view.frame.size.height + spaceBetweenFormFields;
        }
        [self.reviewsContentView setFrame:CGRectMake(0.0,
                                                     currentY,
                                                     width,
                                                     initialContentY)];
        [self.centerView addSubview:self.reviewsContentView];
    }
    
    
    if (VALID_NOTEMPTY(self.reviewsContentView, UIView)){
        currentY += self.reviewsContentView.frame.size.height;
    }
    
    // Add space between last form field and send review button
    currentY += 38.0f;
    
    NSString *imageNameFormat = @"orangeHalfMedium_%@";
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
    
    [self.centerView setFrame:CGRectMake(0.0f,
                                         0.0f,
                                         width,
                                         CGRectGetMaxY(self.sendReviewButton.frame) + verticalMargin)];
    [self.writeReviewScrollView addSubview:self.centerView];
    [self.writeReviewScrollView setContentSize:CGSizeMake(self.writeReviewScrollView.frame.size.width, currentY)];
}

- (void) setupEmptyReviewsView:(CGFloat)width originY:(CGFloat)originY
{
    
    CGFloat horizontalMargin = 6.0f;
    CGFloat totalHeight = 6.0f;
    
    self.emptyReviewsView.layer.cornerRadius = 5.0f;
    [self.emptyReviewsView setFrame:CGRectMake(horizontalMargin,
                                               originY,
                                               width,
                                               self.centerView.frame.size.height)];
    
    [self.emptyReviewsLabel setText:STRING_SELLER_REVIEWS_EMPTY];
    [self.emptyReviewsLabel sizeToFit];
    [self.emptyReviewsLabel setTextColor:UIColorFromRGB(0xcccccc)];
    
    CGFloat marginBetweenImageAndLabel = 30.0f;
    CGFloat componentsHeight = self.emptyReviewsImageView.frame.size.height + marginBetweenImageAndLabel;
    
    CGFloat emptyReviewsLabelHorizontalMargin = 60.0f;
    CGRect emptyReviewsLabelRect = [STRING_SELLER_REVIEWS_EMPTY boundingRectWithSize:CGSizeMake(width - emptyReviewsLabelHorizontalMargin * 2, (self.emptyReviewsView.frame.size.height - componentsHeight))
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName:self.emptyReviewsLabel.font} context:nil];
    componentsHeight += emptyReviewsLabelRect.size.height;
    totalHeight += componentsHeight + 6.0f;
    if(totalHeight > self.emptyReviewsView.frame.size.height)
    {
        [self.emptyReviewsView setFrame:CGRectMake(horizontalMargin,
                                                   originY,
                                                   width,
                                                   totalHeight)];
    }
    
    CGFloat verticalMargin = (self.emptyReviewsView.frame.size.height - componentsHeight) / 2;
    [self.emptyReviewsImageView setFrame:CGRectMake((self.emptyReviewsView.frame.size.width - self.emptyReviewsImageView.frame.size.width) / 2,
                                                    verticalMargin,
                                                    self.emptyReviewsImageView.frame.size.width,
                                                    self.emptyReviewsImageView.frame.size.height)];
    
    [self.emptyReviewsLabel setFrame:CGRectMake((self.emptyReviewsView.frame.size.width - emptyReviewsLabelRect.size.width) / 2,
                                                CGRectGetMaxY(self.emptyReviewsImageView.frame) + marginBetweenImageAndLabel,
                                                emptyReviewsLabelRect.size.width,
                                                emptyReviewsLabelRect.size.height)];
    if (self.contentScrollView) {
        [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.width, CGRectGetMaxY(self.emptyReviewsView.frame) + verticalMargin)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)goToNewReviews:(id)sender
{
    NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(self.product, RIProduct))
    {
        [userInfo setObject:self.product forKey:@"product"];
    }
    
    if(VALID_NOTEMPTY(self.sellerReviewInfo.averageReviews, NSNumber))
    {
        [userInfo setObject:self.sellerReviewInfo.averageReviews forKey:@"sellerAverageReviews"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenNewSellerReview object:nil userInfo:userInfo];
}

#pragma mark - Tableview methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.reviewsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RISellerReview* review = [self.reviewsArray objectAtIndex:indexPath.row];
    return [JAReviewCell cellHeightWithSellerReview:review width:self.tableViewComments.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.row == ([self.reviewsArray count] - 1)) && (!self.loadedEverything))
    {
        
        [self sellerReviewsRequest];
        
    }
    JAReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell"];
    
    if (!cell) {
        cell = [[JAReviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reviewCell"];
    }
    
    RISellerReview* review = [self.reviewsArray objectAtIndex:indexPath.row];
    
    BOOL showSeparator = YES;
    if(indexPath.row == ([self.reviewsArray count] - 1))
    {
        showSeparator = NO;
    }
    
    [cell setupWithSellerReview:review width:self.tableViewComments.frame.size.width showSeparator:showSeparator];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification object:nil userInfo:userInfoLogin];
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
            
            [self showMessage:STRING_REVIEW_SENT success:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
                                                                object:nil
                                                              userInfo:nil];
        } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
            
            [self hideLoading];
            
            if (RIApiResponseNoInternetConnection == apiResponse)
            {
                [self showMessage:STRING_NO_CONNECTION success:NO];
            }
            else if(VALID_NOTEMPTY(errorObject, NSDictionary))
            {
                [currentDynamicForm validateFields:errorObject];
                
                [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
            }
            else if(VALID_NOTEMPTY(errorObject, NSArray))
            {
                [currentDynamicForm checkErrors];
                
                [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
            }
            else
            {
                [currentDynamicForm checkErrors];
                
                [self showMessage:STRING_ERROR success:NO];
            }
        }];
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
    // This happens only in landscape so we need to remove keyboard width.
    [UIView animateWithDuration:0.3 animations:^{
        [self.writeReviewScrollView setFrame:CGRectMake(self.writeReviewScrollViewInitialRect.origin.x,
                                                        self.writeReviewScrollViewInitialRect.origin.y,
                                                        self.writeReviewScrollViewInitialRect.size.width,
                                                        self.writeReviewScrollViewInitialRect.size.height - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.writeReviewScrollView setFrame:self.writeReviewScrollViewInitialRect];
    }];
}

-(void)hideKeyboards
{
    [self.reviewsDynamicForm resignResponder];
}

@end

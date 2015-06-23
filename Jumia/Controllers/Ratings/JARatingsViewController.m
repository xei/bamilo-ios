//
//  JARatingsViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARatingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JAReviewCell.h"
#import "JANewRatingViewController.h"
#import "JAPriceView.h"
#import "JADynamicForm.h"
#import "JAAddRatingView.h"
#import "JARatingsViewMedium.h"
#import "RIProduct.h"
#import "RIForm.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import "RICategory.h"
#import <FacebookSDK/FacebookSDK.h>

#define kDistanceBetweenStarsAndText 70.0f

#define kHorizontalMargin 6.0f
#define kVerticalMargin 6.0f

@interface JARatingsViewController ()
<
UITableViewDelegate,
UITableViewDataSource
> {
    CGFloat _viewsWidth;
    BOOL _hasComments;
    BOOL _reviewsEnabled;
    float _ratingTypeLinesHeight;
    int _topViewHeight;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *resumeView;
@property (nonatomic, strong) NSMutableArray* ratingStars;
@property (nonatomic, strong) NSMutableArray* ratingStarLabels;
@property (weak, nonatomic) IBOutlet UILabel *labelUsedProduct;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewButton;
@property (weak, nonatomic) IBOutlet UITableView *tableViewComments;
@property (nonatomic, strong) JAPriceView *priceView;

@property (weak, nonatomic) IBOutlet UIView *emptyReviewsView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyReviewsImageView;
@property (weak, nonatomic) IBOutlet UILabel *emptyReviewsLabel;
// iPad landscape components only
@property (strong, nonatomic) UIScrollView *writeReviewScrollView;
@property (assign, nonatomic) CGRect writeReviewScrollViewInitialRect;

@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) UILabel *fixedLabel;
@property (strong, nonatomic) UIButton *sendReviewButton;

@property (nonatomic, strong) UISwitch *modeSwitch;
@property (nonatomic, assign) BOOL isShowingRating;

@property (nonatomic, strong) RIForm* ratingsForm;
@property (nonatomic, strong) JADynamicForm* ratingsDynamicForm;
@property (nonatomic, strong) UIView* ratingsContentView;
@property (nonatomic, strong) RIForm* reviewsForm;
@property (nonatomic, strong) JADynamicForm* reviewsDynamicForm;
@property (nonatomic, strong) UIView* reviewsContentView;

@property (assign, nonatomic) NSInteger numberOfRequests;
@property (assign, nonatomic) RIApiResponse apiResponse;
@property (assign, nonatomic) BOOL requestsDone;
@property (assign, nonatomic) BOOL loadedEverything;
@property (strong, nonatomic) NSMutableArray *reviewsArray;

@end

@implementation JARatingsViewController

@synthesize numberOfRequests=_numberOfRequests;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"");
    }
    return self;
}

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
    
    self.reviewsArray = [NSMutableArray new];
    
    self.loadedEverything = NO;
    
    if(VALID_NOTEMPTY(self.product.sku, NSString))
    {
        self.screenName = [NSString stringWithFormat:@"RatingScreen / %@", self.product.sku];
    }
    else
    {
        self.screenName = @"RatingScreen";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.brandLabel.font = [UIFont fontWithName:kFontMediumName size:self.brandLabel.font.pointSize];
    self.nameLabel.font = [UIFont fontWithName:kFontRegularName size:self.nameLabel.font.pointSize];
    self.labelUsedProduct.font = [UIFont fontWithName:kFontLightName size:self.labelUsedProduct.font.pointSize];
    self.writeReviewButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.writeReviewButton.titleLabel.font.pointSize];
    self.emptyReviewsLabel.font = [UIFont fontWithName:kFontRegularName size:self.emptyReviewsLabel.font.pointSize];
    
    self.brandLabel.text = self.product.brand;
    
    self.nameLabel.text = self.product.name;
    
    self.requestsDone = NO;
    
    self.apiResponse = RIApiResponseSuccess;
    
    if(self.requestsDone)
    {
        [self setupViews];
    }else
    {
        [self showLoading];
        
        [self requestReviews];
    }
    
    [self hideViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboards)
                                                 name:kOpenMenuNotification
                                               object:nil];
    
   
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
        {
            [self ratingsRequests];
        }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"Reviews"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self hideLoading];
    CGFloat alpha = self.view.alpha;
    [UIView animateWithDuration:.1 animations:^{
        [UIView animateWithDuration:.1 animations:^{
            [self.view setAlpha:.7f];
        } completion:^(BOOL finished) {
            [self setupViews];
            [UIView animateWithDuration:.1 animations:^{
                [self.view setAlpha:alpha];
            }];
        }];
    }];
}

- (void)ratingsRequests
{
    self.numberOfRequests = 0;
    self.apiResponse = RIApiResponseSuccess;
    
    [self showLoading];
    
    if ([[RICountryConfiguration getCurrentConfiguration].ratingIsEnabled boolValue]) {
        self.numberOfRequests++;
        [RIForm getForm:@"rating"
           successBlock:^(RIForm *form)
         {
             self.ratingsForm = form;
             self.numberOfRequests--;
         } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
             self.apiResponse = apiResponse;
             self.numberOfRequests--;
         }];
    }
    
    if ([[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
        self.numberOfRequests++;
        [RIForm getForm:@"review"
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

- (void)finishedRequests
{
    [self setupViews];
    
    [self hideLoading];
    
    [self removeErrorView];
    
    if(RIApiResponseSuccess != self.apiResponse)
    {
        if (RIApiResponseNoInternetConnection == self.apiResponse)
        {
            [self showErrorView:YES startingY:0.0f selector:@selector(ratingsRequests) objects:nil];
        }
        else
        {
            [self showErrorView:NO startingY:0.0f selector:@selector(ratingsRequests) objects:nil];
        }
    }
    
    self.requestsDone = YES;
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setObject:self.product.sku forKey:kRIEventSkuKey];
    [trackingDictionary setObject:self.product.brand forKey:kRIEventBrandKey];
    [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
    
    NSNumber *price = (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue] > 0.0f) ? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;
    [trackingDictionary setValue:price forKey:kRIEventPriceKey];
    
    if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet))
    {
        NSArray *categoryIds = [self.product.categoryIds array];
        NSInteger subCategoryIndex = [categoryIds count] - 1;
        NSInteger categoryIndex = subCategoryIndex - 1;
        
        if(categoryIndex >= 0)
        {
            NSString *categoryId = [categoryIds objectAtIndex:categoryIndex];
            [trackingDictionary setValue:[RICategory getCategoryName:categoryId] forKey:kRIEventCategoryNameKey];
            
            NSString *subCategoryId = [categoryIds objectAtIndex:subCategoryIndex];
            [trackingDictionary setValue:[RICategory getCategoryName:subCategoryId] forKey:kRIEventSubCategoryNameKey];
        }
        else
        {
            NSString *categoryId = [categoryIds objectAtIndex:subCategoryIndex];
            [trackingDictionary setValue:[RICategory getCategoryName:categoryId] forKey:kRIEventCategoryNameKey];
        }
    }
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewRatings] data:trackingDictionary];
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
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
    _hasComments = NO;
    
    if(VALID_NOTEMPTY(self.productRatings, RIProductRatings) && VALID_NOTEMPTY(self.productRatings.reviews, NSArray))
    {
        _hasComments = YES;
    }
    
    if (VALID_NOTEMPTY(self.ratingsForm, RIForm)) {
        self.isShowingRating = YES;
    } else {
        self.isShowingRating = NO;
    }
    
    [self setupTopView];
    
    self.contentScrollView.x = 0.f;
    self.contentScrollView.y = self.topView.frame.size.height + kVerticalMargin;
    self.contentScrollView.width = self.view.width;
    self.contentScrollView.height = self.view.height - self.contentScrollView.y;
    _viewsWidth = self.view.frame.size.width - (2 * kHorizontalMargin);
    
    BOOL ipadLandscape = NO;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        [self.resumeView setHidden:YES];
        [self setupSendReviewView:self.view.width/2 originY:CGRectGetMaxY(self.topView.frame) + kVerticalMargin];
        [self.writeReviewScrollView setHidden:NO];
        ipadLandscape = YES;
    }else{
        [self.resumeView setHidden:NO];
        [self.writeReviewScrollView setHidden:YES];
        [self setupResumeView];
    }
    
    self.tableViewComments.layer.cornerRadius = 5.0f;
    self.tableViewComments.allowsSelection = NO;
    
    CGFloat startingYForContent = CGRectGetMaxY(self.resumeView.frame) + kVerticalMargin;
    
    if (NO == [[RICountryConfiguration getCurrentConfiguration].ratingIsEnabled boolValue] &&
        NO == [[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
        
        [self.resumeView setHidden:YES];
        startingYForContent = self.resumeView.frame.origin.y;
        _reviewsEnabled = NO;
    } else {
        _reviewsEnabled = YES;
    }
    
    if(_hasComments)
    {
        [self.tableViewComments setX:kHorizontalMargin];
        if (!self.writeReviewScrollView || (self.writeReviewScrollView && self.writeReviewScrollView.hidden)) {
            [self.tableViewComments setWidth:self.view.width - 2*kHorizontalMargin];
        }else {
            [self.tableViewComments setWidth:self.view.width/2 - kHorizontalMargin - 3.f];
        }
        
        if (!_reviewsEnabled || ipadLandscape) {
            [self.tableViewComments setY:self.resumeView.y];
        }else{
            [self.tableViewComments setY:CGRectGetMaxY(self.resumeView.frame) + kVerticalMargin];
        }
        [self.tableViewComments setHeight:self.view.bounds.size.height - self.contentScrollView.y - self.tableViewComments.y - kVerticalMargin];
        
        [self.tableViewComments setHidden:NO];
        [self.emptyReviewsView setHidden:YES];
    }
    else
    {
        [self.tableViewComments setHidden:YES];
        [self.emptyReviewsView setHidden:NO];
        [self setupEmptyReviewsView];
    }
    
    self.tableViewComments.delegate = self;
    self.tableViewComments.dataSource = self;
    
    [self.tableViewComments reloadData];
    
    if (RI_IS_RTL)
    {
        [self.view flipAllSubviews];
    }
    
    self.writeReviewScrollViewInitialRect = self.writeReviewScrollView.frame;
    [self.view bringSubviewToFront:self.tableViewComments];
}

- (void)setupTopView
{
    _topViewHeight = self.topView.frame.size.height;
    _ratingTypeLinesHeight = -self.nameLabel.bounds.size.height;
    
    CGRect topViewFrame = self.topView.frame;
    topViewFrame.size.width = [self.view bounds].size.width;
    topViewFrame.size.height = _topViewHeight;
    self.topView.frame = topViewFrame;
    
    CGRect brandLabelFrame = self.brandLabel.frame;
    brandLabelFrame.origin.x = 2*kHorizontalMargin;
    brandLabelFrame.size.width = topViewFrame.size.width - 4*kHorizontalMargin;
    self.brandLabel.frame = brandLabelFrame;
    [self.brandLabel sizeToFit];
    
    CGRect nameLabelFrame = self.nameLabel.frame;
    nameLabelFrame.origin.x = 2*kHorizontalMargin;
    nameLabelFrame.size.width = topViewFrame.size.width - 4*kHorizontalMargin;
    self.nameLabel.frame = nameLabelFrame;
    [self.nameLabel sizeToFit];
    _ratingTypeLinesHeight += self.nameLabel.bounds.size.height;
    
    if (RI_IS_RTL)
        [self.nameLabel setTextAlignment:NSTextAlignmentRight];
    
    if(VALID(self.priceView, JAPriceView))
    {
        [self.priceView removeFromSuperview];
    }
    
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:self.product.priceFormatted
                     specialPrice:self.product.specialPriceFormatted
                         fontSize:14.0f
            specialPriceOnTheLeft:NO];
    
    self.priceView.frame = CGRectMake(12.0f,
                                      CGRectGetMaxY(self.nameLabel.frame) + 4.0f,
                                      self.topView.bounds.size.width - 24.0f,
                                      self.priceView.frame.size.height);
    
    [self.topView addSubview:self.priceView];
    
    CGFloat topViewMinHeight = CGRectGetMaxY(self.priceView.frame);
    
    if (VALID_NOTEMPTY(self.ratingStars, NSMutableArray)) {
        for (UIView* view in self.ratingStars) {
            [view removeFromSuperview];
        }
    }
    
    if (VALID_NOTEMPTY(self.ratingStarLabels, NSMutableArray)) {
        for (UIView* view in self.ratingStarLabels) {
            [view removeFromSuperview];
        }
    }
    
    self.ratingStars = [NSMutableArray new];
    self.ratingStarLabels = [NSMutableArray new];
    
    NSInteger numberOfItemsSideBySide = 3;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        numberOfItemsSideBySide = 7;
    }
    
    topViewMinHeight += 6.0f;
    
    CGFloat ratingViewWidth = (self.topView.frame.size.width - 2*kHorizontalMargin) / numberOfItemsSideBySide;
    
    CGFloat currentX = 2*kHorizontalMargin;
    
    if (ISEMPTY(self.productRatings.ratingInfo.averageRatingsArray)) {
        UILabel* titleLabel = [UILabel new];
        [titleLabel setTextColor:UIColorFromRGB(0x666666)];
        [titleLabel setFont:[UIFont fontWithName:kFontLightName size:12.0f]];
        [titleLabel setText:@" "];
        [titleLabel sizeToFit];
        [titleLabel setFrame:CGRectMake(currentX,
                                        topViewMinHeight,
                                        ratingViewWidth,
                                        titleLabel.frame.size.height)];
        [self.topView addSubview:titleLabel];
        
        [self.ratingStarLabels addObject:titleLabel];
        
        JARatingsViewMedium* ratingsView = [JARatingsViewMedium getNewJARatingsViewMedium];
        [ratingsView setRating:0];
        [ratingsView setFrame:CGRectMake(2*kHorizontalMargin,
                                     topViewMinHeight + titleLabel.frame.size.height,
                                     ratingsView.frame.size.width,
                                     ratingsView.frame.size.height)];
        [self.topView addSubview:ratingsView];
        [self.ratingStars addObject:ratingsView];
        
        topViewMinHeight += titleLabel.frame.size.height + ratingsView.frame.size.height;
    } else {
        for (int i = 0; i < self.productRatings.ratingInfo.averageRatingsArray.count; i++) {
            
            NSString* title = [self.productRatings.ratingInfo.typesArray objectAtIndex:i];
            
            UILabel* titleLabel = [UILabel new];
            [titleLabel setTextColor:UIColorFromRGB(0x666666)];
            [titleLabel setFont:[UIFont fontWithName:kFontLightName size:12.0f]];
            [titleLabel setText:title];
            [titleLabel sizeToFit];
            
            [titleLabel setFrame:CGRectMake(currentX,
                                            topViewMinHeight,
                                            ratingViewWidth - 12,
                                            titleLabel.frame.size.height)];
            
            [self.topView addSubview:titleLabel];
            
            [self.ratingStarLabels addObject:titleLabel];
            
            NSNumber* average = [self.productRatings.ratingInfo.averageRatingsArray objectAtIndex:i];
            
            
            JARatingsViewMedium* ratingsView = [JARatingsViewMedium getNewJARatingsViewMedium];
            [ratingsView setRating:[average integerValue]];
            
            [ratingsView setFrame:CGRectMake(currentX,
                                             topViewMinHeight + titleLabel.frame.size.height,
                                             ratingsView.frame.size.width,
                                             ratingsView.frame.size.height)];
            
            [self.topView addSubview:ratingsView];
            
            [self.ratingStars addObject:ratingsView];
            
            currentX += ratingViewWidth;
            
            NSInteger nextIndex = i+1;
            if (nextIndex < self.productRatings.ratingInfo.averageRatingsArray.count) {
                if (0 == nextIndex%numberOfItemsSideBySide) {
                        currentX = 2*kHorizontalMargin;
                    if (0 != nextIndex) {
                        topViewMinHeight += titleLabel.frame.size.height + ratingsView.frame.size.height;
                        _ratingTypeLinesHeight += titleLabel.frame.size.height + ratingsView.frame.size.height;
                    }
                    
                    
                }
            }
        }
    }
    
    topViewFrame = self.topView.frame;
    topViewFrame.size.height += _ratingTypeLinesHeight;
    self.topView.frame = topViewFrame;
    
    [self.topView sizeToFit];
    
    if(topViewMinHeight < 38.0f)
    {
        topViewMinHeight = 38.0f;
    }
    topViewMinHeight += 6.0f;
    
    [self.topView setHidden:NO];
}

-(void)addReviewsToTable:(NSArray *)reviews
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


-(void)requestReviews
{
    NSInteger currentPage = 0;
    if(VALID_NOTEMPTY(self.productRatings, RIProductRatings))
    {
        if([self.productRatings.currentPage integerValue] == [self.productRatings.totalPages integerValue])
        {
            self.loadedEverything = YES;
            return;
        }
        
        currentPage = [self.productRatings.currentPage integerValue] + 1;
    }
    
    [self showLoading];
    [RIProductRatings getRatingsForProductWithUrl:self.product.url
                                      allowRating:1
                                       pageNumber:currentPage
                                     successBlock:^(RIProductRatings *ratings) {
                                         
                                         self.productRatings = ratings;
                                         
                                         [self removeErrorView];
                                         
                                         if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
                                         {
                                             [self ratingsRequests];
                                         }
                                         else
                                         {
                                             self.numberOfRequests = 0;
                                         }
                                         
                                         
                                         [self addReviewsToTable:self.productRatings.reviews];
                                         
                                         [self hideLoading];
                                         
                                     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                         
                                         if(RIApiResponseSuccess != self.apiResponse)
                                         {
                                             if (RIApiResponseNoInternetConnection == self.apiResponse)
                                             {
                                                 [self showErrorView:YES startingY:0.0f selector:@selector(requestReviews) objects:nil];
                                             }
                                             else
                                             {
                                                 [self showErrorView:NO startingY:0.0f selector:@selector(requestReviews) objects:nil];
                                             }
                                         }
                                         self.numberOfRequests = 0;
                                         [self hideLoading];
                                     }];

}

- (void)setupResumeView
{
    
    if (NO == [[RICountryConfiguration getCurrentConfiguration].ratingIsEnabled boolValue] &&
        NO == [[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {

        [self.labelUsedProduct setHidden:YES];
        [self.writeReviewButton setHidden:YES];
        _reviewsEnabled = NO;
    } else {
        _reviewsEnabled = YES;
        self.labelUsedProduct.text = STRING_RATE_PRODUCT;
        [self.labelUsedProduct setTextColor:UIColorFromRGB(0x666666)];
        
        if (RI_IS_RTL) {
            [self.labelUsedProduct setTextAlignment:NSTextAlignmentRight];
        }
        
        [self.writeReviewButton setTitle:STRING_WRITE_REVIEW
                                forState:UIControlStateNormal];
        [self.writeReviewButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                                     forState:UIControlStateNormal];
        
    }
    
    self.resumeView.layer.cornerRadius = 5.0f;
    
    CGRect resumeViewFrame = self.resumeView.frame;
    resumeViewFrame.origin.x = kHorizontalMargin;
    resumeViewFrame.size.width = self.view.bounds.size.width - 2*kHorizontalMargin;
    resumeViewFrame.origin.y = CGRectGetMaxY(self.topView.frame) + kVerticalMargin;
    if (self.contentScrollView) {
        resumeViewFrame.origin.y = 0.f;
    }
    self.resumeView.frame = resumeViewFrame;
    
    [self.labelUsedProduct setX:kHorizontalMargin];
    [self.labelUsedProduct sizeToFit];
    
    [self.writeReviewButton setX:self.view.bounds.size.width/2 - self.writeReviewButton.bounds.size.width/2];
    
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
    CGFloat horizontalMargin = 3.0f;
    
    if (!self.writeReviewScrollView) {
        self.writeReviewScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(width + horizontalMargin,
                                                                                    originY,
                                                                                    width - 3*horizontalMargin,
                                                                                    self.view.frame.size.height - originY)];
        [self.view addSubview:self.writeReviewScrollView];
    }
    [self.writeReviewScrollView setFrame:CGRectMake(width + horizontalMargin,
                                                   originY,
                                                   width - 3*horizontalMargin,
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
    self.fixedLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
    self.fixedLabel.text = STRING_RATE_PRODUCT;
    self.fixedLabel.textColor = UIColorFromRGB(0x666666);
    
    [self.centerView addSubview:self.fixedLabel];
    
    CGFloat currentY = CGRectGetMaxY(self.fixedLabel.frame) + 12.0f;
    CGFloat spaceBetweenFormFields = 6.0f;
    
    if (self.ratingsForm) {
        NSInteger count = 0;
        CGFloat initialContentY = 0;
        self.ratingsDynamicForm = [[JADynamicForm alloc] initWithForm:self.ratingsForm
                                                     startingPosition:initialContentY
                                                            widthSize:width
                                                   hasFieldNavigation:YES];
        self.ratingsContentView = [UIView new];
        for (UIView *view in self.ratingsDynamicForm.formViews)
        {
            view.tag = count;
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
            
            [self.ratingsContentView addSubview:view];
            initialContentY += view.frame.size.height + spaceBetweenFormFields;
            count++;
        }
        [self.ratingsContentView setFrame:CGRectMake(0.0,
                                                     currentY,
                                                     width,
                                                     initialContentY)];
        [self.centerView addSubview:self.ratingsContentView];
    }
    
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
            if (NO == [view isKindOfClass:[JAAddRatingView class]]) {
                if (VALID_NOTEMPTY(self.ratingsForm, RIForm) && VALID_NOTEMPTY(self.reviewsForm, RIForm)) {
                    //has switch
                    frame.origin.y = frame.origin.y + kDistanceBetweenStarsAndText;
                }
            }
            view.frame = frame;
            
            [self.reviewsContentView addSubview:view];
            
            initialContentY += view.frame.size.height + spaceBetweenFormFields;
        }
        if (VALID_NOTEMPTY(self.ratingsForm, RIForm) && VALID_NOTEMPTY(self.reviewsForm, RIForm)) {
            //has switch
            initialContentY += kDistanceBetweenStarsAndText;
        }
        [self.reviewsContentView setFrame:CGRectMake(0.0,
                                                     currentY,
                                                     width,
                                                     initialContentY)];
        [self.centerView addSubview:self.reviewsContentView];
    }
    
    
    if (self.isShowingRating && VALID_NOTEMPTY(self.ratingsContentView, UIView)) {
        self.reviewsContentView.hidden = YES;
        currentY += self.ratingsContentView.frame.size.height;
    } else if (NO == self.isShowingRating && VALID_NOTEMPTY(self.reviewsContentView, UIView)){
        self.ratingsContentView.hidden = NO;
        currentY += self.reviewsContentView.frame.size.height;
    }
    
    if (VALID_NOTEMPTY(self.ratingsForm, RIForm) && VALID_NOTEMPTY(self.reviewsForm, RIForm)) {
        //show the switch
        self.modeSwitch = [UISwitch new];
        [self.modeSwitch addTarget:self action:@selector(switchBetweenModes) forControlEvents:UIControlEventTouchUpInside];
        CGFloat modeSwitchX = 10.0f;
        if (isiPad) {
            modeSwitchX = 75.0f;
        }
        [self.modeSwitch setFrame:CGRectMake(modeSwitchX, currentY, self.modeSwitch.frame.size.width, self.modeSwitch.frame.size.height)];
        [self.centerView addSubview:self.modeSwitch];
        
        CGFloat writeReviewLabelX = CGRectGetMaxX(self.modeSwitch.frame) + 15.0f;
        CGFloat maxWriteReviewWidth = width - writeReviewLabelX;
        UILabel* writeReviewLabel = [UILabel new];
        writeReviewLabel.textColor = UIColorFromRGB(0x666666);
        writeReviewLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
        writeReviewLabel.numberOfLines = 2;
        writeReviewLabel.text = STRING_WRITE_FULL_REVIEW;
        [writeReviewLabel sizeToFit];
        CGFloat finalWidth = writeReviewLabel.frame.size.width;
        CGFloat finalHeight = writeReviewLabel.frame.size.height;
        CGFloat yOffset = 5.0f;
        if (maxWriteReviewWidth < writeReviewLabel.frame.size.width) {
            finalWidth = maxWriteReviewWidth;
            finalHeight *= 2;
            yOffset = 0.0f;
        }
        [writeReviewLabel setFrame:CGRectMake(writeReviewLabelX,
                                              self.modeSwitch.frame.origin.y + yOffset,
                                              finalWidth,
                                              finalHeight)];
        [self.centerView addSubview:writeReviewLabel];
        
        currentY += self.modeSwitch.frame.size.height + 50.0f;
    } else {
        // Add space between last form field and send review button
        currentY += 38.0f;
    }
    
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
                                         self.writeReviewScrollView.width,
                                         CGRectGetMaxY(self.sendReviewButton.frame) + verticalMargin)];
    [self.writeReviewScrollView addSubview:self.centerView];
    [self.writeReviewScrollView setContentSize:CGSizeMake(self.writeReviewScrollView.frame.size.width, currentY)];
    
    [self.view bringSubviewToFront:self.writeReviewScrollView];
}

- (void) setupEmptyReviewsView
{
    BOOL ipadLandscape = NO;
    CGFloat width = self.view.bounds.size.width/2 - kHorizontalMargin - 3.f;
    if (!self.writeReviewScrollView || (self.writeReviewScrollView && self.writeReviewScrollView.hidden)) {
        width = self.view.bounds.size.width - kHorizontalMargin - 6.f;
        ipadLandscape = YES;
    }
    
    self.emptyReviewsView.layer.cornerRadius = 5.0f;
    
    [self.emptyReviewsView setX:kHorizontalMargin];
    [self.emptyReviewsView setY:kVerticalMargin];
    [self.emptyReviewsView setWidth:width];
    
    if (ipadLandscape || !_reviewsEnabled) {
        [self.emptyReviewsView setY:CGRectGetMaxY(self.resumeView.frame) + kVerticalMargin];
    }else{
        [self.emptyReviewsView setY:self.emptyReviewsView.y = self.resumeView.y];
    }
    
    [self.emptyReviewsLabel setText:STRING_REVIEWS_EMPTY];
    [self.emptyReviewsLabel sizeToFit];
    [self.emptyReviewsLabel setTextColor:UIColorFromRGB(0xcccccc)];
    
    CGRect emptyReviewsLabelFrame = self.emptyReviewsLabel.frame;
    emptyReviewsLabelFrame.origin.x = width/2 - emptyReviewsLabelFrame.size.width/2;
    [self.emptyReviewsLabel setFrame:emptyReviewsLabelFrame];
    
    CGRect emptyReviewsImageViewFrame = self.emptyReviewsImageView.frame;
    emptyReviewsImageViewFrame.origin.x = width/2 - emptyReviewsImageViewFrame.size.width/2;
    [self.emptyReviewsImageView setFrame:emptyReviewsImageViewFrame];
    
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
    
    if(VALID_NOTEMPTY(self.productRatings, RIProductRatings))
    {
        [userInfo setObject:self.productRatings forKey:@"productRatings"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowNewRatingScreenNotification object:nil userInfo:userInfo];
}

#pragma mark - Tableview methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.reviewsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RIReview* review = [self.reviewsArray objectAtIndex:indexPath.row];
    return [JAReviewCell cellHeightWithReview:review width:self.tableViewComments.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell"];
    
    if (!cell) {
        cell = [[JAReviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reviewCell"];
    }
    
    if((indexPath.row == ([self.reviewsArray count] - 1)) && (!self.loadedEverything))
    {
        [self requestReviews];
    }


    RIReview* review = [self.reviewsArray objectAtIndex:indexPath.row];

    BOOL showSeparator = YES;
    if(indexPath.row == ([self.reviewsArray count] - 1))
    {
        showSeparator = NO;
    }
    
    [cell setupWithReview:review width:self.tableViewComments.frame.size.width showSeparator:showSeparator];
    
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
    
    [self.ratingsDynamicForm resignResponder];
    [self.reviewsDynamicForm resignResponder];
        
    RIForm* currentForm;
    JADynamicForm* currentDynamicForm;
    if (self.isShowingRating) {
        currentForm = self.ratingsForm;
        currentDynamicForm = self.ratingsDynamicForm;
        if ([[RICountryConfiguration getCurrentConfiguration].ratingRequiresLogin boolValue] && NO == [RICustomer checkIfUserIsLogged]) {
            [self hideLoading];
            [self showMessage:STRING_LOGIN_TO_RATE success:NO];
            return;
        }
    } else {
        currentForm = self.reviewsForm;
        currentDynamicForm = self.reviewsDynamicForm;
        if ([[RICountryConfiguration getCurrentConfiguration].reviewRequiresLogin boolValue] && NO == [RICustomer checkIfUserIsLogged]) {
            [self hideLoading];
            [self showMessage:STRING_LOGIN_TO_REVIEW success:NO];
            return;
        }
    }
    
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[currentDynamicForm getValues]];
    
    [parameters addEntriesFromDictionary:@{@"rating-customer": [RICustomer getCustomerId]}];
    NSString* skuKey = [currentDynamicForm getFieldNameForKey:@"sku"];
    [parameters addEntriesFromDictionary:@{skuKey: self.product.sku}];
    
    [RIForm sendForm:currentForm
          parameters:parameters
        successBlock:^(id object) {
            
            NSNumber *price = (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue] > 0.0f) ? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;
            
            NSMutableDictionary *globalRateDictionary = [[NSMutableDictionary alloc] init];
            [globalRateDictionary setObject:self.product.sku forKey:kRIEventSkuKey];
            [globalRateDictionary setObject:self.product.brand forKey:kRIEventBrandKey];
            [globalRateDictionary setValue:price forKey:kRIEventPriceKey];
            
            for (UIView *component in currentDynamicForm.formViews)
            {
                if ([component isKindOfClass:[JAAddRatingView class]]) {
                    
                    JAAddRatingView* ratingView = (JAAddRatingView*)component;
                    
                    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                    [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
                    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                    [trackingDictionary setValue:@(ratingView.rating) forKey:kRIEventValueKey];
                    
                    if ([ratingView.fieldRatingStars.type isEqualToString:@"1"])
                    {
                        [globalRateDictionary setValue:[NSNumber numberWithInteger:ratingView.rating] forKey:kRIEventRatingPriceKey];
                        [trackingDictionary setValue:@"RateProductPrice" forKey:kRIEventActionKey];
                    }
                    else if ([ratingView.fieldRatingStars.type isEqualToString:@"2"])
                    {
                        [globalRateDictionary setValue:[NSNumber numberWithInteger:ratingView.rating] forKey:kRIEventRatingAppearanceKey];
                        [trackingDictionary setValue:@"RateProductAppearance" forKey:kRIEventActionKey];
                    }
                    else if ([ratingView.fieldRatingStars.type isEqualToString:@"3"])
                    {
                        [globalRateDictionary setValue:[NSNumber numberWithInteger:ratingView.rating] forKey:kRIEventRatingQualityKey];
                        [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
                    }
                    else
                    {
                        // There is no indication about the default tracking for rating
                        [globalRateDictionary setValue:[NSNumber numberWithInteger:ratingView.rating] forKey:kRIEventRatingKey];
                        [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
                    }
                    
                    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                    [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
                    
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRateProduct]
                                                              data:[trackingDictionary copy]];
                    
                    float value = [@(ratingView.rating) floatValue];
                    [FBAppEvents logEvent:FBAppEventNameRated
                               valueToSum:value
                               parameters:@{FBAppEventParameterNameContentType: self.product.name,
                                            FBAppEventParameterNameContentID: self.product.sku,
                                            FBAppEventParameterNameMaxRatingValue: @5 }];
                }
            }
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRateProductGlobal]
                                                      data:[globalRateDictionary copy]];
            
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

#pragma mark - Switch

- (void)switchBetweenModes
{
    [self.reviewsDynamicForm resignResponder];
    [self.ratingsDynamicForm resignResponder];
    
    for (int i = 0; i < self.ratingsDynamicForm.formViews.count; i++) {
        JAAddRatingView* ratingView = [self.ratingsDynamicForm.formViews objectAtIndex:i];
        JAAddRatingView* reviewView = [self.reviewsDynamicForm.formViews objectAtIndex:i];
        
        if (VALID_NOTEMPTY(ratingView, JAAddRatingView) && VALID_NOTEMPTY(reviewView, JAAddRatingView)) {
            if (self.isShowingRating) {
                reviewView.rating = ratingView.rating;
            } else {
                ratingView.rating = reviewView.rating;
            }
        }
    }
    
    self.isShowingRating = !self.isShowingRating;
    
    CGFloat difference = self.ratingsContentView.frame.size.height - self.reviewsContentView.frame.size.height + kDistanceBetweenStarsAndText;
    if (self.isShowingRating) {
        self.ratingsContentView.hidden = NO;
        self.reviewsContentView.hidden = YES;
    } else {
        difference = -difference;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.sendReviewButton setFrame:CGRectMake(self.sendReviewButton.frame.origin.x,
                                                   self.sendReviewButton.frame.origin.y + difference,
                                                   self.sendReviewButton.frame.size.width,
                                                   self.sendReviewButton.frame.size.height)];
        [self.centerView setFrame:CGRectMake(self.centerView.frame.origin.x,
                                             self.centerView.frame.origin.y,
                                             self.centerView.frame.size.width,
                                             self.centerView.frame.size.height + difference)];
        self.writeReviewScrollView.contentSize = CGSizeMake(self.writeReviewScrollView.frame.size.width,
                                                            self.centerView.frame.size.height + self.centerView.frame.origin.y);
    } completion:^(BOOL finished) {
        //do this only after animation
        if (NO == self.isShowingRating) {
            self.ratingsContentView.hidden = YES;
            self.reviewsContentView.hidden = NO;
        }
    }];
}

-(void)hideKeyboards
{
    [self.reviewsDynamicForm resignResponder];
}


@end

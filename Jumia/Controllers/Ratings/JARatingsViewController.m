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

@interface JARatingsViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
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
@property (weak, nonatomic) IBOutlet UIScrollView *writeReviewScrollView;
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

@end

@implementation JARatingsViewController

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
        self.screenName = [NSString stringWithFormat:@"RatingScreen / %@", self.product.sku];
    }
    else
    {
        self.screenName = @"RatingScreen";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.topView.translatesAutoresizingMaskIntoConstraints = YES;
    self.brandLabel.text = self.product.brand;
    self.brandLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.nameLabel.text = self.product.name;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.resumeView.translatesAutoresizingMaskIntoConstraints = YES;
    self.tableViewComments.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.tableViewComments.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.requestsDone = NO;
    
    self.apiResponse = RIApiResponseSuccess;
    
    if(VALID_NOTEMPTY(self.writeReviewScrollView, UIScrollView))
    {
        self.writeReviewScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    if(VALID_NOTEMPTY(self.emptyReviewsView, UIView))
    {
        self.emptyReviewsView.translatesAutoresizingMaskIntoConstraints = YES;
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
    
    if(self.requestsDone)
    {
        [self setupViews];
    }
    else
    {
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
        {
            [self ratingsRequests];
        }
        else
        {
            self.numberOfRequests = 0;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    [self hideViews];
    
    [self.reviewsDynamicForm resignResponder];
    [self.ratingsDynamicForm resignResponder];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self hideLoading];
    
    [self setupViews];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
    
    if(RIApiResponseSuccess != self.apiResponse)
    {
        if (RIApiResponseNoInternetConnection == self.apiResponse)
        {
            [self showMessage:STRING_NO_CONNECTION success:NO];
        }
        else
        {
            [self showMessage:STRING_ERROR success:NO];
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
    
    if(VALID_NOTEMPTY(self.productRatings, RIProductRatings) && VALID_NOTEMPTY(self.productRatings.reviews, NSArray))
    {
        hasComments = YES;
    }
    
    if (VALID_NOTEMPTY(self.ratingsForm, RIForm)) {
        self.isShowingRating = YES;
    } else {
        self.isShowingRating = NO;
    }
    
    [self setupTopView];
    
    CGFloat viewsWidth = self.view.frame.size.width - (2 * horizontalMargin);
    
    if(!isiPad || !isInLandscape)
    {
        [self setupResumeView:viewsWidth];
    }
    
    CGFloat originY = CGRectGetMaxY(self.resumeView.frame) + verticalMargin;
    self.tableViewComments.layer.cornerRadius = 5.0f;
    self.tableViewComments.allowsSelection = NO;
    
    if(isInLandscape)
    {
        [self.resumeView setHidden:YES];
        [self.writeReviewScrollView setHidden:NO];
        
        originY = CGRectGetMaxY(self.topView.frame) + verticalMargin;
        
        
        CGFloat rightSideViewsWidth = 0.0f;
        
        if (NO == [[RICountryConfiguration getCurrentConfiguration].ratingIsEnabled boolValue] &&
            NO == [[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
            
            //keep them the same
            
        } else {
            
            // The 18.0f pixeis are the left, middle and right margins
            viewsWidth = ((self.view.frame.size.width - 18.0f) / 2);
            rightSideViewsWidth = viewsWidth;
        }
        
        [self.tableViewComments setFrame:CGRectMake(horizontalMargin,
                                                    originY,
                                                    viewsWidth,
                                                    self.view.frame.size.height - originY - verticalMargin)];
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
        
        if (NO == [[RICountryConfiguration getCurrentConfiguration].ratingIsEnabled boolValue] &&
            NO == [[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
            
            [self.resumeView setHidden:YES];
            startingYForContent = self.resumeView.frame.origin.y;
        } else {
            [self.resumeView setHidden:NO];
        }
        
        [self.writeReviewScrollView setHidden:YES];
        
        if(hasComments)
        {
            [self.tableViewComments setFrame:CGRectMake(verticalMargin,
                                                        startingYForContent,
                                                        viewsWidth,
                                                        self.view.frame.size.height - startingYForContent - verticalMargin)];
            [self.tableViewComments setHidden:NO];
            [self.emptyReviewsView setHidden:YES];
        }
        else
        {
            [self.tableViewComments setHidden:YES];
            [self.emptyReviewsView setHidden:NO];
            [self setupEmptyReviewsView:viewsWidth originY:startingYForContent];
        }
    }
    
    [self.tableViewComments reloadData];
}

- (void)setupTopView
{
    [self.brandLabel setFrame:CGRectMake(12.0f,
                                         6.0f,
                                         self.view.frame.size.width - 24.0f,
                                         self.view.frame.size.height)];
    [self.brandLabel sizeToFit];
    
    [self.nameLabel setFrame:CGRectMake(12.0f,
                                        CGRectGetMaxY(self.brandLabel.frame) + 6.0f,
                                        self.view.frame.size.width - 24.0f,
                                        self.view.frame.size.height)];
    [self.nameLabel sizeToFit];
    
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
                                      self.priceView.frame.size.width,
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
        if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation || UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)
        {
            numberOfItemsSideBySide = 7;
        }
    }
    
    topViewMinHeight += 6.0f;
    
    CGFloat currentX = 12.0f;
    CGFloat ratingViewWidth = (self.view.frame.size.width - 6.0f*2) / numberOfItemsSideBySide;
    
    if (ISEMPTY(self.productRatings.ratingInfo.averageRatingsArray)) {
        UILabel* titleLabel = [UILabel new];
        [titleLabel setTextColor:UIColorFromRGB(0x666666)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
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
        [ratingsView setFrame:CGRectMake(currentX,
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
            [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
            [titleLabel setText:title];
            [titleLabel sizeToFit];
            [titleLabel setFrame:CGRectMake(currentX,
                                            topViewMinHeight,
                                            ratingViewWidth,
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
                    currentX = 6.0f;
                    if (0 != nextIndex) {
                        topViewMinHeight += titleLabel.frame.size.height + ratingsView.frame.size.height;
                    }
                }
            } else {
                topViewMinHeight += 20.0f + ratingsView.frame.size.height;
            }
        }
    }
    
    if(topViewMinHeight < 38.0f)
    {
        topViewMinHeight = 38.0f;
    }
    topViewMinHeight += 6.0f;
    
    [self.topView setFrame:CGRectMake(0.0f,
                                      0.0f,
                                      self.view.frame.size.width,
                                      topViewMinHeight)];
    [self.topView setHidden:NO];
}

- (void)setupResumeView:(CGFloat)width
{
    CGFloat currentY = 6.0f;
    
    if (NO == [[RICountryConfiguration getCurrentConfiguration].ratingIsEnabled boolValue] &&
        NO == [[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {

        [self.labelUsedProduct removeFromSuperview];
        [self.writeReviewButton removeFromSuperview];
    } else {
        self.labelUsedProduct.text = STRING_RATE_PRODUCT;
        [self.labelUsedProduct setTextColor:UIColorFromRGB(0x666666)];
        self.labelUsedProduct.translatesAutoresizingMaskIntoConstraints = YES;
        [self.labelUsedProduct setFrame:CGRectMake(self.labelUsedProduct.frame.origin.x,
                                                   currentY,
                                                   self.labelUsedProduct.frame.size.width,
                                                   self.labelUsedProduct.frame.size.height)];
        [self.writeReviewButton setTitle:STRING_WRITE_REVIEW
                                forState:UIControlStateNormal];
        [self.writeReviewButton sizeToFit];
        [self.writeReviewButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                                     forState:UIControlStateNormal];
        
        currentY += self.labelUsedProduct.frame.size.height + self.writeReviewButton.frame.size.height;
    }
    
    self.resumeView.layer.cornerRadius = 5.0f;
    [self.resumeView setFrame:CGRectMake(6.0f,
                                         CGRectGetMaxY(self.topView.frame) + 6.0f,
                                         width,
                                         currentY + 20.0f)];
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
    self.writeReviewScrollViewInitialRect = CGRectMake(width + horizontalMargin,
                                                       originY,
                                                       width,
                                                       self.view.frame.size.height - originY);
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
    self.fixedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    self.fixedLabel.text = STRING_RATE_PRODUCT;
    self.fixedLabel.textColor = UIColorFromRGB(0x666666);
    
    [self.centerView addSubview:self.fixedLabel];
    
    CGFloat currentY = CGRectGetMaxY(self.fixedLabel.frame) + 12.0f;
    CGFloat spaceBetweenFormFields = 6.0f;
    
    if (self.ratingsForm) {
        NSInteger count = 0;
        CGFloat initialContentY = 0;
        self.ratingsDynamicForm = [[JADynamicForm alloc] initWithForm:self.ratingsForm
                                                             delegate:nil
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
                                                             delegate:nil
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
        writeReviewLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:13.0f];
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
    self.sendReviewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
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
    self.emptyReviewsView.translatesAutoresizingMaskIntoConstraints = YES;
    self.emptyReviewsImageView.translatesAutoresizingMaskIntoConstraints = YES;
    self.emptyReviewsLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    CGFloat horizontalMargin = 6.0f;
    CGFloat totalHeight = 6.0f;
    
    self.emptyReviewsView.layer.cornerRadius = 5.0f;
    [self.emptyReviewsView setFrame:CGRectMake(horizontalMargin,
                                               originY,
                                               width,
                                               self.centerView.frame.size.height)];
    
    [self.emptyReviewsLabel setText:STRING_REVIEWS_EMPTY];
    [self.emptyReviewsLabel sizeToFit];
    [self.emptyReviewsLabel setTextColor:UIColorFromRGB(0xcccccc)];
    
    CGFloat marginBetweenImageAndLabel = 30.0f;
    CGFloat componentsHeight = self.emptyReviewsImageView.frame.size.height + marginBetweenImageAndLabel;
    
    CGFloat emptyReviewsLabelHorizontalMargin = 60.0f;
    CGRect emptyReviewsLabelRect = [STRING_REVIEWS_EMPTY boundingRectWithSize:CGSizeMake(width - emptyReviewsLabelHorizontalMargin * 2, (self.emptyReviewsView.frame.size.height - componentsHeight))
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
    return self.productRatings.reviews.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RIReview* review = [self.productRatings.reviews objectAtIndex:indexPath.row];
    return [JAReviewCell cellHeightWithReview:review width:self.tableViewComments.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell"];

    RIReview* review = [self.productRatings.reviews objectAtIndex:indexPath.row];

    BOOL showSeparator = YES;
    if(indexPath.row == ([self.productRatings.reviews count] - 1))
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

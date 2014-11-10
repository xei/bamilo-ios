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
#import "RIRatings.h"
#import "RICustomer.h"
#import "JAUtils.h"

@interface JARatingsViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *resumeView;
@property (weak, nonatomic) JARatingsViewMedium *stars;
@property (weak, nonatomic) IBOutlet UILabel *labelUsedProduct;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewButton;
@property (weak, nonatomic) IBOutlet UITableView *tableViewComments;
@property (nonatomic, strong) JAPriceView *priceView;

// iPad landscape components only
@property (weak, nonatomic) IBOutlet UIView *emptyReviewsView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyReviewsImageView;
@property (weak, nonatomic) IBOutlet UILabel *emptyReviewsLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *writeReviewScrollView;
@property (assign, nonatomic) CGRect writeReviewScrollViewInitialRect;

@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) UILabel *fixedLabel;
@property (strong, nonatomic) UIButton *sendReviewButton;

@property (strong, nonatomic) RIForm *form;
@property (strong, nonatomic) JADynamicForm *ratingDynamicForm;
@property (strong, nonatomic) NSArray *ratings;
@property (strong, nonatomic) NSMutableArray *ratingStarsArray;
@property (assign, nonatomic) NSInteger numberOfFields;

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
    self.resumeView.translatesAutoresizingMaskIntoConstraints = YES;
    self.tableViewComments.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.tableViewComments.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.goToNewRatingButtonPressed = NO;
    self.requestsDone = NO;
    
    if(VALID_NOTEMPTY(self.writeReviewScrollView, UIScrollView))
    {
        self.writeReviewScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    if(VALID_NOTEMPTY(self.emptyReviewsView, UIView))
    {
        self.emptyReviewsView.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    [self hideViews];
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        self.numberOfRequests = 2;
        self.apiResponse = RIApiResponseSuccess;
        
        [self showLoading];
        
        [RIRatings getRatingsWithSuccessBlock:^(NSArray *ratings)
         {
             self.ratings = ratings;
             self.numberOfRequests--;
         } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages)
         {
             self.apiResponse = apiResponse;
             self.numberOfRequests--;
         }];
        
        [RIForm getForm:@"rating"
           successBlock:^(RIForm *form)
         {
             self.form = form;
             self.numberOfRequests--;
         } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
             self.apiResponse = apiResponse;
             self.numberOfRequests--;
         }];
    }
    else
    {
        self.numberOfRequests = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.requestsDone)
    {
        [self setupViews];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self showLoading];
    
    [self hideViews];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self hideLoading];
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && (ISEMPTY(self.productRatings) || ISEMPTY(self.productRatings.comments) || self.goToNewRatingButtonPressed))
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
            
            [userInfo setObject:[NSNumber numberWithBool:self.goToNewRatingButtonPressed] forKey:@"goToNewRatingButtonPressed"];
            [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"animated"];
            
            // if the user has clicked on write review button when it was on portrait we
            // should not pop the last view controller
            [userInfo setObject:[NSNumber numberWithBool:!self.goToNewRatingButtonPressed] forKey:@"popLastViewController"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowNewRatingScreenNotification object:nil userInfo:userInfo];
        }
        else
        {
            // This means that the application made a rotation without going to the new reviews screen.
            // We have to set the goToNewRatingButtonPressed to NO so that the application does not
            // open the new rating screen again
            self.goToNewRatingButtonPressed = NO;
            [self setupViews];
        }
    }
    else
    {
        [self setupViews];
    }
}

- (void)finishedRequests
{
    [self setupViews];
    
    [self hideLoading];
    
    self.requestsDone = YES;
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setObject:self.product.sku forKey:kRIEventSkuKey];
    [trackingDictionary setObject:self.product.brand forKey:kRIEventBrandKey];
    
    NSNumber *price = VALID_NOTEMPTY(self.product.specialPrice, NSNumber) ? self.product.specialPrice : self.product.price;
    [trackingDictionary setValue:[price stringValue] forKey:kRIEventPriceKey];
    
    [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
    
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
    
    if(VALID_NOTEMPTY(self.productRatings, RIProductRatings) && VALID_NOTEMPTY(self.productRatings.comments, NSArray))
    {
        hasComments = YES;
    }
    
    BOOL addNumberOfReviewsInTopView = (isiPad && isInLandscape && hasComments);
    [self setupTopView:addNumberOfReviewsInTopView];
    
    CGFloat viewsWidth = self.view.frame.size.width - (2 * horizontalMargin);
    
    if(!isiPad || !isInLandscape)
    {
        [self setupResumeView:viewsWidth];
    }
    
    CGFloat originY = CGRectGetMaxY(self.resumeView.frame) + verticalMargin;
    self.tableViewComments.layer.cornerRadius = 5.0f;
    self.tableViewComments.allowsSelection = NO;
    
    if(isiPad)
    {
        if(isInLandscape)
        {
            [self.resumeView setHidden:YES];
            [self.writeReviewScrollView setHidden:NO];
            
            originY = CGRectGetMaxY(self.topView.frame) + verticalMargin;
            
            // The 18.0f pixeis are the left, middle and right margins
            viewsWidth = ((self.view.frame.size.width - 18.0f) / 2);
            
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
            
            [self setupSendReviewView:viewsWidth originY:originY];
            
            [self setupEmptyReviewsView:viewsWidth originY:originY];
        }
        else
        {
            [self.resumeView setHidden:NO];
            [self.emptyReviewsView setHidden:YES];
            
            if(hasComments)
            {
                [self.writeReviewScrollView setHidden:YES];
                [self.tableViewComments setFrame:CGRectMake(verticalMargin,
                                                            originY,
                                                            viewsWidth,
                                                            self.view.frame.size.height - originY - verticalMargin)];
                [self.tableViewComments setHidden:NO];
            }
            else
            {
                [self.tableViewComments setHidden:YES];
                [self.writeReviewScrollView setHidden:NO];
            }
        }
    }
    else
    {
        [self.resumeView setHidden:NO];
        
        [self.tableViewComments setFrame:CGRectMake(verticalMargin,
                                                    originY,
                                                    viewsWidth,
                                                    self.view.frame.size.height - originY - verticalMargin)];
        [self.tableViewComments setHidden:NO];
    }
}

- (void)setupTopView:(BOOL)addNumberOfReviewsInTopView
{
    self.brandLabel.text = self.product.brand;
    CGRect brandLabelRect = [self.brandLabel.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 24.0f, self.view.frame.size.height)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{NSFontAttributeName:self.brandLabel.font} context:nil];
    [self.brandLabel setFrame:CGRectMake(12.0f,
                                         6.0f,
                                         brandLabelRect.size.width,
                                         brandLabelRect.size.height)];
    
    self.nameLabel.text = self.product.name;
    CGRect nameLabelRect = [self.nameLabel.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 24.0f, self.view.frame.size.height)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:self.nameLabel.font} context:nil];
    [self.nameLabel setFrame:CGRectMake(12.0f,
                                        CGRectGetMaxY(self.brandLabel.frame) + 6.0f,
                                        nameLabelRect.size.width,
                                        nameLabelRect.size.height)];
    
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
    
    if(VALID_NOTEMPTY(self.stars, JARatingsViewMedium))
    {
        [self.stars removeFromSuperview];
    }
    
    if(addNumberOfReviewsInTopView)
    {
        topViewMinHeight += 6.0f;
        self.stars = [JARatingsViewMedium getNewJARatingsViewMedium];
        [self.stars setFrame:CGRectMake(12.0f,
                                        topViewMinHeight,
                                        self.stars.frame.size.width,
                                        self.stars.frame.size.height)];
        [self.topView addSubview:self.stars];
        [self.stars setRating:[self.product.avr integerValue]];
        [self.stars setNumberOfReviews:self.productRatings.commentsCount];
        topViewMinHeight += self.stars.frame.size.height;
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
    self.resumeView.layer.cornerRadius = 5.0f;
    [self.resumeView setFrame:CGRectMake(6.0f,
                                         CGRectGetMaxY(self.topView.frame) + 6.0f,
                                         width,
                                         self.resumeView.frame.size.height)];
    
    if(VALID_NOTEMPTY(self.stars, JARatingsViewMedium))
    {
        [self.stars removeFromSuperview];
    }
    self.stars = [JARatingsViewMedium getNewJARatingsViewMedium];
    [self.stars setFrame:CGRectMake(6.0f,
                                    10.0f,
                                    self.stars.frame.size.width,
                                    self.stars.frame.size.height)];
    [self.resumeView addSubview:self.stars];
    [self.stars setRating:[self.product.avr integerValue]];
    [self.stars setNumberOfReviews:self.productRatings.commentsCount];
    
    self.labelUsedProduct.text = STRING_RATE_PRODUCT;
    [self.labelUsedProduct setTextColor:UIColorFromRGB(0x666666)];
    self.labelUsedProduct.translatesAutoresizingMaskIntoConstraints = YES;
    [self.labelUsedProduct setFrame:CGRectMake(self.labelUsedProduct.frame.origin.x,
                                               CGRectGetMaxY(self.stars.frame) + 5.0f,
                                               self.labelUsedProduct.frame.size.width,
                                               self.labelUsedProduct.frame.size.height)];
    [self.writeReviewButton setTitle:STRING_WRITE_REVIEW
                            forState:UIControlStateNormal];
    [self.writeReviewButton sizeToFit];
    [self.writeReviewButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                                 forState:UIControlStateNormal];
}

- (void)setupSendReviewView:(CGFloat)width originY:(CGFloat)originY
{
    CGFloat verticalMargin = 6.0f;
    
    // This value is calculated by adding the left and middle margin of the two main views
    CGFloat horizontalMargin = 12.0f;
    [self.writeReviewScrollView setFrame:CGRectMake(width + horizontalMargin,
                                                    originY,
                                                    width,
                                                    self.view.frame.size.height - originY)];
    self.writeReviewScrollViewInitialRect = self.writeReviewScrollView.frame;
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
    
    self.numberOfFields = 0;
    self.ratingStarsArray = [NSMutableArray new];
    
    CGFloat currentY = CGRectGetMaxY(self.fixedLabel.frame) + 12.0f;
    for (RIRatingsDetails *option in self.ratings)
    {
        JAAddRatingView *stars = [JAAddRatingView getNewJAAddRatingView];
        [stars setupWithOption:option];
        
        CGRect frame = stars.frame;
        frame.origin.y = currentY;
        frame.origin.x = dynamicFormHorizontalMargin;
        frame.size.width = width - (2 * dynamicFormHorizontalMargin);
        [stars setFrame:frame];
        
        [self.centerView addSubview:stars];
        currentY += stars.frame.size.height;
        
        [self.ratingStarsArray addObject:stars];
        
        self.numberOfFields++;
    }
    
    self.ratingDynamicForm = [[JADynamicForm alloc] initWithForm:self.form
                                                        delegate:nil
                                                startingPosition:currentY];
    
    CGFloat spaceBetweenFormFields = 6.0f;
    NSInteger count = 0;
    for (UIView *view in self.ratingDynamicForm.formViews)
    {
        view.tag = count;
        
        CGRect frame = view.frame;
        frame.origin.x = dynamicFormHorizontalMargin;
        frame.size.width = width - (2 * dynamicFormHorizontalMargin);
        view.frame = frame;
        
        [self.centerView addSubview:view];
        currentY += view.frame.size.height + spaceBetweenFormFields;
        
        count++;
    }
    
    // Add space between last form field and send review button
    currentY += 38.0f;
    
    NSString *imageNameFormat = @"orangeHalfMedium_%@";
    UIImage* buttonImageNormal = [UIImage imageNamed:[NSString stringWithFormat:imageNameFormat, @"normal"]];
    UIImage* buttonImageHighlighted = [UIImage imageNamed:[NSString stringWithFormat:imageNameFormat, @"highlighted"]];
    UIImage* buttonImageDisabled = [UIImage imageNamed:[NSString stringWithFormat:imageNameFormat, @"disabled"]];
    self.sendReviewButton = [[UIButton alloc] initWithFrame:CGRectMake((width - buttonImageNormal.size.width) / 2 ,
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
    currentY += self.sendReviewButton.frame.size.height + verticalMargin;
    
    [self.centerView setFrame:CGRectMake(0.0f,
                                         0.0f,
                                         width,
                                         currentY)];
    
    [self.writeReviewScrollView addSubview:self.centerView];
    [self.writeReviewScrollView setContentSize:CGSizeMake(self.writeReviewScrollView.frame.size.width, currentY)];
}

- (void) setupEmptyReviewsView:(CGFloat)width originY:(CGFloat)originY
{
    self.emptyReviewsView.translatesAutoresizingMaskIntoConstraints = YES;
    self.emptyReviewsImageView.translatesAutoresizingMaskIntoConstraints = YES;
    self.emptyReviewsLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    CGFloat horizontalMargin = 6.0f;
    
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
    self.goToNewRatingButtonPressed = YES;
    
    NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(self.product, RIProduct))
    {
        [userInfo setObject:self.product forKey:@"product"];
    }
    
    if(VALID_NOTEMPTY(self.productRatings, RIProductRatings))
    {
        [userInfo setObject:self.productRatings forKey:@"productRatings"];
    }
    
    [userInfo setObject:[NSNumber numberWithBool:self.goToNewRatingButtonPressed] forKey:@"goToNewRatingButtonPressed"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowNewRatingScreenNotification object:nil userInfo:userInfo];
}

#pragma mark - Tableview methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productRatings.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    static JAReviewCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableViewComments dequeueReusableCellWithIdentifier:@"reviewCell"];
    });
    
    RIRatingComment *comment = [self.productRatings.comments objectAtIndex:indexPath.row];
    cell.labelDescription.text = comment.detail;
    
    return [self calculateHeightForConfiguredSizingCell:cell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    [sizingCell setNeedsLayout];
    [sizingCell layoutSubviews];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell"];
    [cell setupCell:self.view.frame];
    
    cell.labelPrice.text = STRING_PRICE;
    cell.labelAppearance.text = STRING_APPEARENCE;
    cell.labelQuality.text = STRING_QUANTITY;
    
    RIRatingComment *comment = [self.productRatings.comments objectAtIndex:indexPath.row];
    
    cell.labelTitle.text = comment.title;
    cell.labelDescription.text = comment.detail;
    
    NSInteger count = comment.options.count;
    
    if (count == 1) {
        [cell.viewAppearance removeFromSuperview];
        [cell.viewQuality removeFromSuperview];
    } else if (2 == count) {
        [cell.viewQuality removeFromSuperview];
    }
    
    for (int i = 0 ; i < count ; i++)
    {
        RIRatingOption *option = comment.options[i];
        
        if (i == 0)
        {
            [cell setPriceRating:[option.optionValue integerValue]];
            cell.labelPrice.text = option.title;
        }
        else if (i == 1)
        {
            [cell setAppearanceRating:[option.optionValue integerValue]];
            cell.labelAppearance.text = option.title;
        }
        else if (i == 2)
        {
            [cell setQualityRating:[option.optionValue integerValue]];
            cell.labelQuality.text = option.title;
        }
    }
    
    NSString *string;
    
    if (comment.nickname.length > 0) {
        string = [NSString stringWithFormat:STRING_POSTED_BY, comment.nickname, comment.createdAt];
    } else {
        string = [NSString stringWithFormat:STRING_POSTED_BY_ANONYMOUS, comment.createdAt];
    }
    
    cell.labelAuthorDate.text = string;
    
    [cell.separator setHidden:NO];
    if(indexPath.row == ([self.productRatings.comments count] - 1))
    {
        [cell.separator setHidden:YES];
    }
    
    [cell layoutSubviews];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Send review

- (void)sendReview:(id)sender
{
    [self continueSendingReview];
}

- (void)continueSendingReview
{
    [self showLoading];
    
    [self.ratingDynamicForm resignResponder];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self.ratingDynamicForm getValues]];
    
    for (JAAddRatingView *component in self.ratingStarsArray)
    {
        RIRatingsOptions *option = [component.ratingOptions objectAtIndex:(component.rating - 1)];
        NSString *key = [NSString stringWithFormat:@"rating-option--%@", option.fkRatingType];
        
        [parameters addEntriesFromDictionary:@{key: option.value}];
    }
    
    [parameters addEntriesFromDictionary:@{@"rating-customer": [RICustomer getCustomerId]}];
    [parameters addEntriesFromDictionary:@{@"rating-catalog-sku": self.product.sku}];
    
    [RIForm sendForm:self.ratingDynamicForm.form
          parameters:parameters
        successBlock:^(id object) {
            
            NSMutableDictionary *globalRateDictionary = [[NSMutableDictionary alloc] init];
            [globalRateDictionary setObject:self.product.sku forKey:kRIEventSkuKey];
            [globalRateDictionary setObject:self.product.brand forKey:kRIEventBrandKey];
            NSNumber *price = VALID_NOTEMPTY(self.product.specialPrice, NSNumber) ? self.product.specialPrice : self.product.price;
            [globalRateDictionary setValue:[price stringValue] forKey:kRIEventPriceKey];
            
            for (JAAddRatingView *component in self.ratingStarsArray)
            {
                NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
                [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                [trackingDictionary setValue:@(component.rating) forKey:kRIEventValueKey];
                
                if ([component.idRatingType isEqualToString:@"1"])
                {
                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.rating] forKey:kRIEventRatingPriceKey];
                    [trackingDictionary setValue:@"RateProductPrice" forKey:kRIEventActionKey];
                }
                else if ([component.idRatingType isEqualToString:@"2"])
                {
                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.rating] forKey:kRIEventRatingAppearanceKey];
                    [trackingDictionary setValue:@"RateProductAppearance" forKey:kRIEventActionKey];
                }
                else if ([component.idRatingType isEqualToString:@"3"])
                {
                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.rating] forKey:kRIEventRatingQualityKey];
                    [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
                }
                else
                {
                    // There is no indication about the default tracking for rating
                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.rating] forKey:kRIEventRatingKey];
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
                [self showMessage:STRING_NO_NEWTORK success:NO];
            }
            else if(VALID_NOTEMPTY(errorObject, NSDictionary))
            {
                [self.ratingDynamicForm validateFields:errorObject];
                
                [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
            }
            else if(VALID_NOTEMPTY(errorObject, NSArray))
            {
                [self.ratingDynamicForm checkErrors];
                
                [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
            }
            else
            {
                [self.ratingDynamicForm checkErrors];
                
                [self showMessage:STRING_ERROR success:NO];
            }
        }];
}

#pragma mark - Keyboard notifications

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.writeReviewScrollView setFrame:CGRectMake(self.writeReviewScrollViewInitialRect.origin.x,
                                                        self.writeReviewScrollViewInitialRect.origin.y,
                                                        self.writeReviewScrollViewInitialRect.size.width,
                                                        self.writeReviewScrollViewInitialRect.size.height - kbSize.height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.writeReviewScrollView setFrame:self.writeReviewScrollViewInitialRect];
    }];
}

@end

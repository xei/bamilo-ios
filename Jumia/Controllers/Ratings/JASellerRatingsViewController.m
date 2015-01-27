//
//  JASellerRatingsViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 27/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JASellerRatingsViewController.h"
#import "RIProduct.h"
#import "RISeller.h"
#import "RIForm.h"
#import "JADynamicForm.h"
#import "JARatingsView.h"
#import "RISellerReviewInfo.h"
#import "JAReviewCell.h"

@interface JASellerRatingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) JARatingsView* ratingsView;
@property (nonatomic, strong) UILabel* numberOfReviewsLabel;

@property (weak, nonatomic) IBOutlet UIView *resumeView;
@property (weak, nonatomic) IBOutlet UILabel *reviewSellerLabel;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewButton;

@property (weak, nonatomic) IBOutlet UITableView *tableViewComments;

@property (nonatomic, strong) RISellerReviewInfo* sellerReviewInfo;


// iPad landscape components only
@property (weak, nonatomic) IBOutlet UIView *emptyReviewsView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyReviewsImageView;
@property (weak, nonatomic) IBOutlet UILabel *emptyReviewsLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *writeReviewScrollView;
@property (assign, nonatomic) CGRect writeReviewScrollViewInitialRect;

@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) UILabel *fixedLabel;
@property (strong, nonatomic) UIButton *sendReviewButton;

@property (nonatomic, strong) RIForm* sellerReviewForm;
@property (nonatomic, strong) JADynamicForm* sellerReviewsDynamicForm;
@property (nonatomic, strong) UIView* sellerReviewsContentView;

@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JASellerRatingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.screenName = @"SellerRatingScreen";
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;

    self.topView.translatesAutoresizingMaskIntoConstraints = YES;
    self.nameLabel.text = self.product.seller.name;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.resumeView.translatesAutoresizingMaskIntoConstraints = YES;
    self.tableViewComments.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.tableViewComments.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.goToNewRatingButtonPressed = NO;
    
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    [self hideViews];
    
    [self.sellerReviewsDynamicForm resignResponder];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self hideLoading];
    
    [self setupViews];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (VALID_NOTEMPTY(self.sellerReviewForm, RIForm)) {
        [self setupViews];
    } else {
        [self requestSellerReviewForm];
    }

    if(NO == VALID_NOTEMPTY(self.sellerReviewInfo, RISellerReviewInfo))
    {
        [self requestSellerReviews];
    }
}

#pragma mark - Setups views

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
        isInLandscape = NO;//YES;
    }
    
    if(VALID_NOTEMPTY(self.sellerReviewInfo.reviews, NSArray))
    {
        hasComments = YES;
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
    
    [self.tableViewComments reloadData];
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
    
    if (self.sellerReviewForm) {
        NSInteger count = 0;
        CGFloat initialContentY = 0;
        self.sellerReviewsDynamicForm = [[JADynamicForm alloc] initWithForm:self.sellerReviewForm
                                                                   delegate:nil
                                                           startingPosition:initialContentY
                                                                  widthSize:width
                                                         hasFieldNavigation:YES];
        self.sellerReviewsContentView = [UIView new];
        for (UIView *view in self.sellerReviewsDynamicForm.formViews)
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
            
            [self.sellerReviewsContentView addSubview:view];
            initialContentY += view.frame.size.height + spaceBetweenFormFields;
            count++;
        }
        [self.sellerReviewsContentView setFrame:CGRectMake(0.0,
                                                           currentY,
                                                           width,
                                                           initialContentY)];
        [self.centerView addSubview:self.sellerReviewsContentView];
    }    
    

    currentY += self.sellerReviewsContentView.frame.size.height + 38.0f;
    
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


- (void)setupTopView
{
    [self.nameLabel setFrame:CGRectMake(12.0f,
                                        6.0f,
                                        self.view.frame.size.width - 24.0f,
                                        self.view.frame.size.height)];
    [self.nameLabel sizeToFit];
    
    CGFloat currentY = CGRectGetMaxY(self.nameLabel.frame) + 10.0f;
    
    [self.ratingsView removeFromSuperview];
    self.ratingsView = [JARatingsView getNewJARatingsView];
    self.ratingsView.rating = [self.product.seller.reviewAverage integerValue];
    [self.ratingsView setFrame:CGRectMake(self.nameLabel.frame.origin.x,
                                          currentY,
                                          self.ratingsView.frame.size.width,
                                          self.ratingsView.frame.size.height)];
    [self.topView addSubview:self.ratingsView];
    
    [self.numberOfReviewsLabel removeFromSuperview];
    self.numberOfReviewsLabel = [UILabel new];
    self.numberOfReviewsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f];
    self.numberOfReviewsLabel.textColor = UIColorFromRGB(0xcccccc);
    if (1 == [self.product.seller.reviewTotal integerValue]) {
        self.numberOfReviewsLabel.text = STRING_REVIEW;
    } else {
        self.numberOfReviewsLabel.text = [NSString stringWithFormat:STRING_REVIEWS, [self.product.seller.reviewTotal integerValue]];
    }
    [self.numberOfReviewsLabel sizeToFit];
    [self.numberOfReviewsLabel setFrame:CGRectMake(CGRectGetMaxX(self.ratingsView.frame) + 4.0f,
                                                   self.ratingsView.frame.origin.y,
                                                   self.numberOfReviewsLabel.frame.size.width,
                                                   self.numberOfReviewsLabel.frame.size.height)];
    [self.topView addSubview:self.numberOfReviewsLabel];
    
    currentY += self.ratingsView.frame.size.height + 10.0f;
    
    [self.topView setFrame:CGRectMake(0.0f,
                                      0.0f,
                                      self.view.frame.size.width,
                                      currentY)];
    [self.topView setHidden:NO];
}


- (void)setupResumeView:(CGFloat)width
{
    CGFloat currentY = 6.0f;
    
    self.reviewSellerLabel.text = @"Rate this seller now!";
    [self.reviewSellerLabel setTextColor:UIColorFromRGB(0x666666)];
    self.reviewSellerLabel.translatesAutoresizingMaskIntoConstraints = YES;
    [self.reviewSellerLabel setFrame:CGRectMake(self.reviewSellerLabel.frame.origin.x,
                                               currentY,
                                               self.reviewSellerLabel.frame.size.width,
                                               self.reviewSellerLabel.frame.size.height)];
    
    [self.writeReviewButton setTitle:STRING_WRITE_REVIEW
                            forState:UIControlStateNormal];
    [self.writeReviewButton sizeToFit];
    [self.writeReviewButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                                 forState:UIControlStateNormal];
    
    self.resumeView.layer.cornerRadius = 5.0f;
    [self.resumeView setFrame:CGRectMake(6.0f,
                                         CGRectGetMaxY(self.topView.frame) + 6.0f,
                                         width,
                                         currentY + self.reviewSellerLabel.frame.size.height + self.writeReviewButton.frame.size.height + 20.0f)];
}

#pragma mark - Raquests

- (void)requestSellerReviewForm
{
//    self.apiResponse = RIApiResponseSuccess;
//    
//    [self showLoading];
//
//    [RIForm getForm:@"sellerReview"
//       successBlock:^(RIForm *form)
//     {
//         self.sellerReviewForm = form;
//         
//         [self setupViews];
//         
//         [self hideLoading];
//         
//     } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
//         [self hideLoading];
//         
//         self.apiResponse = apiResponse;
//         if (RIApiResponseNoInternetConnection == self.apiResponse)
//         {
//             [self showMessage:STRING_NO_CONNECTION success:NO];
//         }
//         else
//         {
//             [self showMessage:STRING_ERROR success:NO];
//         }
//     }];
}

- (void)requestSellerReviews
{
    self.apiResponse = RIApiResponseSuccess;
    
    [self showLoading];

    [RISellerReviewInfo getSellerReviewForProductWithUrl:self.product.url
                                                pageSize:10
                                              pageNumber:1
                                            successBlock:^(RISellerReviewInfo *sellerReviewInfo) {
                                                self.sellerReviewInfo = sellerReviewInfo;
                                                
                                                [self hideLoading];
                                                
//                                                if (VALID_NOTEMPTY(self.sellerReviewForm, RIForm)){
                                                    [self setupViews];
//                                                }
                                            } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                                                [self hideLoading];
                                                
                                                self.apiResponse = apiResponse;
                                                if (RIApiResponseNoInternetConnection == self.apiResponse)
                                                {
                                                    [self showMessage:STRING_NO_CONNECTION success:NO];
                                                }
                                                else
                                                {
                                                    [self showMessage:STRING_ERROR success:NO];
                                                }
                                            }];
}

#pragma mark - Tableview methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sellerReviewInfo.reviews.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RISellerReview* review = [self.sellerReviewInfo.reviews objectAtIndex:indexPath.row];
    return [JAReviewCell cellHeightWithSellerReview:review width:self.tableViewComments.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell"];
    
    RISellerReview* review = [self.sellerReviewInfo.reviews objectAtIndex:indexPath.row];
    
    BOOL showSeparator = YES;
    if(indexPath.row == ([self.sellerReviewInfo.reviews count] - 1))
    {
        showSeparator = NO;
    }
    
    [cell setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 100)];
    
    [cell setupWithSellerReview:review showSeparator:showSeparator];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Button actions
- (void)sendReview:(id)sender
{

}


@end

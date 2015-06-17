//
//  JAProductDetailsViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 08/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAProductDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JAPriceView.h"
#import "JAAppDelegate.h"
#import "RIProduct.h"
#import "JAPickerScrollView.h"
#import "RISpecification.h"
#import "RISpecificationAttribute.h"

@interface JAProductDetailsViewController () <JAPickerScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UILabel *labelName;
@property (strong, nonatomic) UILabel *labelBrand;
@property (strong, nonatomic) UIScrollView *contentScrollView;

@property (strong, nonatomic) UIView *featuresView;
@property (strong, nonatomic) UILabel *featuresTitleLabel;
@property (strong, nonatomic) UIView *featuresSeparator;
@property (strong, nonatomic) UILabel *featuresTextLabel;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) UILabel *descriptionTitleLabel;
@property (strong, nonatomic) UIView *descriptionSeparator;
@property (strong, nonatomic) UILabel *descriptionTextLabel;

@property (strong, nonatomic) UIScrollView *specificationScrollView;


@property (weak, nonatomic) IBOutlet JAPickerScrollView *pickerScrollView;
@property (strong, nonatomic) NSArray *sortList;
@property (assign, nonatomic) BOOL animatedScroll;

@property (nonatomic, strong) JAPriceView *priceView;

@property (nonatomic, strong) NSMutableArray *specificationContentViewArray;


@end

@implementation JAProductDetailsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view setFrame:[UIScreen mainScreen].bounds];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.animatedScroll = YES;
    
    self.sortList = [NSArray arrayWithObjects:STRING_SUMMARY, STRING_SPECIFICATIONS, nil];
    
    [self.mainScrollView setPagingEnabled:YES];
    [self.mainScrollView setScrollEnabled:NO];
    
    if (VALID_NOTEMPTY(self.product.sku, NSString)) {
        self.screenName = [NSString stringWithFormat:@"PDSSecondScreen / %@", self.product.sku];
    }
    else {
        self.screenName = @"PDSSecondScreen";
    }
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.view.backgroundColor = JABackgroundGrey;
    
    self.pickerScrollView.delegate = self;
    self.pickerScrollView.startingIndex = self.selectedIndex;
    [self.pickerScrollView setWidth:self.view.width];
    [self.pickerScrollView setOptions:self.sortList];
    
    self.mainScrollView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.contentScrollView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(RI_IS_RTL?self.view.bounds.size.width:0.0f,
                                                            0.0f,
                                                            self.view.frame.size.width,
                                                            92.0f)];
    [self.topView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.mainScrollView addSubview:self.topView];
    
    self.labelBrand = [[UILabel alloc] initWithFrame:CGRectMake(12.0f,
                                                                8.0f,
                                                                self.view.frame.size.width - (2 * 12),
                                                                17.0f)];
    self.labelBrand.font = [UIFont fontWithName:kFontMediumName size:14.0f];
    self.labelBrand.numberOfLines = 1;
    self.labelBrand.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.topView addSubview:self.labelBrand];
    
    self.labelName = [[UILabel alloc] initWithFrame:CGRectMake(12.0f,
                                                               CGRectGetMaxY(self.labelBrand.frame) + 4.0f,
                                                               self.view.frame.size.width - (2 * 12),
                                                               17.0f)];
    self.labelName.font = [UIFont fontWithName:kFontMediumName size:14.0f];
    self.labelName.numberOfLines = 0;
    self.labelName.lineBreakMode = NSLineBreakByWordWrapping;
    [self.topView addSubview:self.labelName];
    
    self.specificationScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.specificationScrollView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    
    [self.mainScrollView addSubview:self.contentScrollView];
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipeGesture.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:leftSwipeGesture];
    [self.view addGestureRecognizer:rightSwipeGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mainScrollView setWidth:self.view.frame.size.width];
    [self.pickerScrollView setWidth:self.view.frame.size.width];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffMenuSwipePanelNotification
                                                        object:nil];
    
    
    [self setupViews:self.view.bounds.size.width height:self.view.bounds.size.height];
    
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"ProductSpecs"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews:(CGFloat)width height:(CGFloat)height {
    self.labelBrand.text = self.product.brand;
    [self.labelBrand setFrame:CGRectMake(12.0f,
                                         6.0f,
                                         width - 24.0f,
                                         height)];
    [self.labelBrand sizeToFit];
    
    self.labelName.text = self.product.name;
    [self.labelName setFrame:CGRectMake(12.0f,
                                        CGRectGetMaxY(self.labelBrand.frame) + 4.0f,
                                        width - 24.0f,
                                        height)];
    [self.labelName sizeToFit];
    
    if (VALID(self.priceView, JAPriceView)) {
        [self.priceView removeFromSuperview];
    }
    
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:self.product.priceFormatted
                     specialPrice:self.product.specialPriceFormatted
                         fontSize:14.0f
            specialPriceOnTheLeft:NO];
    
    self.priceView.frame = CGRectMake(12.0f,
                                      CGRectGetMaxY(self.labelName.frame) + 4.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.topView addSubview:self.priceView];
    
    CGFloat topViewMinHeight = CGRectGetMaxY(self.priceView.frame);
    if (topViewMinHeight < 38.0f) {
        topViewMinHeight = 38.0f;
    }
    topViewMinHeight += 6.0f;
    
    [self.topView setFrame:CGRectMake(RI_IS_RTL?self.view.width:0.0f,
                                      0.0f,
                                      width,
                                      topViewMinHeight)];
    
    [self.contentScrollView setFrame:CGRectMake(RI_IS_RTL?self.view.width:0.0f,
                                                 topViewMinHeight,
                                                 width,
                                                 height - topViewMinHeight - CGRectGetMinY(self.topView.frame) - self.pickerScrollView.frame.size.height)];
    
    if (VALID(self.featuresView, UIView)) {
        for (UIView *subView in self.featuresView.subviews) {
            [subView removeFromSuperview];
        }
        [self.featuresView removeFromSuperview];
    }
    
    if (VALID(self.descriptionView, UIView)) {
        for (UIView *subView in self.descriptionView.subviews) {
            [subView removeFromSuperview];
        }
        [self.descriptionView removeFromSuperview];
    }
    
    self.featuresView = [[UIView alloc] initWithFrame:CGRectMake(6.0f,
                                                                 6.0f,
                                                                 self.contentScrollView.frame.size.width - 12.0f,
                                                                 0.0f)];
    
    [self.featuresView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.featuresView.layer.cornerRadius = 5.0f;
    [self.contentScrollView addSubview:self.featuresView];
    
    CGFloat horizontalMargin = 6.0f;
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        horizontalMargin = 10.0f;
    }
    
    self.featuresTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin,
                                                                        2.0f,
                                                                        self.featuresView.frame.size.width - (2 * horizontalMargin),
                                                                        21.0f)];
    [self.featuresTitleLabel setNumberOfLines:1];
    [self.featuresTitleLabel setText:STRING_KEY_FEATURES];
    [self.featuresTitleLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.featuresTitleLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.featuresView addSubview:self.featuresTitleLabel];
    
    self.featuresSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      26.0f,
                                                                      self.featuresView.frame.size.width,
                                                                      1.0f)];
    [self.featuresSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.featuresView addSubview:self.featuresSeparator];
    
    self.featuresTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin,
                                                                       33.0f,
                                                                       self.featuresView.frame.size.width - (2 * horizontalMargin),
                                                                       0.0f)];
    [self.featuresTextLabel setNumberOfLines:0];
    [self.featuresTextLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.featuresTextLabel setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
    [self.featuresView addSubview:self.featuresTextLabel];
    
    if (VALID_NOTEMPTY(self.product.shortSummary, NSString)) {
        [self.featuresTextLabel setText:self.product.shortSummary];
        [self.featuresTextLabel sizeToFit];
        [self.featuresView setFrame:CGRectMake(6.0f,
                                               6.0f,
                                               self.contentScrollView.frame.size.width - 12.0f,
                                               CGRectGetMaxY(self.featuresTextLabel.frame) + 6.0f)];
        
        self.descriptionView = [[UIView alloc] initWithFrame:CGRectMake(6.0f,
                                                                        6.0f,
                                                                        self.contentScrollView.frame.size.width - 12.0f,
                                                                        0.0f)];
        [self.descriptionView setBackgroundColor:UIColorFromRGB(0xffffff)];
        self.descriptionView.layer.cornerRadius = 5.0f;
        [self.contentScrollView addSubview:self.descriptionView];
        
        self.descriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin,
                                                                               2.0f,
                                                                               self.descriptionView.frame.size.width - (2 * horizontalMargin),
                                                                               21.0f)];
        [self.descriptionTitleLabel setNumberOfLines:1];
        [self.descriptionTitleLabel setText:STRING_DESCRIPTION];
        [self.descriptionTitleLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
        [self.descriptionTitleLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
        [self.descriptionView addSubview:self.descriptionTitleLabel];
        
        self.descriptionSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             26.0f,
                                                                             self.descriptionView.frame.size.width,
                                                                             1.0f)];
        [self.descriptionSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
        [self.descriptionView addSubview:self.descriptionSeparator];
        
        self.descriptionTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin,
                                                                              33.0f,
                                                                              self.descriptionView.frame.size.width - (2 * horizontalMargin),
                                                                              0.0f)];
        [self.descriptionTextLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.descriptionTextLabel setFont:[UIFont fontWithName:kFontLightName size:12.0f]];
        [self.descriptionTextLabel setNumberOfLines:0];
        [self.descriptionView addSubview:self.descriptionTextLabel];
        
        [self.descriptionTextLabel setText:self.product.summary];
        [self.descriptionTextLabel sizeToFit];
        [self.descriptionView setFrame:CGRectMake(6.0f,
                                                  CGRectGetMaxY(self.featuresView.frame) + 6.0f,
                                                  self.contentScrollView.frame.size.width - 12.0f,
                                                  CGRectGetMaxY(self.descriptionTextLabel.frame) + 6.0f)];
        
        [self.contentScrollView setContentSize:CGSizeMake(width,
                                                           CGRectGetMaxY(self.descriptionView.frame) + 6.0f)];
    }
    else {
        [self.featuresTextLabel setText:self.product.summary];
        [self.featuresTextLabel sizeToFit];
        [self.featuresView setFrame:CGRectMake(6.0f,
                                               6.0f,
                                               self.contentScrollView.frame.size.width - 12.0f,
                                               CGRectGetMaxY(self.featuresTextLabel.frame) + 6.0f)];
        
        [self.contentScrollView setContentSize:CGSizeMake(width,
                                                           CGRectGetMaxY(self.featuresView.frame) + 6.0f)];
    }
    
    if (VALID_NOTEMPTY(self.specificationContentViewArray, NSMutableArray)) {
        for (UIView *contentView in self.specificationContentViewArray) {
            [contentView removeFromSuperview];
        }
    }
    
    [self setupSpecificationView];
    UIView *lastView = self.specificationContentViewArray.lastObject;
    [self.specificationScrollView setContentSize:CGSizeMake(self.specificationScrollView.frame.size.width,
                                                            CGRectGetMaxY(lastView.frame) + self.pickerScrollView.frame.size.height - 12.0f)];
    
    if (RI_IS_RTL)
    {
        [self.topView flipSubviewAlignments];
        [self.topView flipSubviewPositions];
        [self.featuresView flipSubviewPositions];
        [self.featuresView flipSubviewAlignments];
        [self.descriptionView flipSubviewAlignments];
        [self.descriptionView flipSubviewPositions];
        [self.specificationScrollView flipSubviewPositions];
        [self.specificationScrollView flipSubviewAlignments];
        [self.contentScrollView flipSubviewAlignments];
        [self.contentScrollView flipSubviewPositions];
    }
}

- (void)setupSpecificationView {
    CGFloat margin = 6.0f;
    CGFloat startingY = 6.0f;
    
    NSOrderedSet *listSpecifications = self.product.specifications;
    
    
    [self.specificationScrollView setFrame:CGRectMake(RI_IS_RTL?0:self.contentScrollView.frame.size.width,
                                                      0.0f,
                                                      self.contentScrollView.frame.size.width,
                                                      self.contentScrollView.frame.size.height + self.priceView.frame.size.height + self.pickerScrollView.frame.size.height + 24.0f)];
    
    self.specificationContentViewArray = [NSMutableArray new];
    for (RISpecification *specification in listSpecifications) {
        UIView *currentContentView = [[UIView alloc] init];
        [self.specificationContentViewArray addObject:currentContentView];
        
        [currentContentView setFrame:CGRectMake(margin,
                                                startingY,
                                                self.contentScrollView.frame.size.width - 12.f,
                                                0.0f)];
        
        currentContentView.translatesAutoresizingMaskIntoConstraints = YES;
        currentContentView.layer.cornerRadius = 5.0f;
        [currentContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [self.specificationScrollView addSubview:currentContentView];
        
        
        UILabel* specificationTitleLabel = [[UILabel alloc]init];
        
        
        self.featuresView.layer.cornerRadius = 5.0f;
        
        [specificationTitleLabel setFrame:CGRectMake(margin,
                                                     2.0f,
                                                     currentContentView.frame.size.width - 12.0f,
                                                     23.0f)];
        [currentContentView addSubview:specificationTitleLabel];
        
        
        [specificationTitleLabel setText:specification.headLabel];
        [specificationTitleLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
        [specificationTitleLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
        [specificationTitleLabel setBackgroundColor:[UIColor clearColor]];
        
        
        
        UIView* specificationSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                  26.0f,
                                                                                  currentContentView.frame.size.width,
                                                                                  1.0f)];
        [specificationSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
        [currentContentView addSubview:specificationSeparator];
        
        
        UIView* specificationTextView = [[UILabel alloc] init];
        [currentContentView addSubview:specificationTextView];
        
        [specificationTextView setFrame:CGRectMake(margin,
                                                   CGRectGetMaxY(specificationSeparator.frame) + 1.0f,
                                                   currentContentView.frame.size.width - (2 * margin),
                                                   0.0f)];
        
        CGFloat currentY = 6.0f;
        NSMutableArray *specificationAttributes = specification.specificationAttributes;
        for (RISpecificationAttribute *specificationAttribute in  specificationAttributes) {
            UILabel* specificationKeyLabel = [[UILabel alloc] init];
            
            if (VALID_NOTEMPTY(specificationAttribute.key, NSString)) {
                
                [specificationKeyLabel setFrame:CGRectMake(margin,
                                                           currentY,
                                                           specificationTextView.frame.size.width / 2,
                                                           12.0f)];
                
                
                
                [specificationKeyLabel setNumberOfLines:0];
                [specificationKeyLabel setTextColor:UIColorFromRGB(0x666666)];
                [specificationKeyLabel setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
                [specificationKeyLabel setText:specificationAttribute.key];
                [specificationKeyLabel sizeToFit];
                [specificationTextView addSubview:specificationKeyLabel];
            }
            
            UILabel* specificationValueLabel = [[UILabel alloc] init];
            
            if (VALID_NOTEMPTY(specificationAttribute.value, NSString)) {
                
                [specificationValueLabel setFrame:CGRectMake((specificationTextView.frame.size.width / 2) + 6.0f,
                                                             currentY,
                                                             (specificationTextView.frame.size.width / 2) - 12.0f,
                                                             12.0f)];
                
                
                [specificationValueLabel setNumberOfLines:0];
                [specificationValueLabel setTextColor:UIColorFromRGB(0x666666)];
                [specificationValueLabel setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
                [specificationValueLabel setText:specificationAttribute.value];
                [specificationValueLabel sizeToFit];
                [specificationTextView addSubview:specificationValueLabel];
                
            }
            
            currentY += MAX(specificationTitleLabel.frame.size.height, specificationValueLabel.frame.size.height);
        }
        
        [specificationTextView setFrame:CGRectMake(specificationTextView.frame.origin.x,
                                                   specificationTextView.frame.origin.y,
                                                   specificationTextView.frame.size.width,
                                                   currentY)];
        
        if (RI_IS_RTL) {
            [specificationTextView flipSubviewAlignments];
            [specificationTextView flipSubviewPositions];
        }
        
        [currentContentView setFrame:CGRectMake(margin,
                                                startingY,
                                                self.contentScrollView.frame.size.width - 12.f,
                                                currentY + 34.0f)];
        if (RI_IS_RTL) {
            [currentContentView flipSubviewPositions];
            [currentContentView flipSubviewAlignments];
        }
        
        startingY += currentContentView.frame.size.height + 6.0f;
    }
    
    [self.mainScrollView addSubview:self.specificationScrollView];
    [self.mainScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width * 2,
                                                   CGRectGetMaxY(self.mainScrollView.frame) - 24.0f)];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self showLoading];
    
    self.selectedIndex = self.pickerScrollView.selectedIndex;
    
    self.pickerScrollView.startingIndex = self.selectedIndex;
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    CGFloat newHeight = self.view.frame.size.width - self.view.frame.origin.y;
    
    [self setupViews:newWidth height:newHeight];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.animatedScroll = NO;
    
    [self selectedIndex:self.selectedIndex];
    [self.pickerScrollView setWidth:self.view.width];
    [self.mainScrollView setWidth:self.view.width];
    [self.pickerScrollView setNeedsLayout];
    
    [self setupViews:self.view.frame.size.width height:self.view.frame.size.height];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Swipe Actions
- (IBAction)swipeRight:(id)sender {
    [self.pickerScrollView scrollRightAnimated:YES];
}

- (IBAction)swipeLeft:(id)sender {
    [self.pickerScrollView scrollLeftAnimated:YES];
}

#pragma mark JAPickerScrollView
- (void)selectedIndex:(NSInteger)index {
    [self.mainScrollView scrollRectToVisible:CGRectMake(index * self.mainScrollView.frame.size.width,
                                                        0.0f,
                                                        self.mainScrollView.frame.size.width,
                                                        self.mainScrollView.frame.size.height) animated:self.animatedScroll];
    self.animatedScroll = YES;
}

@end

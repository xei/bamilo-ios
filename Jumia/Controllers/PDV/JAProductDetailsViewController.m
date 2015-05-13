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

@interface JAProductDetailsViewController ()

<
JAPickerScrollViewDelegate
>
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelBrand;
@property (weak, nonatomic) IBOutlet UIScrollView *contenteScrollView;
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

@property (nonatomic, strong) NSMutableArray* specificationContentViewArray;
@property (nonatomic, strong) UIView *specificationSeparator;
@property (nonatomic, strong) UILabel *specificationTitleLabel;
@property (nonatomic, strong) UILabel *specificationTextLabel;
@property (nonatomic, strong) UILabel *specificationKeyLabel;
@property (nonatomic, strong) UILabel *specificationValueLabel;


@end

@implementation JAProductDetailsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animatedScroll = YES;
    
    self.sortList = [NSArray arrayWithObjects:STRING_SUMMARY, STRING_SPECIFICATIONS, nil];
    
    [self.mainScrollView setPagingEnabled:YES];
    [self.mainScrollView setScrollEnabled:NO];
    
    if(VALID_NOTEMPTY(self.product.sku, NSString))
    {
        self.screenName = [NSString stringWithFormat:@"PDSSecondScreen / %@", self.product.sku];
    }
    else
    {
        self.screenName = @"PDSSecondScreen";
    }
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.view.backgroundColor = JABackgroundGrey;
    
    self.contenteScrollView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    self.contenteScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.mainScrollView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    self.mainScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.topView.translatesAutoresizingMaskIntoConstraints = YES;
    self.pickerScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    
    
    self.labelBrand.font = [UIFont fontWithName:kFontMediumName size:self.labelBrand.font.pointSize];
    self.labelBrand.text = self.product.brand;
    self.labelBrand.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.labelName.font = [UIFont fontWithName:kFontMediumName size:self.labelName.font.pointSize];
    self.labelName.text = self.product.name;
    self.labelName.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.specificationScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.specificationScrollView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    self.specificationScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    
    
    //self.specificationContentView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.pickerScrollView.delegate = self;
    self.pickerScrollView.startingIndex = self.selectedIndex;
    [self.pickerScrollView setOptions:self.sortList];
    //[self.pickerScrollView setHidden:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupViews:self.view.frame.size.width height:self.view.frame.size.height];
  
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"ProductSpecs"];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setupViews:(CGFloat)width height:(CGFloat)height
{
    [self.pickerScrollView setFrame:CGRectMake(self.view.bounds.origin.x,
                                               self.view.bounds.origin.y,
                                               self.view.bounds.size.width,
                                               self.pickerScrollView.frame.size.height)];
    [self.mainScrollView setFrame:CGRectMake(self.view.bounds.origin.x,
                                            CGRectGetMaxY(self.pickerScrollView.frame),
                                            self.view.bounds.size.width,
                                             self.view.bounds.size.height - self.pickerScrollView.frame.size.height)];
    
    [self.labelBrand setFrame:CGRectMake(12.0f,
                                         6.0f,
                                         width - 24.0f,
                                         height)];
    [self.labelBrand sizeToFit];
    
    [self.labelName setFrame:CGRectMake(12.0f,
                                        CGRectGetMaxY(self.labelBrand.frame) + 4.0f,
                                        width - 24.0f,
                                        height)];
    [self.labelName sizeToFit];
    
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
                                      CGRectGetMaxY(self.labelName.frame) + 4.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.topView addSubview:self.priceView];
    
    CGFloat topViewMinHeight = CGRectGetMaxY(self.priceView.frame);
    if(topViewMinHeight < 38.0f)
    {
        topViewMinHeight = 38.0f;
    }
    topViewMinHeight += 6.0f;
    
    [self.topView setFrame:CGRectMake(0.0f,
                                      0.0f,
                                      width,
                                      topViewMinHeight)];
    
    [self.contenteScrollView setFrame:CGRectMake(0.0f,
                                                 topViewMinHeight,
                                                 width,
                                                 height - topViewMinHeight - CGRectGetMinY(self.topView.frame) - self.pickerScrollView.frame.size.height)];
    
    if(VALID(self.featuresView, UIView))
    {
        for(UIView *subView in self.featuresView.subviews)
        {
            [subView removeFromSuperview];
        }
        [self.featuresView removeFromSuperview];
    }
    
    if(VALID(self.descriptionView, UIView))
    {
        for(UIView *subView in self.descriptionView.subviews)
        {
            [subView removeFromSuperview];
        }
        [self.descriptionView removeFromSuperview];
    }
    
    self.featuresView = [[UIView alloc] initWithFrame:CGRectMake(6.0f,
                                                                 6.0f,
                                                                 self.contenteScrollView.frame.size.width - 12.0f,
                                                                 0.0f)];
    [self.featuresView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.featuresView.layer.cornerRadius = 5.0f;
    [self.contenteScrollView addSubview:self.featuresView];
    
    CGFloat horizontalMargin = 6.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
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
    
    if (VALID_NOTEMPTY(self.product.shortSummary, NSString))
    {
        [self.featuresTextLabel setText:self.product.shortSummary];
        [self.featuresTextLabel sizeToFit];
        [self.featuresView setFrame:CGRectMake(6.0f,
                                               6.0f,
                                               self.contenteScrollView.frame.size.width - 12.0f,
                                               CGRectGetMaxY(self.featuresTextLabel.frame) + 6.0f)];
        
        self.descriptionView = [[UIView alloc] initWithFrame:CGRectMake(6.0f,
                                                                        6.0f,
                                                                        self.contenteScrollView.frame.size.width - 12.0f,
                                                                        0.0f)];
        [self.descriptionView setBackgroundColor:UIColorFromRGB(0xffffff)];
        self.descriptionView.layer.cornerRadius = 5.0f;
        [self.contenteScrollView addSubview:self.descriptionView];
        
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
                                                  self.contenteScrollView.frame.size.width - 12.0f,
                                                  CGRectGetMaxY(self.descriptionTextLabel.frame) + 6.0f)];
        
        [self.contenteScrollView setContentSize:CGSizeMake(width,
                                                           CGRectGetMaxY(self.descriptionView.frame) + 6.0f)];
    }
    else
    {
        [self.featuresTextLabel setText:self.product.summary];
        [self.featuresTextLabel sizeToFit];
        [self.featuresView setFrame:CGRectMake(6.0f,
                                               6.0f,
                                               self.contenteScrollView.frame.size.width - 12.0f,
                                               CGRectGetMaxY(self.featuresTextLabel.frame) + 6.0f)];
        
        [self.contenteScrollView setContentSize:CGSizeMake(width,
                                                           CGRectGetMaxY(self.featuresView.frame) + 6.0f)];
    }
    
    if(VALID_NOTEMPTY(self.specificationContentViewArray, NSMutableArray)){
        for (UIView *contentView in self.specificationContentViewArray) {
            [contentView removeFromSuperview];
        
        }
    }
    
    [self setupSpecificationView];
    
    }

-(void)setupSpecificationView{
    
    CGFloat width = self.contenteScrollView.frame.size.width;
    CGFloat margin = 6.0f;
    CGFloat height = 44.0f;
    CGFloat startingY = 6.0f;
    
    NSOrderedSet *listSpecifications = self.product.specifications;
    
    
    [self.specificationScrollView setFrame:CGRectMake(width,
                                                      0.0f,
                                                      self.contenteScrollView.frame.size.width,
                                                      self.contenteScrollView.frame.size.height+self.priceView.frame.size.height + self.pickerScrollView.frame.size.height + 24.0f)];
    
    self.specificationContentViewArray = [NSMutableArray new];
    for(RISpecification *specification in listSpecifications){
        
        
        UIView* currentContentView = [[UIView alloc] init];
        [self.specificationContentViewArray addObject:currentContentView];
        
        [currentContentView setFrame:CGRectMake(margin,
                                                           startingY,
                                                           self.contenteScrollView.frame.size.width - 12.f,
                                                           0.0f)];
        
        currentContentView.translatesAutoresizingMaskIntoConstraints = YES;
        currentContentView.layer.cornerRadius = 5.0f;
        [currentContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [self.specificationScrollView addSubview:currentContentView];
        
        
        self.specificationTitleLabel = [[UILabel alloc]init];

        
        self.featuresView.layer.cornerRadius = 5.0f;
        
        [self.specificationTitleLabel setFrame: CGRectMake(margin,
                                                            2.0f,
                                                            currentContentView.frame.size.width - 12.0f,
                                                            23.0f)];
        [currentContentView addSubview:self.specificationTitleLabel];

        
        [self.specificationTitleLabel setText:specification.headLabel];
        [self.specificationTitleLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
        [self.specificationTitleLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
        [self.specificationTitleLabel setBackgroundColor:[UIColor clearColor]];
        
        
        
        self.specificationSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                          26.0f,
                                                                          currentContentView.frame.size.width,
                                                                          1.0f)];
        [self.specificationSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
        [currentContentView addSubview:self.specificationSeparator];
        

        self.specificationTextLabel = [[UILabel alloc] init ];
        [currentContentView addSubview:self.specificationTextLabel];
                                       
         [self.specificationTextLabel setFrame:CGRectMake (margin,
                                                        CGRectGetMaxY(self.specificationSeparator.frame) + 1.0f,
                                                          currentContentView.frame.size.width - (2 * margin),
                                                                           0.0f)];
        [self.specificationTextLabel setNumberOfLines:0];
        [self.specificationTextLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.specificationTextLabel setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
        
        CGFloat keyYMargin = 6.0f;
        NSMutableArray *specificationAttributes = specification.specificationAttributes;
        for(RISpecificationAttribute *specificationAttribute in  specificationAttributes){
            if(VALID_NOTEMPTY(specificationAttribute.key, NSString)){
                
                self.specificationKeyLabel = [[UILabel alloc] init];
               
            
                [self.specificationKeyLabel setFrame:CGRectMake(margin,
                                                               keyYMargin,
                                                               self.specificationTextLabel.frame.size.width/2,
                                                                                 12.0f)];
                
                
                
                [self.specificationKeyLabel setNumberOfLines:0];
                [self.specificationKeyLabel setTextColor:UIColorFromRGB(0x666666)];
                [self.specificationKeyLabel setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
                [self.specificationKeyLabel setText:specificationAttribute.key];
                [self.specificationKeyLabel sizeToFit];
                [self.specificationTextLabel addSubview:self.specificationKeyLabel];
                
        
                
            }
            
            if(VALID_NOTEMPTY(specificationAttribute.value, NSString)){
                self.specificationValueLabel = [[UILabel alloc] init];
                
                [self.specificationValueLabel setFrame: CGRectMake ((self.specificationTextLabel.frame.size.width/2) + 6.0f,
                                                                                 keyYMargin,
                                                                                 (self.specificationTextLabel.frame.size.width/2) - 12.0f,
                                                                                 12.0f)];
                
                
                [self.specificationValueLabel setNumberOfLines:0];
                [self.specificationValueLabel setTextColor:UIColorFromRGB(0x666666)];
                [self.specificationValueLabel setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
                [self.specificationValueLabel setText:specificationAttribute.value];
                [self.specificationValueLabel sizeToFit];
                [self.specificationTextLabel addSubview:self.specificationValueLabel];
            
                
                keyYMargin = keyYMargin + 26.0f;
                
            }
        }
        
        height = height + CGRectGetMaxY(self.specificationValueLabel.frame) + 2.0f;

        [currentContentView setFrame:CGRectMake(margin,
                                                           startingY,
                                                           self.contenteScrollView.frame.size.width - 12.f,
                                                           height)];
    
        startingY = startingY + currentContentView.frame.size.height + 6.0f;
        height = 44.0f;
    }
    
    [self.mainScrollView addSubview:self.specificationScrollView];
    [self.mainScrollView setContentSize:CGSizeMake(self.contenteScrollView.frame.size.width*2,
                                                   CGRectGetMaxY(self.mainScrollView.frame) - 24.0f)];
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    [self showLoading];
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    CGFloat newHeight = self.view.frame.size.width - self.view.frame.origin.y;
    
    [self setupViews:newWidth height:newHeight];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    [self setupViews:self.view.frame.size.width height:self.view.frame.size.height];
    
    [self hideLoading];

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Swipe Actions
- (IBAction)swipeRight:(id)sender
{
    
    [self.pickerScrollView scrollRightAnimated:YES];
}

- (IBAction)swipeLeft:(id)sender
{
  
    [self.pickerScrollView scrollLeftAnimated:YES];
}

#pragma mark JAPickerScrollView
- (void)selectedIndex:(NSInteger)index
{
    // Summary
    if(0 == index)
    {
        [self.mainScrollView scrollRectToVisible:CGRectMake(index * self.mainScrollView.frame.size.width,
                                                               0.0f,
                                                               self.mainScrollView.frame.size.width,
                                                               self.mainScrollView.frame.size.height) animated:self.animatedScroll];
    }
    // Specifications
    else if(1 == index)
    {
     
            
            [self.mainScrollView scrollRectToVisible:CGRectMake(index * self.mainScrollView.frame.size.width,
                                                                   0.0f,
                                                                   self.mainScrollView.frame.size.width,
                                                                   self.mainScrollView.frame.size.height) animated:self.animatedScroll];
    }
    
    NSNotification *nextNotification = [NSNotification notificationWithName:kOpenSpecificationsScreen object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:index] forKey:@"selected_index"]];
    
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setObject:nextNotification forKey:@"notification"];
            [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"from_side_menu"];
    
    self.animatedScroll = YES;
}

@end

//
//  JASizeGuideViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 09/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASizeGuideViewController.h"
#import "UIImageView+WebCache.h"
#import "JASizeGuideWizardView.h"

@interface JASizeGuideViewController () <UIScrollViewDelegate>

@property (nonatomic, strong)UIImageView* imageView;
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong) JASizeGuideWizardView *wizardView;

@end

@implementation JASizeGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.backButtonTitle = STRING_BACK;
    self.navBarLayout.title = STRING_SIZE_GUIDE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self positionViews];
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(VALID_NOTEMPTY(self.wizardView, JASizeGuideWizardView))
    {
        CGRect newFrame = CGRectMake(self.wizardView.frame.origin.x,
                                     self.wizardView.frame.origin.y,
                                     self.view.frame.size.height + self.view.frame.origin.y,
                                     self.view.frame.size.width - self.view.frame.origin.y);
        [self.wizardView reloadForFrame:newFrame];
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self positionViews];
    
    if(VALID_NOTEMPTY(self.wizardView, JASizeGuideWizardView))
    {
        [self.wizardView reloadForFrame:self.view.bounds];
        [self.view bringSubviewToFront:self.wizardView];
    }
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


- (void)positionViews
{
    [self.scrollView removeFromSuperview];
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.scrollView setFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    if (VALID_NOTEMPTY(self.sizeGuideUrl, NSString)) {
        [self.imageView removeFromSuperview];
        self.imageView = [[UIImageView alloc] init];
        __weak typeof(self) weakSelf = self;
        [self.imageView setImageWithURL:[NSURL URLWithString:self.sizeGuideUrl] success:^(UIImage *image, BOOL cached) {
            [weakSelf resizeWithImage:image];
        } failure:^(NSError *error) {}];
     
        [self.imageView setFrame:self.scrollView.bounds];
        [self.scrollView addSubview:self.imageView];
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:kJASizeGuideWizardUserDefaultsKey] == NO)
    {
        self.wizardView = [[JASizeGuideWizardView alloc] initWithFrame:self.view.bounds];
        [self setupWizardView:self.wizardView];
    }
}


-(void)setupWizardView:(JAWizardView *)wizardView
{
    [self.view addSubview:wizardView];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJASizeGuideWizardUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resizeWithImage:(UIImage*)image
{
    if (image.size.height < self.view.frame.size.height ||
        image.size.width < self.view.frame.size.width)
    {
        CGSize scrolableArea = CGSizeMake(image.size.width, image.size.height);
        [self.scrollView setContentSize:scrolableArea];
        
        self.scrollView.bounces = NO;
        
        self.imageView.contentMode = UIViewContentModeTop;
    }
}


#pragma mark - UIScrollView

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end

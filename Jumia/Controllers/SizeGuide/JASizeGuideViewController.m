//
//  JASizeGuideViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 09/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASizeGuideViewController.h"
#import "UIImageView+WebCache.h"

@interface JASizeGuideViewController () <UIScrollViewDelegate>

@property (nonatomic, strong)UIImageView* imageView;
@property (nonatomic, strong)UIScrollView* scrollView;

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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self positionViews];
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
}

- (void)resizeWithImage:(UIImage*)image
{
    if (image.size.height < self.view.frame.size.height ||
        image.size.width < self.view.frame.size.width) {
        self.imageView.contentMode = UIViewContentModeCenter;
    }
}


#pragma mark - UIScrollView

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}



@end

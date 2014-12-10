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
    
    
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.scrollView setFrame:self.view.bounds];
    if (VALID_NOTEMPTY(self.sizeGuideUrl, NSString)) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
        [self.imageView setImageWithURL:[NSURL URLWithString:self.sizeGuideUrl]];
        [self.scrollView addSubview:self.imageView];
        self.scrollView.contentSize = self.view.frame.size;
    }
}

#pragma mark - UIScrollView

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}



@end

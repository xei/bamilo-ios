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
//$WIZ$
//@property (nonatomic, strong) JASizeGuideWizardView *wizardView;

@end

@implementation JASizeGuideViewController
{
    UIImage *sizeGuideImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navBarLayout setShowBackButton:YES];
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
    //$WIZ$
//    if(VALID_NOTEMPTY(self.wizardView, JASizeGuideWizardView))
//    {
//        CGRect newFrame = CGRectMake(self.wizardView.frame.origin.x,
//                                     self.wizardView.frame.origin.y,
//                                     self.view.frame.size.height + self.view.frame.origin.y,
//                                     self.view.frame.size.width - self.view.frame.origin.y);
//        [self.wizardView reloadForFrame:newFrame];
//    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self positionViews];
    
    //$WIZ$
//    if(VALID_NOTEMPTY(self.wizardView, JASizeGuideWizardView))
//    {
//        [self.wizardView reloadForFrame:self.view.bounds];
//        [self.view bringSubviewToFront:self.wizardView];
//    }
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


- (void)positionViews
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        [self onErrorResponse:RIApiResponseNoInternetConnection messages:nil showAsMessage:NO selector:@selector(positionViews) objects:nil];
        [self hideLoading];
    } else {
        if(sizeGuideImage == nil)
        {
            if (!self.sizeGuideUrl) {
                [self onErrorResponse:RIApiResponseUnknownError messages:nil showAsMessage:NO selector:@selector(positionViews) objects:nil];
                return ;
            }
            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
            [self showLoading];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_async(queue, ^{
                
                
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.sizeGuideUrl]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideLoading];
                    if (!imageData) {
                        [self onErrorResponse:RIApiResponseUnknownError messages:nil showAsMessage:NO selector:@selector(positionViews) objects:nil];
                        return;
                    }
                    UIImage *image = [UIImage imageWithData:imageData];
                    sizeGuideImage = image;
                    [self setupScrollViewBasedOnImage:sizeGuideImage];

                    //$WIZ$
//                    if(VALID_NOTEMPTY(self.wizardView, JASizeGuideWizardView))
//                    {
//                        [self.wizardView reloadForFrame:self.view.bounds];
//                        [self.view bringSubviewToFront:self.wizardView];
//                    }
                });
            });
        }
        else
        {
            [self setupScrollViewBasedOnImage:sizeGuideImage];
        }
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:kJASizeGuideWizardUserDefaultsKey] == NO)
        {
            [self hideLoading];
            //$WIZ$
//            self.wizardView = [[JASizeGuideWizardView alloc] initWithFrame:self.view.bounds];
//            [self setupWizardView:self.wizardView];
        }
    }
}


/**
 * utility method to set up the scroll view based on the image that will be used in the scroll view
 *
 * @param: UIImage image    image to add to the scroll view
 */
-(void)setupScrollViewBasedOnImage:(UIImage *)image
{
    [self.scrollView removeFromSuperview];
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.scrollView setFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    [self.imageView removeFromSuperview];
    self.imageView = [[UIImageView alloc] init];
    [self.imageView setImage:image];
    
    self.scrollView.contentSize = image.size;
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.zoomScale = minScale;
    self.scrollView.bounces = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self centerScrollViewContents];
    
    [self.imageView setFrame:self.scrollView.bounds];
    [self.scrollView addSubview:self.imageView];
}


/**
 * adjusts the contents of the scroll view so that they show up 
 * centered in the scroll view
 *
 */
-(void)centerScrollViewContents
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if(contentsFrame.size.width < boundsSize.width)
    {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    }
    else
    {
        contentsFrame.origin.x = 0.0f;
    }
    
    if(contentsFrame.size.height < boundsSize.height)
    {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    }
    else
    {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}


-(void)setupWizardView:(JAWizardView *)wizardView
{
    [self.view addSubview:wizardView];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJASizeGuideWizardUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - UIScrollView

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end

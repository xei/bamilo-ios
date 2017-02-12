//
//  LoadingManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "LoadingManager.h"

@interface LoadingManager()
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIImageView *loadingAnimationView;
@end

@implementation LoadingManager {
@private
    int _pendingRequestsCount;
}

- (instancetype)init {
    if (self = [super init]) {
        _pendingRequestsCount = 0;
        
        self.loadingView = [[UIView alloc] initWithFrame:CGRectZero];
        self.loadingView.backgroundColor = [UIColor blackColor];
        self.loadingView.alpha = 0.0f;
        self.loadingView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelLoading)];
        [self.loadingView addGestureRecognizer:tap];
        
        UIImage *image = [UIImage imageNamed:@"loadingAnimationFrame1"];
        
        int lastFrame = 8;
        
        self.loadingAnimationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        self.loadingAnimationView.animationDuration = 1.0f;
        NSMutableArray *animationFrames = [NSMutableArray new];
        for (int i = 1; i <= lastFrame; i++) {
            NSString *frameName = [NSString stringWithFormat:@"loadingAnimationFrame%d", i];
            UIImage *frame = [UIImage imageNamed:frameName];
            [animationFrames addObject:frame];
        }
        self.loadingAnimationView.animationImages = [animationFrames copy];
        self.loadingView.alpha = 0.0f;
    }
    
    return self;
}

static LoadingManager *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LoadingManager alloc] init];
    });
    
    return instance;
}

-(void)showLoadingOn:(id)viewcontroller {
    if([viewcontroller isKindOfClass:[UIViewController class]]) {
        UIViewController *targetViewController = ((UIViewController *)viewcontroller);
        
        _pendingRequestsCount++;
        
        if(_pendingRequestsCount == 1) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            [self.loadingView setFrame:CGRectMake(0, 0, targetViewController.view.bounds.size.width, targetViewController.view.bounds.size.height)];
            self.loadingAnimationView.center = self.loadingView.center;
            
            
            [targetViewController.view addSubview:self.loadingView];
            [targetViewController.view addSubview:self.loadingAnimationView];
            
            [self.loadingAnimationView startAnimating];
            
            [UIView animateWithDuration:0.4f animations: ^{
                self.loadingView.alpha = 0.5f;
                self.loadingAnimationView.alpha = 0.5f;
            }];
        }
    }
}

-(void)hideLoading {
    _pendingRequestsCount--;
    
    if(_pendingRequestsCount < 0) {
        _pendingRequestsCount = 0;
    }
    
    if(_pendingRequestsCount == 0) {
        [UIView animateWithDuration:0.4f animations: ^{
            self.loadingView.alpha = 0.0f;
            self.loadingAnimationView.alpha = 0.0f;
        } completion: ^(BOOL finished) {
            [self.loadingView removeFromSuperview];
            [self.loadingAnimationView removeFromSuperview];
        }];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma mark - Private Methods
- (void)cancelLoading { [[NSNotificationCenter defaultCenter] postNotificationName:kCancelLoadingNotificationName object:nil];
}

@end

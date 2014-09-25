//
//  JANoConnectionView.m
//  Jumia
//
//  Created by Miguel Chaves on 22/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANoConnectionView.h"

@interface JANoConnectionView ()

@property (weak, nonatomic) IBOutlet UIView *noNetworkView;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
// No internet connection
@property (weak, nonatomic) IBOutlet UIImageView *noInternetImageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
// Generic error
@property (weak, nonatomic) IBOutlet UIImageView *genericImageView;
@property (weak, nonatomic) IBOutlet UILabel *genericErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *genericDetailLabel;

@end

@implementation JANoConnectionView

void(^retryBock)(BOOL dismiss);

+ (JANoConnectionView *)getNewJANoConnectionView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JANoConnectionView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JANoConnectionView class]]) {
            return (JANoConnectionView *)obj;
        }
    }
    
    return nil;
}

- (void)setupNoConnectionViewForNoInternetConnection:(BOOL)internetConnection
{
    [self.retryButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                           forState:UIControlStateNormal];
    
    [self.retryButton setTitle:@"Try Again"
                      forState:UIControlStateNormal];
    
    self.backgroundColor = UIColorFromRGB(0xc8c8c8);
    self.noNetworkView.layer.cornerRadius = 4.0f;
    self.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.genericErrorLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.genericDetailLabel.textColor = UIColorFromRGB(0x4e4e4e);
    
    if (internetConnection)
    {
        self.textLabel.text = @"No Network";
        
        self.noInternetImageView.hidden = NO;
        self.textLabel.hidden = NO;
        self.genericImageView.hidden = YES;
        self.genericErrorLabel.hidden = YES;
        self.genericDetailLabel.hidden = YES;
    }
    else
    {
        self.noInternetImageView.hidden = YES;
        self.textLabel.hidden = YES;
        self.genericImageView.hidden = NO;
        self.genericErrorLabel.hidden = NO;
        self.genericDetailLabel.hidden = NO;
        
        self.genericErrorLabel.text = @"Oops!";
        self.genericDetailLabel.text = @"Something seems broken. Please try again.";
    }
}

- (IBAction)retryConnectionButtonTapped:(id)sender
{
    if (retryBock) {
        retryBock(YES);
    }
    
    if ([self.delegate respondsToSelector:@selector(retryConnection)]) {
        [self.delegate retryConnection];
    }
    
    [self removeFromSuperview];
}

- (void)setRetryBlock:(void(^)(BOOL dismiss))completion
{
    retryBock = completion;
}

@end

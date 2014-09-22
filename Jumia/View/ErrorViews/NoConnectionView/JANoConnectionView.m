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
@property (weak, nonatomic) IBOutlet UIImageView *noInternetImageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;

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

- (void)setupNoConnectionView
{
    self.backgroundColor = UIColorFromRGB(0xc8c8c8);
    self.noNetworkView.layer.cornerRadius = 4.0f;
    self.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
    
    [self.retryButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                           forState:UIControlStateNormal];
    
    self.textLabel.text = @"No Network";

    [self.retryButton setTitle:@"Try Again"
                      forState:UIControlStateNormal];
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

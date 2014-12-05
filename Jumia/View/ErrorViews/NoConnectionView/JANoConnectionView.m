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
@property (weak, nonatomic) IBOutlet UIView *noInternetFirstView;
@property (weak, nonatomic) IBOutlet UIView *errorFirstView;

@end

@implementation JANoConnectionView

void(^retryBock)(BOOL dismiss);

+ (JANoConnectionView *)getNewJANoConnectionView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JANoConnectionView"
                                                 owner:nil
                                               options:nil];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        xib = [[NSBundle mainBundle] loadNibNamed:@"JANoConnectionView~iPad" owner:nil options:nil];
    }
    
    for (NSObject *obj in xib)
    {
        if ([obj isKindOfClass:[JANoConnectionView class]])
        {
            return (JANoConnectionView *)obj;
        }
    }
    return nil;
}

- (void)setupNoConnectionViewForNoInternetConnection:(BOOL)internetConnection
{
    self.translatesAutoresizingMaskIntoConstraints = YES;
    self.backgroundColor = UIColorFromRGB(0xc8c8c8);
    self.noNetworkView.layer.cornerRadius = 5.0f;

    [self.retryButton setTitle:STRING_TRY_AGAIN forState:UIControlStateNormal];
    [self.retryButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    
    self.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.genericErrorLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.genericDetailLabel.textColor = UIColorFromRGB(0x4e4e4e);
    
    if (internetConnection)
    {
        self.textLabel.text = STRING_NO_NEWTORK;
        
        self.noInternetImageView.hidden = NO;
        self.textLabel.hidden = NO;
        self.genericImageView.hidden = YES;
        self.genericErrorLabel.hidden = YES;
        self.genericDetailLabel.hidden = YES;
        self.errorFirstView.hidden = YES;
        self.noInternetFirstView.hidden = NO;
    }
    else
    {
        self.noInternetImageView.hidden = YES;
        self.textLabel.hidden = YES;
        self.genericImageView.hidden = NO;
        self.genericErrorLabel.hidden = NO;
        self.genericDetailLabel.hidden = NO;
        self.errorFirstView.hidden = NO;
        self.noInternetFirstView.hidden = YES;
        
        self.genericErrorLabel.text = STRING_OOPS;
        self.genericDetailLabel.text = STRING_SOMETHING_BROKEN;
    }
}

- (IBAction)retryConnectionButtonTapped:(id)sender
{
    if (retryBock)
    {
        retryBock(YES);
    }
        
    [self removeFromSuperview];
}

- (void)setRetryBlock:(void(^)(BOOL dismiss))completion
{
    retryBock = completion;
}

@end

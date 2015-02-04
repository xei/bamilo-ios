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
@property (weak, nonatomic) IBOutlet UILabel *noConnectionDetailsLabel;

@property (strong, nonatomic) UIImageView *animationView;

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
    self.noConnectionDetailsLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.genericErrorLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.genericDetailLabel.textColor = UIColorFromRGB(0x4e4e4e);
    
    CGRect buttonTextLabelRect = [self.textLabel.text boundingRectWithSize: CGSizeMake(self.retryButton.frame.size.width, self.retryButton.frame.size.height)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes: @{NSFontAttributeName:self.textLabel.font} context:nil];
    
    [self.textLabel setFrame:(CGRectMake((self.retryButton.frame.size.width - buttonTextLabelRect.size.width)/2,
                                         self.textLabel.frame.origin.y,
                                         buttonTextLabelRect.size.width,
                                         buttonTextLabelRect.size.height))];
    
    UIImage *tryAgainImage = [UIImage imageNamed:@"tryAgainAnimationF1"];
    CGFloat offset = 40.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        offset = 50.0f;
    }
    self.animationView = [[UIImageView alloc] initWithFrame:CGRectMake(self.textLabel.frame.origin.x - offset - tryAgainImage.size.width ,
                                                                       (self.retryButton.frame.size.height - tryAgainImage.size.height)/2,
                                                                       tryAgainImage.size.width,
                                                                       tryAgainImage.size.height)];

    [self.animationView setImage:tryAgainImage];
    
    NSMutableArray* animationFrames = [NSMutableArray new];
    for (int i = 1; i <= 25; i++) {
        NSString* frameName = [NSString stringWithFormat:@"tryAgainAnimationF%d", i];
        UIImage* frame = [UIImage imageNamed:frameName];
        [animationFrames addObject:frame];
    }
    
    self.animationView.animationImages = [animationFrames copy];

    self.animationView.animationDuration = 2.0f;
    
    self.animationView.alpha = 1.0f;
    [self.retryButton addSubview:self.animationView];

    if (internetConnection)
    {
        self.textLabel.text = STRING_NO_CONNECTION;
        self.noConnectionDetailsLabel.text = STRING_NO_NETWORK_DETAILS;
        self.noInternetImageView.hidden = NO;
        self.textLabel.hidden = NO;
        self.noConnectionDetailsLabel.hidden = NO;
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
        self.noConnectionDetailsLabel.hidden = YES; 
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
    [self.animationView startAnimating];
    
    if (retryBock)
    {
        retryBock(YES);
    }   
}

- (void)setRetryBlock:(void(^)(BOOL dismiss))completion
{
    retryBock = completion;
}

@end

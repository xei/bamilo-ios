//
//  JANoConnectionView.m
//  Jumia
//
//  Created by Miguel Chaves on 22/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANoConnectionView.h"

@interface JANoConnectionView () {
    NSLock *_lockAnim;
    BOOL _internetConnection;
}

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
@property (nonatomic) BOOL noConnection;
@property (nonatomic, strong) void(^retryBock)(BOOL dismiss);
@end

@implementation JANoConnectionView

+ (JANoConnectionView *)getNewJANoConnectionViewWithFrame:(CGRect)frame {
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JANoConnectionView"
                                                 owner:self
                                               options:nil];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        xib = [[NSBundle mainBundle] loadNibNamed:@"JANoConnectionView~iPad" owner:nil options:nil];
    }
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JANoConnectionView class]]) {
            [((JANoConnectionView *)obj) setFrame:frame];
            return (JANoConnectionView *)obj;
        }
    }
    return nil;
}

- (void)setupNoConnectionViewForNoInternetConnection:(BOOL)internetConnection {
    _internetConnection = internetConnection;
    if (_noConnection) {
        if (!_lockAnim) {
            _lockAnim = [NSLock new];
        }
        [_lockAnim tryLock];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.animationView.layer removeAllAnimations];
            [_lockAnim unlock];
        });
    }
    _noConnection = YES;
    
    
    if (internetConnection) {
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
        [self.textLabel sizeToFit];
        [self.noConnectionDetailsLabel sizeToFit];
        [self.textLabel setXCenterAligned];
        [self.noConnectionDetailsLabel setXCenterAligned];
    } else {
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
        [self.genericErrorLabel sizeToFit];
        [self.genericDetailLabel sizeToFit];
        [self.genericErrorLabel setXCenterAligned];
        [self.genericDetailLabel setXCenterAligned];
    }
    
    self.backgroundColor = JANoConnectionBackground;
    self.noNetworkView.layer.cornerRadius = 5.0f;
    [self.noNetworkView setX:6.f];
    [self.noNetworkView setWidth:self.width - 2 * 6.f];
    [self.noInternetFirstView setX:0.f];
    [self.noInternetFirstView setWidth:self.noNetworkView.width];
    [self.errorFirstView setX:0.f];
    [self.errorFirstView setWidth:self.noNetworkView.width];

    self.retryButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.retryButton.titleLabel.font.pointSize];
    [self.retryButton setTitle:STRING_TRY_AGAIN forState:UIControlStateNormal];
    [self.retryButton setTitleColor:JAButtonTextOrange forState:UIControlStateNormal];
    [self.retryButton setXCenterAligned];
    
    [self.genericImageView setXCenterAligned];
    [self.noInternetImageView setXCenterAligned];
    
    self.textLabel.font = [UIFont fontWithName:kFontRegularName size:self.textLabel.font.pointSize];
    self.textLabel.textColor = JAButtonTextOrange;
    
    self.noConnectionDetailsLabel.font = [UIFont fontWithName:kFontRegularName size:self.noConnectionDetailsLabel.font.pointSize];
    self.noConnectionDetailsLabel.textColor = JAButtonTextOrange;
    [self.noConnectionDetailsLabel setWidth:self.width - 2 * 6.f];
    [self.noConnectionDetailsLabel sizeToFit];
    [self.noConnectionDetailsLabel setXCenterAligned];
    self.genericErrorLabel.font = [UIFont fontWithName:kFontRegularName size:self.genericErrorLabel.font.pointSize];
    self.genericErrorLabel.textColor = JAButtonTextOrange;
    [self.genericErrorLabel setXCenterAligned];
    self.genericDetailLabel.font = [UIFont fontWithName:kFontRegularName size:self.genericDetailLabel.font.pointSize];
    self.genericDetailLabel.textColor = JAButtonTextOrange;
    [self.genericDetailLabel setXCenterAligned];
    
    CGRect buttonTextLabelRect = [self.textLabel.text boundingRectWithSize: CGSizeMake(self.retryButton.frame.size.width, self.retryButton.frame.size.height)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes: @{NSFontAttributeName:self.textLabel.font} context:nil];
    
    CGRect buttonLabel = [self.retryButton.titleLabel.text boundingRectWithSize: CGSizeMake(1000.0f, self.retryButton.frame.size.height)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{NSFontAttributeName:self.textLabel.font} context:nil];
    
    
    
    [self.textLabel setFrame:(CGRectMake((self.retryButton.frame.size.width - buttonTextLabelRect.size.width)/2,
                                         self.textLabel.frame.origin.y,
                                         buttonTextLabelRect.size.width,
                                         buttonTextLabelRect.size.height))];
    [self.textLabel setXCenterAligned];
    
    UIImage *tryAgainImage = [UIImage imageNamed:@"tryAgainAnimationF1"];
    CGFloat offset = 40.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        offset = 50.0f;
    }
    
    if (!self.animationView) {
        self.animationView = [[UIImageView alloc] init];
        [self.retryButton addSubview:self.animationView];
        
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
    }
                           
    CGFloat spaceBetweenLabelandImage = 12.0f;
    CGFloat labelAndImageTotalWidth = tryAgainImage.size.width + spaceBetweenLabelandImage + buttonLabel.size.width;
    
    [self.animationView setFrame:CGRectMake((self.retryButton.frame.size.width - labelAndImageTotalWidth)/2,
                                           (self.retryButton.frame.size.height - tryAgainImage.size.height)/2,
                                           tryAgainImage.size.width,
                                           tryAgainImage.size.height)];
    
    [self.retryButton.titleLabel setFrame:(CGRectMake(self.animationView.frame.origin.x + spaceBetweenLabelandImage,
                                                      self.textLabel.frame.origin.y,
                                                      buttonLabel.size.width,
                                                      buttonLabel.size.height))];
    
    
    if(RI_IS_RTL){
        [self.retryButton flipSubviewPositions];
    }
}

- (void)reDraw {
    [self setupNoConnectionViewForNoInternetConnection:_internetConnection];
}

- (IBAction)retryConnectionButtonTapped:(id)sender
{
    [self.animationView startAnimating];
    
    if (self.retryBock) {
        self.retryBock(YES);
    }   
}

- (void)setRetryBlock:(void(^)(BOOL dismiss))completion {
    self.retryBock = completion;
}

@end

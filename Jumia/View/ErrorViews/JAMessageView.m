//
//  JAMessageView.m
//  Jumia
//
//  Created by Miguel Angelo on 21/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMessageView.h"

@interface JAMessageView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;

@property (assign, nonatomic) CGFloat messageViewHeight;
@property (assign, nonatomic) CGFloat messageViewInitialY;
@property (assign, nonatomic) CGFloat errorImageViewHeight;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL successState;

@end

@implementation JAMessageView

+ (JAMessageView *)getNewJAMessageView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAMessageView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAMessageView class]]) {
            return (JAMessageView *)obj;
        }
    }
    
    return nil;
}

- (void)setupView
{
    self.translatesAutoresizingMaskIntoConstraints = YES;
    self.titleLabel.textAlignment = (NSTextAlignmentLeft);
    
    self.alpha = 0.95f;
    
    self.messageViewHeight = self.frame.size.height;
    self.messageViewInitialY = 64.0f;
    self.errorImageViewHeight = self.errorImageView.frame.size.height;
    
    self.titleLabel.font = [UIFont fontWithName:kFontLightName size:self.titleLabel.font.pointSize];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.titleLabel.textColor = UIColorFromRGB(0xffffff);
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                       self.titleLabel.frame.origin.y,
                                       self.titleLabel.frame.size.width,
                                       0);
    
    self.errorImageView.translatesAutoresizingMaskIntoConstraints = YES;
    self.errorImageView.frame = CGRectMake(self.errorImageView.frame.origin.x,
                                           -self.errorImageViewHeight,
                                           self.errorImageView.frame.size.width,
                                           0);
    
    // Add tap to remove
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(removeView)];
    [self addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTitle:(NSString *)title
         success:(BOOL)success
{
    self.successState = success;
    
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0f
                                                  target:self
                                                selector:@selector(removeView)
                                                userInfo:nil
                                                 repeats:NO];
    
    if(!success)
    {
        self.backgroundColor = UIColorFromRGB(0xe77979);
    }
    else
    {
        self.backgroundColor = UIColorFromRGB(0x7dcb7d);
    }
    
    self.frame = CGRectMake(0.0f,
                            self.messageViewInitialY,
                            self.frame.size.width,
                            0.0f);
    
    self.errorImageView.frame = CGRectMake(self.errorImageView.frame.origin.x,
                                           -self.errorImageViewHeight,
                                           self.errorImageView.frame.size.width,
                                           0.0f);
    
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                       self.titleLabel.frame.origin.y,
                                       self.titleLabel.frame.size.width,
                                       0.0f);
    if (VALID(title, NSString))
    {
        self.titleLabel.text = title;
        [self adjustFrames];
        [UIView animateWithDuration:0.5f
                         animations:^{
                             self.frame = CGRectMake(0.0f,
                                                     self.messageViewInitialY,
                                                     self.frame.size.width,
                                                     self.messageViewHeight);
                             
                             self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                                                0.0f,
                                                                self.titleLabel.frame.size.width,
                                                                self.frame.size.height);
                             if(!success)
                             {
                                 self.errorImageView.frame = CGRectMake(self.errorImageView.frame.origin.x,
                                                                        (self.messageViewHeight - self.errorImageViewHeight)/2,
                                                                        self.errorImageView.frame.size.width,
                                                                        self.errorImageViewHeight);
                             }
                         }];
    }
}

- (void)removeView
{
    if ((self.hidden == NO) && (self != nil))
    {
        [UIView animateWithDuration:0.5f
                         animations:^{
                             self.errorImageView.frame = CGRectMake(self.errorImageView.frame.origin.x,
                                                                    -self.errorImageViewHeight,
                                                                    self.errorImageView.frame.size.width,
                                                                    0.0f);
                             
                             self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                                                self.titleLabel.frame.origin.y,
                                                                self.titleLabel.frame.size.width,
                                                                0.0f);
                             
                             self.frame = CGRectMake(0.0f,
                                                     self.messageViewInitialY,
                                                     self.frame.size.width,
                                                     0.0f);
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
}

- (void)adjustFrames
{
    CGFloat maxHeight = 88.0f;
    CGFloat horizontalMargin = 6.0f;
    CGFloat verticalMargin = 6.0f;
    
    CGFloat titleLabelStartingX = 0.0f;
    CGFloat marginBetweenImageAndText = 10.0f;
    
    CGFloat roundedTitleWidth = 0.0f;
    CGFloat roundedTitleHeight = 0.0f;
    
    if(!self.successState)
    {
        [self.errorImageView setHidden:NO];
        
        CGRect titleLabelRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width - (2 * horizontalMargin) - marginBetweenImageAndText - self.errorImageView.frame.size.width, maxHeight)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil];
        roundedTitleWidth = ceilf(titleLabelRect.size.width);
        roundedTitleHeight = ceilf(titleLabelRect.size.height);
        
        CGFloat leftMargin = (self.frame.size.width - roundedTitleWidth - self.errorImageView.frame.size.width - marginBetweenImageAndText)/2;
        
        titleLabelStartingX = leftMargin + marginBetweenImageAndText + self.errorImageView.frame.size.width;
        
        // Adjust frames
        self.errorImageView.frame = CGRectMake(leftMargin,
                                               self.errorImageView.frame.origin.y,
                                               self.errorImageView.frame.size.width,
                                               self.errorImageView.frame.size.height);
    }
    else
    {
        [self.errorImageView setHidden:YES];
        
        CGRect titleLabelRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width - (2 * horizontalMargin), maxHeight)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil];
        
        roundedTitleWidth = ceilf(titleLabelRect.size.width);
        roundedTitleHeight = ceilf(titleLabelRect.size.height);
        titleLabelStartingX = (self.frame.size.width - roundedTitleWidth)/2;
    }
    
    if(roundedTitleHeight > self.messageViewHeight - (2 * verticalMargin))
    {
        self.messageViewHeight = (2 * verticalMargin) + roundedTitleHeight;
    }
    else if(roundedTitleHeight > maxHeight)
    {
        self.messageViewHeight = 88.0f;
    }
    
    [self.titleLabel setFrame:CGRectMake(titleLabelStartingX,
                                         0.0f,
                                         roundedTitleWidth,
                                         self.titleLabel.frame.size.height)];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self.timer invalidate];
    [self removeFromSuperview];
}

@end

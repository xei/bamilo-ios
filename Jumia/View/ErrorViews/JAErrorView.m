//
//  JAErrorView.m
//  Jumia
//
//  Created by Miguel Angelo on 21/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAErrorView.h"

@interface JAErrorView ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation JAErrorView

+ (JAErrorView *)getNewJAErrorView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAErrorView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAErrorView class]]) {
            return (JAErrorView *)obj;
        }
    }
    
    return nil;
}

- (void)setErrorTitle:(NSString *)title
             andAddTo:(UIViewController *)viewController
{
    if (VALID(title, NSString))
    {
        BOOL findedSuccessView = NO;
        
        for (UIView *view in viewController.view.subviews)
        {
            if ([view isKindOfClass:[JAErrorView class]])
            {
                [((JAErrorView *)view) udpateViewWithNewTitle:title];
                findedSuccessView = YES;
                break;
            }
        }
        
        if (!findedSuccessView)
        {
            CGRect tempFrame = CGRectMake(0,
                                          -44,
                                          320,
                                          44);
            
            self.frame = tempFrame;
            
            self.backgroundColor = UIColorFromRGB(0xe77979);
            self.alpha = 0.95f;
            
            self.titleLabel.textColor = UIColorFromRGB(0xffffff);
            
            self.titleLabel.text = title;
            
            [viewController.view addSubview:self];
            
            [self adjustFrames];
            
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 CGRect newFrame = CGRectMake(0,
                                                              0,
                                                              320,
                                                              44);
                                 
                                 self.frame = newFrame;
                             }];
            
            // Add tap to remove
            self.titleLabel.userInteractionEnabled = YES;
            self.errorImageView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(removeErrorView)];
            [self.titleLabel addGestureRecognizer:tap];
            [self.errorImageView addGestureRecognizer:tap];
            
            [NSTimer scheduledTimerWithTimeInterval:4.0f
                                             target:self
                                           selector:@selector(removeErrorView)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
}

- (void)removeErrorView
{
    if ((self.hidden == NO) && (self != nil))
    {
        [UIView animateWithDuration:0.5f
                         animations:^{
                             CGRect newFrame = CGRectMake(0,
                                                          -44,
                                                          320,
                                                          44);
                             
                             self.frame = newFrame;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
}

- (void)adjustFrames
{
    [self.titleLabel sizeToFit];
    
    float totalWidth = self.titleLabel.frame.size.width + self.errorImageView.frame.size.width + 10; // 10 it's the space in the elements
    
    float remaningSpace = self.frame.size.width - totalWidth;
    
    // Adjust frames
    self.errorImageView.frame = CGRectMake(remaningSpace / 2,
                                           self.errorImageView.frame.origin.y,
                                           self.errorImageView.frame.size.width,
                                           self.errorImageView.frame.size.height);
    
    self.titleLabel.frame = CGRectMake((remaningSpace / 2) + self.errorImageView.frame.size.width + 10,
                                       self.titleLabel.frame.origin.y,
                                       self.titleLabel.frame.size.width,
                                       self.titleLabel.frame.size.height);
    
    [self layoutSubviews];
}

- (void)udpateViewWithNewTitle:(NSString *)newTitle
{
    if (VALID(newTitle, NSString))
    {
        [self.timer invalidate];
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             self.titleLabel.text = newTitle;
                             [self adjustFrames];
                         }];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0f
                                                      target:self
                                                    selector:@selector(removeErrorView)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

@end

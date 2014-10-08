//
//  JAMessageView.m
//  Jumia
//
//  Created by Miguel Angelo on 21/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMessageView.h"

@interface JAMessageView ()

@property (strong, nonatomic) NSTimer *timer;

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

- (void)setTitle:(NSString *)title
         success:(BOOL)success
           addTo:(UIViewController *)viewController
{
    if (VALID(title, NSString))
    {
        BOOL findedView = NO;
        
        for (UIView *view in viewController.view.subviews)
        {
            if ([view isKindOfClass:[JAMessageView class]])
            {
                [((JAMessageView *)view) udpateViewWithNewTitle:title success:success];
                findedView = YES;
                break;
            }
        }
        
        if (!findedView)
        {
            self.frame = CGRectMake(0, 64, 320, 0);
            self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                               self.titleLabel.frame.origin.y,
                                               self.titleLabel.frame.size.width,
                                               0);
            
            if(!success)
            {
                self.backgroundColor = UIColorFromRGB(0xe77979);
            }
            else
            {
                self.backgroundColor = UIColorFromRGB(0x7dcb7d);
            }
            
            self.alpha = 0.95f;
            
            self.titleLabel.textColor = UIColorFromRGB(0xffffff);
            self.titleLabel.text = title;
            self.titleLabel.numberOfLines = 2;
            
            [viewController.view addSubview:self];
            
            [self adjustFrames:success];
            
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 
                                 self.frame = CGRectMake(0, 64, 320, 44);
                                 self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                                                    self.titleLabel.frame.origin.y,
                                                                    self.titleLabel.frame.size.width,
                                                                    44);
                                 if(!success)
                                 {
                                     self.errorImageView.frame = CGRectMake(self.errorImageView.frame.origin.x,
                                                                            self.errorImageView.frame.origin.y,
                                                                            self.errorImageView.frame.size.width,
                                                                            17);
                                 }
                             }];
            
            // Add tap to remove
            self.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(removeView)];
            [self addGestureRecognizer:tap];
            
            [NSTimer scheduledTimerWithTimeInterval:4.0f
                                             target:self
                                           selector:@selector(removeView)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
}

- (void)removeView
{
    if ((self.hidden == NO) && (self != nil))
    {
        [UIView animateWithDuration:0.5f
                         animations:^{
                             [self.errorImageView setHidden:YES];
                             self.frame = CGRectMake(0, 64, 320, 0);
                             self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                                                self.titleLabel.frame.origin.y,
                                                                self.titleLabel.frame.size.width,
                                                                0);
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
}

- (void)adjustFrames:(BOOL)success
{
    [self.titleLabel sizeToFit];
    
    
    float totalWidth = self.titleLabel.frame.size.width;
    float remaningSpace = self.frame.size.width - totalWidth;
    float leftMargin = (remaningSpace / 2);
    
    if(!success)
    {
        totalWidth += self.errorImageView.frame.size.width + 10; // 10 it's the space in the elements
        remaningSpace = self.frame.size.width - totalWidth;
        leftMargin = (remaningSpace / 2) + self.errorImageView.frame.size.width + 10;

        [self.errorImageView setHidden:NO];
        // Adjust frames
        self.errorImageView.frame = CGRectMake(remaningSpace / 2,
                                               self.errorImageView.frame.origin.y,
                                               self.errorImageView.frame.size.width,
                                               0);
    }
    else
    {
        [self.errorImageView setHidden:YES];
    }
    
    
    self.titleLabel.frame = CGRectMake(leftMargin,
                                       self.titleLabel.frame.origin.y,
                                       self.titleLabel.frame.size.width,
                                       0);
    
    [self layoutSubviews];
}

- (void)udpateViewWithNewTitle:(NSString *)newTitle success:(BOOL)success
{
    if(!success)
    {
        self.backgroundColor = UIColorFromRGB(0xe77979);
    }
    else
    {
        self.backgroundColor = UIColorFromRGB(0x7dcb7d);
    }
    
    if (VALID(newTitle, NSString))
    {
        [self.timer invalidate];
        
        self.titleLabel.text = newTitle;
        [self adjustFrames:success];
        
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                           self.titleLabel.frame.origin.y,
                                           self.titleLabel.frame.size.width,
                                           44);
        if(!success)
        {
            self.errorImageView.frame = CGRectMake(self.errorImageView.frame.origin.x,
                                                   self.errorImageView.frame.origin.y,
                                                   self.errorImageView.frame.size.width,
                                                   17);
        }
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0f
                                                      target:self
                                                    selector:@selector(removeView)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

@end

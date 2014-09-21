//
//  JASuccessView.m
//  Jumia
//
//  Created by Miguel Angelo on 21/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASuccessView.h"

@implementation JASuccessView

+ (JASuccessView *)getNewJASuccessView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JASuccessView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JASuccessView class]]) {
            return (JASuccessView *)obj;
        }
    }
    
    return nil;
}

- (void)setSuccessTitle:(NSString *)title
               andAddTo:(UIViewController *)viewController
{
    if (VALID(title, NSString))
    {
        CGRect tempFrame = CGRectMake(0,
                                     -44,
                                     320,
                                     44);
        
        self.frame = tempFrame;
        
        self.backgroundColor = UIColorFromRGB(0x7dcb7d);
        self.alpha = 0.95f;
        
        self.titleLabel.textColor = UIColorFromRGB(0xffffff);
        
        self.titleLabel.text = title;
        
        [viewController.view addSubview:self];
        
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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(removeSuccessView)];
        [self.titleLabel addGestureRecognizer:tap];
        
        [NSTimer scheduledTimerWithTimeInterval:4.0f
                                         target:self
                                       selector:@selector(removeSuccessView)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)removeSuccessView
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

@end

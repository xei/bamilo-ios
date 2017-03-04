//
//  BMLAlertView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BMLAlertView.h"

@implementation BMLAlertView

-(void)animateSenior {
    self.mainView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.mainView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.mainView.transform = CGAffineTransformIdentity;
        }];
    }];
}

-(void)exit {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.mainView.transform = CGAffineTransformMakeScale(0, 0);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [super exit];
        self.alpha = 1.0f;
    }];
}

@end

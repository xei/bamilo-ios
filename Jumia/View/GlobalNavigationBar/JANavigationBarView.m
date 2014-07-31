//
//  JANavigationBarView.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANavigationBarView.h"

@implementation JANavigationBarView

+ (JANavigationBarView *)getNewNavBarView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JANavigationBarView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JANavigationBarView class]]) {
            return (JANavigationBarView *)obj;
        }
    }
    
    return nil;
}

#pragma mark - Public methods

- (void)changeNavigationBarTitle:(NSString *)newTitle
{
    self.logoImageView.hidden = YES;
    self.titleLabel.text = newTitle;
    self.titleLabel.hidden = NO;
}

- (void)changedToHomeViewController
{
    self.logoImageView.hidden = NO;
    self.titleLabel.hidden = YES;
}

@end

//
//  JASuccessView.h
//  Jumia
//
//  Created by Miguel Angelo on 21/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASuccessView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (JASuccessView *)getNewJASuccessView;

- (void)setSuccessTitle:(NSString *)title
               andAddTo:(UIViewController *)viewController;

@end

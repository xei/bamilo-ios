//
//  JAErrorView.h
//  Jumia
//
//  Created by Miguel Angelo on 21/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAErrorView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;

+ (JAErrorView *)getNewJAErrorView;

- (void)setErrorTitle:(NSString *)title
             andAddTo:(UIViewController *)viewController;

@end

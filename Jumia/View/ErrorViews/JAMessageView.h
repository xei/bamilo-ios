//
//  JAMessageView.h
//  Jumia
//
//  Created by Miguel Angelo on 21/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMessageView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;

+ (JAMessageView *)getNewJAMessageView;

- (void)setTitle:(NSString *)title
         success:(BOOL)success
           addTo:(UIViewController *)viewController;

- (void)udpateViewWithNewTitle:(NSString *)newTitle success:(BOOL)success;

@end

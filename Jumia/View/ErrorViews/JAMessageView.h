//
//  JAMessageView.h
//  Jumia
//
//  Created by Miguel Angelo on 21/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMessageView : UIView

+ (JAMessageView *)getNewJAMessageView;

- (void)setupView;

- (void)setTitle:(NSString *)title
         success:(BOOL)success;

@end

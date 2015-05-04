//
//  JAKickoutView.h
//  Jumia
//
//  Created by Telmo Pinto on 30/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAKickoutView : UIView

- (void)setupKickoutView:(CGRect)frame orientation:(UIInterfaceOrientation)myOrientation;

- (void)setRetryBlock:(void(^)(BOOL dismiss))completion;

@end

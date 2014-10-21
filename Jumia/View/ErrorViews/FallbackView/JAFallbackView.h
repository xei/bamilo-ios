//
//  JAFallbackView.h
//  Jumia
//
//  Created by Telmo Pinto on 17/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAFallbackView : UIView

+ (JAFallbackView *)getNewJAFallbackView;

- (void)setupFallbackView:(CGRect)frame;

@end

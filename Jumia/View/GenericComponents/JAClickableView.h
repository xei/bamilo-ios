//
//  JAClickableView.h
//  Jumia
//
//  Created by Telmo Pinto on 13/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAClickableView : UIView

@property (nonatomic, assign)BOOL selected;

- (void)addTarget:(id)target
           action:(SEL)action
 forControlEvents:(UIControlEvents)controlEvents;

@end

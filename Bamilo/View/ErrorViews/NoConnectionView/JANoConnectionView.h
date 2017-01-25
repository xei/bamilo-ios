//
//  JANoConnectionView.h
//  Jumia
//
//  Created by Miguel Chaves on 22/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JANoConnectionView : UIView

+ (JANoConnectionView *)getNewJANoConnectionViewWithFrame:(CGRect)frame;

- (void)setupNoConnectionViewForNoInternetConnection:(BOOL)internetConnection;

- (IBAction)retryConnectionButtonTapped:(id)sender;

- (void)setRetryBlock:(void(^)(BOOL dismiss))completion;

- (void)reDraw;

@end

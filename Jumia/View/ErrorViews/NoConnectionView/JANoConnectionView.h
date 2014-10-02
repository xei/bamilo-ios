//
//  JANoConnectionView.h
//  Jumia
//
//  Created by Miguel Chaves on 22/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol JANoConnectionViewDelegate <NSObject>
//
//@required
//
//- (void)retryConnection;
//
//@end

@interface JANoConnectionView : UIView

//@property (weak, nonatomic) id<JANoConnectionViewDelegate> delegate;

+ (JANoConnectionView *)getNewJANoConnectionView;

- (void)setupNoConnectionViewForNoInternetConnection:(BOOL)internetConnection;

- (IBAction)retryConnectionButtonTapped:(id)sender;

- (void)setRetryBlock:(void(^)(BOOL dismiss))completion;

@end

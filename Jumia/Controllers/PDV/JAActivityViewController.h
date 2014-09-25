//
//  JAActivityViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JAActivityViewController;

@protocol JAActivityViewControllerDelegate <NSObject>

@optional

- (void)willDismissActivityViewController:(JAActivityViewController *)activityViewController;

@end

@interface JAActivityViewController : UIActivityViewController

@property (nonatomic, weak) id<JAActivityViewControllerDelegate> delegate;

@end

//
//  JAHomeViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAPickerScrollView.h"
#import "JAShopWebViewController.h"
#import "MPCoachMarks.h"
#import "JATeaserPageView.h"

@interface JAHomeViewController : JABaseViewController <JAPickerScrollViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) JATeaserPageView* teaserPageView;
- (void)stopLoading;

@end

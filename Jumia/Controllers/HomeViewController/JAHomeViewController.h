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

@interface JAHomeViewController : JABaseViewController
<
JAPickerScrollViewDelegate,
UIScrollViewDelegate
>

@property (nonatomic, retain) NSString* A4SViewControllerAlias;

- (void)stopLoading;

@end

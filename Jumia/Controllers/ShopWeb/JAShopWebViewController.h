//
//  JAShopWebViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 06/02/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@interface JAShopWebViewController : JABaseViewController <UIWebViewDelegate>

@property (nonatomic, strong)NSString* targetString;

@property (nonatomic, strong) NSString* teaserTrackingInfo;

@end

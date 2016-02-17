//
//  JANewsletterSubscriptionViewController.h
//  Jumia
//
//  Created by telmopinto on 15/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@protocol JANewsletterSubscriptionDelegate <NSObject>

- (void)newsletterSubscriptionSelected:(BOOL)selected;

@end

@interface JANewsletterSubscriptionViewController : JABaseViewController

@property (nonatomic, strong) NSString* targetString;
@property (nonatomic, assign) id<JANewsletterSubscriptionDelegate>delegate;

@end

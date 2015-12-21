//
//  JASignInViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASignInViewController : JABaseViewController

@property (nonatomic, retain) NSString* A4SViewControllerAlias;
@property (nonatomic, assign) BOOL fromSideMenu;
@property (nonatomic, strong) void(^nextStepBlock)(void);
@property (nonatomic, strong) NSString *authenticationEmail;

@end

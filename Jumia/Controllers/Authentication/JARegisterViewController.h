//
//  JARegisterViewController.h
//  Jumia
//
//  Created by Jose Mota on 01/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@interface JARegisterViewController : JABaseViewController

@property (nonatomic, retain) NSString* A4SViewControllerAlias;
@property (nonatomic, assign) BOOL fromSideMenu;
@property (nonatomic, strong) void(^nextStepBlock)(void);
@property (nonatomic, strong) NSString *authenticationEmail;

@end

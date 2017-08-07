//
//  SignUpViewController.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationBaseViewController.h"
#import "DataServiceProtocol.h"
#import "FormViewControl.h"
#import "AuthenticationDelegate.h"

@interface SignUpViewController : AuthenticationBaseViewController <DataServiceProtocol, FormViewControlDelegate>

@property (nonatomic, assign) BOOL fromSideMenu;
@property (weak, nonatomic) id<AuthenticationDelegate> delegate;

@end

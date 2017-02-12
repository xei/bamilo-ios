//
//  SignInViewController.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationBaseViewController.h"
#import "DataServiceProtocol.h"

@interface SignInViewController : AuthenticationBaseViewController <DataServiceProtocol, UIScrollViewDelegate, UITextFieldDelegate>

@end

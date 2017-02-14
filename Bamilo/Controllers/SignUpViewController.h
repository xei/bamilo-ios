//
//  SignUpViewController.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationBaseViewController.h"
#import "FormViewController.h"
#import "DataManager.h"

@interface SignUpViewController : FormViewController <DataServiceProtocol, UITextFieldDelegate>
@property (nonatomic, assign) BOOL fromSideMenu;
@property (nonatomic, strong) void(^nextStepBlock)(void);
@end

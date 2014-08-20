//
//  JACartViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@interface JACartViewController : JABaseViewController

@property (weak, nonatomic) IBOutlet UIView *emptyCartView;
@property (weak, nonatomic) IBOutlet UILabel *emptyCartLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingButton;
//@property (weak, nonatomic) IBOutlet UIButton *goToLogin;
//@property (weak, nonatomic) IBOutlet UIButton *loginAndGoToAddresses;

@end

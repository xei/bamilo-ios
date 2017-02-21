//
//  AddressEditViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewController.h"
#import "ProtectedViewControllerProtocol.h"
#import "ArgsReceiverProtocol.h"
#import "FormViewControl.h"
#import "Address.h"

@interface AddressEditViewController : BaseViewController <ProtectedViewControllerProtocol, ArgsReceiverProtocol, FormViewControlDelegate>

@property (nonatomic, copy) NSString *addressUID;

@end

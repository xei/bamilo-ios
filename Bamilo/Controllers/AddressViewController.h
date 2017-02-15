//
//  AddressTableViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProtectedViewControllerProtocol.h"
#import "DataServiceProtocol.h"
#import "BaseViewController.h"

@interface AddressViewController : BaseViewController <DataServiceProtocol, ProtectedViewControllerProtocol>

@property (copy, nonatomic) NSString *titleHeaderText;

@end

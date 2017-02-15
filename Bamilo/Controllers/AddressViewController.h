//
//  AddressTableViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProtectedViewController.h"
#import "DataServiceProtocol.h"

@interface AddressViewController : ProtectedViewController <DataServiceProtocol>

@property (copy, nonatomic) NSString *titleHeaderText;

@end

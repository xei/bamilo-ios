//
//  OrderListViewController.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DataServiceProtocol.h"
#import "ProtectedViewControllerProtocol.h"

@interface OrderListViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, DataServiceProtocol, ProtectedViewControllerProtocol>
@end

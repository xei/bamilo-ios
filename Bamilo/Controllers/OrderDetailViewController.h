//
//  OrderDetailViewController.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ProtectedViewControllerProtocol.h"
#import "DataServiceProtocol.h"
#import "Order.h"

@interface OrderDetailViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, ProtectedViewControllerProtocol, DataServiceProtocol>
@property (nonatomic, copy) Order *order;
@end

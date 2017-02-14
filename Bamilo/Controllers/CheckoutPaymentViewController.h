//
//  CheckoutPaymentViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutBaseViewController.h"
#import "RICart.h"
#import "DataServiceProtocol.h"

@interface CheckoutPaymentViewController : CheckoutBaseViewController <DataServiceProtocol, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) RICart *cart;

@end

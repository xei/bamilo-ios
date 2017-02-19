//
//  CartViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataServiceProtocol.h"
#import "RICart.h"
#import "CartEntitySummaryViewControl.h"

@interface CartViewController : JABaseViewController <DataServiceProtocol, UITableViewDataSource, UIScrollViewDelegate, UITableViewDelegate, CartEntitySummaryDelegate>
@property (strong, nonatomic) RICart *cart;
@end

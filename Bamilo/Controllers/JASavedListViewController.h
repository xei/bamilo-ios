//
//  JASavedListViewController.h
//  Jumia
//
//  Created by Jose Mota on 04/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAPicker.h"
#import "ProtectedViewControllerProtocol.h"
#import "DataServiceProtocol.h"

@interface JASavedListViewController : JABaseViewController <ProtectedViewControllerProtocol, DataServiceProtocol>

@end

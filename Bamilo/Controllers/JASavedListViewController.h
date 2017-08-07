//
//  JASavedListViewController.h
//  Jumia
//
//  Created by Jose Mota on 04/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "BaseViewController.h"
#import "JAPicker.h"
#import "ProtectedViewControllerProtocol.h"
#import "DataServiceProtocol.h"

@interface JASavedListViewController : BaseViewController <ProtectedViewControllerProtocol, DataServiceProtocol>

@end

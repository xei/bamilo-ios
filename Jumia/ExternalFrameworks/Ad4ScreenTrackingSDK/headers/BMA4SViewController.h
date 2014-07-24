//
//  A4SViewController.h
//  MultiTester
//
//  Created by fabrice noui on 10/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Base class for view controller.
You should inherit all of your view controller from BMA4SViewController
so the SDK can know which is the active view controller.
This will allow to trigger inApp notification only for specific view.
*/
@interface BMA4SViewController : UIViewController

/** Contains an alias for the controler. The SDK will look for this alias to determine if the current active
controller match the active view controller condition for any inApp Notification.*/
@property (nonatomic, retain) NSString* A4SViewControllerAlias;

@end

/** Base class for Navigation view controller.
 You should inherit all of your NavigationViewController from BMA4SNavigationController
 so the SDK can know which is the active view controller.
 This will allow to trigger inApp notification only for specific view.
 */
@interface BMA4SNavigationController : UINavigationController

/** Contains an alias for the controler. The SDK will look for this alias to determine if the current active
controller match the active view controller condition for any inApp Notification.*/
@property (nonatomic, retain) NSString* A4SViewControllerAlias;

@end
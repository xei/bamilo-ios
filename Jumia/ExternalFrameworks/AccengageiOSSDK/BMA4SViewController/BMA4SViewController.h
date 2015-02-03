//
//  BMA4SViewController.h
//  Accengage SDK 
//
//  Copyright (c) 2010-2014 Accengage. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Use BMA4SViewController if you want show inapp or push notification in this view.
 You can use this ViewController as a standard UIViewController.
 */
@interface BMA4SViewController : UIViewController

/**
 Alias is used in ad4push.com for display inapp/push notification.
 If not defined, you can use the name of the class in ad4Push.com
 */
@property (nonatomic, retain) NSString *A4SViewControllerAlias;

@end

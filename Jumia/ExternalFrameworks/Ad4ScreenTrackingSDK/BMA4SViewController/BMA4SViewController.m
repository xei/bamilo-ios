//
//  A4SViewController.m
//  MultiTester
//
//  Created by fabrice noui on 10/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMA4SViewController.h"

#define A4S_INAPP_NOTIF_VIEW_DID_APPEAR @"A4S_INAPP_NOTIF_VIEW_DID_APPEAR"
#define A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR @"A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR"


@implementation BMA4SViewController
@synthesize A4SViewControllerAlias=A4SViewControllerAlias_;

//--------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	// notify the InAppNotification SDK that this the active view controller
	[[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
}



//--------------------------------------------------------------------------------------------------
- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// notify the InAppNotification SDK that this view controller in no more active
	[[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}


@end
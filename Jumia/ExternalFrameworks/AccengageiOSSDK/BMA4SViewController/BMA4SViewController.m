//
//  BMA4SViewController.m
//  Accengage SDK 
//
//  Copyright (c) 2010-2014 Accengage. All rights reserved.
//

#import "BMA4SViewController.h"

#define A4S_INAPP_NOTIF_VIEW_DID_APPEAR     @"A4S_INAPP_NOTIF_VIEW_DID_APPEAR"
#define A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR  @"A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR"


@implementation BMA4SViewController

#if !__has_feature(objc_arc)
- (void)dealloc
{
    self.A4SViewControllerAlias = nil;
    [super dealloc];
}
#endif

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	// notify the InAppNotification SDK that this is the active view controller
	[[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// notify the InAppNotification SDK that this view controller is no more active
	[[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

@end

//
//  BMA4SBeaconsService.h
//  Accengage SDK 
//
//  Copyright (c) 2010-2015 Accengage. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *
 */
@interface BMA4SBeaconsService : NSObject


/**
 *  Enable or disable the beacons service of the SDK. By default the service 
 *  is disabled.
 *
 *  @param arg YES to enable the service, No to disable it (Default).
 */
+ (void)setBeaconServiceEnabled:(BOOL)arg;

/**
 *  Returns the current state of beacons service.
 *
 *  @return YES if the service is enabled or NO if it is not.
 *
 *  @see setBeaconServiceEnabled:
 */
+ (BOOL)isBeaconServiceEnabled;

/**
 *  Allow or not beacons service to ask needed authorization.
 *
 *  Beacons monitoring requires the Always Authorization access. 
 *  By default and  if needed, the SDK beacon service pushes the 
 *  location authorization.
 *
 *  You can prevent the SDK from asking for the needed authorization by setting
 *  the value to NO. If you disable the automated authorization request, 
 *  you will need to ask Always Authorization manually, otherwise beacons 
 *  service will not be activated.
 *
 *  @param arg YES to enable asking authorization by the SDK (Default), 
 *  No to disable it.
 *
 *  @see [requestAlwaysAuthorization](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/occ/instm/CLLocationManager/requestAlwaysAuthorization)
 */
+ (void)setCanRequestLocationAccess:(BOOL)arg;


/**
 *  Returns YES if the SDK can ask needed authorization NO if it can't.
 *
 *  @return YES if the SDK can ask needed authorization NO if it can't.
 *
 *  @see setCanRequestLocationAccess:
 */
+ (BOOL)canRequestLocationAccess;

/**
 *  Returns a Boolean indicating whether the device supports beacon monitoring.
 *
 *  Beacons monitoring requires iOS 7 (or a more recent version of iOS) and at 
 *  least an iPhone 4S, iPod touch (5th generation), 
 *  iPad (3rd generation or later), or iPad mini.
 *
 *  @return YES if the device is capable of monitoring beacons or NO if it is not.
 */
+ (BOOL)isBeaconMonitoringAvailible;
@end

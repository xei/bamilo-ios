//
//  DeviceManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceManager : NSObject

+(NSString *) getDeviceModel;
+(NSOperatingSystemVersion) getOSVersion;
+(NSString *) getOSVersionFormatted;
+(NSString *) getLocalTimeZoneRFC822Formatted; //RFC 822 Format
+(NSString *) getConnectionType;

@end

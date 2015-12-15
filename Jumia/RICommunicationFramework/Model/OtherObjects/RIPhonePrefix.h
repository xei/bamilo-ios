//
//  RIPhonePrefix.h
//  Jumia
//
//  Created by Jose Mota on 03/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPhonePrefix : NSObject

@property (nonatomic) BOOL disable;
@property (nonatomic) BOOL isDefault;
@property (nonatomic) NSString *label;
@property (nonatomic) NSNumber *value;

+ (RIPhonePrefix *)parse:(NSDictionary *)jsonString;

@end

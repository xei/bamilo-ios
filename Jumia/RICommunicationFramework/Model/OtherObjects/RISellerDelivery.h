//
//  RISellerDelivery.h
//  Jumia
//
//  Created by miguelseabra on 13/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RISellerDelivery : NSObject

@property (nonatomic,strong) NSArray* products;
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* deliveryTime;
@property (nonatomic,strong) NSString* shippingGlobal;

+(RISellerDelivery*) parseSellerDelivery:(NSDictionary*)json;

@end

//
//  RIFieldOption.h
//  Jumia
//
//  Created by Pedro Lopes on 29/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIField;

@interface RIFieldOption : NSManagedObject

@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * isUserSubscribed;
@property (nonatomic, retain) RIField *field;

+ (RIFieldOption *)parseFieldOption:(NSDictionary *)fieldOptionObject;

+ (void)saveFieldOption:(RIFieldOption *)option;

@end

//
//  RIField.h
//  Comunication Project
//
//  Created by Telmo Pinto on 23/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIForm;

@interface RIField : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * requiredMessage;
@property (nonatomic, retain) NSNumber * min;
@property (nonatomic, retain) NSNumber * max;
@property (nonatomic, retain) NSString * regex;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) RIForm *form;

//Class Methods

+ (RIField *)parseField:(NSDictionary *)fieldJSON;
+ (void)saveField:(RIField *)field;

@end

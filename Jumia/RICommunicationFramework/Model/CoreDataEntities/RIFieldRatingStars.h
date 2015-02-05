//
//  RIFieldRatingStars.h
//  Jumia
//
//  Created by Telmo Pinto on 09/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RIFieldRatingStars : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * minStar;
@property (nonatomic, retain) NSNumber * maxStar;
@property (nonatomic, retain) RIField *field;

+ (RIFieldRatingStars*)parseFieldRatingStars:(NSDictionary*)json;
+ (void)saveFieldRatingStars:(RIFieldRatingStars *)fieldRatingStars;

@end

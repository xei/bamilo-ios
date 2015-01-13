//
//  RIFieldRatingStars.m
//  Jumia
//
//  Created by Telmo Pinto on 09/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RIFieldRatingStars.h"


@implementation RIFieldRatingStars

@dynamic uid;
@dynamic title;
@dynamic minStar;
@dynamic maxStar;
@dynamic field;

+ (RIFieldRatingStars*)parseFieldRatingStars:(NSDictionary*)json
{
    RIFieldRatingStars* newFieldRatingStars = (RIFieldRatingStars*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIFieldRatingStars class])];
    
    if ([json objectForKey:@"id_rating_type"]) {
        newFieldRatingStars.uid = [json objectForKey:@"id_rating_type"];
    }
    if ([json objectForKey:@"display_title"]) {
        newFieldRatingStars.title = [json objectForKey:@"display_title"];
    }
    if ([json objectForKey:@"stars"]) {
        
        NSDictionary* stars = [json objectForKey:@"stars"];
        if (VALID_NOTEMPTY(stars, NSDictionary)) {
            if ([stars objectForKey:@"min"]) {
                newFieldRatingStars.minStar = [stars objectForKey:@"min"];
            }
            if ([stars objectForKey:@"max"]) {
                newFieldRatingStars.maxStar = [stars objectForKey:@"max"];
            }
        }
    }
    
    return newFieldRatingStars;
}

+ (void)saveFieldRatingStars:(RIFieldRatingStars *)fieldRatingStars;
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:fieldRatingStars];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end

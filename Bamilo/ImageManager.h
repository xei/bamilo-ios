//
//  ImageManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSUInteger, PlaceHolderImageType) {
    PLACEHOLDER_IMAGE_SMALL,
    PLACEHOLDER_IMAGE_MEDIUM,
    PLACEHOLDER_IMAGE_LARGE
};

@interface ImageManager : NSObject

+(UIImage *) defaultPlaceholder;
+(UIImage *) placeholderWithType:(PlaceHolderImageType)type;

//TEMP
+(NSURL *)getCorrectedUrlForCartItemImageUrl:(NSString *)url;

@end

//
//  ImageManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ImageManager.h"

@implementation ImageManager

+(UIImage *) defaultPlaceholder {
    return [ImageManager placeholderWithType:PLACEHOLDER_IMAGE_LARGE];
}

+(UIImage *) placeholderWithType:(PlaceHolderImageType)type {
    switch (type) {
        case PLACEHOLDER_IMAGE_SMALL:
        case PLACEHOLDER_IMAGE_MEDIUM:
        case PLACEHOLDER_IMAGE_LARGE:
            return [UIImage imageNamed:@"placeholder_gallery"];
    }
}

//TEMP
+(NSURL *)getCorrectedUrlForCartItemImageUrl:(NSString *)url {
    return [NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@"cart" withString:@"catalog_grid_3"]];
}

@end

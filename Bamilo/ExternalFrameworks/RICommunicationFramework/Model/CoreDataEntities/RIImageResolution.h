//
//  RIImageResolution.h
//  Comunication Project
//
//  Created by Pedro Lopes on 23/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RIImage.h"

/**
 * Type of the image
 */
enum {
    RIImageCatalog = 0,
    RIImageCart = 1,
    RIImageProduct = 2,
    RIImageGallery = 3,
    RIImageZoom = 4,
    RIImageRelated = 5,
    RIImageList = 6,
    RIImageGrid = 7
};
typedef NSUInteger RIImageType;

@interface RIImageResolution : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * width;
@property (nonatomic, retain) NSString * height;
@property (nonatomic, retain) NSString * extension;

/**
 * Method to download image resolution array and save it into core data
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)loadImageResolutionsIntoDatabaseForCountry:(NSString*)countryUrl
                              countryUserAgentInjection:(NSString *)countryUserAgentInjection
                                       withSuccessBlock:(void (^)())successBlock
                                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;

/**
 * Method to cancel the request
 *
 * @param the operationID that was returned by the getCountriesWithSuccessBlock:andFailureBlock method
 */
+ (void)cancelRequest:(NSString *)operationID;

/**
 * Method to get a url for a higher resolution of an image
 *
 * @param the current image
 * @return the url of the a higher resolution if it exists, the current image url otherwise
 */
+ (NSString*)getNextResolutionImageForUrl:(RIImage*)image;

/**
 * Method to get a url for a different resolution of an image
 *
 * @param the current image
 * @param the new image resolution
 * @return the url of the new resolution if it exists, the current image url otherwise
 */
+ (NSString*)getNewImageForUrl:(RIImage*)image
                       andType:(RIImageType)imageType;

@end

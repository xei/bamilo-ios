//
//  RIImageResolution.m
//  Comunication Project
//
//  Created by Pedro Lopes on 23/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIImageResolution.h"

#ifndef kImageResolutionRegularExpression
#define kImageResolutionRegularExpression @"(\\-)([a-zA-Z]*)(\\.)"
#endif

#ifndef kImageResolutionWithExtensionRegularExpression
#define kImageResolutionWithExtensionRegularExpression @"(\\-[a-zA-Z]*\\.[a-zA-Z]*)"
#endif

@implementation RIImageResolution

@dynamic identifier;
@dynamic width;
@dynamic height;
@dynamic extension;

+ (NSString*)loadImageResolutionsIntoDatabaseForCountry:(NSString*)countryUrl
                                       withSuccessBlock:(void (^)())successBlock
                                        andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", countryUrl, RI_API_VERSION, RI_API_IMAGE_RESOLUTIONS]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  NSArray* data = [metadata objectForKey:@"data"];
                                                                  if (VALID_NOTEMPTY(data, NSArray))
                                                                  {
                                                                      successBlock([RIImageResolution parseImageResolutions:data]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

+ (NSString*)getNextResolutionImageForUrl:(RIImage*)image
{
    NSString *newImageUrl = nil;
    if(VALID_NOTEMPTY(image, RIImage) && VALID_NOTEMPTY(image.url, NSString)) {
        newImageUrl = image.url;
        NSString *resolutionString = [RIImageResolution getResolutionFormImagePath:newImageUrl];
        if(VALID_NOTEMPTY(resolutionString, NSString)) {
            NSArray *resolutions = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIImageResolution class]) withPropertyName:@"identifier" andPropertyValue:resolutionString];
            if(VALID_NOTEMPTY(resolutions, NSArray))
            {
                RIImageResolution* resolution = [resolutions objectAtIndex:0];
                if(VALID_NOTEMPTY(resolution, RIImageResolution))
                {
                    RIImageResolution *nextResolution = [RIImageResolution getNextResolution:resolution];
                    if(VALID_NOTEMPTY(nextResolution, RIImageResolution))
                    {
                        NSString *simpleUrlImage = [RIImageResolution getSimpleImageUrl:newImageUrl];
                        if(VALID_NOTEMPTY(simpleUrlImage, NSString))
                        {
                            newImageUrl = [NSString stringWithFormat:@"%@-%@.%@", simpleUrlImage, nextResolution.identifier,nextResolution.extension];
                        }
                    }
                }
            }
        }
    }
    return newImageUrl;
}

+ (NSString*)getNewImageForUrl:(RIImage*)image
                       andType:(RIImageType)imageType
{
    NSString *newImageUrl = nil;
    if(VALID_NOTEMPTY(image, RIImage) && VALID_NOTEMPTY(image.url, NSString)) {
        newImageUrl = image.url;
        
        RIImageResolution *resolution = [RIImageResolution getResolutionForType:imageType];
        
        if(VALID_NOTEMPTY(resolution, RIImageResolution))
        {
            NSString *simpleUrlImage = [RIImageResolution getSimpleImageUrl:newImageUrl];
            if(VALID_NOTEMPTY(simpleUrlImage, NSString))
            {
                newImageUrl = [NSString stringWithFormat:@"%@-%@.%@", simpleUrlImage, resolution.identifier,resolution.extension];
            }
        }
    }
    
    return newImageUrl;
}

#pragma mark - Private methods

+ (NSArray*)parseImageResolutions:(NSArray*)imageResolutionsArray;
{
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIImageResolution class])];
    NSMutableArray* imageResolutions = [NSMutableArray new];
    for (NSDictionary* imageResolutionObject in imageResolutionsArray)
    {
        if (VALID_NOTEMPTY(imageResolutionObject, NSDictionary))
        {
            RIImageResolution* imageResolution = [RIImageResolution parseImageResolution:imageResolutionObject];
            [RIImageResolution saveImageResolution:imageResolution];
            [imageResolutions addObject:imageResolution];
        }
    }
    
    return imageResolutions;
}


+ (RIImageResolution *)parseImageResolution:(NSDictionary *)imageResolutionObject
{
    RIImageResolution* imageResolution;
    
    imageResolution = (RIImageResolution*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIImageResolution class])];
    
    if ([imageResolutionObject objectForKey:@"identifier"])
    {
        imageResolution.identifier = [imageResolutionObject objectForKey:@"identifier"];
    }
    if ([imageResolutionObject objectForKey:@"width"])
    {
        imageResolution.width = [imageResolutionObject objectForKey:@"width"];
    }
    if ([imageResolutionObject objectForKey:@"height"])
    {
        imageResolution.height = [imageResolutionObject objectForKey:@"height"];
    }
    if ([imageResolutionObject objectForKey:@"extension"])
    {
        imageResolution.extension = [imageResolutionObject objectForKey:@"extension"];
    }
    
    return imageResolution;
}

+ (void)saveImageResolution:(RIImageResolution *)imageResolution
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:imageResolution];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

/**
 * Method to get resolution according to image type
 *
 * @param the type of the image that we want
 */
+ (RIImageResolution *) getResolutionForType:(RIImageType)imageType
{
    RIImageResolution *resolution = nil;
    NSString *propertyValue = @"";
    switch (imageType) {
        case RIImageCatalog:
            propertyValue = @"catalog";
            break;
        case RIImageCart:
            propertyValue = @"cart";
            break;
        case RIImageProduct:
            propertyValue = @"product";
            break;
        case RIImageGallery:
            propertyValue = @"gallery";
            break;
        case RIImageZoom:
            propertyValue = @"zoom";
            break;
        case RIImageRelated:
            propertyValue = @"related";
            break;
        case RIImageList:
            propertyValue = @"list";
            break;
        case RIImageGrid:
            propertyValue = @"catalog_grid_3";
            break;
        default:
            break;
    }
    
    NSArray *resolutions = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIImageResolution class]) withPropertyName:@"identifier" andPropertyValue:propertyValue];
    if(VALID_NOTEMPTY(resolutions, NSArray))
    {
        resolution = [resolutions objectAtIndex:0];
    }
    
    return resolution;
}

/**
 * Method to remove resolution (e.g: "catalog", "product", ..) and extention from image url
 *
 * @param image url to remove the resolution and extension
 */
+ (NSString*)getSimpleImageUrl:(NSString*) url
{
    NSString *simpleImageUrl = nil;
    
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kImageResolutionWithExtensionRegularExpression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:url options:0 range:NSMakeRange(0, [url length])];
    if(VALID_NOTEMPTY(matches, NSArray))
    {
        NSInteger lastIndex = [matches count] - 1;
        NSTextCheckingResult *match = [matches objectAtIndex:lastIndex];
        NSRange matchRange = [match range];
        simpleImageUrl = [regex stringByReplacingMatchesInString:url options:0 range:matchRange withTemplate:@""];
    }
    
    return simpleImageUrl;
}

/**
 * Method to get image resolution (e.g: "catalog", "product", ..)
 *
 * @param image url to get the resolution from
 */
+ (NSString*)getResolutionFormImagePath:(NSString*) url
{
    NSString *resolution = nil;
    
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kImageResolutionRegularExpression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:url options:0 range:NSMakeRange(0, [url length])];
    if(VALID_NOTEMPTY(matches, NSArray))
    {
        NSInteger lastIndex = [matches count] - 1;
        NSTextCheckingResult *match = [matches objectAtIndex:lastIndex];
        resolution = [url substringWithRange:[match range]];
        if(VALID_NOTEMPTY(resolution, NSString))
        {
            resolution = [resolution stringByReplacingOccurrencesOfString:@"-" withString:@""];
            resolution = [resolution stringByReplacingOccurrencesOfString:@"." withString:@""];
        }
    }
    
    return resolution;
}

/**
 * Method that returns the next higher resolution
 *
 * @param the current image resolution
 */
+ (RIImageResolution *)getNextResolution:(RIImageResolution*) resolution
{
    RIImageResolution *nextResolution = nil;
    NSArray *allResolutions = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIImageResolution class])];
    for(RIImageResolution *newResolution in allResolutions)
    {
        if([newResolution.width floatValue] > [resolution.width floatValue] && [newResolution.height floatValue] > [resolution.height floatValue]
           && (ISEMPTY(nextResolution) || ([newResolution.width floatValue] < [nextResolution.width floatValue] && [newResolution.height floatValue] < [nextResolution.height floatValue])))
        {
            nextResolution = newResolution;
        }
    }
    
    return nextResolution;
}

@end

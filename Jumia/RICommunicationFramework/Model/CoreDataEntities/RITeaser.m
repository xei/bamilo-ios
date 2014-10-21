//
//  RITeaser.m
//  Jumia
//
//  Created by Telmo Pinto on 15/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RITeaser.h"
#import "RITeaserGroup.h"
#import "RITeaserImage.h"
#import "RITeaserProduct.h"
#import "RITeaserText.h"


@implementation RITeaser

@dynamic targetType;
@dynamic teaserGroup;
@dynamic teaserImages;
@dynamic teaserProducts;
@dynamic teaserTexts;

+ (RITeaser *)parseTeaser:(NSDictionary *)json
                   ofType:(NSInteger)type
     countryConfiguration:(RICountryConfiguration*)countryConfiguration;
{
    RITeaser *teaser = (RITeaser*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RITeaser class])];
    
    switch (type) {
        case 0: {
            
            if ([json objectForKey:@"attributes"]) {
                NSDictionary *attributes = [json objectForKey:@"attributes"];
                
                if ([attributes objectForKey:@"image_list"]) {
                    NSArray *imageList = [attributes objectForKey:@"image_list"];
                    
                    NSString *description = @"";
                    
                    if ([attributes objectForKey:@"description"]) {
                        description = [attributes objectForKey:@"description"];
                    }
                    
                    for (NSDictionary *imageDic in imageList) {
                        RITeaserImage *image = [RITeaserImage parseTeaserImage:imageDic];
                        image.teaserDescription = description;
                        image.teaser = teaser;
                        
                        [teaser addTeaserImagesObject:image];
                    }
                }
                
                //It will tell us what type of link the image has
                if ([attributes objectForKey:@"target_type"]) {
                    NSString* targetTypeString = [attributes objectForKey:@"target_type"];
                    NSNumberFormatter * f = [NSNumberFormatter new];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    teaser.targetType = [f numberFromString:targetTypeString];
                }
            }
            
        }
            break;
            
        case 1: {
            
            if ([json objectForKey:@"attributes"]) {
                NSDictionary *attributes = [json objectForKey:@"attributes"];
                
                if ([attributes objectForKey:@"image_list"]) {
                    NSArray *imageList = [attributes objectForKey:@"image_list"];
                    
                    NSString *description = @"";
                    
                    if ([attributes objectForKey:@"description"]) {
                        description = [attributes objectForKey:@"description"];
                    }
                    
                    for (NSDictionary *imageDic in imageList) {
                        RITeaserImage *image = [RITeaserImage parseTeaserImage:imageDic];
                        image.teaserDescription = description;
                        image.teaser = teaser;
                        
                        [teaser addTeaserImagesObject:image];
                    }
                }
                
                if ([attributes objectForKey:@"target_type"]) {
                    NSString* targetTypeString = [attributes objectForKey:@"target_type"];
                    NSNumberFormatter * f = [NSNumberFormatter new];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    teaser.targetType = [f numberFromString:targetTypeString];
                }
            }
        }
            
            break;
            
        case 2: {
            
            
            RITeaserProduct *product = [RITeaserProduct parseTeaserProduct:json countryConfiguration:countryConfiguration];
            product.teaser = teaser;
            
            [teaser addTeaserProductsObject:product];
            
        }
            
            break;
            
        case 3: {
            
            RITeaserText *teaserText = [RITeaserText parseTeaserText:json];
            teaserText.teaser = teaser;
            [teaser addTeaserTextsObject:teaserText];
            
        }
            
            break;
            
        case 4: {
            
            if ([json objectForKey:@"attributes"]) {
                NSDictionary *attributes = [json objectForKey:@"attributes"];
                
                if ([attributes objectForKey:@"image_list"]) {
                    NSArray *imageList = [attributes objectForKey:@"image_list"];
                    
                    for (NSDictionary *imageDic in imageList) {
                        RITeaserImage *image = [RITeaserImage parseTeaserImage:imageDic];
                        
                        if ([attributes objectForKey:@"description"]) {
                            image.teaserDescription = [attributes objectForKey:@"description"];
                        }
                        
                        image.teaser = teaser;
                        [teaser addTeaserImagesObject:image];
                    }
                }
                
                if ([attributes objectForKey:@"target_type"]) {
                    NSString* targetTypeString = [attributes objectForKey:@"target_type"];
                    NSNumberFormatter * f = [NSNumberFormatter new];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    teaser.targetType = [f numberFromString:targetTypeString];
                }
            }
            
        }
            
            break;
            
        case 5: {
            
            RITeaserText *teaserText = [RITeaserText parseTeaserText:json];
            teaserText.teaser = teaser;
            [teaser addTeaserTextsObject:teaserText];
            
        }
            
            break;
            
        case 6: {
            
            RITeaserText *teaserText = [RITeaserText parseTeaserText:json];
            teaserText.teaser = teaser;
            [teaser addTeaserTextsObject:teaserText];
            
        }
            break;
            
        default:
            break;
    }
    
    return teaser;
}

+ (void)saveTeaser:(RITeaser *)teaser
{
    for (RITeaserImage *image in teaser.teaserImages) {
        [RITeaserImage saveTeaserImage:image];
    }
    
    for (RITeaserProduct *product in teaser.teaserProducts) {
        [RITeaserProduct saveTeaserProduct:product];
    }
    
    for (RITeaserText *text in teaser.teaserTexts) {
        [RITeaserText saveTeaserText:text];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:teaser];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end

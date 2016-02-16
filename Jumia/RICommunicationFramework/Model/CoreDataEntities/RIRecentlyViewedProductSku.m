//
//  RIRecentlyViewedProductSku.m
//  Jumia
//
//  Created by telmopinto on 25/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "RIRecentlyViewedProductSku.h"
#import "RIProduct.h"

@implementation RIRecentlyViewedProductSku

@dynamic productSku;
@dynamic lastViewedDate;
@dynamic brand;
@dynamic numberOfTimesSeen;

+ (void)getRecentlyViewedProductSkusWithSuccessBlock:(void (^)(NSArray *recentlyViewedProductSkus))successBlock;
{
    NSArray* recentlyViewedProductSkus = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIRecentlyViewedProductSku class]) withPropertyName:@"lastViewedDate"];
    
    if (VALID(recentlyViewedProductSkus, NSArray)) {
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                            sortDescriptorWithKey:@"lastViewedDate"
                                            ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
        NSArray *sortedArray = [recentlyViewedProductSkus
                                sortedArrayUsingDescriptors:sortDescriptors];
        
        successBlock(sortedArray);
    } else {
        successBlock(nil);
    }
}

+ (void)addToRecentlyViewed:(RIProduct*)product
               successBlock:(void (^)(void))successBlock
            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    NSArray* allRecentlyViewedProductSkus = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIRecentlyViewedProductSku class])];
    
    BOOL productExists = NO;
    for (RIRecentlyViewedProductSku* currentProductSku in allRecentlyViewedProductSkus) {
        if ([currentProductSku.productSku isEqualToString:product.sku]) {
            
            //found it, so just update the last viewed date
            currentProductSku.lastViewedDate = [NSDate date];
            [RIRecentlyViewedProductSku saveRecentlyViewedProductSku:currentProductSku andContext:YES];
            productExists = YES;
            break;
        }
    }
    
    if (NO == productExists) {
        //did not find it, so create a new object and save
        RIRecentlyViewedProductSku* newRecentlyViewedProductSku = (RIRecentlyViewedProductSku*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIRecentlyViewedProductSku class])];
        
        newRecentlyViewedProductSku.productSku = product.sku;
        newRecentlyViewedProductSku.brand = product.brand;
        newRecentlyViewedProductSku.lastViewedDate = [NSDate date];
        [RIRecentlyViewedProductSku saveRecentlyViewedProductSku:newRecentlyViewedProductSku andContext:YES];
    }
    
    //now we need to check if there are more than 15 products
    [RIRecentlyViewedProductSku getRecentlyViewedProductSkusWithSuccessBlock:^(NSArray *recentlyViewedProductSkus) {
        //there are more than 15, we need to remove the oldest
        if (VALID_NOTEMPTY(recentlyViewedProductSkus, NSArray) && recentlyViewedProductSkus.count > 15) {
            //NSArray recentlyViewedProductSkus is already ordered in getRecentlyViewedProductSkusWithSuccessBlock
            RIRecentlyViewedProductSku* productSkuToDelete = [recentlyViewedProductSkus lastObject];
            
            if (VALID_NOTEMPTY(productSkuToDelete, RIRecentlyViewedProductSku)) {
                [[RIDataBaseWrapper sharedInstance] deleteObject:productSkuToDelete];
            }
            
            [[RIDataBaseWrapper sharedInstance] saveContext];
        }
        if (successBlock) {
            successBlock();
        }
    }];
}

+ (void)removeFromRecentlyViewed:(RIProduct *)product;
{
    NSArray* recentlyViewedProductSkus = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIRecentlyViewedProductSku class]) withPropertyName:@"productSku" andPropertyValue:product.sku];
    
    for (RIRecentlyViewedProductSku* currentProductSku in recentlyViewedProductSkus) {
        [[RIDataBaseWrapper sharedInstance] deleteObject:currentProductSku];
    }
    
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (void)removeAllRecentlyViewedProductSkus
{
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIRecentlyViewedProductSku class])];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (void)resetRecentlyViewedWithProducts:(NSArray *)productsArray
                           successBlock:(void (^)(NSArray* productsArray))successBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    [RIRecentlyViewedProductSku getRecentlyViewedProductSkusWithSuccessBlock:^(NSArray *recentlyViewedProductSkus) {
        
        for (RIRecentlyViewedProductSku* currentProductSku in recentlyViewedProductSkus) {
            
            BOOL shouldDelete = YES;
            
            for (RIProduct* product in productsArray) {
                
                if ([currentProductSku.productSku isEqualToString:product.sku]) {
                    
                    shouldDelete = NO;
                    break;
                }
            }
            
            if (YES == shouldDelete) {
                [[RIDataBaseWrapper sharedInstance] deleteObject:currentProductSku];
            }
        }
        [[RIDataBaseWrapper sharedInstance] saveContext];
        
        if (successBlock) {
            successBlock(productsArray);
        }
        
    }];
}

+ (void)saveRecentlyViewedProductSku:(RIRecentlyViewedProductSku *)recentlyViewedProductSku andContext:(BOOL)save
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:recentlyViewedProductSku];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
}

@end

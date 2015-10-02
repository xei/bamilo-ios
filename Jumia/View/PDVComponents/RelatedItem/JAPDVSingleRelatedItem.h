//
//  JAPDVSingleRelatedItem.h
//  Jumia
//
//  Created by Miguel Chaves on 05/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"
#import "RIProduct.h"
#import "RISearchSuggestion.h"

@interface JAPDVSingleRelatedItem : JAClickableView

@property (strong, nonatomic) RIProduct *product;
@property (strong, nonatomic) RISearchTypeProduct *searchTypeProduct;
@property (strong, nonatomic) NSString *productUrl;

@end

//
//  JAPDVSingleRelatedItem.h
//  Jumia
//
//  Created by Miguel Chaves on 05/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProduct.h"

@interface JAPDVSingleRelatedItem : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageViewItem;
@property (weak, nonatomic) IBOutlet UILabel *labelBrand;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (strong, nonatomic) RIProduct *product;

+ (JAPDVSingleRelatedItem *)getNewPDVSingleRelatedItem;

@end

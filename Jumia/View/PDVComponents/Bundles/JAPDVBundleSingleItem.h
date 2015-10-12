//
//  JAPDVBundleSingleItem.h
//  Jumia
//
//  Created by epacheco on 21/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JAClickableView.h"
#import "RIProduct.h"

@interface JAPDVBundleSingleItem : UIView

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedProduct;
@property (weak, nonatomic) IBOutlet JAClickableView *sizeClickableView;
@property (strong, nonatomic) RIProduct *product;
@property (strong, nonatomic) NSString *productUrl;

@property (nonatomic, assign)BOOL alwaysSelected;
@property (nonatomic, assign)BOOL selected;

+ (JAPDVBundleSingleItem *)getNewPDVBundleSingleItem;

- (void)addSelectTarget:(id)target action:(SEL)selector;

@end

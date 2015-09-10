//
//  JACatalogListCollectionViewCell.h
//  Jumia
//
//  Created by josemota on 7/2/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACatalogCollectionViewCell.h"

#define JACatalogViewControllerListCellHeight_ipad 103.0f
#define JACatalogViewControllerListCellHeight 98.0f
#define JACatalogViewControllerListCellNewLabelX 4.0f
#define JACatalogViewControllerListCellNewLabelY 15.0f
#define JACatalogViewControllerListCellNewLabelX_ipad -2.0f
#define JACatalogViewControllerListCellNewLabelY_ipad 20.0f

@interface JACatalogListCollectionViewCell : JACatalogCollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *quantityButton;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end
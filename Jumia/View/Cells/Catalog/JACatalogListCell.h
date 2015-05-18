//
//  JACatalogListCell.h
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACatalogCell.h"

#define JACatalogViewControllerListCellHeight_ipad 103.0f
#define JACatalogViewControllerListCellHeight 98.0f
#define JACatalogViewControllerListCellNewLabelX 4.0f
#define JACatalogViewControllerListCellNewLabelY 15.0f
#define JACatalogViewControllerListCellNewLabelX_ipad -2.0f
#define JACatalogViewControllerListCellNewLabelY_ipad 20.0f

@interface JACatalogListCell : JACatalogCell

@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *quantityButton;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end

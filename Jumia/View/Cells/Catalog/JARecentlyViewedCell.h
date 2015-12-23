//
//  JARecentlyViewedCell.h
//  Jumia
//
//  Created by Jose Mota on 21/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogListCollectionViewCell.h"
#import "JARadioComponent.h"

@interface JARecentlyViewedCell : JACatalogListCollectionViewCell

@property (nonatomic) UIButton *addToCartButton;
@property (nonatomic) JARadioComponent *sizeComponent;

@end

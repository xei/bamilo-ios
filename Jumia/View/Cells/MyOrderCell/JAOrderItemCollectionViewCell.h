//
//  JAOrderItemCollectionViewCell.h
//  Jumia
//
//  Created by Jose Mota on 08/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIOrder.h"
#import "JAProductInfoPriceLine.h"

@interface JAOrderItemCollectionViewCell : UICollectionViewCell

@property (nonatomic) JAClickableView *feedbackView;
@property (nonatomic) RIItemCollection *item;
@property (nonatomic) UIButton *reorderButton;

@end

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
#import "JAButton.h"

@interface JAOrderItemCollectionViewCell : UICollectionViewCell

@property (nonatomic) JAClickableView *feedbackView;
@property (nonatomic) RIItemCollection *item;
@property (nonatomic) JAButton *reorderButton;
@property (nonatomic) JAButton *returnButton;
@property (nonatomic) UIButton *checkToReturnButton;

@end

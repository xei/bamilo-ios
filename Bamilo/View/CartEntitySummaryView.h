//
//  CartEntitySummaryView.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartEntity.h"
#import "BaseControlView.h"

@protocol CartEntitySummaryViewDelegate <NSObject>
@optional - (void)cartEntitySummeryTapped:(id)view;
@end

@interface CartEntitySummaryView: BaseControlView
@property (nonatomic, strong) CartEntity *cartEntity;
@property (nonatomic, weak) id<CartEntitySummaryViewDelegate> delegate;

- (void)applyColor:(UIColor *)color;
@end

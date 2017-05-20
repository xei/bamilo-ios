//
//  CartEntitySummaryViewControl.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewControl.h"
#import "CartEntitySummaryView.h"

@protocol CartEntitySummaryDelegate <NSObject>
- (void)cartEntityTapped:(id)cartEntityControl;
@end

@interface CartEntitySummaryViewControl : BaseViewControl <CartEntitySummaryViewDelegate>
@property (nonatomic, weak) id<CartEntitySummaryDelegate> delegate;

- (void)applyColor:(UIColor *)color;
@end

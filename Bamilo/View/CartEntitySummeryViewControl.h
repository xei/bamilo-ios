//
//  CartEntitySummeryViewControl.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewControl.h"
#import "CartEntitySummeryView.h"

@protocol CartEntitySummeryDelegate <NSObject>
- (void)cartEntityTapped:(id)cartEntityControl;
@end

@interface CartEntitySummeryViewControl : BaseViewControl <CartEntitySummeryViewDelegate>
@property (nonatomic, weak) id<CartEntitySummeryDelegate> delegate;
@end

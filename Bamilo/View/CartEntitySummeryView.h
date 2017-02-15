//
//  CartEntitySummeryView.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartEntity.h"

@protocol CartEntitySummeryViewDelegate <NSObject>
@optional - (void)cartEntitySummeryTapped:(id)view;
@end

@interface CartEntitySummeryView: UIView
@property (nonatomic, strong) CartEntity *cartEntity;
@property (nonatomic, weak) id<CartEntitySummeryViewDelegate> delegate;
@end

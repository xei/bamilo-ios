//
//  StepperViewControl.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewControl.h"
#import "StepperViewControlDelegate.h"

@interface StepperViewControl : BaseViewControl

@property (weak, nonatomic) id<StepperViewControlDelegate> delegate;
@property (assign, nonatomic) int quantity;
@property (assign, nonatomic) int maxQuantity;
@property (assign, nonatomic) int minQuantity;

@end

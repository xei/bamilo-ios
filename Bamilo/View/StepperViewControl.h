//
//  StepperViewControl.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StepperViewControlDelegate.h"

@interface StepperViewControl : UIView
@property (nonatomic) int quantity;
@property (nonatomic) int maxQuantity;
@property (nonatomic) int minQuantity;
@property (nonatomic, strong) id<StepperViewControlDelegate> delegate;
@end

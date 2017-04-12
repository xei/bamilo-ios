//
//  StepperView.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StepperViewControl.h"

@interface StepperView : UIView
@property (nonatomic) int quantity;
@property (nonatomic) int maxQuantity;
@property (nonatomic) int minQuantity;
@property (nonatomic, weak) StepperViewControl *controller;
@end

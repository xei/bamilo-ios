//
//  RadioButtonViewControl.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewControl.h"
#import "RadioButtonViewControlDelegate.h"

@interface RadioButtonViewControl : BaseViewControl <RadioButtonViewControlDelegate>

@property (assign, nonatomic) BOOL isSelected;
@property (weak, nonatomic) id<RadioButtonViewControlDelegate> delegate;

@end

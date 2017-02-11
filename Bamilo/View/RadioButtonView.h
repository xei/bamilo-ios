//
//  RadioButtonView.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioButtonViewProtocol.h"
#import "RadioButtonViewControlDelegate.h"

@interface RadioButtonView : UIView <RadioButtonViewProtocol>

@property (weak, nonatomic) id<RadioButtonViewControlDelegate> delegate;

@end

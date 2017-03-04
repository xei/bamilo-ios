//
//  StepperViewControlDelegate.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StepperViewControlDelegate

- (void)valueHasBeenChanged:(id) stepperViewControl withNewValue:(int) value;
- (void)wantsToBeMoreThanMax:(id) stepperViewControl;
- (void)wantsToBeLessThanMin:(id) stepperViewControl;
@end


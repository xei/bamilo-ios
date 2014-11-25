//
//  JAHomeWizardView.h
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAWizardView.h"

#define kJAHomeWizardUserDefaultsKey @"homeWizardUserDefaultsKey"

@interface JAHomeWizardView : JAWizardView

- (void)reloadForFrame:(CGRect)frame;

@end

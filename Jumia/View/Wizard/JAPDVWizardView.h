//
//  JAPDVWizardView.h
//  Jumia
//
//  Created by Telmo Pinto on 16/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAWizardView.h"

#define kJAPDVWizardUserDefaultsKey @"pdvWizardUserDefaultsKey"

#define kJAWizardViewFirstImageLeftMargin 170.0f
#define kJAWizardViewThirdImageTopMargin_landscape 205.0f
#define kJAWizardViewThirdImageTopMargin 50.0f

@interface JAPDVWizardView : JAWizardView

@property (nonatomic) BOOL hasNoSeller;

@end

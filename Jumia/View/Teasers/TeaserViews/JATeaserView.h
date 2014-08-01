//
//  JATeaserView.h
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RITeaser.h"
#import "RITeaserProduct.h"
#import "RITeaserImage.h"
#import "RITeaserText.h"

@interface JATeaserView : UIView

@property (nonatomic, strong)NSOrderedSet* teasers;

- (void)load;

@end

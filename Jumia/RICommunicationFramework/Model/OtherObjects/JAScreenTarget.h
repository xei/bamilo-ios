//
//  RIScreenTarget.h
//  Jumia
//
//  Created by Jose Mota on 29/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "RITarget.h"

@interface JAScreenTarget : NSObject

@property (nonatomic, strong) RITarget *target;
@property (nonatomic, strong) JANavigationBarLayout *navBarLayout;
@property (nonatomic) BOOL pushAnimation;
@property (nonatomic, strong) NSDictionary *screenInfo;

@end

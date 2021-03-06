//
//  JATeaserView.h
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RITeaserGrouping.h"
#import "RITeaserComponent.h"

@interface JATeaserView : UIView

@property (nonatomic, strong)RITeaserGrouping* teaserGrouping;
@property (nonatomic, strong)NSArray* validTeaserComponents;

- (void)load;

- (void)teaserPressed:(UIControl*)control;
- (void)teaserPressedForIndex:(NSInteger)index;

//virtual
- (NSString*)teaserTrackingInfoForIndex:(NSInteger)index;

@end

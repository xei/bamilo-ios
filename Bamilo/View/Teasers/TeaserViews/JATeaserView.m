//
//  JATeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATeaserView.h"
#import "RITarget.h"

@implementation JATeaserView

- (void)load {
    self.backgroundColor = [UIColor clearColor];
    if (!self.teaserGrouping) {
        return;
    }
}

- (void)teaserPressed:(UIControl*)control {
    NSInteger index = control.tag;
    [self teaserPressedForIndex:index];
}

- (void)teaserPressedForIndex:(NSInteger)index {
    if (self.teaserGrouping.teaserComponents.count <= index) return;
    RITeaserComponent* teaserComponent = [self.teaserGrouping.teaserComponents objectAtIndex:index];
    if (self.validTeaserComponents) {
        teaserComponent = [self.validTeaserComponents objectAtIndex:index];
    }
    [teaserComponent sendNotificationForTeaseTarget: [self teaserTrackingInfoForIndex:index]];
}

- (NSString*)teaserTrackingInfoForIndex:(NSInteger)index {
    //should be implemented in subclasses
    return nil;
}

@end

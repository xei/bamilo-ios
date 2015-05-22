//
//  UIView+Mirror.h
//  Jumia
//
//  Created by Telmo Pinto on 22/05/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Mirror)

//single view methods
- (void)flipViewPositionInsideSuperview;
- (void)flipViewAlignment;
- (void)flipViewImage;

//subview methods
- (void)flipSubviewPositions;
- (void)flipSubviewAlignments;
- (void)flipSubviewImages;

@end

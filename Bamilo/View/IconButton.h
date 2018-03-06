//
//  IconButton.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseButton.h"

typedef NS_ENUM(NSUInteger, IconButtonPosition) {
    IconButtonPositionLTR = 0,
    IconButtonPositionRTL = 1,
    IconButtonPositionCenter = 2
};

@interface IconButton : BaseButton
@property (nonatomic) IBInspectable CGFloat imageHeightToButtonHeightRatio;
@property (nonatomic) IBInspectable NSUInteger positionStatus;
@end

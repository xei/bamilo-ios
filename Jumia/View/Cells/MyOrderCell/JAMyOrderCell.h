//
//  JAMyOrderCell.h
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIOrder.h"
#import "JAClickableView.h"

@interface JAMyOrderCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UIImageView *portraitArrowImageView;
@property (weak, nonatomic) IBOutlet JAClickableView *clickableView;

- (void)setupWithOrder:(RITrackOrder*)order isInLandscape:(BOOL)isInLandscape;

+ (CGFloat)getCellHeight;

@end

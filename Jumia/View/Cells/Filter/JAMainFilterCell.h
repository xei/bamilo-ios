//
//  JAMainFilterCell.h
//  Jumia
//
//  Created by Telmo Pinto on 21/08/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@class RIFilter;

@interface JAMainFilterCell : UITableViewCell

@property (nonatomic, strong)JAClickableView* clickView;

- (void)setupWithFilter:(RIFilter*)filter options:(NSString*)options width:(CGFloat)width;

@end

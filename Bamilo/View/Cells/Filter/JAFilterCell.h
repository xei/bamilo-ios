//
//  JAFilterCell.h
//  Jumia
//
//  Created by Telmo Pinto on 05/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"


@interface JAFilterCell : UITableViewCell

@property (nonatomic, strong) JAClickableView* clickView;

- (void)setupWithFilter:(id)filter
         cellIsSelected:(BOOL)cellIsSelected
                  width:(CGFloat)width
                 margin:(CGFloat)margin;

+ (CGFloat)height;

@end

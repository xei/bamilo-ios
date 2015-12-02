//
//  JARatingFilterCell.h
//  Jumia
//
//  Created by miguelseabra on 02/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAProductInfoRatingLine.h"
#import "RIFilter.h"

@interface JARatingFilterCell : UITableViewCell

@property (nonatomic, strong) UIImageView* customAccessoryView;
@property (nonatomic, strong) JAProductInfoRatingLine* ratingLine;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
                            isLandscape:(BOOL)isLandscape
                                  frame:(CGRect)frame;

- (void)setFilterOption:(RIFilterOption*)option;

@end

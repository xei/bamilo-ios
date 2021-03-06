//
//  JAColorFilterCell.h
//  Jumia
//
//  Created by Telmo Pinto on 14/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAColorView.h"
#import "JAClickableView.h"

@interface JAColorFilterCell : UITableViewCell

@property (strong, nonatomic) JAColorView *colorView;
@property (strong, nonatomic) UILabel *colorTitleLabel;
@property (nonatomic, strong) UIImageView* customAccessoryView;
@property (nonatomic, strong) UIView* separator;
@property (nonatomic, strong) JAClickableView* clickableView;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier isLandscape:(BOOL)isLandscape frame:(CGRect)frame;
- (void)setupIsLandscape:(BOOL)landscape;
- (void)setFilterOption:(id)option;
+ (CGFloat)height;

@end

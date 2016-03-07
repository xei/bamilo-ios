//
//  JATextFilterCell.h
//  Jumia
//
//  Created by miguelseabra on 02/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIFilter.h"
#import "JAClickableView.h"

@interface JATextFilterCell : UITableViewCell

@property (nonatomic, strong) UIImageView* customAccessoryView;
@property (nonatomic, strong) JAClickableView* clickableView;
@property (nonatomic, strong) UIView* separatorView;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* quantityLabel;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
                            isLandscape:(BOOL)isLandscape
                                  frame:(CGRect)frame;

- (void)setupIsLandscape:(BOOL)landscape;

- (void)setFilterOption:(RIFilterOption*)option;

@end

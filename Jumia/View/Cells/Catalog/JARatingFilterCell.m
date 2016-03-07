//
//  JARatingFilterCell.m
//  Jumia
//
//  Created by miguelseabra on 02/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JARatingFilterCell.h"

@implementation JARatingFilterCell


-(UIImageView *)customAccessoryView {
    if (!VALID(_customAccessoryView, UIImageView)) {
        CGFloat margin = 12.0f;
        UIImage* customAccessoryIcon = [UIImage imageNamed:@"selectionCheckmark"];
        _customAccessoryView = [[UIImageView alloc] initWithImage:customAccessoryIcon];
        _customAccessoryView.frame = CGRectMake(self.ratingLine.frame.size.width - margin - customAccessoryIcon.size.width,
                                               (self.ratingLine.frame.size.height - customAccessoryIcon.size.height) / 2,
                                               customAccessoryIcon.size.width,
                                               customAccessoryIcon.size.height);
        [_customAccessoryView setHidden:YES];
        [self.ratingLine addSubview:_customAccessoryView];
    }
    return _customAccessoryView;
}

-(JAProductInfoRatingLine *)ratingLine {
    if (!VALID(_ratingLine, JAProductInfoRatingLine)) {
        _ratingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectMake(0.0f,
                                                                               0.0f,
                                                                               self.width,
                                                                               self.height)];
        _ratingLine.imageRatingSize = kImageRatingSizeSmall;

        [self addSubview:_ratingLine];
    }
    return _ratingLine;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
                            isLandscape:(BOOL)isLandscape
                                  frame:(CGRect)frame;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = frame;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)setupIsLandscape:(BOOL)landscape {
    CGFloat margin = 12.0f;
    
    [self.customAccessoryView setX:(self.ratingLine.frame.size.width - margin - self.customAccessoryView.width)];
    
    if (RI_IS_RTL) {
        [self.ratingLine flipAllSubviews];
    }
}

-(void)setFilterOption:(RIFilterOption *)filterOption {
    self.ratingLine.ratingAverage = filterOption.average;
    self.ratingLine.ratingSum = filterOption.totalProducts;
    self.ratingLine.imageRatingSize = kImageRatingSizeSmall;
    self.ratingLine.bottomSeparatorVisibility = YES;
    
    [self.customAccessoryView setHidden:!filterOption.selected];
    
}
@end

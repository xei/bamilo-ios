//
//  JATextFilterCell.m
//  Jumia
//
//  Created by miguelseabra on 02/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JATextFilterCell.h"

@implementation JATextFilterCell

-(JAClickableView *)clickableView {
    if (!VALID(_clickableView, JAClickableView)) {
        _clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                          self.width, self.height)];
        [self addSubview:_clickableView];
    }
    return _clickableView;
}

-(UIView *)separatorView {
    if (!VALID(_separatorView, UIView)) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                             self.clickableView.frame.size.height - 1,
                                                             self.width,
                                                             1.0f)];
        _separatorView.backgroundColor = JABlack400Color;
        [self.clickableView addSubview:_separatorView];
    }
    return _separatorView;
}

-(UIImageView *)customAccessoryView {
    if (!VALID(_customAccessoryView, UIImageView)) {
        UIImage* customAccessoryIcon = [UIImage imageNamed:@"selectionCheckmark"];
        _customAccessoryView = [[UIImageView alloc] initWithImage:customAccessoryIcon];
        _customAccessoryView.frame = CGRectMake(self.clickableView.frame.size.width - customAccessoryIcon.size.width,
                                               (self.clickableView.frame.size.height - customAccessoryIcon.size.height) / 2,
                                               customAccessoryIcon.size.width,
                                               customAccessoryIcon.size.height);
        [self.clickableView addSubview:_customAccessoryView];
    }
    return _customAccessoryView;
}

-(UILabel *)nameLabel {
    if (!VALID(_nameLabel, UILabel)) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont fontWithName:kFontRegularName size:16.0f];
        _nameLabel.textColor = UIColorFromRGB(0x4e4e4e);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.clickableView addSubview:_nameLabel];
    }
    return _nameLabel;
}

-(UILabel *)quantityLabel {
    if (!VALID(_quantityLabel, UILabel)) {
        _quantityLabel = [UILabel new];
        _quantityLabel.font = [UIFont fontWithName:kFontRegularName size:16.0f];
        _quantityLabel.textColor = UIColorFromRGB(0x4e4e4e);
        _quantityLabel.textAlignment = NSTextAlignmentRight;
        [self.clickableView addSubview:_quantityLabel];
    }
    return _quantityLabel;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
                            isLandscape:(BOOL)isLandscape
                                  frame:(CGRect)frame;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = frame;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupIsLandscape:isLandscape];
    }
    return self;
}

-(void)setupIsLandscape:(BOOL)landscape {
    
    self.clickableView.frame = CGRectMake(0.0f, 0.0f, self.width, self.height);
    
    
    CGFloat startingX = 0.0;
    if (landscape) {
        startingX = 20.0f;
    }
    CGFloat margin = 12.0f;
    
    self.separatorView.frame = CGRectMake(0.0f, self.clickableView.frame.size.height - 1,
                                 self.width, 1.0f);
    
    [self.customAccessoryView setX:(self.clickableView.frame.size.width - margin - self.customAccessoryView.frame.size.width)];
    
    [self.nameLabel setX:startingX];
    [self.nameLabel sizeToFit];
    [self.nameLabel setHeight:self.clickableView.frame.size.height];

    [self.quantityLabel sizeToFit];
    [self.quantityLabel setTextAlignment:NSTextAlignmentRight];
    self.quantityLabel.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame), 0,
                                          self.quantityLabel.width + 5.f,
                                          self.clickableView.frame.size.height);
    
    if (CGRectGetMaxX(self.quantityLabel.frame) > self.customAccessoryView.frame.origin.x) {
        [self.quantityLabel setX:(self.customAccessoryView.frame.origin.x - self.quantityLabel.width)];
        [self.nameLabel setWidth:(self.quantityLabel.x - self.nameLabel.x)];
    }
    
    if (RI_IS_RTL) {
        [self.clickableView flipAllSubviews];
    }

}

-(void)setFilterOption:(RIFilterOption *)filterOption {
    self.nameLabel.text = filterOption.name;
    self.quantityLabel.text = [NSString stringWithFormat:@"(%ld)",[filterOption.totalProducts longValue]];
    [self.customAccessoryView setHidden:!filterOption.selected];
}

@end

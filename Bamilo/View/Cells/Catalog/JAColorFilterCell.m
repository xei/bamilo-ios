//
//  JAColorFilterCell.m
//  Jumia
//
//  Created by Telmo Pinto on 14/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAColorFilterCell.h"
#import "SearchFilterItemOption.h"

@implementation JAColorFilterCell

-(UILabel *)colorTitleLabel {
    if(!_colorTitleLabel) {
        _colorTitleLabel = [[UILabel alloc] init];
        _colorTitleLabel.font = JADisplay3Font;
        _colorTitleLabel.textColor = JAButtonTextOrange;
        [self addSubview:_colorTitleLabel];
    }
    return _colorTitleLabel;
}

-(JAColorView *)colorView {
    if (!_colorView) {
        _colorView = [[JAColorView alloc] init];
        [self addSubview:_colorView];
    }
    return _colorView;
}

-(UIImageView *)customAccessoryView {
    if (!_customAccessoryView) {
        UIImage* customAccessoryIcon = [UIImage imageNamed:@"selectionCheckmark"];
        
        _customAccessoryView = [[UIImageView alloc] init];
        _customAccessoryView.image = nil;
        _customAccessoryView.highlightedImage = customAccessoryIcon;
        _customAccessoryView.frame = CGRectMake(self.clickableView.frame.size.width - customAccessoryIcon.size.width,
                                                (self.clickableView.frame.size.height - customAccessoryIcon.size.height) / 2,
                                                customAccessoryIcon.size.width,
                                                customAccessoryIcon.size.height);
        [self addSubview:_customAccessoryView];
    }
    return _customAccessoryView;
}

-(UIView *)separator {
    if (!_separator) {
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = JABlack400Color;
        [self addSubview:_separator];
    }
    return _separator;
}

-(JAClickableView *)clickableView {
    if (!_clickableView) {
        
        _clickableView = [[JAClickableView alloc]initWithFrame:CGRectMake(0, 0, self.width, [JAColorFilterCell height])];
        [self addSubview:_clickableView];
        
    }
    return _clickableView;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier isLandscape:(BOOL)isLandscape frame:(CGRect)frame {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.frame = frame;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupIsLandscape:isLandscape];
        
    }
    return self;
}

- (void)setupIsLandscape:(BOOL)landscape {
    CGFloat height = [JAColorFilterCell height];
    
    self.colorView.frame = CGRectMake(0.0f, 0.0f, 54.0f, height);
    
    self.colorTitleLabel.text = @" ";
    self.colorTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.colorTitleLabel sizeToFit];
    self.colorTitleLabel.frame = CGRectMake(50.0f, (height - self.colorTitleLabel.frame.size.height) / 2,
                                            self.frame.size.width - 50.0f,
                                            self.colorTitleLabel.frame.size.height);

    [self.customAccessoryView setX:(self.frame.size.width - 12.0f - self.customAccessoryView.width)];
    self.separator.frame = CGRectMake(0.0f, height - 1.0f, self.frame.size.width, 1.0f);
    [self.clickableView setFrame:CGRectMake(0, 0, self.width, [JAColorFilterCell height])];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (void)setFilterOption:(SearchFilterItemOption*)option {
    
    self.colorTitleLabel.text = [[NSString stringWithFormat:@"%@ (%ld)",option.name, [option.productsCount longValue]] numbersToPersian];
    if (option.colorHexValue) {
        [self.colorView setColorWithHexString:option.colorHexValue];
    }
}

+ (CGFloat)height {
    return 48.0f;
}

@end

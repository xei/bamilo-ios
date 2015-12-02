//
//  JAColorFilterCell.m
//  Jumia
//
//  Created by Telmo Pinto on 14/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAColorFilterCell.h"
#import "RIFilter.h"

@implementation JAColorFilterCell

-(UILabel *)colorTitleLabel {
    if(!VALID(_colorTitleLabel, UILabel)) {
        _colorTitleLabel = [[UILabel alloc] init];
        _colorTitleLabel.font = [UIFont fontWithName:kFontRegularName size:16.0f];
        _colorTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
        [self addSubview:_colorTitleLabel];
    }
    return _colorTitleLabel;
}

-(JAColorView *)colorView {
    if (!VALID(_colorView, JAColorView)) {
        _colorView = [[JAColorView alloc] init];
        [self addSubview:_colorView];
    }
    return _colorView;
}

-(UIImageView *)customAccessoryView {
    if (!VALID(_customAccessoryView, UIImageView)) {
        UIImage* customAccessoryIcon = [UIImage imageNamed:@"selectionCheckmark"];
        _customAccessoryView = [[UIImageView alloc] initWithImage:customAccessoryIcon];
        _customAccessoryView.hidden = YES;
        [self addSubview:_customAccessoryView];
    }
    return _customAccessoryView;
}

-(UIView *)separator {
    if (!VALID(_separator, UIView)) {
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = JABlack400Color;
        [self addSubview:_separator];
    }
    return _separator;
}

-(JAClickableView *)clickableView {
    if (!VALID(_clickableView, JAClickableView)) {
        _clickableView = [[JAClickableView alloc]initWithFrame:CGRectMake(0, 0, self.width, [JAColorFilterCell height])];
        [self addSubview:_clickableView];
    }
    return _clickableView;
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

- (void)setupIsLandscape:(BOOL)landscape
{
    CGFloat height = [JAColorFilterCell height];
    
    self.colorView.frame = CGRectMake(0.0f,
                                      0.0f,
                                      54.0f,
                                      height);
    
    self.colorTitleLabel.text = @" ";
    self.colorTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.colorTitleLabel sizeToFit];
    self.colorTitleLabel.frame = CGRectMake(50.0f,
                                            (height - self.colorTitleLabel.frame.size.height) / 2,
                                            self.frame.size.width - 50.0f,
                                            self.colorTitleLabel.frame.size.height);

    
    
    UIImage* customAccessoryIcon = [UIImage imageNamed:@"selectionCheckmark"];
    self.customAccessoryView.frame = CGRectMake(self.frame.size.width - 12.0f - customAccessoryIcon.size.width,
                                                (height - customAccessoryIcon.size.height) / 2,
                                                customAccessoryIcon.size.width,
                                                customAccessoryIcon.size.height);
    
    self.separator.frame = CGRectMake(0.0f,
                                 height - 1.0f,
                                 self.frame.size.width,
                                 1.0f);
    
    [self.clickableView setFrame:CGRectMake(0, 0, self.width, [JAColorFilterCell height])];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (void)setFilterOption:(RIFilterOption*)filterOption {
    self.colorTitleLabel.text = [NSString stringWithFormat:@"%@ (%ld)",filterOption.name, [filterOption.totalProducts longValue]];
    
    if (filterOption.colorHexValue) {
        [self.colorView setColorWithHexString:filterOption.colorHexValue];
    }
}

+ (CGFloat)height
{
    return 48.0f;
}

@end

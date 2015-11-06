//
//  JAColorFilterCell.m
//  Jumia
//
//  Created by Telmo Pinto on 14/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAColorFilterCell.h"

@implementation JAColorFilterCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
                            isLandscape:(BOOL)isLandscape
                                  frame:(CGRect)frame;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = frame;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.colorView = [[JAColorView alloc] init];
        [self addSubview:self.colorView];
        
        self.colorTitleLabel = [[UILabel alloc] init];
        self.colorTitleLabel.font = [UIFont fontWithName:kFontRegularName size:16.0f];
        self.colorTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
        [self addSubview:self.colorTitleLabel];
        
        UIImage* customAccessoryIcon = [UIImage imageNamed:@"selectionCheckmark"];
        self.customAccessoryView = [[UIImageView alloc] initWithImage:customAccessoryIcon];
        self.customAccessoryView.hidden = YES;
        [self addSubview:self.customAccessoryView];
        
        self.separator = [[UIView alloc] init];
        self.separator.backgroundColor = JABlack400Color;
        [self addSubview:self.separator];
        
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
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

+ (CGFloat)height
{
    return 48.0f;
}

@end

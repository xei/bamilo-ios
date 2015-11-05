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
        
        CGFloat height = [JAColorFilterCell height];
        
        self.colorView = [[JAColorView alloc] initWithFrame:CGRectMake(0.0f,
                                                                       0.0f,
                                                                       54.0f,
                                                                       height)];
        [self addSubview:self.colorView];
        
        self.colorTitleLabel = [[UILabel alloc] init];
        self.colorTitleLabel.font = [UIFont fontWithName:kFontRegularName size:14.0f];
        self.colorTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
        self.colorTitleLabel.text = @" ";
        [self.colorTitleLabel sizeToFit];
        self.colorTitleLabel.frame = CGRectMake(50.0f,
                                                (height - self.colorTitleLabel.frame.size.height) / 2,
                                                self.frame.size.width - 50.0f,
                                                self.colorTitleLabel.frame.size.height);
        [self addSubview:self.colorTitleLabel];
        
        
        UIImage* customAccessoryIcon = [UIImage imageNamed:@"selectionCheckmark"];
        self.customAccessoryView = [[UIImageView alloc] initWithImage:customAccessoryIcon];
        self.customAccessoryView.frame = CGRectMake(self.frame.size.width - 12.0f - customAccessoryIcon.size.width,
                                                    (height - customAccessoryIcon.size.height) / 2,
                                                    customAccessoryIcon.size.width,
                                                    customAccessoryIcon.size.height);
        self.customAccessoryView.hidden = YES;
        [self addSubview:self.customAccessoryView];
        
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     height - 1.0f,
                                                                     self.frame.size.width,
                                                                     1.0f)];
        separator.backgroundColor = JABlack400Color;
        [self addSubview:separator];
    }
    return self;
}

+ (CGFloat)height
{
    return 48.0f;
}

@end

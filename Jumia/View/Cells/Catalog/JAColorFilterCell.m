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
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectionCheckmark"]];
        
        self.colorView = [[JAColorView alloc] initWithFrame:CGRectMake(0.0f,
                                                                       0.0f,
                                                                       44.0f,
                                                                       44.0f)];
        [self addSubview:self.colorView];
        
        self.colorTitleLabel = [[UILabel alloc] init];
        self.colorTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        self.colorTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
        self.colorTitleLabel.text = @" ";
        [self.colorTitleLabel sizeToFit];
        self.colorTitleLabel.frame = CGRectMake(50.0f,
                                                (44.0f - self.colorTitleLabel.frame.size.height) / 2,
                                                self.frame.size.width - 50.0f,
                                                self.colorTitleLabel.frame.size.height);
        [self addSubview:self.colorTitleLabel];
        
        self.separatorInset = UIEdgeInsetsMake(0, 50.0f, 0, 0);
    }
    return self;
}

@end

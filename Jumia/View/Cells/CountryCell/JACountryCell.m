//
//  JACountryCell.m
//  Jumia
//
//  Created by Miguel Chaves on 01/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACountryCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation JACountryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

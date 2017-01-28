//
//  MoreMenuTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "MoreMenuTableViewCell.h"

@interface MoreMenuTableViewCell()
    @property (nonatomic, weak) IBOutlet UILabel* titleUILabel;
@end

@implementation MoreMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.titleUILabel setFont:[UIFont fontWithName:kFontRegularName size:12]];
}

+(NSString *) nibName {
    return @"MoreMenuTableViewCell";
}

- (void)setTitle:(NSString *)title {
    self.titleUILabel.text = title;
}

@end

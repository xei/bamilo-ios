//
//  PopularTeaserHeaderTableViewCell.m
//  Jumia
//
//  Created by aliunco on 1/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PopularTeaserHeaderTableViewCell.h"

@interface PopularTeaserHeaderTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleStringUILabel;
@end

@implementation PopularTeaserHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setTitleString:(NSString *)titleString {
    self.titleStringUILabel.text = titleString;
}

+ (NSString *)nibName {
    return @"PopularTeaserHeaderTableViewCell";
}

@end

//
//  IconTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "IconTableViewCell.h"

@interface IconTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView* iconImage;
@end

@implementation IconTableViewCell

- (void)setImageName:(NSString *)imageName {
    self.iconImage.image = [UIImage imageNamed:imageName];
}

#pragma mark - Overrides
+ (NSString *)nibName {
    return @"IconTableViewCell";
}

@end

//
//  IconTableViewHeaderCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "IconTableViewHeaderCell.h"

@interface IconTableViewHeaderCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@end

@implementation IconTableViewHeaderCell

- (void)setImageName:(NSString *)imageName {
    self.iconImage.image = [UIImage imageNamed:imageName];
}

#pragma mark - Overrides
+ (NSString *)nibName {
    return @"IconTableViewHeaderCell";
}

@end

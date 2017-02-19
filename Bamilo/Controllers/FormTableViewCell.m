//
//  FormTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormTableViewCell.h"

@implementation FormTableViewCell
+ (NSString *)nibName {
    return @"FormTableViewCell";
}
- (void)prepareForReuse {
    [self.formItemControl resetAndClear];
}
@end

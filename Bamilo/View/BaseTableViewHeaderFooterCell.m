//
//  BaseTableViewHeaderFooterCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewHeaderFooterCell.h"

@implementation BaseTableViewHeaderFooterCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Public Methods
+(CGFloat)cellHeight {
    return 0;
}

+ (NSString *)nibName {
    return nil;
}

@end

//
//  OnlinePaymentVariationTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OnlinePaymentVariationTableViewCell.h"

@implementation OnlinePaymentVariationTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Overrides
+ (NSString *)nibName {
    return @"OnlinePaymentVariationTableViewCell";
}

@end

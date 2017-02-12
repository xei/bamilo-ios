//
//  PayOnDeliveryTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PaymentDescTableViewCell.h"

@implementation PaymentDescTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.descLabel applyStyle:kFontRegularName fontSize:12.0f color:cDARK_GRAY_COLOR];
}

#pragma mark - Overrides
+ (NSString *)nibName {
    return @"PaymentDescTableViewCell";
}

@end

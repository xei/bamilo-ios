//
//  DeliveryTimeTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DeliveryTimeTableViewCell.h"

@implementation DeliveryTimeTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self.titleLabel applyStyle:kFontBoldName fontSize:self.titleLabel.font.pointSize color:self.titleLabel.textColor];
}

#pragma mark - Overrides
+ (NSString *) nibName {
    return @"DeliveryTimeTableViewCell";
}

@end

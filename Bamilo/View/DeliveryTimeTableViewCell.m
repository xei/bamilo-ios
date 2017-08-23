//
//  DeliveryTimeTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DeliveryTimeTableViewCell.h"
@interface DeliveryTimeTableViewCell()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation DeliveryTimeTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    [self.titleLabel applyStyle:kFontBoldName fontSize:self.titleLabel.font.pointSize color:self.titleLabel.textColor];
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
}

- (void)updateTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self.activityIndicator stopAnimating];
}

#pragma mark - Overrides
+ (NSString *) nibName {
    return @"DeliveryTimeTableViewCell";
}

@end

//
//  DeliveryTimeTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DeliveryTimeTableViewCell.h"
#import "ThreadManager.h"

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
    [ThreadManager executeOnMainThread:^{
        self.titleLabel.text = title;
        if ([title length]) {
            [self.activityIndicator stopAnimating];
        } else {
            [self.activityIndicator startAnimating];
        }
    }];
}

#pragma mark - Overrides
+ (NSString *) nibName {
    return @"DeliveryTimeTableViewCell";
}

@end

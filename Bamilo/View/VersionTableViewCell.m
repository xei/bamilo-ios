//
//  VersionTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "VersionTableViewCell.h"
#import "AppManager.h"

@interface VersionTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *versionUILabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleUILabel;
@end

@implementation VersionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.versionUILabel.text = [[AppManager sharedInstance] getAppBuildNumber];
    self.subtitleUILabel.text = [self.isLastVersion boolValue] ? STRING_UP_TO_DATE : STRING_UPDATE_NOW;
    
    [self.versionUILabel setFont:JACaptionFont];
    [self.versionUILabel setTextColor:JABlackColor];
    
    [self.subtitleUILabel setFont:JACaptionFont];
    [self.subtitleUILabel setTextColor:JABlack800Color];
    
    //If isLastVersion variable is not clear (isLastVersion variable is nil)
    if (!self.isLastVersion) {
        [self.versionUILabel setHidden:YES];
        [self.subtitleUILabel setHidden:YES];
    }
    
}

- (NSNumber*)isLastVersion {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString: [[AppManager sharedInstance] getAppBuildNumber]];
    if (myNumber && [RIApi getApiInformation].curVersion) {
        if ([myNumber compare:[RIApi getApiInformation].curVersion] == NSOrderedAscending) {
            return [NSNumber numberWithBool:NO];
        } else {
            return [NSNumber numberWithBool:YES];
        }
    } else {
        return nil;
    }
}


+ (NSString *)nibName {
    return @"VersionTableViewCell";
}

@end

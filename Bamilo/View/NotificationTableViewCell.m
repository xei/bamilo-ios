//
//  NotificationTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "NotificationTableViewCell.h"


@interface NotificationTableViewCell()
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;

@end

@implementation NotificationTableViewCell {
    @private Boolean notificationIsOn;
}

- (void)prepareForReuse {
    notificationIsOn = [[NSUserDefaults standardUserDefaults] boolForKey: kChangeNotificationsOptions];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)changeSwitch:(id)sender {
        if (self.notificationSwitch.on) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kChangeNotificationsOptions];
        } else {
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kChangeNotificationsOptions];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (NSString *)nibName {
    return @"NotificationTableViewCell";
}
@end

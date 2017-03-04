//
//  NotificationBarView.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationBarView : UIView

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

+ (instancetype)sharedInstance;

-(void) show:(UIViewController *)viewController text:(NSString *)text isSuccess:(BOOL)isSuccess;
-(void) dismiss;

@end

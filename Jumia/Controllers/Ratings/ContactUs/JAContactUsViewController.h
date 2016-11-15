//
//  JAContactUsViewController.h
//  Jumia
//
//  Created by Admin on 9/1/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import <MessageUI/MFMailComposeViewController.h>


@interface JAContactUsViewController : JABaseViewController<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *addresslabel;
@property (weak, nonatomic) IBOutlet UIButton *callToContactUsButton;
@property (weak, nonatomic) IBOutlet UIButton *mailForAppFeedbackButton;
@property (weak, nonatomic) IBOutlet UIScrollView *contactUsScreen;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView2;

@end

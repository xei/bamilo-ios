//
//  JAContactUsViewController.m
//  Jumia
//
//  Created by Admin on 9/1/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAContactUsViewController.h"
#import "JAUtils.h"
#import "RICustomer.h"
#import <sys/utsname.h>

@implementation JAContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = STRING_CONTACT_US;
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.title = STRING_CONTACT_US;
    self.addresslabel.text = @"تهران، میدان ونک، بزرگراه حقانی \n نرسیده به چهارراه جهان کودک \n پلاک ۶۳، طبقه اول و دوم";
    
    [self.mailForAppFeedbackButton addTarget:self action:@selector(mailForAppFeedback) forControlEvents:UIControlEventTouchUpInside];
}

-(IBAction)callToContactUs:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"تماس با تیم خدمات مشتریان بامیلو" delegate:nil cancelButtonTitle:@"لغو" otherButtonTitles:@"تایید", nil];
    alert.delegate = self;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != 0) {
        [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
            
            [self trackingEventCallToOrder];
            NSString *phoneNumber = [@"tel://" stringByAppendingString:[JAUtils convertToEnglishNumber:configuration.phoneNumber]];//tessa
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        }];
    }
}

- (void)mailForAppFeedback {
    if(![MFMailComposeViewController canSendMail]) {
//        [JAUtils showAlertWithTitle:ERROR_STRING message:EMAIL_NOT_CONFIGURED delegate:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"EMAIL NOT CONFIGURED"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:  nil];
        [alert show];
    } else {
        
        NSString *emailTitle = [NSString stringWithFormat:@" گزارش مشکلات برنامه"];
        
        NSString *messageBody = [NSString stringWithFormat:@"OS Version: %@ \n Device Name: %@ \n App Version: %@",
                                 [UIDevice currentDevice].systemVersion,
                                 [[UIDevice currentDevice] model],
                                 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        
        
        NSArray *toRecipents = [NSArray arrayWithObjects:@"application@bamilo.com", nil];
        //        NSArray *toRecipents = [NSArray arrayWithObjects:@"tessa@qburst.com", nil];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:false];
        [mc setToRecipients:toRecipents];
        
        
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:nil];
        
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)trackingEventCallToOrder {
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCallToOrder]
                                              data:[trackingDictionary copy]];
}

@end

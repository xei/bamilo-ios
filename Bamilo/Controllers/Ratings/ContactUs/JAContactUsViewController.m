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
    self.view.backgroundColor = [UIColor whiteColor];
    self.addresslabel.text = @"تهران، میدان ونک، بزرگراه حقانی \n نرسیده به چهارراه جهان کودک \n پلاک ۶۳، طبقه اول و دوم";
    self.addresslabel.font = JATitleFont;
    
    UIImage* currentImage = _arrowImageView1.image;
    
    UIImage* newImage = [currentImage flipImageWithOrientation:UIImageOrientationUpMirrored];
    _arrowImageView1.image = newImage;
    _arrowImageView2.image = newImage;
    [self.mailForAppFeedbackButton addTarget:self action:@selector(mailForAppFeedback)forControlEvents:UIControlEventTouchUpInside];
    float sizeOfContent = 0;
    
    NSInteger wd = self.mailForAppFeedbackButton.frame.origin.y + 100 ;
    NSInteger ht = self.mailForAppFeedbackButton.frame.size.height;
    
    sizeOfContent = wd+ht;
    
    [self.contactUsScreen setContentSize:CGSizeMake(self.contactUsScreen.frame.size.width, sizeOfContent)];

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

//- (NSString*)deviceName {
    
//    static NSDictionary* deviceNamesByCode = nil;
//    static NSString* deviceName = nil;
//    
//    deviceNamesByCode = @{
//                          @"i386"      :@"Simulator",
//                          @"iPod1,1"   :@"iPod Touch",      // (Original)
//                          @"iPod2,1"   :@"iPod Touch",      // (Second Generation)
//                          @"iPod3,1"   :@"iPod Touch",      // (Third Generation)
//                          @"iPod4,1"   :@"iPod Touch",      // (Fourth Generation)
//                          @"iPhone1,1" :@"iPhone",          // (Original)
//                          @"iPhone1,2" :@"iPhone",          // (3G)
//                          @"iPhone2,1" :@"iPhone",          // (3GS)
//                          @"iPad1,1"   :@"iPad",            // (Original)
//                          @"iPad2,1"   :@"iPad 2",          //
//                          @"iPad3,1"   :@"iPad",            // (3rd Generation)
//                          @"iPhone3,1" :@"iPhone 4",        //
//                          @"iPhone4,1" :@"iPhone 4S",       //
//                          @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
//                          @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
//                          @"iPad3,4"   :@"iPad",            // (4th Generation)
//                          @"iPad2,5"   :@"iPad Mini",       // (Original)
//                          @"iPhone5,3" :@"iPhone 5c",       // (model A1456, A1532 | GSM)
//                          @"iPhone5,4" :@"iPhone 5c",       // (model A1507, A1516, A1526 (China), A1529 | Global)
//                          @"iPhone6,1" :@"iPhone 5s",       // (model A1433, A1533 | GSM)
//                          @"iPhone6,2" :@"iPhone 5s",       // (model A1457, A1518, A1528 (China), A1530 | Global)
//                          @"iPhone7,2" :@"iPhone 6",
//                          @"iPhone7,1" :@"iPhone 6 Plus",
//                          @"iPhone8,1" :@"iPhone 6s",
//                          @"iPhone8,2" :@"iPhone 6S Plus",    //
//                          @"iPhone8,4" :@"iPhone SE",         //
//                          @"iPhone9,1" :@"iPhone 7",          //
//                          @"iPhone9,3" :@"iPhone 7",          //
//                          @"iPhone9,2" :@"iPhone 7 Plus",     //
//                          @"iPhone9,4" :@"iPhone 7 Plus",     //
//                          @"iPad4,1"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Wifi
//                          @"iPad4,2"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Cellular
//                          @"iPad4,4"   :@"iPad Mini",       // (2nd Generation iPad Mini - Wifi)
//                          @"iPad4,5"   :@"iPad Mini",       // (2nd Generation iPad Mini - Cellular)
//                          @"iPad4,7"   :@"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
//                          @"iPad6,7"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584)
//                          @"iPad6,8"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1652)
//                          @"iPad6,3"   :@"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
//                          @"iPad6,4"   :@"iPad Pro (9.7\")"   // iPad Pro 9.7 inches - (models A1674 and A1675)
//                          };
//    
//    struct utsname systemInfo;
//    uname(&systemInfo);
//    NSString* code = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
//    
//    deviceName = [deviceNamesByCode objectForKey:code];
//    
//    if (!deviceName) {
//        // Not found in database. At least guess main device type from string contents:
//        
//        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
//            deviceName = @"iPod Touch";
//        } else if([code rangeOfString:@"iPad"].location != NSNotFound) {
//            deviceName = @"iPad";
//        } else if([code rangeOfString:@"iPhone"].location != NSNotFound){
//            deviceName = @"iPhone";
//        } else {
//            deviceName = @"Simulator";
//        }
//    }
//    
//    return deviceName;
//}

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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

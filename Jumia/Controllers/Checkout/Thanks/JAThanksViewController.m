//
//  JAThanksViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAThanksViewController.h"
#import "RICustomer.h"
#import "JAUtils.h"

@interface JAThanksViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *thankYouLabel;
@property (weak, nonatomic) IBOutlet UILabel *successMessage;
@property (weak, nonatomic) IBOutlet UILabel *trackOrderMessage;
@property (weak, nonatomic) IBOutlet UITextField *orderNumberField;
@property (weak, nonatomic) IBOutlet UIButton *orderCopyButton;
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingButton;

@end

@implementation JAThanksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.navBarLayout.title = STRING_CHECKOUT;
    self.navBarLayout.showCartButton = NO;
    
    self.view.backgroundColor = JABackgroundGrey;
    
    // Notification to clean cart
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    
    self.contentView.layer.cornerRadius = 5.0f;
    self.thankYouLabel.textColor = UIColorFromRGB(0x666666);
    self.thankYouLabel.text = STRING_THANK_YOU_ORDER_TITLE;
    self.successMessage.textColor = UIColorFromRGB(0x666666);
    self.successMessage.text = STRING_ORDER_SUCCESS;

    NSString* baseString = STRING_ORDER_TRACK_SUCCESS;
    NSDictionary* baseAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"HelveticaNeue-Light" size:12], NSFontAttributeName,
                                    UIColorFromRGB(0x666666), NSForegroundColorAttributeName, nil];
    
    NSString* particleString = STRING_ORDER_TRACK_LINK;
    NSRange particleStringRange = [baseString rangeOfString:particleString];
    NSDictionary* highlightAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"HelveticaNeue-Light" size:12], NSFontAttributeName,
                                         UIColorFromRGB(0x55a1ff), NSForegroundColorAttributeName, nil];
    
    NSMutableAttributedString* finalString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:baseAttributes];
    [finalString setAttributes:highlightAttributes range:particleStringRange];
    
    self.trackOrderMessage.attributedText = finalString;
    
    UIButton* goToTrackOrdersButton = [[UIButton alloc] initWithFrame:self.trackOrderMessage.frame];
    [goToTrackOrdersButton addTarget:self action:@selector(goToTrackOrders) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goToTrackOrdersButton];
    
    //STRING_ORDER_TRACK_LINK
    [self.orderNumberField setText:self.orderNumber];
    self.orderNumberField.textColor = UIColorFromRGB(0x4e4e4e);
    
    [self.orderCopyButton addTarget:self action:@selector(copyOrderNumber) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.continueShoppingButton setTitleColor:JAButtonTextOrange forState:UIControlStateNormal];
    [self.continueShoppingButton setTitle:STRING_CONTINUE_SHOPPING forState:UIControlStateNormal];
    
    self.continueShoppingButton.layer.cornerRadius = 5.0f;
    
    [self.continueShoppingButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"Finished" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:[NSNumber numberWithInteger:[self.orderNumber integerValue]] forKey:kRIEventValueKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckout]
                                              data:[trackingDictionary copy]];
    
    BOOL userDidFirstBuy = [[[NSUserDefaults standardUserDefaults] objectForKey:kDidFirstBuyKey] boolValue];
    if([RICustomer wasSignup] && !userDidFirstBuy)
    {
        // Send customer event
        NSMutableDictionary *customerDictionary = [[NSMutableDictionary alloc] init];
        [customerDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [customerDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [customerDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        [customerDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
        [customerDictionary setValue:self.orderNumber forKey:kRIEcommerceTransactionIdKey];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithFloat:RIEventGuestCustomer] data:customerDictionary];
    }
    
    [RICheckout getConversionRate:^(CGFloat rate)
    {
        NSMutableDictionary *ecommerceDictionary = [[NSMutableDictionary alloc] init];
        [ecommerceDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [ecommerceDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [ecommerceDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        [ecommerceDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
        [ecommerceDictionary setValue:self.orderNumber forKey:kRIEcommerceTransactionIdKey];
        NSDictionary *products = self.checkout.cart.cartItems;
        if(VALID_NOTEMPTY(products, NSDictionary))
        {
            [ecommerceDictionary setValue:[products allKeys] forKey:kRIEcommerceSkusKey];
        }
        
        [ecommerceDictionary setValue:self.checkout.orderSummary.shippingAmount forKey:kRIEcommerceShippingKey];
        [ecommerceDictionary setValue:self.checkout.orderSummary.taxAmount forKey:kRIEcommerceTaxKey];
        
        NSNumber *grandTotal = self.checkout.orderSummary.grandTotal;
        NSNumber *convertedGrandTotal = [NSNumber numberWithFloat:([grandTotal floatValue] * rate)];
        
        [ecommerceDictionary setValue:convertedGrandTotal forKey:kRIEcommerceTotalValueKey];
        
        if([RICustomer wasSignup] && !userDidFirstBuy)
        {
            [ecommerceDictionary setValue:[NSNumber numberWithBool:[RICustomer wasSignup]] forKey:kRIEcommerceGuestKey];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kDidFirstBuyKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [[RITrackingWrapper sharedInstance] trackCheckout:ecommerceDictionary];
    }];
}

- (void)copyOrderNumber
{
    [[UIPasteboard generalPasteboard] setString:[self.orderNumberField text]];
}

- (void)goToHomeScreen
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"ContinueShopping" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckout]
                                              data:[trackingDictionary copy]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

- (void)goToTrackOrders
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowTrackOrderScreenNotification object:self.orderNumber];
}

@end

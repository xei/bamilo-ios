//
//  JAThanksViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAThanksViewController.h"
#import "RICustomer.h"

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
}

- (void)copyOrderNumber
{
    [[UIPasteboard generalPasteboard] setString:[self.orderNumberField text]];
}

- (void)goToHomeScreen
{
    [[RITrackingWrapper sharedInstance] trackEvent:[RICustomer getCustomerId]
                                             value:nil
                                            action:@"ContinueShopping"
                                          category:@"Checkout"
                                              data:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

- (void)goToTrackOrders
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowTrackOrderScreenNotification object:self.orderNumber];
}

@end

//
//  JAThanksViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAThanksViewController.h"

@interface JAThanksViewController ()

@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;

@end

@implementation JAThanksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.navBarLayout.title = @"Thanks";
    
    self.navBarLayout.showCartButton = NO;
    
    if(VALID_NOTEMPTY(self.orderNumber, NSString))
    {
        [self.orderNumberLabel setText:self.orderNumber];
        [self.orderNumberLabel sizeToFit];
    }
}

@end

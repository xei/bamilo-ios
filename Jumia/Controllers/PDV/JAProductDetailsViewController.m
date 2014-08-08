//
//  JAProductDetailsViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 08/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAProductDetailsViewController.h"

@interface JAProductDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelBrand;
@property (weak, nonatomic) IBOutlet UILabel *labelNewPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelOldPrice;

@end

@implementation JAProductDetailsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelBrand.text = self.stringBrand;
    self.labelName.text = self.stringName;
    self.labelNewPrice.text = [self.stringNewPrice stringValue];
    self.labelOldPrice.text = [self.stringOldPrice stringValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

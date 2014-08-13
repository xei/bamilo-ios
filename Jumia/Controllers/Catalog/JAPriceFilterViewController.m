//
//  JAPriceFilterViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 13/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPriceFilterViewController.h"
#import "NMRangeSlider.h"

@interface JAPriceFilterViewController ()

@property (weak, nonatomic) IBOutlet UILabel *priceRangeLabel;
@property (weak, nonatomic) IBOutlet NMRangeSlider *priceRangeSlider;
@property (weak, nonatomic) IBOutlet UISwitch *discountSwitch;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

@end

@implementation JAPriceFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.priceRangeSlider.minimumValue = self.priceFilterOption.min;
    self.priceRangeSlider.maximumValue = self.priceFilterOption.max;
    
    self.priceRangeSlider.lowerValue = self.priceFilterOption.min;
    self.priceRangeSlider.upperValue = self.priceFilterOption.max;
    
    self.priceRangeSlider.stepValue = self.priceFilterOption.interval;
    [self sliderMoved:nil];
    
    self.discountLabel.text = @"With discount only";
    self.discountSwitch.on = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *nameDic = [NSMutableDictionary dictionary];
    [nameDic addEntriesFromDictionary:@{@"name": @"Price"}];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kShowSpecificFilterNavNofication
                                      object:self
                                    userInfo:nameDic];
}

- (IBAction)sliderMoved:(id)sender
{
    self.priceRangeLabel.text = [NSString stringWithFormat:@"%d - %d", (int)self.priceRangeSlider.lowerValue, (int)self.priceRangeSlider.upperValue];
}

@end

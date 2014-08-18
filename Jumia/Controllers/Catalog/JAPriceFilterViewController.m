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

    self.priceRangeSlider.stepValue = self.priceFilterOption.interval;

    self.priceRangeSlider.maximumValue = self.priceFilterOption.max;
    self.priceRangeSlider.minimumValue = self.priceFilterOption.min;
    
    //found out the hard way that self.priceRangeSlider.upperValue has to be set before self.priceRangeSlider.lowerValue
    self.priceRangeSlider.upperValue = self.priceFilterOption.upperValue;
    self.priceRangeSlider.lowerValue = self.priceFilterOption.lowerValue;
    
    [self sliderMoved:nil];
    
    self.discountLabel.text = @"With discount only";
    self.discountSwitch.on = self.priceFilterOption.discountOnly;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneButtonPressed)
                                                 name:kDidPressDoneNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Button Actions

- (void)doneButtonPressed
{
    //save selection in filter
    
    self.priceFilterOption.lowerValue = self.priceRangeSlider.lowerValue;
    self.priceFilterOption.upperValue = self.priceRangeSlider.upperValue;
    self.priceFilterOption.discountOnly = self.discountSwitch.on;
}

- (IBAction)sliderMoved:(id)sender
{
    self.priceRangeLabel.text = [NSString stringWithFormat:@"%d - %d", (int)self.priceRangeSlider.lowerValue, (int)self.priceRangeSlider.upperValue];
}

@end

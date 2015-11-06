//
//  JAPriceFiltersView.m
//  Jumia
//
//  Created by Telmo Pinto on 10/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPriceFiltersView.h"
#import "NMRangeSlider.h"

@interface JAPriceFiltersView()

@property (weak, nonatomic) IBOutlet UILabel *priceRangeLabel;
@property (weak, nonatomic) IBOutlet NMRangeSlider *priceRangeSlider;
@property (weak, nonatomic) IBOutlet UISwitch *discountSwitch;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong)RIFilterOption* priceFilterOption;

@end

@implementation JAPriceFiltersView

- (void)initializeWithPriceFilterOption:(RIFilterOption*)priceFilterOption;
{
    self.priceFilterOption = priceFilterOption;
    
    self.backgroundColor = [UIColor whiteColor];
    self.priceRangeLabel.font = [UIFont fontWithName:kFontRegularName size:16.0f];
    self.priceRangeLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.discountLabel.font = [UIFont fontWithName:kFontRegularName size:14.0f];
    self.discountLabel.textColor = UIColorFromRGB(0x4e4e4e);
    
    self.priceRangeSlider.stepValue = self.priceFilterOption.interval;
    
    self.priceRangeSlider.maximumValue = self.priceFilterOption.max;
    self.priceRangeSlider.minimumValue = self.priceFilterOption.min;
    
    //found out the hard way that self.priceRangeSlider.upperValue has to be set before self.priceRangeSlider.lowerValue
    self.priceRangeSlider.upperValue = self.priceFilterOption.upperValue;
    self.priceRangeSlider.lowerValue = self.priceFilterOption.lowerValue;
    
    [self sliderMoved:nil];
    
    self.discountLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.discountLabel.text = STRING_WITH_DISCOUNT_ONLY;
    [self.discountLabel sizeToFit];
    self.discountSwitch.on = self.priceFilterOption.discountOnly;
    [self.discountSwitch setAccessibilityLabel:STRING_WITH_DISCOUNT_ONLY];
    [self.discountSwitch addTarget:self action:@selector(switchMoved:) forControlEvents:UIControlEventTouchUpInside];
    
    self.discountSwitch.translatesAutoresizingMaskIntoConstraints = YES;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.contentView.frame = CGRectMake(16.0f,
                                        (self.frame.size.height - self.contentView.frame.size.width)/2,
                                        self.contentView.frame.size.width,
                                        self.contentView.frame.size.height);
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (void)reload
{
    self.contentView.frame = CGRectMake(16.0f,
                                        (self.frame.size.height - self.contentView.frame.size.width)/2,
                                        self.contentView.frame.size.width,
                                        self.contentView.frame.size.height);
    if (RI_IS_RTL) {
        [self.contentView flipViewPositionInsideSuperview];
    }
}

- (void)saveOptions
{
    //save selection in filter
    self.priceFilterOption.lowerValue = self.priceRangeSlider.lowerValue;
    self.priceFilterOption.upperValue = self.priceRangeSlider.upperValue;
    self.priceFilterOption.discountOnly = self.discountSwitch.on;
    
    [super saveOptions];
}

- (IBAction)sliderMoved:(id)sender
{
    self.priceRangeLabel.text = [NSString stringWithFormat:@"%d - %d", (int)self.priceRangeSlider.lowerValue, (int)self.priceRangeSlider.upperValue];
    [self saveOptions];
}

- (void)switchMoved:(id)sender
{
    [self saveOptions];
}

@end

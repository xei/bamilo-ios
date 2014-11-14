//
//  JAPriceFilterViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 13/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPriceFilterViewController.h"
#import "JAPriceFiltersView.h"

@interface JAPriceFilterViewController()

@property (nonatomic, strong)JAPriceFiltersView* priceFiltersView;

@end

@implementation JAPriceFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"PriceFilter";
    
    self.navBarLayout.title = STRING_PRICE;
    self.navBarLayout.backButtonTitle = STRING_FILTERS;
    self.navBarLayout.showDoneButton = YES;
    
    self.priceFiltersView = [[[NSBundle mainBundle] loadNibNamed:@"JAPriceFiltersView" owner:self options:nil] objectAtIndex:0];
    [self.priceFiltersView setFrame:self.view.bounds];
    [self.view addSubview:self.priceFiltersView];
    [self.priceFiltersView initializeWithPriceFilterOption:self.priceFilterOption];
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

#pragma mark - Button Actions

- (void)doneButtonPressed
{
    [self.priceFiltersView saveOptions];
    
    [super doneButtonPressed];
}



@end

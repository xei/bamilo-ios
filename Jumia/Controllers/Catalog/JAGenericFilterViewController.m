//
//  JAGenericFilterViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 14/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAGenericFilterViewController.h"
#import "JAGenericFiltersView.h"

@interface JAGenericFilterViewController ()

@property (nonatomic, strong)JAGenericFiltersView* genericFiltersView;

@end

@implementation JAGenericFilterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(VALID_NOTEMPTY(self.filter, RIFilter))
    {
        self.screenName =  [NSString stringWithFormat:@"%@Filter", self.filter.name];
    }
    
    self.navBarLayout.title = self.filter.name;
    self.navBarLayout.backButtonTitle = STRING_FILTERS;
    self.navBarLayout.showDoneButton = YES;

    self.genericFiltersView = [[[NSBundle mainBundle] loadNibNamed:@"JAGenericFiltersView" owner:self options:nil] objectAtIndex:0];
    [self.genericFiltersView setFrame:self.view.bounds];
    [self.view addSubview:self.genericFiltersView];
    [self.genericFiltersView initializeWithFilter:self.filter];
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneButtonPressed)
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
    [self.genericFiltersView saveOptions];
}

@end

//
//  JACategoryFilterViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 18/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACategoryFilterViewController.h"

@interface JACategoryFilterViewController ()

@property (nonatomic, strong)JACategoryFiltersView* categoryFiltersView;

@end

@implementation JACategoryFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.screenName = @"CategoryFilter";
    
    self.navBarLayout.title = STRING_CATEGORIES;
    self.navBarLayout.backButtonTitle = STRING_FILTERS;
    self.navBarLayout.showDoneButton = YES;
    
    self.categoryFiltersView = [[[NSBundle mainBundle] loadNibNamed:@"JACategoryFiltersView" owner:self options:nil] objectAtIndex:0];
    [self.categoryFiltersView setFrame:self.view.bounds];
    [self.view addSubview:self.categoryFiltersView];
    self.categoryFiltersView.delegate = self;
    [self.categoryFiltersView initializeWithCategories:self.categoriesArray
                                      selectedCategory:self.selectedCategory];
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];

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
    [self.categoryFiltersView saveOptions];
}

#pragma mark - JACategoryFiltersViewDelegate

- (void)selectedCategory:(RICategory*)category;
{
    self.selectedCategory = category;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(categoriesFilterSelectedCategory:)]) {
        [self.delegate categoriesFilterSelectedCategory:category];
    }
}

@end

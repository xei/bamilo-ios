//
//  JACatalogViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogViewController.h"

@interface JACatalogViewController ()

@property (weak, nonatomic) IBOutlet JAPickerScrollView *sortingScrollView;

@end

@implementation JACatalogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sortingScrollView.delegate = self;
    
    NSArray* sortList = [NSArray arrayWithObjects:@"Popularity", @"Best Rating", @"New In", @"Price Up", @"Price Down", @"Name", @"Brand", nil];
    
    [self.sortingScrollView setOptions:sortList];
}

#pragma mark - JAPickerScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{

}

@end

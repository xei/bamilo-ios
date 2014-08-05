//
//  JACatalogViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogViewController.h"
#import "RIProduct.h"

@interface JACatalogViewController ()

@property (weak, nonatomic) IBOutlet JAPickerScrollView *sortingScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation JACatalogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sortingScrollView.delegate = self;
    
    NSArray* sortList = [NSArray arrayWithObjects:@"Popularity", @"Best Rating", @"New In", @"Price Up", @"Price Down", @"Name", @"Brand", nil];
    
    [self.sortingScrollView setOptions:sortList];
    
    if (VALID_NOTEMPTY(self.category, RICategory)) {
        [self showLoading];
        [RIProduct getProductsWithUrl:self.category.apiUrl successBlock:^(id products) {
            
            
            [self hideLoading];
        } andFailureBlock:^(NSArray *error) {
            [self hideLoading];
        }];
    }
}

#pragma mark - JAPickerScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{

}

@end

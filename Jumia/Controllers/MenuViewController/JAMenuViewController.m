//
//  JAMenuViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMenuViewController.h"

@interface JAMenuViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMenu;

@end

@implementation JAMenuViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutSearchBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

#pragma mark - Layout search bar

- (void)layoutSearchBar
{
    UITextField *textFieldSearch = [self.searchBar valueForKey:@"_searchField"];
    textFieldSearch.backgroundColor = [UIColor lightGrayColor];
    
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
}

@end

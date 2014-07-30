//
//  JAHomeViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAHomeViewController.h"
#import "JATeaserCategoryScrollView.h"

@interface JAHomeViewController ()

@property (weak, nonatomic) IBOutlet JATeaserCategoryScrollView *teaserCategoryScrollView;

@end

@implementation JAHomeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    NSArray* array = [NSArray arrayWithObjects:@"home", @"computing", @"other", @"maracana", @"electronics", @"herp the derp", @"rio dei djanerou", nil];
    
    [self.teaserCategoryScrollView setCategories:array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar:(JANavigationBar *)navBar
{
    [self.navigationController setValue:navBar
                             forKeyPath:@"navigationBar"];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end

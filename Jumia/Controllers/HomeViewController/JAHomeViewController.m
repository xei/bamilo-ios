//
//  JAHomeViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAHomeViewController.h"
#import "JATeaserCategoryScrollView.h"
#import "JANavigationBar.h"

@interface JAHomeViewController ()
<
    JANavigationBarDelegate
>

@property (weak, nonatomic) IBOutlet JATeaserCategoryScrollView *teaserCategoryScrollView;
@property (strong, nonatomic) JANavigationBar *navBar;

@end

@implementation JAHomeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add the custom navigation bar
    self.navBar = [[JANavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.navBar.customDelegate = self;
    [self.navigationController setValue:self.navBar
                             forKeyPath:@"navigationBar"];
    
    // Do any additional setup after loading the view.
    NSArray* array = [NSArray arrayWithObjects:@"home", @"computing", @"other", @"maracana", @"electronics", @"herp the derp", @"rio dei djanerou", nil];
    
    [self.teaserCategoryScrollView setCategories:array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom navigation bar delegates

- (void)customNavigationBarOpenMenu
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenMenuNotification
                                                        object:nil];
}

#pragma mark - Public methods

- (void)pushViewControllerWithName:(NSString *)name
                    titleForNavBar:(NSString *)title
{
    [self.navBar changeNavigationBarTitle:title];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

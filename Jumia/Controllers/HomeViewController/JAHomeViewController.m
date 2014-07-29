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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    // Dispose of any resources that can be recreated.
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

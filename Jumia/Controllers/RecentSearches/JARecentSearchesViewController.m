//
//  JARecentSearchesViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARecentSearchesViewController.h"

@interface JARecentSearchesViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>

@property (strong, nonatomic) NSMutableArray *recentSearches;
@property (weak, nonatomic) IBOutlet UIView *noSearchesView;
@property (weak, nonatomic) IBOutlet UIImageView *noSearchesImageView;
@property (weak, nonatomic) IBOutlet UILabel *noSearchesLabel;
@property (weak, nonatomic) IBOutlet UITableView *recentSearchesTableView;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;
@property (strong, nonatomic) UIButton *button;

@end

@implementation JARecentSearchesViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"RecentSearches";
    
    self.navBarLayout.title = STRING_RECENT_SEARCHES;
        
    self.noSearchesView.layer.cornerRadius = 5.0f;
    [self.noSearchesLabel setText:STRING_NO_RECENT_SEARCHES];
    
    self.recentSearches = [NSMutableArray new];
    
    self.recentSearches = [[RISearchSuggestion getRecentSearches] mutableCopy];
    
    if (0 == self.recentSearches.count) {
        self.recentSearchesTableView.hidden = YES;
    } else {
        self.noSearchesView.alpha = 0.0f;
        self.noSearchesView.hidden = YES;
        self.recentSearchesTableView.layer.cornerRadius = 5.0f;
        
        float newSize = self.recentSearches.count * 44.0;
        
        self.tableHeightConstraint.constant = newSize;
        [self.recentSearchesTableView needsUpdateConstraints];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(6,
                                  newSize + 20,
                                  self.view.frame.size.width - 12,
                                  44);
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue"
                                       size:16.0];
        
        self.button.titleLabel.font = font;
        [self.button setTitleColor:UIColorFromRGB(0x4e4e4e)
                          forState:UIControlStateNormal];

        [self.button setBackgroundImage:[UIImage imageNamed:@"grayBig_normal"]
                               forState:UIControlStateNormal];
        
        [self.button setBackgroundImage:[UIImage imageNamed:@"grayBig_highlighted"]
                               forState:UIControlStateSelected];
        
        [self.button setBackgroundImage:[UIImage imageNamed:@"grayBig_highlighted"]
                               forState:UIControlStateHighlighted];
        
        [self.button setBackgroundImage:[UIImage imageNamed:@"grayBig_disabled"]
                               forState:UIControlStateDisabled];
        
        [self.button setTitle:STRING_CLEAR_RECENT_SEARCHES
                     forState:UIControlStateNormal];
        
        [self.button addTarget:self
                   action:@selector(clearRecentSearches)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.button];
    }
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action clear

- (void)clearRecentSearches
{
    [RISearchSuggestion deleteAllSearches];
    
    self.noSearchesView.hidden = NO;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.recentSearchesTableView.alpha = 0.0f;
                         self.button.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         
                         self.recentSearchesTableView.hidden = YES;
                         self.button.hidden = YES;
                         
                         [UIView animateWithDuration:0.4f
                                          animations:^{
                                              self.noSearchesView.alpha = 1.0f;
                                          } completion:^(BOOL finished) {
                                              
                                          }];
                     }];
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recentSearches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    
    RISearchSuggestion *search = [self.recentSearches objectAtIndex:indexPath.row];
    
    cell.textLabel.text = search.item;
    
    cell.imageView.image = [UIImage imageNamed:@"ico_recentsearches_results"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    RISearchSuggestion *suggestion = [self.recentSearches objectAtIndex:indexPath.row];
    [RISearchSuggestion putRecentSearchInTop:suggestion];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedRecentSearchNotification object:suggestion];
}

@end

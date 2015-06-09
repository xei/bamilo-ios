//
//  JARecentSearchesViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARecentSearchesViewController.h"
#import "JAClickableView.h"

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
    self.noSearchesLabel.font = [UIFont fontWithName:kFontRegularName size:self.noSearchesLabel.font.pointSize];
    [self.noSearchesLabel setText:STRING_NO_RECENT_SEARCHES];
    
    self.recentSearches = [NSMutableArray new];
    
    self.recentSearches = [[RISearchSuggestion getRecentSearches] mutableCopy];
    
    if (0 == self.recentSearches.count) {
        self.recentSearchesTableView.hidden = YES;
    } else {
        self.noSearchesView.alpha = 0.0f;
        self.noSearchesView.hidden = YES;
        self.recentSearchesTableView.layer.cornerRadius = 5.0f;
        self.recentSearchesTableView.scrollEnabled = NO;
        self.recentSearchesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIFont *font = [UIFont fontWithName:kFontRegularName
                                       size:16.0];
        
        self.button.titleLabel.font = font;
        [self.button setTitleColor:UIColorFromRGB(0x4e4e4e)
                          forState:UIControlStateNormal];

        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
            [self.button setBackgroundImage:[UIImage imageNamed:@"greyFullPortrait_normal"]
                                   forState:UIControlStateNormal];
            [self.button setBackgroundImage:[UIImage imageNamed:@"greyFullPortrait_highlighted"]
                                   forState:UIControlStateSelected];
            [self.button setBackgroundImage:[UIImage imageNamed:@"greyFullPortrait_highlighted"]
                                   forState:UIControlStateHighlighted];
            [self.button setBackgroundImage:[UIImage imageNamed:@"greyFullPortrait_disabled"]
                                   forState:UIControlStateDisabled];
        } else {
            [self.button setBackgroundImage:[UIImage imageNamed:@"greyBig_normal"]
                                   forState:UIControlStateNormal];
            [self.button setBackgroundImage:[UIImage imageNamed:@"greyBig_highlighted"]
                                   forState:UIControlStateSelected];
            [self.button setBackgroundImage:[UIImage imageNamed:@"greyBig_highlighted"]
                                   forState:UIControlStateHighlighted];
            [self.button setBackgroundImage:[UIImage imageNamed:@"greyBig_disabled"]
                                   forState:UIControlStateDisabled];
        }
        
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat newSize = self.recentSearches.count * [self tableView:self.recentSearchesTableView heightForRowAtIndexPath:nil];
    self.recentSearchesTableView.frame = CGRectMake(self.recentSearchesTableView.frame.origin.x,
                                                    self.recentSearchesTableView.frame.origin.y,
                                                    self.view.frame.size.width - self.recentSearchesTableView.frame.origin.x*2,
                                                    newSize);
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        CGFloat buttonWidth = [UIImage imageNamed:@"greyFullPortrait_normal"].size.width;
        self.button.frame = CGRectMake((self.view.frame.size.width - buttonWidth) / 2,
                                       newSize + 12.0f,
                                       buttonWidth,
                                       44);
        self.noSearchesView.frame = CGRectMake(self.noSearchesView.frame.origin.x,
                                               self.noSearchesView.frame.origin.y,
                                               self.view.frame.size.width - self.noSearchesView.frame.origin.x * 2,
                                               300.0f);
        self.noSearchesImageView.frame = CGRectMake((self.noSearchesView.frame.size.width - self.noSearchesImageView.frame.size.width)/2,
                                                    56.0f,
                                                    self.noSearchesImageView.frame.size.width,
                                                    self.noSearchesImageView.frame.size.height);
        self.noSearchesLabel.frame = CGRectMake(12.0f,
                                                183.0f,
                                                self.noSearchesView.frame.size.width - 12*2,
                                                self.noSearchesLabel.frame.size.height);
    } else {
        self.button.frame = CGRectMake(6,
                                       newSize + 20,
                                       self.view.frame.size.width - 12,
                                       44);
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"RecentSearches"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat newSize = self.recentSearches.count * [self tableView:self.recentSearchesTableView heightForRowAtIndexPath:nil];
    self.recentSearchesTableView.frame = CGRectMake(self.recentSearchesTableView.frame.origin.x,
                                                    self.recentSearchesTableView.frame.origin.y,
                                                    self.view.frame.size.width - self.recentSearchesTableView.frame.origin.x*2,
                                                    newSize);
    [self.recentSearchesTableView reloadData];
    CGFloat buttonWidth = [UIImage imageNamed:@"greyFullPortrait_normal"].size.width;
    self.button.frame = CGRectMake((self.view.frame.size.width - buttonWidth) / 2,
                                   newSize + 12.0f,
                                   buttonWidth,
                                   44);
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        self.noSearchesView.frame = CGRectMake(self.noSearchesView.frame.origin.x,
                                               self.noSearchesView.frame.origin.y,
                                               self.view.frame.size.width - self.noSearchesView.frame.origin.x * 2,
                                               300.0f);
        self.noSearchesImageView.frame = CGRectMake((self.noSearchesView.frame.size.width - self.noSearchesImageView.frame.size.width)/2,
                                                    56.0f,
                                                    self.noSearchesImageView.frame.size.width,
                                                    self.noSearchesImageView.frame.size.height);
        self.noSearchesLabel.frame = CGRectMake(12.0f,
                                                183.0f,
                                                self.noSearchesView.frame.size.width - 12*2,
                                                self.noSearchesLabel.frame.size.height);
    }
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
    
    if (ISEMPTY(cell)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchCell"];
    }
    for (UIView* view in cell.subviews) {
        if ([view isKindOfClass:[JAClickableView class]]) { //remove the clickable view
            [view removeFromSuperview];
        } else {
            for (UIView* subview in view.subviews) {
                if ([subview isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                    [subview removeFromSuperview];
                }
            }
        }
    }
    
    JAClickableView* clickableView = [[JAClickableView alloc] init];
    clickableView.frame = CGRectMake(0.0f,
                                     0.0f,
                                     self.recentSearchesTableView.frame.size.width,
                                     cell.height);
    clickableView.tag = indexPath.row;
    [clickableView addTarget:self action:@selector(pressedClickableViewInCell:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:clickableView];
    
    UIImage* customIcon = [UIImage imageNamed:@"ico_recentsearches_results"];
    UIImageView* customImageView = [[UIImageView alloc] initWithImage:customIcon];
    
    CGFloat margin = (clickableView.bounds.size.height - customIcon.size.height)/2;
    customImageView.frame = CGRectMake(margin,
                                       margin,
                                       customIcon.size.width,
                                       customIcon.size.height);
    [clickableView addSubview:customImageView];
    
    CGFloat remainingWidth = clickableView.frame.size.width - customImageView.frame.size.width - margin*3;
    UILabel* customTextLabel = [UILabel new];
    customTextLabel.frame = CGRectMake(CGRectGetMaxX(customImageView.frame) + margin,
                                       clickableView.bounds.origin.y,
                                       remainingWidth,
                                       clickableView.frame.size.height);
    [clickableView addSubview:customTextLabel];
    
    RISearchSuggestion *search = [self.recentSearches objectAtIndex:indexPath.row];
    customTextLabel.text = search.item;
    
    if (indexPath.row < self.recentSearches.count-1) {
        UIView* separator = [UIView new];
        separator.backgroundColor = JALabelGrey;
        separator.frame = CGRectMake(0.0f,
                                     clickableView.frame.size.height - 1,
                                     clickableView.frame.size.width,
                                     1);
        [clickableView addSubview:separator];
    }
    
    if (RI_IS_RTL) {
        [clickableView flipSubviewAlignments];
        [clickableView flipSubviewPositions];
    }
    
    return cell;
}

- (void)pressedClickableViewInCell:(UIButton*)sender
{
    [self tableView:self.recentSearchesTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
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

//
//  NoResultViewController.m
//  Jumia
//
//  Created by aliunco on 1/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CatalogNoResultViewController.h"
#import "RITeaserGrouping.h"
#import "RITeaserComponent.h"
#import "PopularTeaserTableViewCell.h"

@interface CatalogNoResultViewController ()
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
    @property (strong, nonatomic) RITeaserGrouping *teaserGroup;
@end

@implementation CatalogNoResultViewController

const CGFloat tableViewCellHeight = 55;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getPopularTeasers];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    
    [self.tableView registerNib:[UINib nibWithNibName:[PopularTeaserTableViewCell nibNAme] bundle:nil]
                    forCellReuseIdentifier:[PopularTeaserTableViewCell nibNAme]];

}


- (void)getPopularTeasers {
    NSDictionary* popularTeaserJson = [self getPopularTeaserMock];
    self.teaserGroup = [RITeaserGrouping parseTeaserGrouping:popularTeaserJson country:nil];
    [self refreshView];
}

- (NSDictionary *)getPopularTeaserMock {
    return @{
             @"type" : @"popular_teaser",
             @"title": @"مجموعه های منتخب",
             @"data" : @[
                     @{
                         @"image": @"",
                         @"title": @"مد و لباس",
                         @"target":@"static_page::fashion-lp"
                         },
                     @{
                         @"image": @"",
                         @"title": @"لوازم جانبی الکترونیکی",
                         @"target":@"shop_in_shop::electronic_accessories_lp"
                         },
                     @{
                         @"image": @"",
                         @"title": @"خانه و سبک زندگی",
                         @"target":@"shop_in_shop::home_furniture_lifestyle_lp"
                         },
                     
                     @{
                         @"image": @"",
                         @"title": @"زیبایی و سلامت",
                         @"target":@"shop_in_shop::health_beauty_personal_care_lp"
                         },
                     @{
                         @"image": @"",
                         @"title": @"موبایل و تبلت",
                         @"target":@"shop_in_shop::smartphone_tablet_mobile_lp"
                         }
                     ]
             };
}

- (void)refreshView {
    dispatch_async(dispatch_get_main_queue(), ^{
       self.tableViewHeightConstraint.constant = tableViewCellHeight * self.teaserGroup.teaserComponents.count;
    });
    [self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self.teaserGroup.teaserComponents objectAtIndex:indexPath.row] sendNotificationForTeaseTarget:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:false];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopularTeaserTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[PopularTeaserTableViewCell nibNAme] forIndexPath:indexPath];
    RITeaserComponent* teaserComponent = [self.teaserGroup.teaserComponents objectAtIndex:indexPath.row];
    cell.titleString = teaserComponent.title;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.teaserGroup.teaserComponents.count;
}

@end

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
#import "PlainTableViewHeaderCell.h"

@interface CatalogNoResultViewController ()
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
    @property (weak, nonatomic) IBOutlet UILabel *noResultMessageUILabel;
    @property (weak, nonatomic) IBOutlet UILabel *warningMessageUILabel;

    @property (strong, nonatomic) RITeaserGrouping *teaserGroup;
@end

@implementation CatalogNoResultViewController

const CGFloat tableViewCellHeight = 45;
const CGFloat tableViewHeaderSectionHeight = 35;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getPopularTeasers];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:[PopularTeaserTableViewCell nibName] bundle:nil]
                    forCellReuseIdentifier:[PopularTeaserTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil]
         forCellReuseIdentifier:[PlainTableViewHeaderCell nibName]];
    
    [self.noResultMessageUILabel setFont: [UIFont fontWithName:kFontRegularName size:14]];
    [self.warningMessageUILabel setFont: [UIFont fontWithName:kFontLightName size:11]];

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
                         @"image": @"fashion",
                         @"title": @"مد و لباس",
                         @"target":@"static_page::fashion-lp"
                         },
                     @{
                         @"image": @"electronic-acc",
                         @"title": @"لوازم جانبی الکترونیکی",
                         @"target":@"shop_in_shop::electronic_accessories_lp"
                         },
                     @{
                         @"image": @"home-life-style",
                         @"title": @"خانه و سبک زندگی",
                         @"target":@"shop_in_shop::home_furniture_lifestyle_lp"
                         },
                     
                     @{
                         @"image": @"health-and-beauty",
                         @"title": @"زیبایی و سلامت",
                         @"target":@"shop_in_shop::health_beauty_personal_care_lp"
                         },
                     @{
                         @"image": @"mobile-tablet",
                         @"title": @"موبایل و تبلت",
                         @"target":@"shop_in_shop::smartphone_tablet_mobile_lp"
                         }
                     ]
             };
}

- (void)refreshView {
    dispatch_async(dispatch_get_main_queue(), ^{
       self.tableViewHeightConstraint.constant = (tableViewCellHeight * self.teaserGroup.teaserComponents.count) + tableViewHeaderSectionHeight;
    });
    [self.tableView reloadData];
}

- (void)setSearchQuery:(NSString *)searchQuery {
    NSString* msgToShow;
    if (searchQuery) {
        
        searchQuery = [searchQuery wrapWithMaxSize:7];
        msgToShow = [NSString stringWithFormat:@"متاسفانه برای %@ شما نتیجه یافت نشد", searchQuery];
        
    } else { //if there is no searchQuery (e.g. comes from empty category
        msgToShow = @"متاسفانه موردی یافت نشد";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.noResultMessageUILabel.text = msgToShow;
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self.teaserGroup.teaserComponents objectAtIndex:indexPath.row] sendNotificationForTeaseTarget:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:false];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlainTableViewHeaderCell *headerCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[PlainTableViewHeaderCell nibName]];
    headerCell.titleString = self.teaserGroup.title;
    return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return tableViewHeaderSectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopularTeaserTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[PopularTeaserTableViewCell nibName] forIndexPath:indexPath];
    RITeaserComponent* teaserComponent = [self.teaserGroup.teaserComponents objectAtIndex:indexPath.row];
    cell.titleString = teaserComponent.title;
    cell.imageUrl = teaserComponent.imagePortraitUrl;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.teaserGroup.teaserComponents.count;
}

@end

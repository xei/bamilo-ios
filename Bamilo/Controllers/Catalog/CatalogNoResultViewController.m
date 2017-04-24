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
#import "EmarsysRecommendationCarouselWidget.h"
#import "EmarsysPredictManager.h"
#import "EmarsysPredictProtocol.h"
#import "NSArray+Extension.h"
#import "RecommendItem.h"
#import "ThreadManager.h"

@interface CatalogNoResultViewController () <EmarsysRecommendationsProtocol, FeatureBoxCollectionViewWidgetViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *noResultMessageUILabel;
@property (weak, nonatomic) IBOutlet UILabel *warningMessageUILabel;
@property (strong, nonatomic) RITeaserGrouping *teaserGroup;
@property (strong, nonatomic) IBOutlet EmarsysRecommendationCarouselWidget *carouselWidget;
@end

@implementation CatalogNoResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.carouselWidget setBackgroundColor:JAHomePageBackgroundGrey];
    self.carouselWidget.delegate = self;
    
    [self.noResultMessageUILabel setFont: [UIFont fontWithName:kFontRegularName size:14]];
    [self.warningMessageUILabel setFont: [UIFont fontWithName:kFontLightName size:11]];
    
    [self.carouselWidget hide];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)getSuggestions {
    [EmarsysPredictManager sendTransactionsOf:self];
}

- (void)updateNavBar {
    self.navBarLayout.showBackButton = YES;
}

- (void)setSearchQuery:(NSString *)searchQuery {
    NSString* msgToShow;
    if (searchQuery) {
        searchQuery = [searchQuery wrapWithMaxSize:20];
        msgToShow = [NSString stringWithFormat:@"متاسفانه برای %@ نتیجه یافت نشد", searchQuery];
    } else { //if there is no searchQuery (e.g. comes from empty category
        msgToShow = @"متاسفانه موردی یافت نشد";
    }
    
    [ThreadManager executeOnMainThread:^{
      self.noResultMessageUILabel.text = msgToShow;
    }];
}

#pragma mark - EmarsysPredictProtocol
- (BOOL)isPreventSendTransactionInViewWillAppear {
    return YES;
}

- (NSArray<EMRecommendationRequest *> *)getRecommendations {
    EMRecommendationRequest *recommend = [EMRecommendationRequest requestWithLogic:@"PERSONAL"];
    recommend.limit = 15;
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
        [ThreadManager executeOnMainThread:^{
            [self.carouselWidget fadeIn:0.15];
            [self.carouselWidget updateWithModel:[result.products map:^id(EMRecommendationItem *item) {
                return [RecommendItem instanceWithEMRecommendationItem:item];
            }]];
        }];
    };
    
    return @[recommend];
}

#pragma mark - FeatureBoxCollectionViewWidgetViewDelegate
- (void)selectFeatureItem:(NSObject *)item widgetBox:(id)widgetBox {
    if ([item isKindOfClass:[RecommendItem class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName: kDidSelectTeaserWithPDVUrlNofication
                                                            object: nil
                                                          userInfo: @{@"sku": ((RecommendItem *)item).sku}];
    }
}

@end

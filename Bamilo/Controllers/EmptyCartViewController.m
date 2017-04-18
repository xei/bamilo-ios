//
//  EmptyCartViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmptyCartViewController.h"
#import "EmarsysPredictProtocol.h"
#import "EmarsysRecommendationCarouselWidget.h"
#import "OrangeButton.h"
#import "ThreadManager.h"
#import "NSArray+Extension.h"
#import "EmarsysPredictManager.h"

@interface EmptyCartViewController() <EmarsysRecommendationsProtocol, FeatureBoxCollectionViewWidgetViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet EmarsysRecommendationCarouselWidget *carouselWidget;
@end

@implementation EmptyCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tabBarIsVisible = YES;
    
    [self.carouselWidget setBackgroundColor:JAHomePageBackgroundGrey];
    self.carouselWidget.delegate = self;
    
    [self.titleLabel applyStyle:[Theme font:kFontVariationRegular size:13.0f] color:[UIColor blackColor]];
}

- (void)getSuggestions {
    [EmarsysPredictManager sendTransactionsOf:self];
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

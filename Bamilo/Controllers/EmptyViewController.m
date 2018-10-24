//
//  EmptyCartViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmptyViewController.h"
#import "EmarsysPredictProtocol.h"
#import "EmarsysRecommendationMinimalCarouselWidget.h"
#import "OrangeButton.h"
#import "ThreadManager.h"
#import "NSArray+Extension.h"
#import "EmarsysPredictManager.h"
#import "Bamilo-Swift.h"

@interface EmptyViewController() //<EmarsysRecommendationsProtocol, FeatureBoxCollectionViewWidgetViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
//@property (weak, nonatomic) IBOutlet EmarsysRecommendationMinimalCarouselWidget *carouselWidget;

@property (copy, nonatomic) NSString *titleString;
@property (strong, nonatomic) UIImage *topImage;
//@property (strong, nonatomic) NSArray<RecommendItem*>* recommendedProducts;

@end

@implementation EmptyViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self.carouselWidget setBackgroundColor:[Theme color:kColorVeryLightGray]];
//    self.carouselWidget.delegate = self;
//    [self.carouselWidget updateTitle:STRING_BAMILO_RECOMMENDATION_FOR_YOU];
    
//    [self.carouselWidget hide];
    [self.titleLabel applyStyle:[Theme font:kFontVariationRegular size:13.0f] color:[UIColor blackColor]];
    
    self.titleLabel.text = self.titleString;
    self.topImageView.image = self.topImage;
    
}

- (void)updateTitle:(NSString *)title {
    self.titleString = title;
    self.titleLabel.text = title;
}

- (void)updateImage:(UIImage *)image {
    self.topImage = image;
    self.topImageView.image = image;
}

- (void)getSuggestions {
//    [EmarsysPredictManager sendTransactionsOf:self];
}

#pragma mark - EmarsysPredictProtocol
//- (BOOL)isPreventSendTransactionInViewWillAppear {
//    return YES;
//}
//
//- (NSArray<EMRecommendationRequest *> *)getRecommendations {
//    EMRecommendationRequest *recommend = [EMRecommendationRequest requestWithLogic:self.recommendationLogic ?: @"PERSONAL"];
//    recommend.limit = 100;
//    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
//        if (!result.products.count) return;
//        [ThreadManager executeOnMainThread:^{
//            [self.carouselWidget fadeIn:0.15];
//            self.recommendedProducts = [result.products map:^id(EMRecommendationItem *item) {
//                return [[RecommendItem alloc] initWithItem:item];
//            }];
//            [self.carouselWidget updateWithModel: [self.recommendedProducts subarrayWithRange:NSMakeRange(0, MIN(self.recommendedProducts.count, 15))]];
//        }];
//    };
//
//    return @[recommend];
//}

//- (void)moreButtonTappedInWidgetView:(id)widgetView {
//    [self performSegueWithIdentifier:@"showAllRecommendationView" sender:nil];
//}

#pragma mark - FeatureBoxCollectionViewWidgetViewDelegate
//- (void)selectFeatureItem:(NSObject *)item widgetBox:(id)widgetBox {
//    if ([item isKindOfClass:[RecommendItem class]]) {
//        [TrackerManager postEventWithSelector:[EventSelectors recommendationTappedSelector] attributes:[EventAttributes tapEmarsysRecommendationWithScreenName:self.parentScreenName logic:self.recommendationLogic ?: @"PERSONAL"]];
//
//        //track behaviour journey from here
//        [[MainTabBarViewController topNavigationController] openScreenTarget:[RITarget getTarget:PRODUCT_DETAIL node:((RecommendItem *)item).sku] purchaseInfo:[BehaviourTrackingInfo trackingInfoWithCategory:@"Emarsys" label:[NSString stringWithFormat:@"%@-%@", self.parentScreenName, self.recommendationLogic ?: @"PERSONAL"]] currentScreenName:self.parentScreenName];
//    }
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString: @"showAllRecommendationView"]) {
//        AllRecommendationViewController *viewCtrl = (AllRecommendationViewController *) [segue destinationViewController];
//        viewCtrl.recommendItems = self.recommendedProducts;
//    }
//}

@end

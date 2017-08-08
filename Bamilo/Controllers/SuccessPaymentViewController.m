//
//  SuccessPaymentViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SuccessPaymentViewController.h"
#import "EmarsysRecommendationMinimalCarouselWidget.h"
#import "EmarsysPredictProtocol.h"
#import "ThreadManager.h"
#import "NSArray+Extension.h"
#import "EventUtilities.h"
#import "EmarsysPredictManager.h"
#import "Bamilo-Swift.h"


// --- Legacy imports ---
#import "RIProduct.h"
#import "RICartItem.h"
#import "JAUtils.h"

@interface SuccessPaymentViewController () <EmarsysPredictProtocol, PerformanceTrackerProtocol, FeatureBoxCollectionViewWidgetViewDelegate>
@property (nonatomic, weak) IBOutlet EmarsysRecommendationMinimalCarouselWidget *carouselWidget;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descLabel;
@end

@implementation SuccessPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.carouselWidget hide];
    STRING_CHECKOUT
    [self.carouselWidget setBackgroundColor:[Theme color:kColorVeryLightGray]];
    self.carouselWidget.delegate = self;
    [self setupView];
    [self trackPurchase];
    [self.carouselWidget updateTitle:STRING_BAMILO_RECOMMENDATION];
}

- (void)setupView {
    [self.titleLabel applyStyle:[Theme font:kFontVariationRegular size:20.0f] color:[Theme color:kColorGreen]];
    [self.descLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[UIColor blackColor]];
    self.titleLabel.text = STRING_THANK_YOU_ORDER_TITLE;
    self.descLabel.text = STRING_ORDER_SUCCESS;
    [self.carouselWidget hide];
}

- (void)trackPurchase {
    //EVENT: PURCHASE
    [TrackerManager postEventWithSelector:[EventSelectors purchaseSelector] attributes:[EventAttributes purchaseWithCart:self.cart success:YES]];
    [TrackerManager postEventWithSelector:[EventSelectors checkoutFinishedSelector] attributes:[EventAttributes chekcoutFinishWithCart:self.cart]];
    
    [TrackerManager sendTagWithTags:@{ @"PurchaseCount": @([UserDefaultsManager incrementCounter:kUDMPurchaseCount]) } completion:^(NSError *error) {
        if(error == nil) {
            NSLog(@"TrackerManager > PurchaseCount > %d", [UserDefaultsManager getCounter:kUDMPurchaseCount]);
        }
    }];
    
    //check if came from teasers and track that info
    NSDictionary* teaserTrackingInfoDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey];
    [self.cart.cartEntity.cartItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[RICartItem class]]) {
            NSString *teaserTrackingInfo = [teaserTrackingInfoDictionary objectForKey:((RICartItem *)obj).sku];
            if (teaserTrackingInfo.length) {
                [TrackerManager postEventWithSelector:[EventSelectors teaserPurchasedSelector] attributes:[EventAttributes teaserPurchaseWithTeaserName:teaserTrackingInfo screenName:@"HomePage"]];
            }
        }
    }];
    
    
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSkusFromTeaserInCartKey];
    //// ------- START OF LEGACY CODES ------
    // Notification to clean cart
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    [RICart resetCartWithSuccessBlock:^{} andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {}];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kDidFirstBuyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //// ------- END OF LEGACY CODES ------
    
    [self publishScreenLoadTime];
    [EmarsysPredictManager sendTransactionsOf:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"ThankYou"];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - EmarsysPredictProtocol
- (EMTransaction *)getDataCollection:(EMTransaction *)transaction {
    [transaction setPurchase:self.cart.orderNr ofItems: [self.cart convertItems]];
    return transaction;
}


- (NSArray<EMRecommendationRequest *> *)getRecommendations {
    NSString *recommendationLogic = self.cart.cartEntity.cartCount.integerValue == 1 ? @"ALSO_BOUGHT" : @"PERSONAL"; //Production requirement
    EMRecommendationRequest *recommend = [EMRecommendationRequest requestWithLogic: recommendationLogic];
    recommend.limit = 15;
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
        if (!result.products.count) return;
        [ThreadManager executeOnMainThread:^{
            [self.carouselWidget fadeIn:0.15];
            [self.carouselWidget updateWithModel:[result.products map:^id(EMRecommendationItem *item) {
                return [RecommendItem instanceWithEMRecommendationItem:item];
            }]];
        }];
        
        //Reset the shared Cart entities
        [RICart sharedInstance].cartEntity.cartItems = @[];
    };
    
    return @[recommend];
}



#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"CheckoutFinish";
}

- (BOOL)isPreventSendTransactionInViewWillAppear {
    return YES;
}

#pragma mark - FeatureBoxCollectionViewWidgetViewDelegate
- (void)selectFeatureItem:(NSObject *)item widgetBox:(id)widgetBox {
    if ([item isKindOfClass:[RecommendItem class]]) {
        [TrackerManager postEventWithSelector:[EventSelectors recommendationTappedSelector] attributes:[EventAttributes tapEmarsysRecommendationWithScreenName:[self getScreenName] logic:self.cart.cartEntity.cartCount.integerValue == 1 ? @"ALSO_BOUGHT" : @"PERSONAL"]];
        [[NSNotificationCenter defaultCenter] postNotificationName: kDidSelectTeaserWithPDVUrlNofication
                                                            object: nil
                                                          userInfo: @{@"sku": ((RecommendItem *)item).sku,
                                                                      @"show_back_button": @(YES)
                                                                      }];
    }
}

#pragma mark - hide tabbar in this view controller
- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}

- (BOOL)navbarhideBackButton {
    return YES;
}


@end

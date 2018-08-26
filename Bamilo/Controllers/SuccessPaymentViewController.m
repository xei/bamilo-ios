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

@interface SuccessPaymentViewController () <EmarsysPredictProtocol, FeatureBoxCollectionViewWidgetViewDelegate>
@property (nonatomic, weak) IBOutlet EmarsysRecommendationMinimalCarouselWidget *carouselWidget;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *orderDetailButton;
@property (strong, nonatomic) NSArray<RecommendItem *>* recommendedProducts;
@end

@implementation SuccessPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.carouselWidget hide];
    
    [self.carouselWidget setBackgroundColor:[Theme color:kColorVeryLightGray]];
    self.carouselWidget.delegate = self;
    [self setupView];
    [self.carouselWidget updateTitle:STRING_BAMILO_RECOMMENDATION_FOR_YOU];
    
    [self.tabBarController.tabBar setTranslucent:NO];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self trackPurchase];
    
    //Ecommerce tracking
    [[GoogleAnalyticsTracker sharedTracker] trackEcommerceCartInCheckoutWithCart:self.cart step:@(5) options:@"SuccessPayment"];
    
    [self resetTheCart];
}

- (void)resetTheCart {
    //Reset the shared Cart entities
    [RICart sharedInstance].cartEntity.cartItems = @[];
    [RICart sharedInstance].cartEntity.packages = @[];
    [RICart sharedInstance].cartEntity.cartCount = 0;
    
    [MainTabBarViewController updateCartValueWithCart:[RICart sharedInstance]];
}

- (void)setupView {
    [self.titleLabel applyStyle:[Theme font:kFontVariationRegular size:19.0f] color: [Theme color:kColorGreen]];
    [self.descLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[UIColor blackColor]];
    self.titleLabel.text = STRING_THANK_YOU_ORDER_TITLE;
    
    if ([self.cart.orderNr isKindOfClass:[NSString class]] && [self.cart.orderNr length]) {
        self.descLabel.text = [[NSString stringWithFormat:@"%@\n%@: %@", STRING_ORDER_SUCCESS, STRING_ORDER_NO, self.cart.orderNr] numbersToPersian];
    } else {
        self.descLabel.text = STRING_ORDER_SUCCESS;
    }

    self.iconImageView.image = [UIImage imageNamed:@"successIcon"];
    [self.carouselWidget hide];
    
    [EmarsysPredictManager sendTransactionsOf:self];
    [self.orderDetailButton setHidden:NO];
    
    if ([self.cart.orderNr isKindOfClass:[NSString class]] && [self.cart.orderNr length]) {
        [ReviewSurveyManager getJourneySurveyWithOrderID: self.cart.orderNr];
    }
}

- (void)trackPurchase {
    //EVENT: PURCHASE
    [TrackerManager postEventWithSelector:[EventSelectors purchaseSelector] attributes:[EventAttributes purchaseWithCart:self.cart success:YES]];
    [TrackerManager postEventWithSelector:[EventSelectors checkoutFinishedSelector] attributes:[EventAttributes chekcoutFinishWithCart:self.cart]];
    
    [[GoogleAnalyticsTracker sharedTracker] trackTransactionWithCart:self.cart];
    [TrackerManager sendTagWithTags:@{ @"PurchaseCount": @([UserDefaultsManager incrementCounter:kUDMPurchaseCount]) } completion:^(NSError *error) {
        if(error == nil) {
            NSLog(@"TrackerManager > PurchaseCount > %d", [UserDefaultsManager getCounter:kUDMPurchaseCount]);
        }
    }];
    
    //check if came from teasers and track that info
    [self.cart.cartEntity.packages enumerateObjectsUsingBlock:^(CartPackage * _Nonnull package, NSUInteger idx, BOOL * _Nonnull stop) {
        [package.products enumerateObjectsUsingBlock:^(RICartItem * _Nonnull product, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([product isKindOfClass:[RICartItem class]]) {
                PurchaseBehaviour *behaviour = [[PurchaseBehaviourRecorder sharedInstance] getBehviourBySkuWithSku:((RICartItem *)product).sku];
                if (behaviour) {
                    [TrackerManager postEventWithSelector:[EventSelectors behaviourPurchasedSelector] attributes:[EventAttributes purchaseBehaviourWithBehaviour:behaviour]];
                }
            }
        }];
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSkusFromTeaserInCartKey];
    //// ------- START OF LEGACY CODES ------
    // Notification to clean cart
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    [RICart resetCartWithSuccessBlock:^{} andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {}];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kDidFirstBuyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //// ------- END OF LEGACY CODES ------
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - EmarsysPredictProtocol
- (EMTransaction *)getDataCollection:(EMTransaction *)transaction {
    [transaction setPurchase:self.cart.orderNr ofItems: [self.cart convertItems]];
    return transaction;
}


- (NSArray<EMRecommendationRequest *> *)getRecommendations {
    NSString *recommendationLogic = self.cart.cartEntity.cartCount.integerValue == 1 ? @"ALSO_BOUGHT" : @"PERSONAL"; //Production requirement
    EMRecommendationRequest *recommend = [EMRecommendationRequest requestWithLogic: recommendationLogic];
    recommend.limit = 100;
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
        if (!result.products.count) return;
        [ThreadManager executeOnMainThread:^{
            [self.carouselWidget fadeIn:0.15];
            self.recommendedProducts = [result.products map:^id(EMRecommendationItem *item) {
                return [[RecommendItem alloc] initWithItem:item];
            }];
            [self.carouselWidget updateWithModel: [self.recommendedProducts subarrayWithRange:NSMakeRange(0, MIN(self.recommendedProducts.count, 15))]];
        }];
    };
    return @[recommend];
}

- (void)moreButtonTappedInWidgetView:(id)widgetView {
    [self performSegueWithIdentifier:@"showAllRecommendationView" sender:nil];
}


#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"CheckoutFinish";
}

- (BOOL)isPreventSendTransactionInViewWillAppear {
    return YES;
}
- (IBAction)orderDetailButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"OrderDetailViewController" sender:sender];
}

#pragma mark - FeatureBoxCollectionViewWidgetViewDelegate
- (void)selectFeatureItem:(NSObject *)item widgetBox:(id)widgetBox {
    if ([item isKindOfClass:[RecommendItem class]]) {
        
        NSString *logic = self.cart.cartEntity.cartCount.integerValue == 1 ? @"ALSO_BOUGHT" : @"PERSONAL";
        
        [TrackerManager postEventWithSelector:[EventSelectors recommendationTappedSelector] attributes:[EventAttributes tapEmarsysRecommendationWithScreenName:[self getScreenName] logic:logic]];
        
        //track behaviour journey from here
        [[MainTabBarViewController topNavigationController] openScreenTarget:[RITarget getTarget:PRODUCT_DETAIL node:((RecommendItem *)item).sku] purchaseInfo:[BehaviourTrackingInfo trackingInfoWithCategory:@"Emarsys" label:[NSString stringWithFormat:@"%@-%@", [self getScreenName], logic]] currentScreenName:[self getScreenName]];
    }
}

#pragma mark - hide tabbar in this view controller
- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}

- (BOOL)navBarhideBackButton {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"showAllRecommendationView"]) {
        AllRecommendationViewController *viewCtrl = (AllRecommendationViewController *) [segue destinationViewController];
        viewCtrl.recommendItems = self.recommendedProducts;
    } else if([segue.identifier isEqualToString: @"OrderDetailViewController"]) {
        self.hidesBottomBarWhenPushed = YES;
        OrderDetailViewController *orderDetailViewCtrl = (OrderDetailViewController *)segue.destinationViewController;
        self.hidesBottomBarWhenPushed = NO;
        orderDetailViewCtrl.orderId = self.cart.orderNr;
    }
}

@end

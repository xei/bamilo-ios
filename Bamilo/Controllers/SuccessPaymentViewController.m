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
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *orderListButton;
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
    
    //Reset the shared Cart entities
    [RICart sharedInstance].cartEntity.cartItems = @[];
    [RICart sharedInstance].cartEntity.cartCount = 0;
    
    [self.tabBarController.tabBar setTranslucent:NO];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self trackPurchase];
}

- (void)setupView {
    [self.titleLabel applyStyle:[Theme font:kFontVariationRegular size:19.0f] color: [Theme color:kColorGreen]];
    [self.descLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[UIColor blackColor]];
    self.titleLabel.text = STRING_THANK_YOU_ORDER_TITLE;
    self.descLabel.text = STRING_ORDER_SUCCESS;
    self.iconImageView.image = [UIImage imageNamed:@"successIcon"];
    [self.carouselWidget hide];
    
    [EmarsysPredictManager sendTransactionsOf:self];
    [self.orderListButton setHidden:NO];
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
    [self.cart.cartEntity.cartItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[RICartItem class]]) {
            PurchaseBehaviour *behaviour = [[PurchaseBehaviourRecorder sharedInstance] getBehviourBySkuWithSku:((RICartItem *)obj).sku];
            if (behaviour) {
                [TrackerManager postEventWithSelector:[EventSelectors behaviourPurchasedSelector] attributes:[EventAttributes purchaseBehaviourWithBehaviour:behaviour]];
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    recommend.limit = 100;
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
        if (!result.products.count) return;
        [ThreadManager executeOnMainThread:^{
            [self.carouselWidget fadeIn:0.15];
            self.recommendedProducts = [result.products map:^id(EMRecommendationItem *item) {
                return [[RecommendItem alloc] initWithItem:item];
            }];
            [self.carouselWidget updateWithModel: [self.recommendedProducts subarrayWithRange:NSMakeRange(0, 15)]];
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

- (BOOL)navBarhideBackButton {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"showAllRecommendationView"]) {
        AllRecommendationViewController *viewCtrl = (AllRecommendationViewController *) [segue destinationViewController];
        viewCtrl.recommendItems = self.recommendedProducts;
    }
}

@end

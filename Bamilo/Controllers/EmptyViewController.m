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

@interface EmptyViewController() <EmarsysRecommendationsProtocol, FeatureBoxCollectionViewWidgetViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet EmarsysRecommendationMinimalCarouselWidget *carouselWidget;

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) UIImage *topImage;
@end

@implementation EmptyViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tabBarIsVisible = YES;
    
    [self.carouselWidget setBackgroundColor:[Theme color:kColorVeryLightGray]];
    self.carouselWidget.delegate = self;
    [self.carouselWidget updateTitle:STRING_BAMILO_RECOMMENDATION];
    
    [self.carouselWidget hide];
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
    [EmarsysPredictManager sendTransactionsOf:self];
}

#pragma mark - EmarsysPredictProtocol
- (BOOL)isPreventSendTransactionInViewWillAppear {
    return YES;
}

- (NSArray<EMRecommendationRequest *> *)getRecommendations {
    EMRecommendationRequest *recommend = [EMRecommendationRequest requestWithLogic:self.recommendationLogic ?: @"PERSONAL"];
    recommend.limit = 15;
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
        if (!result.products.count) return;
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

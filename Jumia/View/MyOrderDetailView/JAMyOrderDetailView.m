//
//  JAMyOrderDetailView.m
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyOrderDetailView.h"
#import "JAProductInfoHeaderLine.h"
#import "JAProductCollectionViewFlowLayout.h"
#import "JAOrderItemCollectionViewCell.h"
#import "JAMyOrderResumeView.h"
#import "JACenterNavigationController.h"
#import "JAUtils.h"
#import "RICustomer.h"

@interface JAMyOrderDetailView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) JAMyOrderResumeView *myOrderResumeView;

@property (nonatomic) JAProductInfoHeaderLine *itemsHeader;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) JAProductCollectionViewFlowLayout *collectionViewFlowLayout;

@property (nonatomic) RITrackOrder *order;
@property (nonatomic, strong) NSMutableArray *itemsToReturnArray;

@end

@implementation JAMyOrderDetailView

- (JAMyOrderResumeView *)myOrderResumeView
{
    if (!VALID(_myOrderResumeView, UIView)) {
        _myOrderResumeView = [[JAMyOrderResumeView alloc] initWithFrame:CGRectMake(0, 0, self.width, 260)];
    }
    return _myOrderResumeView;
}

- (JAProductInfoHeaderLine *)itemsHeader
{
    if (!VALID(_itemsHeader, JAProductInfoHeaderLine)) {
        _itemsHeader = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.myOrderResumeView.frame), self.width, kProductInfoHeaderLineHeight)];
        [_itemsHeader setTitle:[STRING_ORDER_ITEMS uppercaseString]];
    }
    return _itemsHeader;
}

- (UICollectionView *)collectionView
{
    if (!VALID(_collectionView, UICollectionView)) {
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.itemsHeader.frame), self.width, self.height - CGRectGetMaxY(self.itemsHeader.frame))
                                             collectionViewLayout:self.collectionViewFlowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        [_collectionView registerClass:[JAOrderItemCollectionViewCell class] forCellWithReuseIdentifier:@"CellWithLines"];
    }
    return _collectionView;
}

- (JAProductCollectionViewFlowLayout *)collectionViewFlowLayout
{
    if (!VALID_NOTEMPTY(_collectionViewFlowLayout, JAProductCollectionViewFlowLayout)) {
        
        _collectionViewFlowLayout = [[JAProductCollectionViewFlowLayout alloc] init];
        _collectionViewFlowLayout.minimumLineSpacing = 1.0f;
        _collectionViewFlowLayout.minimumInteritemSpacing = 0.f;
        [_collectionViewFlowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"horizontalSeparator"];
        [_collectionViewFlowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"verticalSeparator"];
        
        //                                              top, left, bottom, right
        [_collectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(0.f, 0.0, 0.0, 0.0)];
        _collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _collectionViewFlowLayout;
}

- (NSMutableArray *)itemsToReturnArray
{
    if (!VALID(_itemsToReturnArray, NSMutableArray)) {
        _itemsToReturnArray = [NSMutableArray new];
    }
    return _itemsToReturnArray;
}

- (void)setupWithOrder:(RITrackOrder*)order frame:(CGRect)frame
{
    self.order = order;
    [self setFrame:frame];
    if (!VALID(self.myOrderResumeView.superview, JAMyOrderResumeView)) {
        [self addSubview:self.myOrderResumeView];
    }
    if (!VALID(self.itemsHeader.superview, UIView)) {
        [self addSubview:self.itemsHeader];
    }
    if (!VALID(self.collectionView.superview, UIView)) {
        [self addSubview:self.collectionView];
    }
    [self.myOrderResumeView setOrder:order];
    [self.itemsHeader setY:CGRectGetMaxY(self.myOrderResumeView.frame)];
    [self.collectionView reloadData];
    
    [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                             CGRectGetMaxY(self.itemsHeader.frame),
                                             self.collectionView.frame.size.width,
                                             [self totalHeightForCollectionView])];
    
    [self setFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, CGRectGetMaxY(self.collectionView.frame))];
}

- (CGFloat)totalHeightForCollectionView
{
    CGFloat totalHeight = 0.f;
    for (int i = 0; i < [self collectionView:self.collectionView numberOfItemsInSection:0]; i++) {
        totalHeight += [self collectionView:self.collectionView layout:self.collectionViewFlowLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].height;
    }
    return totalHeight;
}

#pragma mark - collectionView

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RIItemCollection *item = [self.order.itemCollection objectAtIndex:indexPath.row];
    CGFloat extra = 0;
    if (VALID(item, RIItemCollection) && VALID_NOTEMPTY(item.returns, NSArray)) {
        int i = (int)item.returns.count;
        extra = 6.f + 12.f + i * 12;
    }
    CGSize size = CGSizeMake(self.width, 197.f + extra);
    
    self.collectionViewFlowLayout.itemSize = size;
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JAOrderItemCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellWithLines" forIndexPath:indexPath];
    RIItemCollection *item = [self.order.itemCollection objectAtIndex:indexPath.row];
    [cell setTag:indexPath.row];
    [cell.reorderButton addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
    [cell.returnButton addTarget:self action:@selector(returnItem:) forControlEvents:UIControlEventTouchUpInside];
    [cell.feedbackView addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.checkToReturnButton addTarget:self action:@selector(multipleCheckClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell setItem:item];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (VALID(self.order, RITrackOrder)) {
        return self.order.itemCollection.count;
    }
    return 0;
}

- (void)itemClicked:(UIButton *)button
{
    RIItemCollection *item = [self.order.itemCollection objectAtIndex:button.tag];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"fromCatalog"];
    [userInfo setObject:self forKey:@"delegate"];
    if(VALID_NOTEMPTY(item.sku, NSString))
    {
        NSString *sku = [[item.sku componentsSeparatedByString:@"-"] firstObject];
        [userInfo setObject:sku forKey:@"sku"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)addToCart:(UIButton *)button
{
    if (!self.parent) {
        return;
    }
    RIItemCollection *item = [self.order.itemCollection objectAtIndex:button.tag];
    [self.parent showLoading];
    if(VALID_NOTEMPTY(item.sku, NSString))
    [RICart addProductWithQuantity:@"1"
                         simpleSku:item.sku
                  withSuccessBlock:^(RICart *cart, RIApiResponse apiResponse, NSArray *successMessage) {
                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                      [self.parent onSuccessResponse:RIApiResponseTimeOut messages:successMessage showMessage:YES];
                      [self.parent hideLoading];
                  } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                      [self.parent onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:@selector(addToCart:) objects:@[button]];
                      [self.parent hideLoading];
                  }];
}

- (void)multipleCheckClicked:(UIButton *)button
{
    RIItemCollection *item = [self.order.itemCollection objectAtIndex:button.tag];
    if(VALID_NOTEMPTY(item.sku, NSString))
    {
        [button setSelected:!button.selected];
        if (button.selected) {
            if ([self.itemsToReturnArray indexOfObject:item] != NSNotFound) {
                
            }else{
                
            }
        }
    }
}

- (void)returnItem:(UIButton *)button
{
    RIItemCollection *item = [self.order.itemCollection objectAtIndex:button.tag];
    if(VALID_NOTEMPTY(item.sku, NSString))
    {
        if (item.onlineReturn) {
            [[JACenterNavigationController sharedInstance] goToOnlineReturnsConfirmConditionsForItem:item];
        }else if (item.callReturn){
            [self callToReturn];
        }
    }
}

- (void)callToReturn
{
    [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
        
        [self trackingEventCallToReturn];
        
        NSString *phoneNumber = [@"tel://" stringByAppendingString:configuration.phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
    }];
}

- (void)trackingEventCallToReturn
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCallToOrder]
                                              data:[trackingDictionary copy]];
}

@end

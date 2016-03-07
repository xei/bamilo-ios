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

#define kNormalFont [UIFont fontWithName:kFontLightName size:13]
#define kHighlightedFont [UIFont fontWithName:kFontRegularName size:13]

@interface JAMyOrderDetailView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) JAMyOrderResumeView *myOrderResumeView;

@property (nonatomic) JAProductInfoHeaderLine *itemsHeader;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) JAProductCollectionViewFlowLayout *collectionViewFlowLayout;

@property (nonatomic) RITrackOrder *order;

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
    [self.collectionView reloadData];
}

#pragma mark - collectionView

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(self.width, 117.f);
    
    self.collectionViewFlowLayout.itemSize = size;
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JAOrderItemCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellWithLines" forIndexPath:indexPath];
    RIItemCollection *item = [self.order.itemCollection objectAtIndex:indexPath.row];
    [cell setTag:indexPath.row];
    [cell.reorderButton addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
    [cell.feedbackView addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
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

@end

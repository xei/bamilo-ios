//
//  JACartProductsView.m
//  Jumia
//
//  Created by Jose Mota on 11/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JACartProductsView.h"
#import "JACartTableViewCell.h"

@interface JACartProductsView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation JACartProductsView

- (UITableView *)tableView
{
    if (!VALID(_tableView, UITableView)) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        [_tableView registerClass:[JACartTableViewCell class] forCellReuseIdentifier:@"JACartTableViewCell"];
        [_tableView setBackgroundColor:JAWhiteColor];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (CGFloat)maxHeight
{
    CGFloat height = [self cellHeight]*[self tableView:self.tableView numberOfRowsInSection:0];
    return height;
}

- (void)setCart:(RICart *)cart
{
    _cart = cart;
    [self.tableView reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.tableView setFrame:self.bounds];
    [self.tableView reloadData];
}

#pragma mark tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellHeight];
}

- (CGFloat)cellHeight
{
    return JACartViewControllerListCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = 0;
    if(VALID_NOTEMPTY(self.cart, RICart))
    {
        numberOfItemsInSection = self.cart.cartEntity.cartItems.count;
    }
    
    return numberOfItemsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JACartTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"JACartTableViewCell"];
    RICartItem *cartItem = [self.cart.cartEntity.cartItems objectAtIndex:indexPath.row];
    if (indexPath.row+1 == self.cart.cartEntity.cartItems.count) {
        [cell.separatorView setHidden:YES];
    }else{
        [cell.separatorView setHidden:NO];
    }
    if (VALID(cartItem, RICartItem)) {
        [cell setCartItem:cartItem];
        cell.tag = indexPath.row;
        [cell.feedbackView addTarget:self action:@selector(clickableViewPressedInCell:) forControlEvents:UIControlEventTouchUpInside];
        [cell.removeButton addTarget:self
                              action:@selector(removeFromCartPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        [cell.quantityButton addTarget:self
                                action:@selector(quantityPressed:)
                      forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

#pragma mark Events

- (void)clickableViewPressedInCell:(UIButton *)button
{
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartEntity.cartItems, NSArray) && button.tag < [self.cart.cartEntity.cartCount integerValue])
    {
        RICartItem *product = [self.cart.cartEntity.cartItems objectAtIndex:button.tag];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"sku" : product.sku,
                                                                      @"previousCategory" : STRING_CART,
                                                                      @"show_back_button" : [NSNumber numberWithBool:NO]}];
        
//        [[RITrackingWrapper sharedInstance] trackScreenWithName:[NSString stringWithFormat:@"cart_%@",product.name]];
        
    }
}

- (void)removeFromCartPressed:(UIButton *)button
{
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartEntity.cartItems, NSArray) && button.tag < [self.cart.cartEntity.cartCount integerValue])
    {
        RICartItem *product = [self.cart.cartEntity.cartItems objectAtIndex:button.tag];
        if (self.delegate) {
            [self.delegate removeCartItem:product];
        }
    }
}

- (void)quantityPressed:(UIButton *)button
{
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartEntity.cartItems, NSArray) && button.tag < [self.cart.cartEntity.cartCount integerValue])
    {
        RICartItem *product = [self.cart.cartEntity.cartItems objectAtIndex:button.tag];
        if (self.delegate) {
            [self.delegate quantitySelection:product];
        }
    }
}

@end

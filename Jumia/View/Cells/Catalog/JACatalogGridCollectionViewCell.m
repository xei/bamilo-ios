//
//  JACatalogGridCollectionViewCell.m
//  Jumia
//
//  Created by josemota on 7/6/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogGridCollectionViewCell.h"

@interface JACatalogGridCollectionViewCell () {
    CGFloat _lastWidth;
}

@end

@implementation JACatalogGridCollectionViewCell

- (instancetype)init
{
    //    NSLog(@"init");
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    //    NSLog(@"initWithCoder");
    self = [super initWithCoder:coder];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    //    NSLog(@"initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    self.grid = YES;
    [super initViews];
}

- (void)reloadViews
{
    [super reloadViews];
    _lastWidth = self.width;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)loadWithProduct:(RIProduct*)product
{
    [super loadWithProduct:product];
    
    if (_lastWidth != self.width) {
        [self reloadViews];
    }
}

@end

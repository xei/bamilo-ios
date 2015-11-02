//
//  JAPDVVariationsCollectionViewCell.m
//  Jumia
//
//  Created by claudiosobrinho on 21/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVVariationsCollectionViewCell.h"
#import "RIProduct.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"
#import "JARatingsView.h"

@interface JAPDVVariationsCollectionViewCell()

@property (nonatomic, strong) UIView* contentView;

@end

@implementation JAPDVVariationsCollectionViewCell

@synthesize contentView = _contentView, topHorizontalSeparator = _topHorizontalSeparator, bottomHorizontalSeparator = _bottomHorizontalSeparator, rightVerticalSeparator = _rightVerticalSeparator;

- (void)initViews
{
    [super initViews];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(32.0f, 0, self.frame.size.width - 64.0f, self.frame.size.height)];

    } else {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(12.0f, 0, self.frame.size.width - 24.0f , self.frame.size.height)];
    }
    
    [_contentView addSubview:self.productImageView];
    
    [_contentView addSubview:self.brandLabel];
    
    [_contentView addSubview:self.nameLabel];
    
    [_contentView addSubview:self.favoriteButton];
    
    [_contentView addSubview:self.selectorButton];
    
    [_contentView addSubview:self.discountLabel];
    
    [_contentView addSubview:self.recentProductImageView];
    
    [_contentView addSubview:self.sizeButton];
    
    [_contentView addSubview:self.feedbackView];
    
    [_contentView addSubview:self.priceView];
    
    [self addSubview:_contentView];
    
    [self.layer setCornerRadius:0.f];
    
    _bottomHorizontalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 1, self.frame.size.width, 1)];
    [_bottomHorizontalSeparator setBackgroundColor:[UIColor colorWithRed:0.867 green:0.878 blue:0.878 alpha:1]];
    [self addSubview:_bottomHorizontalSeparator];
    
    _topHorizontalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    [_topHorizontalSeparator setBackgroundColor:[UIColor colorWithRed:0.867 green:0.878 blue:0.878 alpha:1]];
    [self addSubview:_topHorizontalSeparator];
    
    _rightVerticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(self.width - 1, 0, 1, self.frame.size.height)];
    [_rightVerticalSeparator setBackgroundColor:[UIColor colorWithRed:0.867 green:0.878 blue:0.878 alpha:1]];
    [self addSubview:_rightVerticalSeparator];

}

- (void)reloadViews
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [_contentView setFrame:CGRectMake(32.0f, 0, self.frame.size.width - 64.0f, self.frame.size.height)];
    } else {
        [_contentView setFrame:CGRectMake(12.0f, 0, self.frame.size.width - 24.0f , self.frame.size.height)];
    }
    [super reloadViews];
    
    [_bottomHorizontalSeparator setWidth:self.frame.size.width];
    [_topHorizontalSeparator setWidth:self.frame.size.width];
    [_rightVerticalSeparator setX:self.frame.size.width - 1];
    [_rightVerticalSeparator setHeight:self.frame.size.height];
}

- (void)loadWithProduct:(RIProduct *)product
{
    [super loadWithProduct:product];
}

@end
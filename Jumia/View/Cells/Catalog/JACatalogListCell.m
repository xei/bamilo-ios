//
//  JACatalogListCell.m
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogListCell.h"
#import "JARatingsView.h"
#import "RIProduct.h"
#import "JAUtils.h"
#import "RICartItem.h"

@interface JACatalogListCell()

@property (weak, nonatomic) IBOutlet JARatingsView *ratingsView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfReviewsLabel;

@end

@implementation JACatalogListCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)loadWithProduct:(RIProduct *)product
{
    [super loadWithProduct:product];
    
    [self.productImageView setX:6.f];
    
    [self.brandLabel setX:80.f];
    [self.brandLabel setWidth:self.backgroundContentView.width - self.productImageView.width - self.favoriteButton.width - 3*6.f];
    
    [self.nameLabel setX:80.f];
    [self.nameLabel setWidth:self.backgroundContentView.width - self.productImageView.width - self.favoriteButton.width - 3*6.f];
    
    self.priceView.frame = CGRectMake(self.nameLabel.frame.origin.x,// + priceXOffset,
                                      CGRectGetMaxY(self.nameLabel.frame) + JACatalogCellPriceLabelOffsetY,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.priceView sizeToFit];
    [self.priceView setY:CGRectGetMaxY(self.nameLabel.frame) + 2*JACatalogCellPriceLabelOffsetY];
    
    [self.favoriteButton setX:self.backgroundContentView.width - self.favoriteButton.width - 6.f];
    
    [self.ratingsView removeFromSuperview];
    self.ratingsView = [JARatingsView getNewJARatingsView];
    [self.backgroundContentView addSubview:self.ratingsView];
    
    if (self.numberOfReviewsLabel) {
        [self.ratingsView setFrame:CGRectMake(80.f,
                                              CGRectGetMaxY(self.priceView.frame) + 6.f,
                                              self.ratingsView.frame.size.width,
                                              self.ratingsView.frame.size.height)];
        self.ratingsView.rating = [product.avr integerValue];
        
        
        self.numberOfReviewsLabel.font = JACatalogCellLightFont;
        self.numberOfReviewsLabel.textColor = JACatalogCellGrayFontColor;
        if (1 == [product.sum integerValue]) {
            self.numberOfReviewsLabel.text = STRING_RATING;
        } else {
            self.numberOfReviewsLabel.text = [NSString stringWithFormat:STRING_RATINGS, [product.sum integerValue]];
        }
        [self.numberOfReviewsLabel sizeToFit];
        [self.numberOfReviewsLabel setX:CGRectGetMaxX(self.ratingsView.frame) + JACatalogCellPriceLabelOffsetX];
        [self.numberOfReviewsLabel setY:self.ratingsView.y];
    } else {
        [self.ratingsView removeFromSuperview];
    }
    
    CGFloat recentLabelX = JACatalogViewControllerListCellNewLabelX;
    CGFloat recentLabelY = JACatalogViewControllerListCellNewLabelY;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        recentLabelX = JACatalogViewControllerListCellNewLabelX_ipad;
        recentLabelY = JACatalogViewControllerListCellNewLabelY_ipad;
    }
    [self.recentLabel removeFromSuperview];
    self.recentLabel = [[UILabel alloc] initWithFrame:CGRectMake(recentLabelX, recentLabelY, 48.0f, 14.0f)];
    self.recentLabel.font = [UIFont fontWithName:kFontBoldName size:8.0f];
    self.recentLabel.text = STRING_NEW;
    self.recentLabel.textAlignment = NSTextAlignmentCenter;
    self.recentLabel.textColor = [UIColor whiteColor];
    self.recentLabel.transform = CGAffineTransformMakeRotation (-M_PI/4);
    [self addSubview:self.recentLabel];
    self.recentLabel.hidden = ![product.isNew boolValue];
    
    self.addToCartButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.addToCartButton.titleLabel.font.pointSize];
    [self.addToCartButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.addToCartButton setTitle:STRING_ADD_TO_SHOPPING_CART forState:UIControlStateNormal];
    
    [self setRTL];
}

- (void)loadWithCartItem:(RICartItem *)cartItem
{
    [super loadWithCartItem:cartItem];
    
    [self.ratingsView removeFromSuperview];
    
    NSString *stringQuantity = [NSString stringWithFormat:STRING_QUANTITY, [[cartItem quantity] stringValue]];
    self.quantityButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.quantityButton.titleLabel.font.pointSize];
    [self.quantityButton setBackgroundColor:[UIColor clearColor]];
    [self.quantityButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.quantityButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.quantityButton setTitle:stringQuantity forState:UIControlStateNormal];
    [self.quantityButton sizeToFit];
    [self.quantityButton setX:self.width-self.quantityButton.width-6.f];
    
    [self.deleteButton setX:self.width-self.deleteButton.width];
    [self.separator setWidth:self.width];
    
    [self setRTL];
}

- (void)setRTL {
    if (RI_IS_RTL) {
        [self.backgroundContentView flipAllSubviews];
    }
}

@end

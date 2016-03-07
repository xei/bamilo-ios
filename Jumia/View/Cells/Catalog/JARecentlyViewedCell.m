//
//  JARecentlyViewedCell.m
//  Jumia
//
//  Created by Jose Mota on 21/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JARecentlyViewedCell.h"
#import "JABottomBar.h"

#define kButtonWidth 140

@interface JARecentlyViewedCell ()

@property (nonatomic) JABottomBar *addToCartBar;

@end

@implementation JARecentlyViewedCell

- (JABottomBar *)addToCartBar
{
    if (!VALID(_addToCartBar, JABottomBar)) {
        _addToCartBar = [[JABottomBar alloc] initWithFrame:CGRectMake(self.width-kButtonWidth-16.f, CGRectGetMaxY(self.discountLabel.frame) + 10.f, kButtonWidth, kBottomDefaultHeight)];
        self.addToCartButton = [_addToCartBar addButton:STRING_BUY_NOW target:nil action:nil];
    }
    return _addToCartBar;
}

- (void)initViews
{
    [super initViews];
    [self addSubview:self.addToCartBar];
    [self.favoriteButton setImage:[UIImage imageNamed:@"btn_delete_saved"] forState:UIControlStateNormal];
    [self.favoriteButton setImage:[UIImage imageNamed:@"btn_delete_saved"] forState:UIControlStateSelected];
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self.addToCartButton setTag:tag];
}

- (void)reloadViews
{
    CGFloat distXImage = JACatalogListCellDistXImage_ipad;
    CGFloat margin = JACatalogListCellDistXAfterImage_ipad;
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        distXImage = JACatalogListCellDistXImage;
        margin = JACatalogListCellDistXAfterImage;
    }
    CGFloat distXAfterImage = JACatalogListCellImageSize.width + distXImage + margin;
    
    CGFloat sizeButtonWidth = self.width - 10 - self.addToCartButton.width - distXAfterImage - 10;
    if (sizeButtonWidth > 80) {
        sizeButtonWidth = 80;
    }
    [self.sizeButton setWidth:sizeButtonWidth];
    
    [super reloadViews];
    
    [self.recentProductBadgeLabel setYBottomOf:self.ratingLine.hidden?self.priceLine:self.ratingLine at:6.f];
    
    [self.addToCartBar setYBottomAligned:10.f];
    [self.addToCartBar setXRightAligned:10.f];
    [self setForRTL:self.addToCartBar];
    
    [self.discountLabel setY:self.priceLine.y];
    
    [self.sizeButton setY:self.addToCartBar.y+self.addToCartBar.height/2 - self.sizeButton.height/2];
}

- (void)setForRTL:(UIView *)view
{
    if (RI_IS_RTL) {
        [view flipViewPositionInsideSuperview];
        [view flipAllSubviews];
        if ([view isKindOfClass:[UILabel class]] && [(UILabel *)view textAlignment] != NSTextAlignmentCenter) {
            [(UILabel *)view setTextAlignment:NSTextAlignmentRight];
        } else if ([view isKindOfClass:[UIButton class]] && [(UIButton*)view contentHorizontalAlignment] != UIControlContentHorizontalAlignmentCenter)
        {
            ((UIButton*)view).contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
    }
}

@end

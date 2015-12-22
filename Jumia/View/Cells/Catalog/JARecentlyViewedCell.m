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
        self.addToCartButton = [_addToCartBar addButton:STRING_ADD_TO_SHOPPING_CART target:nil action:nil];
    }
    return _addToCartBar;
}

- (JARadioComponent *)sizeComponent
{
    if (!VALID(_sizeComponent, JARadioComponent)) {
        _sizeComponent = [[JARadioComponent alloc] initWithFrame:CGRectMake(self.nameLabel.x, self.addToCartBar.y, 100.f, kBottomDefaultHeight)];
        [_sizeComponent.textField setPlaceholder:STRING_SIZE];
        [_sizeComponent.textField setEnabled:NO];
    }
    return _sizeComponent;
}

- (void)initViews
{
    [super initViews];
    [self addSubview:self.addToCartBar];
//    [self addSubview:self.sizeComponent];
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self.addToCartButton setTag:tag];
    [self.sizeComponent.textField setTag:tag];
    [self.sizeComponent setTag:tag];
}

- (void)reloadViews
{
    [super reloadViews];
    CGFloat distXImage = 32.f;
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        distXImage = 6.f;
    }
    
    [self.recentProductBadgeLabel setYBottomOf:self.ratingLine.hidden?self.priceLine:self.ratingLine at:6.f];
    
    [self.addToCartBar setYBottomAligned:10.f];
    [self.addToCartBar setXRightAligned:distXImage];
    [self setForRTL:self.addToCartBar];
    
    [self.discountLabel setY:self.priceLine.y];
    [self.sizeButton setHeight:self.addToCartBar.height];
    [self.sizeButton setY:self.addToCartBar.y];
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

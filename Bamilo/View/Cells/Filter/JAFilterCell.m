//
//  JAFilterTypeCell.m
//  Jumia
//
//  Created by Telmo Pinto on 05/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAFilterCell.h"

@implementation JAFilterCell

- (void)setupWithFilter:(BaseSearchFilterItem*)filter
         cellIsSelected:(BOOL)cellIsSelected
                  width:(CGFloat)width
                 margin:(CGFloat)margin {
    //remove the clickable view
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:[JAClickableView class]]) { //remove the clickable view
            [view removeFromSuperview];
        } else {
            for (UIView* subview in view.subviews) {
                if ([subview isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                    [subview removeFromSuperview];
                }
            }
        }
    }
    //add the new clickable view
    self.clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                       0.0f,
                                                                       width,
                                                                       [JAFilterCell height])];
    [self addSubview:self.clickView];
    
    if (cellIsSelected) {
        self.clickView.backgroundColor = JABlack300Color;
    } else {
        self.clickView.backgroundColor = JAWhiteColor;
    }
    
    //find number of selected options
    NSInteger numberOfSelectedOptions = 0;
    if ([filter isKindOfClass:[SearchFilterItem class]]) {
        for (SearchFilterItemOption *option in ((SearchFilterItem *)filter).options) {
            if (option.selected) numberOfSelectedOptions++;
        }
    } else if ([filter isKindOfClass:[SearchPriceFilter class]]) {
        SearchPriceFilter *priceFilter = (SearchPriceFilter *)filter;
        if (priceFilter.lowerValue > priceFilter.minPrice || priceFilter.upperValue < priceFilter.maxPrice || YES == priceFilter.discountOnly) {
            numberOfSelectedOptions = 1;
        }
    }
    
    NSString* cellText = [NSString stringWithFormat:@"%@",filter.name];
    if (0 < numberOfSelectedOptions) {
        cellText = [[NSString stringWithFormat:@"%@ (%ld)",filter.name, (long)numberOfSelectedOptions] numbersToPersian];
    }
    UILabel* mainLabel = [UILabel new];
    mainLabel.font = [UIFont fontWithName:kFontRegularName size: 13];
    mainLabel.textColor = [UIColor blackColor];
    mainLabel.text = cellText;
    mainLabel.textAlignment = NSTextAlignmentLeft;
    [mainLabel sizeToFit];
    mainLabel.frame = CGRectMake(margin, self.clickView.bounds.origin.y, width - margin, self.clickView.bounds.size.height);
    
    [self.clickView addSubview:mainLabel];
    
    UIView* separator = [UIView new];
    separator.backgroundColor = [UIColor withHexString: @"#E5E5E5"];
    separator.frame = CGRectMake(self.clickView.bounds.origin.x,
                                 self.clickView.bounds.size.height - 1.0f,
                                 self.clickView.bounds.size.width,
                                 1.0f);
    [self.clickView addSubview:separator];
    
    if (RI_IS_RTL) {
        [mainLabel flipViewPositionInsideSuperview];
        [mainLabel flipViewAlignment];
    }
}

+ (CGFloat)height;
{
    return 48.0f;
}

@end

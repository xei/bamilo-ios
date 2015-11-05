//
//  JAFilterTypeCell.m
//  Jumia
//
//  Created by Telmo Pinto on 05/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAFilterCell.h"
#import "RIFilter.h"

@implementation JAFilterCell

- (void)setupWithFilter:(RIFilter*)filter
         cellIsSelected:(BOOL)cellIsSelected
                  width:(CGFloat)width
{
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
        self.clickView.backgroundColor = [UIColor whiteColor];
    } else {
        self.clickView.backgroundColor = JABlack300Color;
    }
    
    //find number of selected options
    NSInteger numberOfSelectedOptions = 0;
    for (RIFilterOption* option in filter.options) {
        if (option.selected) {
            numberOfSelectedOptions++;
        } else if (option.lowerValue > option.min || option.upperValue < option.max || YES == option.discountOnly) {
            numberOfSelectedOptions = 1;
        }
    }
    
    UIFont* labelFont = [UIFont fontWithName:kFontRegularName size:16.0f];
    NSString* cellText = [NSString stringWithFormat:@"%@",filter.name];
    if (0 < numberOfSelectedOptions) {
        labelFont = [UIFont fontWithName:kFontBoldName size:16.0f];
        cellText = [NSString stringWithFormat:@"%@ (%ld)",filter.name, (long)numberOfSelectedOptions];
    }
    UILabel* mainLabel = [UILabel new];
    mainLabel.font = labelFont;
    mainLabel.textColor = [UIColor blackColor];
    mainLabel.text = cellText;
    [mainLabel sizeToFit];
    mainLabel.frame = CGRectMake(16.0f,
                                 self.clickView.bounds.origin.y,
                                 width - 16.0f,
                                 self.clickView.bounds.size.height);
    [self.clickView addSubview:mainLabel];
    
    UIView* separator = [UIView new];
    separator.backgroundColor = JABlack400Color;
    separator.frame = CGRectMake(self.clickView.bounds.origin.x,
                                 self.clickView.bounds.size.height - 1.0f,
                                 self.clickView.bounds.size.width,
                                 1.0f);
    [self.clickView addSubview:separator];
}

+ (CGFloat)height;
{
    return 48.0f;
}

@end

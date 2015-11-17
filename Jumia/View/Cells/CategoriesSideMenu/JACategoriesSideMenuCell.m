//
//  JACategoriesSideMenuCell.m
//  Jumia
//
//  Created by Telmo Pinto on 15/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JACategoriesSideMenuCell.h"
#import "RICategory.h"

@implementation JACategoriesSideMenuCell

- (void)setupWithCategory:(RICategory*)category
                    width:(CGFloat)width
             hasSeparator:(BOOL)hasSeparator
                   isOpen:(BOOL)isOpen;
{
    self.category = category;

    NSString* cellText = category.label;
    NSString* iconImageURL = category.imageUrl;

    JAGenericMenuCellStyle style = JAGenericMenuCellStyleDefault;
    NSString* accessoryImageName;
    if (VALID_NOTEMPTY(category.level, NSNumber) && 1 == [category.level integerValue]) {
        
        if (0 == category.children.count) {
            accessoryImageName = @"sideMenuCell_arrow";
        } else {
            if (isOpen) {
                accessoryImageName = @"sideMenuCell_minus";
            } else {
                accessoryImageName = @"sideMenuCell_plus";
            }
        }
    } else if (VALID_NOTEMPTY(category.level, NSNumber) && 2 == [category.level integerValue]) {
        
        accessoryImageName = @"sideMenuCell_arrow";
        style = JAGenericMenuCellStyleLevelOne;

    } else if (VALID_NOTEMPTY(category.level, NSNumber) && 0 == [category.level integerValue]) {
        
        style = JAGenericMenuCellStyleHeader;
    }

    [self setupWithStyle:style
                   width:width
                cellText:cellText
            iconImageURL:iconImageURL
      accessoryImageName:accessoryImageName
            hasSeparator:hasSeparator];
}

+ (CGFloat)heightForCategory:(RICategory*)category
{
    JAGenericMenuCellStyle style = JAGenericMenuCellStyleDefault;
    if (0 == [category.level integerValue]) {
        style = JAGenericMenuCellStyleHeader;
    } else if (2 == [category.level integerValue]){
        style = JAGenericMenuCellStyleLevelOne;
    }
    return [JAGenericMenuCell heightForStyle:style];
}

- (void)clickableViewWasPressed
{
    if (self.delegate && VALID_NOTEMPTY(self.category, RICategory) && [self.delegate respondsToSelector:@selector(categoryWasSelected:)]) {
        [self.delegate categoryWasSelected:self.category];
    }
}

@end

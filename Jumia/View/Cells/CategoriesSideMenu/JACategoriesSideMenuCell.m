//
//  JACategoriesSideMenuCell.m
//  Jumia
//
//  Created by Telmo Pinto on 15/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JACategoriesSideMenuCell.h"
#import "RICategory.h"

@interface JACategoriesSideMenuCell ()

@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSOrderedSet *children;

@end

@implementation JACategoriesSideMenuCell

- (void)setupWithCategory:(id)category
                        width:(CGFloat)width
                 hasSeparator:(BOOL)hasSeparator
                       isOpen:(BOOL)isOpen;
{
    self.category = category;
    
    JAGenericMenuCellStyle style = JAGenericMenuCellStyleDefault;
    NSString* accessoryImageName;
    if (VALID_NOTEMPTY(self.level, NSNumber) && 1 == self.level.integerValue) {
        
        if (0 == [self.children count]) {
            accessoryImageName = @"sideMenuCell_arrow";
        } else {
            if (isOpen) {
                accessoryImageName = @"sideMenuCell_minus";
            } else {
                accessoryImageName = @"sideMenuCell_plus";
            }
        }
    } else if (VALID_NOTEMPTY(self.level, NSNumber) && 2 == [self.level integerValue]) {
        
        accessoryImageName = @"sideMenuCell_arrow";
        style = JAGenericMenuCellStyleLevelOne;
        
    } else if (VALID_NOTEMPTY(self.level, NSNumber) && 0 == [self.level integerValue]) {
        
        style = JAGenericMenuCellStyleHeader;
    }
    
    [self setupWithStyle:style
                   width:width
                cellText:self.label
            iconImageURL:self.imageUrl
      accessoryImageName:accessoryImageName
            hasSeparator:hasSeparator];
}

- (void)setCategory:(id)category
{
    _category = category;
    if ([category isKindOfClass:[RICategory class]]) {
        self.level = [(RICategory *)category level];
        self.label = [(RICategory *)category label];
        self.imageUrl = [(RICategory *)category imageUrl];
        self.children = [(RICategory *)category children];
    }else if ([category isKindOfClass:[RIExternalCategory class]]) {
        self.level = [(RIExternalCategory *)category level];
        self.label = [(RIExternalCategory *)category label];
        self.imageUrl = [(RIExternalCategory *)category imageUrl];
        self.children = [(RIExternalCategory *)category children];
    }
}

+ (CGFloat)heightForCategory:(id)category
{
    JAGenericMenuCellStyle style = JAGenericMenuCellStyleDefault;
    if (0 == [[category valueForKey:@"level"] integerValue]) {
        style = JAGenericMenuCellStyleHeader;
    } else if (2 == [[category valueForKey:@"level"] integerValue]){
        style = JAGenericMenuCellStyleLevelOne;
    }
    return [JAGenericMenuCell heightForStyle:style];
}

- (void)clickableViewWasPressed
{
    if (self.delegate && (VALID_NOTEMPTY(self.category, RICategory) || VALID_NOTEMPTY(self.category, RIExternalCategory)) && [self.delegate respondsToSelector:@selector(categoryWasSelected:)]) {
        [self.delegate categoryWasSelected:self.category];
    }
}

@end

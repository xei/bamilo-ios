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

- (void)setupWithCategory:(id)category width:(CGFloat)width hasSeparator:(BOOL)hasSeparator isOpen:(BOOL)isOpen {
    self.category = category;
    
    JAGenericMenuCellStyle style = JAGenericMenuCellStyleDefault;
    NSString* accessoryImageName;
    
    int level = [self.level intValue];
    style = (JAGenericMenuCellStyle)level;
    
    if ([self.children count] > 0) {
        if (isOpen) {
            accessoryImageName = @"sideMenuCell_minus";
        } else {
            accessoryImageName = @"sideMenuCell_plus";
        }
    } else {
        accessoryImageName = @"sideMenuCell_arrow";
    }
    
    [self setupWithStyle:style width:width cellText:self.label iconImageURL:self.imageUrl accessoryImageName:accessoryImageName hasSeparator:hasSeparator];
}

- (void)setCategory:(id)category {
    _category = category;
    
    if ([category isKindOfClass:[RICategory class]]) {
        self.level = [(RICategory *)category level];
        self.label = [(RICategory *)category label];
        self.imageUrl = [(RICategory *)category imageUrl];
        self.children = [(RICategory *)category children];
    } else if ([category isKindOfClass:[RIExternalCategory class]]) {
        self.level = [(RIExternalCategory *)category level];
        self.label = [(RIExternalCategory *)category label];
        self.imageUrl = [(RIExternalCategory *)category imageUrl];
        self.children = [(RIExternalCategory *)category children];
    }
}

+ (CGFloat)heightForCategory:(id)category {
    JAGenericMenuCellStyle style = JAGenericMenuCellStyleDefault;
    
    int level = [[category valueForKey:@"level"] intValue];
    
    if (level == 0) {
        style = JAGenericMenuCellStyleHeader;
    } else if (level == 1) {
        style = JAGenericMenuCellStyleLevelOne;
    } else if (level == 2) {
        style = JAGenericMenuCellStyleLevelTwo;
    }
    
    return [JAGenericMenuCell heightForStyle:style];
}

- (void)clickableViewWasPressed {
    if (self.delegate && (VALID_NOTEMPTY(self.category, RICategory) || VALID_NOTEMPTY(self.category, RIExternalCategory)) && [self.delegate respondsToSelector:@selector(categoryWasSelected:)]) {
        [self.delegate categoryWasSelected:self.category];
    }
}

@end

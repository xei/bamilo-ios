//
//  JAGenericMenuCell.h
//  Jumia
//
//  Created by Telmo Pinto on 23/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

typedef NS_ENUM(NSInteger, JAGenericMenuCellStyle) {
    JAGenericMenuCellStyleHeader   = 0,
    JAGenericMenuCellStyleDefault  = 1,
    JAGenericMenuCellStyleLevelOne = 2, //Level 2
    JAGenericMenuCellStyleLevelTwo = 3, //Level 3
};

@interface JAGenericMenuCell : UITableViewCell

@property (nonatomic, strong) JAClickableView* backgroundClickableView;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)setupWithStyle:(JAGenericMenuCellStyle)style width:(CGFloat)width cellText:(NSString*)cellText iconImageURL:(NSString*)iconImageUrl accessoryImageName:(NSString*)accessoryImageName hasSeparator:(BOOL)hasSeparator;

+ (CGFloat)heightForStyle:(JAGenericMenuCellStyle)style;

@end

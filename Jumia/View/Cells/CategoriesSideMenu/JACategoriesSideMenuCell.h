//
//  JACategoriesSideMenuCell.h
//  Jumia
//
//  Created by Telmo Pinto on 15/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAGenericMenuCell.h"

@class RICategory, JAClickableView;

@protocol JACategoriesSideMenuCellDelegate <NSObject>

@optional
- (void)categoryWasSelected:(RICategory*)category;

@end

@interface JACategoriesSideMenuCell : JAGenericMenuCell

@property (nonatomic, strong) RICategory* category;
@property (nonatomic, assign) id<JACategoriesSideMenuCellDelegate> delegate;

- (void)setupWithCategory:(RICategory*)category
                    width:(CGFloat)width
             hasSeparator:(BOOL)hasSeparator
                   isOpen:(BOOL)isOpen;

+ (CGFloat)heightForCategory:(RICategory*)category;

@end

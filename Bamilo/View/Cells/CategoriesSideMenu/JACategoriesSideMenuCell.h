//
//  JACategoriesSideMenuCell.h
//  Jumia
//
//  Created by Telmo Pinto on 15/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAGenericMenuCell.h"
#import "RIExternalCategory.h"

@class RICategory, JAClickableView;

@protocol JACategoriesSideMenuCellDelegate <NSObject>

@optional
- (void)categoryWasSelected:(id)category;

@end

@interface JACategoriesSideMenuCell : JAGenericMenuCell

@property (nonatomic, strong) id category;
//@property (nonatomic, strong) RIExternalCategory *externalCategory;
@property (nonatomic, assign) id<JACategoriesSideMenuCellDelegate> delegate;

- (void)setupWithCategory:(id)category width:(CGFloat)width hasSeparator:(BOOL)hasSeparator isOpen:(BOOL)isOpen;

+ (CGFloat)heightForCategory:(id)category;

@end

//
//  JACategoriesSideMenuCell.h
//  Jumia
//
//  Created by Telmo Pinto on 15/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RICategory, JAClickableView;

@protocol JACategoriesSideMenuCellDelegate <NSObject>

@optional
- (void)categoryWasSelected:(RICategory*)category;

@end

@interface JACategoriesSideMenuCell : UITableViewCell

@property (nonatomic, strong) JAClickableView* backgroundClickableView;
@property (nonatomic, strong) RICategory* category;
@property (nonatomic, assign) id<JACategoriesSideMenuCellDelegate> delegate;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setupWithCategory:(RICategory*)category hasSeparator:(BOOL)hasSeparator isOpen:(BOOL)isOpen;

+ (CGFloat)heightForCategory:(RICategory*)category;

@end

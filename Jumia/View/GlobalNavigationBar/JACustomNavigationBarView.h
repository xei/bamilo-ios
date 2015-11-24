//
//  JACustomNavigationBarView.h
//  Jumia
//
//  Created by Jose Mota on 18/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JACustomNavigationBarView : UIView

@property (nonatomic) UIImageView *logoImageView;
@property (nonatomic) UIButton *cartButton;
@property (nonatomic) UILabel *cartCountLabel;
@property (nonatomic) UIButton *leftButton;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *topTitleLabel;
@property (nonatomic) UILabel *bottomTitleLabel;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIButton *editButton;
@property (nonatomic) UIButton *doneButton;
@property (nonatomic) UIButton *searchButton;

- (void)initialSetup;
- (void)setupWithNavigationBarLayout:(JANavigationBarLayout*)layout;

- (void)updateCartProductCount:(NSNumber*)productCount;

@end

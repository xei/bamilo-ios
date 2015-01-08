//
//  JANavigationBarView.h
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANavigationBarLayout.h"

@interface JANavigationBarView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *cartButton;
@property (weak, nonatomic) IBOutlet UILabel *cartCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

+ (JANavigationBarView *)getNewNavBarView;

- (void)initialSetup;
- (void)setupWithNavigationBarLayout:(JANavigationBarLayout*)layout;

- (void)updateCartProductCount:(NSNumber*)productCount;

@end

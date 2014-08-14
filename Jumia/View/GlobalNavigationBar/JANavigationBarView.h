//
//  JANavigationBarView.h
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JANavigationBarView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *cartButton;
@property (weak, nonatomic) IBOutlet UILabel *cartCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

+ (JANavigationBarView *)getNewNavBarView;

- (void)changeNavigationBarTitle:(NSString *)newTitle;

- (void)changedToHomeViewController;
- (void)updateCartProductCount:(NSNumber*)productCount;

- (void)enteredInFirstLevelWithTitle:(NSString *)title
                     andProductCount:(NSString *)productCount;

- (void)enteredSecondOrThirdLevelWithBackTitle:(NSString *)backTitle;

- (void)changeToChooseCountry;

- (void)changeToMainFilters;
- (void)changeToSpecificFilter:(NSString*)filterName;

@end

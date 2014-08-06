//
//  JACTAButtons.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface JACTAButtons : UIView

@property (weak, nonatomic) IBOutlet UIButton *callToOrderButton;
@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;

+ (JACTAButtons *)getNewPDVCTAButtons;

- (void)layoutViewWithNumberOfButton:(NSInteger)number;

@end

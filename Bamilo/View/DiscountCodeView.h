//
//  DiscountCodeView.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "DiscountSwitcherView.h"

typedef NS_ENUM(NSUInteger, DiscountCodeViewState) {
    DISCOUNT_CODE_VIEW_STATE_CLEAN = 0,
    DISCOUNT_CODE_VIEW_STATE_ACTIVE,
    DISCOUNT_CODE_VIEW_STATE_CONTAINS_CODE
};

@protocol DiscountCodeViewDelegate <NSObject>

-(void)discountCodeViewDidFinish:(id)sender withCode:(NSString *)discountCode;
-(void)discountCodeViewRemoveCodeButtonTapped:(id)sender;

@end

@interface DiscountCodeView : BaseTableViewCell

@property (assign, nonatomic) DiscountCodeViewState state;
@property (weak, nonatomic) id<DiscountCodeViewDelegate> delegate;

-(void) clearOut;

@end

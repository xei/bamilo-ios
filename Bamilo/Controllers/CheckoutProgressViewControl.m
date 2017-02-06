//
//  CheckoutProgressViewControl.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutProgressViewControl.h"
#import "CheckoutProgressView.h"

@interface CheckoutProgressViewControl()
@property (weak, nonatomic) CheckoutProgressView *checkoutProgressView;
@end

@implementation CheckoutProgressViewControl

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.checkoutProgressView = [[[NSBundle mainBundle] loadNibNamed:@"CheckoutProgressView" owner:self options:nil] lastObject];
    
    if(self.checkoutProgressView) {
        [self addSubview:self.checkoutProgressView];
        [self anchorMatch:self.checkoutProgressView];
    }
}

-(void)requestUpdate {
    NSArray *buttonModels = [self.delegate getButtonsForCheckoutProgressView];
    
    if(buttonModels && buttonModels.count > 0) {
        for(CheckoutProgressViewButtonModel *model in buttonModels) {
            [self.checkoutProgressView updateButton:model.uid toModel:model];
        }
     }
}

@end

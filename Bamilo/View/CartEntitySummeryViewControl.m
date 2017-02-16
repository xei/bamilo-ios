//
//  CartEntitySummeryViewControl.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartEntitySummeryViewControl.h"
#import "CartEntitySummeryView.h"

@interface CartEntitySummeryViewControl()
@property (nonatomic, strong) CartEntitySummeryView *summeryView;
@end

@implementation CartEntitySummeryViewControl

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.summeryView = [[[NSBundle mainBundle] loadNibNamed:@"CartEntitySummeryView" owner:self options:nil] lastObject];
    [self addSubview:self.summeryView];
    self.summeryView.frame = self.bounds;
}

- (void)updateWithModel:(id)model {
    if(![model isKindOfClass:CartEntity.class]) {
        return;
    }
    
    [self.summeryView setCartEntity:model]; 
}
@end

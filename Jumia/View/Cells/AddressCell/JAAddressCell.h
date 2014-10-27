//
//  JAAddressCell.h
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@class RIAddress;

@interface JAAddressCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *editAddressButton;
@property (weak, nonatomic) IBOutlet JAClickableView *clickableView;

-(void)loadWithAddress:(RIAddress*)address;

-(void)selectAddress;

-(void)deselectAddress;

@end

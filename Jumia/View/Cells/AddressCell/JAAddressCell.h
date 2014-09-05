//
//  JAAddressCell.h
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIAddress;

@interface JAAddressCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *editAddressButton;

-(void)loadWithAddress:(RIAddress*)address;

-(void)selectAddress;

-(void)deselectAddress;

@end

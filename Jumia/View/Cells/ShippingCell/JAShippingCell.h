//
//  JAShippingCell.h
//  Jumia
//
//  Created by Pedro Lopes on 06/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAShippingCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *separator;

-(void)loadWithShippingMethod:(NSString *)shippingMethod;

-(void)selectAddress;

-(void)deselectAddress;

@end

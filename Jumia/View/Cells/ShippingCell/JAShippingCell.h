//
//  JAShippingCell.h
//  Jumia
//
//  Created by Pedro Lopes on 06/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"
#import "RIShippingMethod.h"

@interface JAShippingCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet JAClickableView *clickableView;

-(void)loadWithShippingMethod:(RIShippingMethod *)shippingMethod;

-(void)selectShippingMethod;

-(void)deselectShippingMethod;

@end

//
//  JAAddNewAddressCell.h
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@interface JAAddNewAddressCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet JAClickableView *clickableView;

-(void)loadWithText:(NSString*)text;

@end

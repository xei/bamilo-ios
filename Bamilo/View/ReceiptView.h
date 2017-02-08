//
//  ReceiptView.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ReusableViewBase.h"
#import "ReceiptItemModel.h"

@interface ReceiptView : ReusableViewBase

@property (strong, nonatomic) NSArray<ReceiptItemModel *> *items;

-(void) resizeToFitItems;

@end

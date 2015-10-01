//
//  JAPDVRelatedItem.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAPDVSingleRelatedItem.h"

@interface JAPDVRelatedItem : UIView

@property (nonatomic) NSString *headerText;

- (void)addRelatedItemView:(JAPDVSingleRelatedItem *)itemView;

@end

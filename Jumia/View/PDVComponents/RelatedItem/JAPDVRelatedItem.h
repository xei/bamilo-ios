//
//  JAPDVRelatedItem.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPDVRelatedItem : UIView

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *relatedItemsScrollView;

+ (JAPDVRelatedItem *)getNewPDVRelatedItemSection;

- (void)setupWithFrame:(CGRect)frame;

@end

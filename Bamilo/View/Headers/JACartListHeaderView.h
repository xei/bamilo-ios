//
//  JACartListHeaderView.h
//  Jumia
//
//  Created by Pedro Lopes on 28/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JACartListHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UILabel *title;

- (void) loadHeaderWithText:(NSString*)text width:(CGFloat)width;

@end

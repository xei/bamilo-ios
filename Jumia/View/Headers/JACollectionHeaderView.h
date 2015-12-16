//
//  JACollectionHeaderView.h
//  Jumia
//
//  Created by miguelseabra on 10/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JACollectionHeaderView : UICollectionReusableView

@property (strong, nonatomic) UILabel *title;

- (void) loadHeaderWithText:(NSString*)text width:(CGFloat)width height:(CGFloat)height;

@end

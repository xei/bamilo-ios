//
//  BaseCollectionViewCell.h
//  Bamilo
//
//  Created by Ali saiedifar on 4/10/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCollectionViewCell : UICollectionViewCell

+ (NSString *)nibName;

// -- Abstract function --
- (void)updateWithModel:(id)model;

@end

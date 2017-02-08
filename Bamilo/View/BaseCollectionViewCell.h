//
//  BaseCollectionViewCell.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCollectionViewCell : UICollectionViewCell

+(CGFloat) cellHeight;
+(NSString *) nibName;

-(void) updateWithModel:(id)model;

@end

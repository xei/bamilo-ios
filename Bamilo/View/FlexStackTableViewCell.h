//
//  FlexStackTableViewCell.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface FlexStackTableViewCell : BaseTableViewCell

@property (assign, nonatomic) BOOL hasBoldSeparator;

-(void) setUpperViewTo:(UIView *)upperView;
-(void) setLowerViewTo:(UIView *)lowerView;

@end

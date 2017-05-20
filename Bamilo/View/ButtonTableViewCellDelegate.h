//
//  ButtonTableViewCellDelegate.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ButtonTableViewCell.h"

@protocol ButtonTableViewCellDelegate <NSObject>
- (void)buttonTapped:(id) cell;
@end

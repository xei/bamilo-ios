//
//  ProgressItemView.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressItemViewModel.h"

@interface ProgressItemView : UIView

-(void) updateWithModel:(ProgressItemViewModel *)item;

@end

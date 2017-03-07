//
//  ProgressViewControl.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewControl.h"
#import "ProgressItemViewModel.h"

@interface ProgressViewControl : BaseViewControl

-(void) updateWithModel:(NSArray<ProgressItemViewModel *> *)items;

@end

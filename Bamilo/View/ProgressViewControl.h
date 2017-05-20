//
//  ProgressViewControl.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewControl.h"
#import "ProgressItemViewModel.h"
#import "ProgressViewDelegate.h"

@interface ProgressViewControl : BaseViewControl

@property (weak, nonatomic) id<ProgressViewDelegate> delegate;

-(void) updateWithModel:(NSArray<ProgressItemViewModel *> *)items;

@end

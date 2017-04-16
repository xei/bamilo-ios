//
//  ProgressView.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressItemView.h"
#import "BaseControlView.h"

@interface ProgressView : BaseControlView

@property (weak, nonatomic) id<ProgressViewDelegate> delegate;

-(void) updateWithModel:(NSArray<ProgressItemViewModel *> *)items;

@end

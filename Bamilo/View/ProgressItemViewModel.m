//
//  ProgressItemViewModel.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ProgressItemViewModel.h"

@implementation ProgressItemImageSet

+(instancetype) setWith:(NSString *)pending active:(NSString *)active done:(NSString *)done {
    ProgressItemImageSet *progressItemImageSet = [ProgressItemImageSet new];
    progressItemImageSet.pending = pending;
    progressItemImageSet.active = active;
    progressItemImageSet.done = done;
    
    return progressItemImageSet;
}

@end

@implementation ProgressItemViewModel

+(instancetype) itemWithIcons:(ProgressItemImageSet *)icons title:(NSString *)title type:(ProgressItemType)type {
    ProgressItemViewModel *progressItemViewModel = [ProgressItemViewModel new];
    progressItemViewModel.icons = icons;
    progressItemViewModel.title = title;
    progressItemViewModel.type = type;
    
    return progressItemViewModel;
}

@end

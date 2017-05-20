//
//  ProgressItemViewModel.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ProgressItemViewModel.h"

@implementation ProgressItemImageSet

+(instancetype) setWith:(NSString *)pending active:(NSString *)active done:(NSString *)done error:(NSString *)error {
    ProgressItemImageSet *progressItemImageSet = [ProgressItemImageSet new];
    progressItemImageSet.pending = pending;
    progressItemImageSet.active = active;
    progressItemImageSet.done = done;
    progressItemImageSet.error = error;
    
    return progressItemImageSet;
}

@end

@implementation ProgressItemViewModel

+(instancetype) itemWithIcons:(ProgressItemImageSet *)icons title:(NSString *)title errorTitle:(NSString *)errorTitle isIndicator:(BOOL)isIndicator {
    ProgressItemViewModel *progressItemViewModel = [ProgressItemViewModel new];
    progressItemViewModel.icons = icons;
    progressItemViewModel.title = title;
    progressItemViewModel.errorTitle = errorTitle;
    progressItemViewModel.isIndicator = isIndicator;
    
    return progressItemViewModel;
}

@end

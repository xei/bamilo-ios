//
//  ProgressItemViewModel.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProgressItemImageSet : NSObject
@property (copy, nonatomic) NSString *pending;
@property (copy, nonatomic) NSString *active;
@property (copy, nonatomic) NSString *done;

+(instancetype) setWith:(NSString *)pending active:(NSString *)active done:(NSString *)done;
@end


typedef NS_ENUM(NSUInteger, ProgressItemType) {
    PROGRESS_ITEM_PENDING = 0,
    PROGRESS_ITEM_ACTIVE,
    PROGRESS_ITEM_DONE
};

@interface ProgressItemViewModel : NSObject

@property (strong, nonatomic) ProgressItemImageSet *icons;
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) ProgressItemType type;

+(instancetype) itemWithIcons:(ProgressItemImageSet *)icons title:(NSString *)title type:(ProgressItemType)type;

@end

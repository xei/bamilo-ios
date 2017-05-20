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
@property (copy, nonatomic) NSString *error;

+(instancetype) setWith:(NSString *)pending active:(NSString *)active done:(NSString *)done error:(NSString *)error;
@end


typedef NS_ENUM(NSUInteger, ProgressItemType) {
    PROGRESS_ITEM_PENDING = 0,
    PROGRESS_ITEM_ACTIVE,
    PROGRESS_ITEM_DONE,
    PROGRESS_ITEM_ERROR
};

@interface ProgressItemViewModel : NSObject

@property (strong, nonatomic) ProgressItemImageSet *icons;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *errorTitle;
@property (assign, nonatomic) ProgressItemType type;
@property (assign, nonatomic) BOOL isIndicator;

+(instancetype) itemWithIcons:(ProgressItemImageSet *)icons title:(NSString *)title errorTitle:(NSString *)errorTitle isIndicator:(BOOL)isIndicator;

@end

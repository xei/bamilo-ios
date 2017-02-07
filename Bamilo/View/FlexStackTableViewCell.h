//
//  FlexStackTableViewCell.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewCell.h"

typedef NS_OPTIONS(NSUInteger, FlexStackViewOptions) {
    NONE = 1 << 0,
    BOLD_SEPARATOR = 1 << 1,
    SHADOW = 1 << 2,
};

typedef NS_ENUM(NSUInteger, FlexStackViews) {
    UPPER_VIEW,
    LOWER_VIEW
};

@interface FlexStackTableViewCell : BaseTableViewCell

@property (assign, nonatomic) FlexStackViewOptions options;

-(void) setUpperViewTo:(UIView *)upperView;
-(void) setLowerViewTo:(UIView *)lowerView;
-(void) update:(FlexStackViews)view set:(BOOL)visible animated:(BOOL)animated;

@end

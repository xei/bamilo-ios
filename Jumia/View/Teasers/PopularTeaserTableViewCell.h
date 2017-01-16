//
//  PopularTeaserTableViewCell.h
//  Jumia
//
//  Created by aliunco on 1/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopularTeaserTableViewCell : UITableViewCell
    @property (strong, nonatomic) NSString* titleString;
    @property (strong, nonatomic) NSString* imageUrl;

    + (NSString *) nibName;
@end

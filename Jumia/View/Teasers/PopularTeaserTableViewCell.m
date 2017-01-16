//
//  PopularTeaserTableViewCell.m
//  Jumia
//
//  Created by aliunco on 1/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PopularTeaserTableViewCell.h"

@interface PopularTeaserTableViewCell ()
    @property (weak, nonatomic) IBOutlet UILabel *titleUILabel;
    @property (weak, nonatomic) IBOutlet UIImageView *imageUIImage;
@end


@implementation PopularTeaserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setImageUrl:(NSString *)imageUrl {
    //This must be implemented diffrently if the url is real (not image name)
    self.imageUIImage.image = [UIImage imageNamed: imageUrl];
}

- (void)setTitleString:(NSString *)titleString {
    self.titleUILabel.text = titleString;
}


- (void)prepareForReuse {
    self.imageUIImage.image = nil;
    self.titleUILabel.text  = nil;
}

+ (NSString *)nibNAme {
    return @"PopularTeaserTableViewCell";
}
@end

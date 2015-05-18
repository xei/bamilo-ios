//
//  JACatalogBannerCell.h
//  Jumia
//
//  Created by epacheco on 15/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@interface JACatalogBannerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet JAClickableView *bannerClickableView;


- (void)loadWithImageView:(UIImageView*)imageView;

@end

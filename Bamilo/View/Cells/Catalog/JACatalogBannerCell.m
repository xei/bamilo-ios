//
//  JACatalogBannerCell.m
//  Jumia
//
//  Created by epacheco on 15/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogBannerCell.h"


@interface JACatalogBannerCell()

@property (nonatomic, strong)UIImageView* imageView;


@end

@implementation JACatalogBannerCell

-(void)loadWithImageView:(UIImageView *)imageView
{
    [self.imageView removeFromSuperview];
    self.imageView = imageView;
    [self setFrame:CGRectMake(0.0f, 0.0f, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    [self addSubview:self.imageView];

}

@end

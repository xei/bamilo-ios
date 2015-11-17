//
//  JAPDVImageSection.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@class RIProduct;

@protocol JAPDVImageSectionDelegate <NSObject>

- (void)imageClickedAtIndex:(NSInteger)index;

@end

@interface JAPDVImageSection : UIView <UIScrollViewDelegate>

@property (nonatomic) UIButton *wishListButton;
@property (nonatomic) UIView *separatorImageView;
@property (nonatomic) UILabel *productNameLabel;
@property (nonatomic) UILabel *productDescriptionLabel;

@property (nonatomic, assign) id<JAPDVImageSectionDelegate> delegate;

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize;
- (void)goToGalleryIndex:(NSInteger)index;
- (void)addGlobalButtonTarget:(id)target action:(SEL)action;

@end

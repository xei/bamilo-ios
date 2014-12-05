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

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *wishListButton;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *separatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet JAClickableView *sizeClickableView;
@property (weak, nonatomic) IBOutlet UIView *sizeImageViewSeparator;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorImageViewYConstrain;

@property (nonatomic, assign) id<JAPDVImageSectionDelegate> delegate;

+ (JAPDVImageSection *)getNewPDVImageSection;

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize;

@end

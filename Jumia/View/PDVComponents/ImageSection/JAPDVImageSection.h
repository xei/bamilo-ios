//
//  JAPDVImageSection.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@protocol JAPDVImageSectionDelegate <NSObject>

- (void)imageClickedAtIndex:(NSInteger)index;

@end

@interface JAPDVImageSection : UIView

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *wishListButton;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *separatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;

@property (nonatomic, assign) id<JAPDVImageSectionDelegate> delegate;

+ (JAPDVImageSection *)getNewPDVImageSection;

- (void)setupWithFrame:(CGRect)frame;

- (void)loadWithImages:(NSArray*)imagesArray;

@end

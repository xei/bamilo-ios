//
//  JAAccountServicesView.m
//  Jumia
//
//  Created by Jose Mota on 05/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAAccountServicesView.h"
#import "UIImageView+WebCache.h"

#define kAccountServicesLineHeight 18.f
#define kPadding 12

@interface JAAccountServicesView ()
{
    NSLock *_lock;
}

@property (nonatomic, strong) NSMutableArray *contentViewsArray;
@property (nonatomic, strong) NSMutableArray *imageViewArray;

@end

@implementation JAAccountServicesView

- (UIView *)getNewContentView
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, kAccountServicesLineHeight)];
    [self addSubview:contentView];
    return contentView;
}

- (void)setAccountServicesArray:(NSArray *)accountServicesArray
{
    _accountServicesArray = accountServicesArray;
    self.contentViewsArray = [NSMutableArray new];
    self.imageViewArray = [NSMutableArray new];
    __weak JAAccountServicesView *weakSelf = self;
    int i = 0;
    CGFloat xOffset = 0;
    for (NSString *imageURL in accountServicesArray) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*kPadding + xOffset, 0, 20, kAccountServicesLineHeight)];
        [weakSelf.imageViewArray addObject:imageView];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [weakSelf regroupImages];
        }];
    }
}

- (void)regroupImages
{
    if (!VALID_NOTEMPTY(_lock, NSLock)) {
        _lock = [NSLock new];
    }
    [_lock lock];
    int i = 0;
    int l = 0;
    CGFloat xOffset = 0;
    for (UIImageView *imageView in self.imageViewArray) {
        if (VALID_NOTEMPTY(imageView.image, UIImage)) {
            [imageView setX:i*kPadding + xOffset];
            CGSize newSize = CGSizeMake(imageView.image.size.width*kAccountServicesLineHeight/imageView.image.size.height, kAccountServicesLineHeight);
            [imageView setWidth:newSize.width];
            if (CGRectGetMaxX(imageView.frame) > self.width) {
                xOffset = 0.f;
                [imageView setX:xOffset];
                i = 0;
                l++;
                CGFloat height = (l+1)*kAccountServicesLineHeight + l*3.f;
                [self setHeight:height];
                if (self.delegate) {
                    [self.delegate accountServicesViewChange];
                }
            }
            xOffset += newSize.width;
            if (!VALID_NOTEMPTY(imageView.superview, UIView)) {
                if (self.contentViewsArray.count < l+1) {
                    [self.contentViewsArray addObject:[self getNewContentView]];
                    CGFloat yOffset = l*(kAccountServicesLineHeight+3.f);
                    [(UIView *)[self.contentViewsArray lastObject] setY:yOffset];
                }
                [(UIView *)[self.contentViewsArray lastObject] addSubview:imageView];
            }
            i++;
        }
    }
    [self alignContentViews];
    [_lock unlock];
}

- (void)alignContentViews
{
    for (UIView *contentView in self.contentViewsArray) {
        [contentView setWidth:CGRectGetMaxX([contentView.subviews lastObject].frame)];
        [contentView setXCenterAligned];
    }
}

- (void)layoutSubviews
{
    [self alignContentViews];
    [super layoutSubviews];
}

@end

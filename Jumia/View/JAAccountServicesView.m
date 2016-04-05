//
//  JAAccountServicesView.m
//  Jumia
//
//  Created by Jose Mota on 05/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAAccountServicesView.h"
#import "UIImageView+WebCache.h"

#define kPadding 12

@interface JAAccountServicesView ()
{
    NSLock *_lock;
}

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSMutableArray *imageViewArray;

@end

@implementation JAAccountServicesView

- (UIView *)contentView
{
    if (!VALID_NOTEMPTY(_contentView, UIView)) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (void)setAccountServicesArray:(NSArray *)accountServicesArray
{
    _accountServicesArray = accountServicesArray;
    self.imageViewArray = [NSMutableArray new];
    __weak JAAccountServicesView *weakSelf = self;
    int i = 0;
    CGFloat xOffset = 0;
    for (NSString *imageURL in accountServicesArray) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*kPadding + xOffset, 0, 20, self.height)];
        [weakSelf.imageViewArray addObject:imageView];
        [imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil success:^(UIImage *image, BOOL cached) {
            [weakSelf regroupImages];
        } failure:nil];
    }
}

- (void)regroupImages
{
    if (!VALID_NOTEMPTY(_lock, NSLock)) {
        _lock = [NSLock new];
    }
    [_lock lock];
    int i = 0;
    CGFloat xOffset = 0;
    for (UIImageView *imageView in self.imageViewArray) {
        if (VALID_NOTEMPTY(imageView.image, UIImage)) {
            [imageView setX:i*kPadding + xOffset];
            CGSize newSize = CGSizeMake(imageView.image.size.width*self.height/imageView.image.size.height, self.height);
            [imageView setWidth:newSize.width];
            xOffset += newSize.width;
            if (!VALID_NOTEMPTY(imageView.superview, UIView)) {
                [self.contentView addSubview:imageView];
            }
            i++;
        }
    }
    [self.contentView setWidth:(i-1)*kPadding + xOffset];
    [self.contentView setXCenterAligned];
    [_lock unlock];
}

- (void)layoutSubviews
{
    [self.contentView setXCenterAligned];
    [super layoutSubviews];
}

@end
